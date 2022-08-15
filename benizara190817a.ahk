;-----------------------------------------------------------------------
;	名称：benizara / 紅皿
;	機能：Yet another NICOLA Emulaton Software
;         キーボード配列エミュレーションソフト
;	ver.0.1.5.00 .... 2022/7/31
;	作者：Ken'ichiro Ayaki
;-----------------------------------------------------------------------
	#InstallKeybdHook
	#MaxhotkeysPerInterval 400
	#KeyHistory
#SingleInstance, Off
	SetStoreCapsLockMode,Off
	StringCaseSense, On			; 大文字小文字を区別
	g_Ver := "ver.0.1.5.00"
	g_Date := "2022/7/31"
	MutexName := "benizara"
    If DllCall("OpenMutex", Int, 0x100000, Int, 0, Str, MutexName)
    {
		Traytip,キーボード配列エミュレーションソフト「紅皿」,多重起動は禁止されています。
        ExitApp
	}
    hMutex := DllCall("CreateMutex", Int, 0, Int, False, Str, MutexName)
	SetWorkingDir, %A_ScriptDir%

	idxLogs := 0
	g_Log := Object()
	aLogCnt := 0
	loop, 64
	{
		g_Log[A_Index-1] := ""
	}
	full_command_line := DllCall("GetCommandLine", "str") 
	if(RegExMatch(full_command_line, " /create(?!\S)")) 
	{
		thisCmd = schtasks.exe /create /tn benizara /tr `"%A_ScriptFullPath%`" /sc onlogon /rl highest /F
		DllCall("ReleaseMutex", Ptr, hMutex)
		Run *Runas %thisCmd%
		ExitApp 
	}
	if(RegExMatch(full_command_line, " /delete(?!\S)")) 
	{
		thisCmd := "schtasks.exe /delete /tn \benizara /F"
		DllCall("ReleaseMutex", Ptr, hMutex)
		Run *Runas %thisCmd%
		ExitApp
	}
	if(RegExMatch(full_command_line, " /admin(?!\S)")) 
	{
		DllCall("ReleaseMutex", Ptr, hMutex)
		Run *Runas %A_ScriptFullPath%
		ExitApp
	}
	g_DataDir := A_AppData . "\ayaki\benizara"
	if (Path_FileExists(g_DataDir . "\NICOLA配列.bnz") == 0)
	{
		g_DataDir := A_ScriptDir
	}
	g_Romaji := "A"
	g_Oya    := "N"
	g_Koyubi := "N"
	g_Modifier := 0
	g_LayoutFile := ".\NICOLA配列.bnz"
	g_Continue := 1
	g_Threshold := 100	; 
	RegRead,_keyboardDelayIdx,HKEY_CURRENT_USER\Control Panel\Keyboard,KeyboardDelay
	g_MaxTimeout := ( 0 = _keyboardDelayIdx) ? 250
				  : ( 1 = _keyboardDelayIdx) ? 500
				  : ( 2 = _keyboardDelayIdx) ? 750
				  : ( 3 = _keyboardDelayIdx) ? 1000
				  : 1000
	if(g_MaxTimeout == 0) {
		g_MaxTimeout := 500
	}
	g_MaxTimeoutM := 500
	g_ThresholdSS := 250	; 
	g_OverlapMO := 35
	g_OverlapOM := 70
	g_OverlapOMO := 50
	g_OverlapSS := 35
	g_ZeroDelay := 1		; 零遅延モード
	g_ZeroDelayOut := ""
	g_ZeroDelaySurface := ""	; 零遅延モードで出力される表層文字列
	g_Offset := 20
	g_trigger := ""
	
	INFINITE := +2147483648

	g_OyaTick   := Object()
	g_OyaUpTick := Object()
	g_Interval  := Object()
	g_LastKey   := Object()		; 最後に入力したキーを濁音や半濁音に置き換える
	g_LastKey["表層"] := ""

	g_metaKeyUp := Object()		; 親指キーを離す
	g_metaKeyUp["R"] := "r"
	g_metaKeyUp["L"] := "l"
	g_metaKeyUp["M"] := "m"
	g_metaKeyUp["S"] := "s"
	g_metaKeyUp["X"] := "x"
	g_metaKeyUp["0"] := "_0"
	g_metaKeyUp["1"] := "_1"
	g_metaKeyUp["2"] := "_2"
	g_metaKeyUp["3"] := "_3"
	g_metaKeyUp["4"] := "_4"
	g_metaKeyUp["5"] := "_5"
	g_metaKeyUp["6"] := "_6"
	g_metaKeyUp["7"] := "_7"
	g_metaKeyUp["8"] := "_8"
	g_metaKeyUp["9"] := "_9"
	g_metaKeyUp["A"] := "a"
	g_metaKeyUp["B"] := "b"
	g_metaKeyUp["C"] := "c"
	g_metaKeyUp["D"] := "d"

	Gosub,InitKeyQueue
	keyTick := Object()
	g_KeyOnHold := ""
	g_RepeatCount := 0
	
	g_sansTick := INFINITE
	g_sans := "N"
	g_sansPos := ""
	
	g_debugout := ""
	
	g_Pause := 0
	g_KeyPause := "Pause"
	vLayoutFile := g_LayoutFile
	g_Tau := 400
	GoSub,Init
	Gosub,ReadLayout
	Traytip,キーボード配列エミュレーションソフト「紅皿」,benizara %g_Ver% `n%g_layoutName%　%g_layoutVersion%
	g_allTheLayout := vAllTheLayout
	g_LayoutFile := vLayoutFile
	kup_save := Object()

	g_SendTick := INFINITE
	if(A_IsCompiled == 1)
	{
		Menu, Tray, NoStandard
	}
	Menu, Tray, Add, 紅皿設定,Settings
	Menu, Tray, Add, ログ,Logs
	Menu, Tray, Add, 一時停止,DoPause
	Menu, Tray, Add, 再開,DoResume
	Menu, Tray, Add, 終了,MenuExit
	Gosub,DoResume

	SetBatchLines, -1
	SetHotkeyInit()
	fPf := Pf_Init()
	_currentTick := Pf_Count()
	g_OyaTick["R"] := _currentTick
	g_OyaTick["L"] := _currentTick
	g_OyaTick["A"] := _currentTick
	g_OyaTick["B"] := _currentTick
	g_OyaTick["C"] := _currentTick
	g_OyaTick["D"] := _currentTick
	VarSetCapacity(lpKeyState,256,0)

	g_process := Object()	; 反対側の親指キー
	g_process["yamabuki_r"] := 0
	g_process["yamabuki"] := 0
	g_process["DvorakJ"] := 0
	g_process["em1keypc"] := 0
	g_process["姫踊子草2"] := 0
	g_intproc := 0
	SetTimer,Interrupt10,10
	SetTimer,InterruptProcessPolling,600
	Suspend,on
	SetHotkey("off")
	SetHotkeyFunction("off")
	g_HotKey := "off"
	return

;-----------------------------------------------------------------------
;	メニューからの終了
;-----------------------------------------------------------------------
MenuExit:
	SetTimer,Interrupt10,off
	SetTimer,InterruptProcessPolling,off
	DllCall("ReleaseMutex", Ptr, hMutex)
	Suspend,on
	SetHotkey("off")
	SetHotkeyFunction("off")
	exitapp

;-----------------------------------------------------------------------
;	一時停止(Pause)
;-----------------------------------------------------------------------
DoPause:
	Menu, Tray,disable,一時停止
	Menu, Tray,enable,再開
	g_Pause := 1
	if(Path_FileExists(A_ScriptDir . "\benizara_off.ico")==1)
	{
		Menu, Tray, Icon, %A_ScriptDir%\benizara_off.ico , ,1
	}
	return

;-----------------------------------------------------------------------
;	再開（一時停止の解除）
;-----------------------------------------------------------------------
DoResume:
	Menu, Tray,enable,一時停止
	Menu, Tray,disable,再開
	g_Pause := 0
	if(Path_FileExists(A_ScriptDir . "\benizara_on.ico")==1)
	{
		Menu, Tray, Icon, %A_ScriptDir%\benizara_on.ico , ,1
	}
	return	


#include IME.ahk
#include ReadLayout6.ahk
#include Settings7.ahk
#include PfCount.ahk
#include Logs1.ahk
#include Path.ahk
#include Objects.ahk
#include KeyQueue.ahk
#include SendOnHold.ahk
#include keyHook.ahk

;-----------------------------------------------------------------------
; 親指シフトキー
; スペースキーに割り当てられていれば連続打鍵
;-----------------------------------------------------------------------

keydownR:	; 無変換
keydownL:	; 変換 
keydownA:	; 拡張1 A13
keydownB:	; 拡張2 A14
keydownC:	; 拡張3 A15
keydownD:	; 拡張4 A16
	g_trigger := g_metaKey
	g_OyaTick[g_metaKey] := Pf_Count()
	RegLogs(g_metaKey . " down", g_KeyInPtn, g_trigger, g_Timeout, "")
	g_Timeout := ""
	if(keyState[g_layoutPos] != 0)
	{
		if(g_KeyRepeat == 1 || g_layoutPos == "A02")
		{
			g_KeyRepeating := true
		} else {
			g_KeyRepeating := true
			critical,off
			return
		}
	} else {
		g_KeyRepeating := false
	}
	g_Oya := g_metaKey
	keyState[g_layoutPos] := 2
	keyTick[g_layoutPos] := g_OyaTick[g_metaKey]

	if(g_KeyInPtn == "MM" || g_KeyInPtn == "MMm")	; S7)MMオン状態、S8)MMオンmオフ状態
	{
		_mode := g_RomajiOnHold[1] . g_OyaOnHold[1] . g_KoyubiOnHold[1]
		if(kdn[_mode . g_MojiOnHold[2] . g_MojiOnHold[1]] == "") {
			g_KeyInPtn := SendOnHoldM()	; 保留した２文字前だけを打鍵してMオン状態に遷移
			SubSendUp(g_MojiOnHold[1])
			g_Timeout := SetTimeout(g_KeyInPtn)
			g_SendTick := calcSendTick(g_OyaTick[g_metaKey], g_Timeout)
		} else {
			; 3キー判定 M1-M2と、M2-M3
			g_Interval["M" . g_metaKey] := g_OyaTick[g_metaKey] - g_TDownOnHold[2]
			g_Interval["S12"]  := g_TDownOnHold[2] - g_TDownOnHold[1]	; 前回の文字キー押しからの期間
			if(g_Interval["S12"] < g_Interval["M" . g_metaKey]) {
				g_KeyInPtn := SendOnHoldMM()
				if(g_KeyInPtn == "M") {
					SubSendUp(g_MojiOnHold[1])
					g_Timeout := SetTimeout(g_KeyInPtn)
					g_SendTick := calcSendTick(g_OyaTick[g_metaKey],g_Timeout)
				}
			} else {
				g_KeyInPtn := SendOnHoldM()	; 保留した２文字前だけを打鍵してMオン状態に遷移
				SubSendUp(g_MojiOnHold[1])
				g_Timeout := SetTimeout(g_KeyInPtn)
				g_SendTick := calcSendTick(g_OyaTick[g_metaKey], g_Timeout)
			}
		}
	}
	else if(g_KeyInPtn == "MMM")	; S9)M1M2M3オン状態
	{
		g_KeyInPtn := SendOnHoldMMM()
	}
	if(g_KeyInPtn == "") 			;S1)初期状態
	{
		g_KeyInPtn := enqueueKey(g_Romaji, g_metaKey, KoyubiOrSans(g_Koyubi,g_sans), g_layoutPos, g_metaKey, g_OyaTick[g_metaKey])
			;S3)Oオンに遷移
		g_Timeout := SetTimeout(g_KeyInPtn)
		g_SendTick := calcSendTick(g_OyaTick[g_metaKey], g_Timeout)
	}
	else if(g_KeyInPtn == "M")			;S2)Mオン状態
	{
		g_Interval["M" . g_metaKey] := g_OyaTick[g_metaKey] - g_TDownOnHold[g_OnHoldIdx]
		if(g_Interval["M" . g_metaKey] > minimum(floor((g_Threshold*(100-g_OverlapMO))/g_OverlapMO),g_MaxTimeout)) {
			g_KeyInPtn := SendOnHoldM()	; タイムアウト・保留キーの打鍵
			g_KeyInPtn := enqueueKey(g_Romaji, g_metaKey, KoyubiOrSans(g_Koyubi,g_sans), g_layoutPos, g_metaKey, g_OyaTick[g_metaKey])
				;S3)Oオンに遷移
			g_Timeout := SetTimeout(g_KeyInPtn)
			g_SendTick := calcSendTick(g_OyaTick[g_metaKey], g_Timeout)
		} else {
			g_KeyInPtn := enqueueKey(g_Romaji, g_metaKey, KoyubiOrSans(g_Koyubi,g_sans), g_layoutPos, g_metaKey, g_OyaTick[g_metaKey])
				;S4)M-Oオンに遷移
			g_Interval["M" . g_metaKey] := g_OyaTick[g_metaKey] - g_TDownOnHold[g_OnHoldIdx - 1]
			g_Timeout := minimum(floor(g_Interval["M" . g_metaKey]*g_OverlapMO/(100-g_OverlapMO)),g_MaxTimeout)
			g_SendTick := g_OyaTick[g_metaKey] + minimum(floor(g_Interval["M" . g_metaKey]*g_OverlapMO/(100-g_OverlapMO)),g_MaxTimeout)
		}
	}
	else if(RegExMatch(g_KeyInPtn, "^[RLABCD]$")==1)	;S3)Oオン状態
	{
		g_KeyInPtn := SendOnHoldO()	; 他の親指キー（保留キー）の打鍵
		g_KeyInPtn := enqueueKey(g_Romaji, g_metaKey, KoyubiOrSans(g_Koyubi,g_sans), g_layoutPos, g_metaKey, g_OyaTick[g_metaKey])
			;S3)Oオンに遷移
		g_Timeout := SetTimeout(g_KeyInPtn)
		g_SendTick := calcSendTick(g_OyaTick[g_metaKey], g_Timeout)
	}
	else if(RegExMatch(g_KeyInPtn, "^M[RLABCD]$")==1)	;S4)M-Oオン状態
	{
		g_KeyInPtn := SendOnHoldMO()			;保留キーの打鍵
		g_KeyInPtn := enqueueKey(g_Romaji, g_metaKey, KoyubiOrSans(g_Koyubi,g_sans), g_layoutPos, g_metaKey, g_OyaTick[g_metaKey])
			;S3)Oオンに遷移
		g_Timeout := SetTimeout(g_KeyInPtn)
		g_SendTick := calcSendTick(g_OyaTick[g_metaKey], g_Timeout)
	}
	else if(RegExMatch(g_KeyInPtn, "^[RLABCD]M$")==1)	;S5)O-Mオン状態
	{
		wOya := substr(g_KeyInPtn,1,1)
		; 処理B 3キー判定　O-M-O
		g_Interval[wOya . "M"] := g_TDownOnHold[g_OnHoldIdx] - g_OyaTick[wOya]	; 他の親指キー押しから文字キー押しまでの期間
		g_Interval["M" . g_metaKey] := g_OyaTick[g_metaKey] - g_TDownOnHold[g_OnHoldIdx]	; 文字キー押しから当該親指キー押しまでの期間
		if(g_Interval["M" . g_metaKey] > g_Interval[wOya . "M"] && g_OnHoldIdx == 2)
		{
			g_KeyInPtn := SendOnHoldOM()	; 保留キーの打鍵　L,Rモードに遷移
			g_KeyInPtn := enqueueKey(g_Romaji, g_metaKey, KoyubiOrSans(g_Koyubi,g_sans), g_layoutPos, g_metaKey, g_OyaTick[g_metaKey])
				; S3)Oオンに遷移
			g_Timeout := SetTimeout(g_KeyInPtn)
			g_SendTick := calcSendTick(g_OyaTick[g_metaKey], g_Timeout)
		}
		else
		{
			if(g_ZeroDelayOut!="")
			{
				CancelZeroDelayOut(g_ZeroDelay)
			}
			g_KeyInPtn := SendOnHoldO()	; 保留キーの打鍵, Mモードに遷移
			g_KeyInPtn := enqueueKey(g_Romaji, g_metaKey, KoyubiOrSans(g_Koyubi,g_sans), g_layoutPos, g_metaKey, g_OyaTick[g_metaKey])
				; S4)M-Oオンに遷移
			g_Interval["M" . g_metaKey] := g_OyaTick[g_metaKey] - g_TDownOnHold[1]
			g_Timeout := minimum(floor(g_Interval["M" . g_metaKey]*g_OverlapMO/(100-g_OverlapMO)),g_MaxTimeout)
			g_SendTick := g_OyaTick[g_metaKey] + minimum(floor(g_Interval["M" . g_metaKey]*g_OverlapMO/(100-g_OverlapMO)),g_MaxTimeout)
			SendZeroDelay(g_RomajiOnHold[2] . g_OyaOnHold[2] . g_KoyubiOnHold[2], g_MojiOnHold[1], g_ZeroDelay)
		}
	}
	else if(RegExMatch(g_KeyInPtn, "^(RMr|LMl|AMa|BMb|CMc|DMd)$")==1)	;S6)O-M-Oオフ状態
	{
		g_KeyInPtn := SendOnHoldO()	; 保留親指キーの単独打鍵
		g_Interval["M" . g_metaKey] := g_OyaTick[g_metaKey] - g_TDownOnHold[g_OnHoldIdx]
		if(g_Interval["M" . g_metaKey] > minimum(floor((g_Threshold*(100-g_OverlapOMO))/g_OverlapOMO),g_MaxTimeout)) {
			g_KeyInPtn := SendOnHoldM()	; タイムアウト・保留キーの打鍵
			g_KeyInPtn := enqueueKey(g_Romaji, g_metaKey, KoyubiOrSans(g_Koyubi,g_sans), g_layoutPos, g_metaKey, g_OyaTick[g_metaKey])
				;S3)Oオンに遷移
			g_Timeout := SetTimeout(g_KeyInPtn)
			g_SendTick := calcSendTick(g_OyaTick[g_metaKey], g_Timeout)
		} else {
			g_KeyInPtn := enqueueKey(g_Romaji, g_metaKey, KoyubiOrSans(g_Koyubi,g_sans), g_layoutPos, g_metaKey, g_OyaTick[g_metaKey])
				;S4)M-Oオンに遷移
			g_Interval["M" . g_metaKey] := g_OyaTick[g_metaKey] - g_TDownOnHold[g_OnHoldIdx - 1]
			g_Timeout := minimum(floor(g_Interval["M" . g_metaKey]*g_OverlapMO/(100-g_OverlapMO)),g_MaxTimeout)
			g_SendTick := g_OyaTick[g_metaKey] + minimum(floor(g_Interval["M" . g_metaKey]*g_OverlapMO/(100-g_OverlapMO)),g_MaxTimeout)
		}
	}
	critical,off
	return  

;-----------------------------------------------------------------------
; 親指シフトキーのオフ
;-----------------------------------------------------------------------
keyupR:	; 無変換
keyupL:	; 変換
keyupA:	; 拡張1 A13
keyupB:	; 拡張2 A14
keyupC:	; 拡張3 A15
keyupD:	; 拡張4 A16
	g_trigger := g_metaKeyUp[g_metaKey]
	g_OyaUpTick[g_metaKey] := Pf_Count()
	setKeyup(g_layoutPos,g_OyaUpTick[g_metaKey])

	if(keyState[g_layoutPos] != 0)
	{
		RegLogs(g_metaKey . " up", g_KeyInPtn, g_trigger, g_Timeout, "")
		g_Timeout := ""
		
		if(g_KeyInPtn == g_metaKey)		;S3)Oオン状態
		{
			g_KeyInPtn := SendOnHoldO()	;保留親指キーの打鍵
		}
		else if(g_KeyInPtn == "M" . g_metaKey)	;S4)M-Oオン状態
		{
			g_Interval["M" . g_metaKey] := g_OyaTick[g_metaKey] - g_TDownOnHold[g_OnHoldIdx]
			g_Interval["M" . "_" . g_metaKey] := g_OyaUpTick[g_metaKey] - g_TDownOnHold[g_OnHoldIdx]
			if(g_Interval["M" . "_" . g_metaKey] > 0) {
				vOverlap := floor((g_Interval[g_metaKey . "_" . g_metaKey]*100)/g_Interval["M" . "_" . g_metaKey])
			} else {
				vOverlap := 0
			}
			if(vOverlap >= g_OverlapMO) {
				g_KeyInPtn := SendOnHoldMO()	; 保留キーの同時打鍵
			} else {
				g_KeyInPtn := SendOnHoldM()
				g_KeyInPtn := SendOnHoldO()
			}
		}
		else if(g_KeyInPtn == g_metaKey . "M")	;S5)O-Mオン状態
		{
			g_Interval["M_" . g_metaKey] := g_OyaUpTick[g_metaKey] - g_TDownOnHold[g_OnHoldIdx]			; 文字キー押しから親指キー解除までの期間
			g_Interval[g_metaKey . "_" . g_metaKey] := g_OyaUpTick[g_metaKey] - g_OyaTick[g_metaKey]	; 親指キー押しから親指キー解除までの期間
			if(g_Continue == 1 && g_OnHoldIdx == 1) {
				if(g_Interval["M_" . g_metaKey] > g_Threshold)
				{
					; タイムアウト状態または親指シフト１文字目：親指シフト文字の出力
					g_KeyInPtn := SendOnHoldOM()	; 保留キーの打鍵
				} else {
					g_KeyInPtn := enqueueKey(g_Romaji, g_metaKey, KoyubiOrSans(g_Koyubi,g_sans), g_layoutPos, g_metaKeyUp[g_metaKey], g_OyaUpTick[g_metaKey])
						; S6)O-M-Oオフ状態に遷移
					g_Interval["M_" . g_metaKey] := g_OyaUpTick[g_metaKey] - g_TDownOnHold[g_OnHoldIdx]	; 文字キー押しから右親指キー解除までの期間
					g_Timeout := minimum(floor((g_Interval["M_" . g_metaKey]*(100-g_OverlapOMO))/g_OverlapOMO),g_MaxTimeout)
					g_SendTick := g_OyaUpTick[g_metaKey] + minimum(floor((g_Interval["M_" . g_metaKey]*(100-g_OverlapOM))/g_OverlapOM),g_MaxTimeout)
				}
			} else {
				; 処理D
				if(g_Interval[g_metaKey . "_" . g_metaKey]>0) {
					vOverlap := floor((100*g_Interval["M_" . g_metaKey])/g_Interval[g_metaKey . "_" . g_metaKey])
				} else {
					vOverlap := 0
				}
				if(vOverlap < g_OverlapOM && g_Interval["M_" . g_metaKey] <= g_Tau)
				{
					g_KeyInPtn := enqueueKey(g_Romaji, g_metaKey, KoyubiOrSans(g_Koyubi,g_sans), g_layoutPos, g_metaKeyUp[g_metaKey], g_OyaUpTick[g_metaKey])
						; S6)O-M-Oオフ状態に遷移
					g_Interval["M_" . g_metaKey] := g_OyaUpTick[g_metaKey] - g_TDownOnHold[g_OnHoldIdx]	; 文字キー押しから親指キー解除までの期間
					g_Timeout := minimum(floor((g_Interval["M_" . g_metaKey]*(100-g_OverlapOMO))/g_OverlapOMO),g_MaxTimeout)
					g_SendTick := g_OyaUpTick[g_metaKey] + minimum(floor((g_Interval["M_" . g_metaKey]*(100-g_OverlapOM))/g_OverlapOM),g_MaxTimeout)
				} else {
					g_KeyInPtn := SendOnHoldOM()	; 保留キーの打鍵
				}
			}
		}
		;else if(g_KeyInPtn="M" || g_KeyInPtn="RMr" || g_KeyInPtn="LMl") ; S2)Mオン状態 S6)O-M-Oオフ状態
		;{
			; 何もしない
		;}
	}
	SubSendUp(g_layoutPos)
	
	if(g_Oya == g_metaKey) {
		if(g_Continue == 1) {
			; 他の親指キーが押されていなければ N に設定
			g_Oya := "N"
			_oyaOther := "RLABCD"
			loop, Parse, _oyaOther
			{
				if(A_LoopField != g_metaKey) 
				{
					_layout := g_Oya2Layout[A_LoopField]
					if(_layout!="")
					{
						_scanCode := scanCodeHash[_layout]
						if(_scanCode!="")
						{
							_keyState := GetKeyState(_scanCode,"P")
							if(_keyState!=0) {
								g_Oya := A_LoopField
								break
							}
						}
					}
				}
			}
		} else {
			g_Oya := "N"
		}
	}
	critical,off
	sleep,-1
	return
;----------------------------------------------------------------------
; 最小値
;----------------------------------------------------------------------
minimum(_val0, _val1) {
	if(_val0 > _val1)
	{
		return _val1
	}
	else
	{
		return _val0
	}
}
;----------------------------------------------------------------------
; 最大値
;----------------------------------------------------------------------
maximum(_val0, _val1) {
	if(_val0 < _val1)
	{
		return _val1
	}
	else
	{
		return _val0
	}
}

;----------------------------------------------------------------------
; ログ保存
;----------------------------------------------------------------------
RegLogs(_keyEvent, _KeyInPtn, _trigger, _Timeout, _send)
{
	global
	local _tickCount, _tmp, _timeSinceLastLog
	static tickLast
	
	_tickCount := Pf_Count()
	_timeSinceLastLog := _tickCount - tickLast
	_tickCount := Mod(_tickCount,100000)
	_tmp := SubStr("      ",1,6-StrLen(_tickCount)) . _tickCount . "|"
	_timeSinceLastLog := Mod(_timeSinceLastLog,100000)
	_tmp .= SubStr("      ",1,6-StrLen(_timeSinceLastLog)) . _timeSinceLastLog . "|"
	_tmp .= " "
	_tmp .= SubStr(_keyEvent . "                ",1,16) . "|"
	_tmp .= SubStr(g_Oya . " ",1,1) . "|"
	_tmp .= SubStr(_KeyInPtn . "   ",1,3) . "|"
	_tmp .= SubStr(_trigger . "   ",1,3) . "|"
	;_tmp .= SubStr("     ",1,5-StrLen(_Timeout)) . _Timeout . "|"
	if(g_OnHoldIdx == 0) {
		_MojiPos := "   "
	} else if(g_OnHoldIdx == 1) {
		if(g_MetaOnHold[1]=="M") {
			_MojiPos := g_MojiOnHold[1]
		} else {
			_MojiPos := "   "
		}
	} else if(g_OnHoldIdx >= 2) {
		if(g_MetaOnHold[1]=="M") {
			_MojiPos := g_MojiOnHold[1]
		} else if(g_MetaOnHold[2]=="M") {
			_MojiPos := g_MojiOnHold[2]
		} else {
			_MojiPos := "   "
		}
	}
	_tmp .= _MojiPos . "|"
	_sendTick := Mod(g_sendTick,100000)
	_tmp .= SubStr("     ",1,6-StrLen(_sendTick)) . _sendTick . "|"
	_tmp .= _send
	g_Log[idxLogs] := _tmp

	idxLogs += 1
	idxLogs &= 63
	if(aLogCnt < 64)
	{
		aLogCnt += 1
	} else {
		aLogCnt := 64
	}
	tickLast := _tickCount
}
;----------------------------------------------------------------------
; 文字キー押下
;----------------------------------------------------------------------
keydownM:
	g_trigger := g_metaKey
	keyTick[g_layoutPos] := Pf_Count()
	RegLogs(kName . " down", g_KeyInPtn, g_trigger, g_Timeout, "")
	g_Timeout := ""
	
	if(keyState[g_layoutPos] != 0)	; 同時打鍵時にはキーリピートしない
	{
		g_KeyOnHold := GetPushedKeys()
		if(strlen(g_KeyOnHold)>=6) {
			critical,off
			return
		}
	}
	keyState[g_layoutPos] := 2
	g_sansTick := INFINITE
	if(keyState[g_sansPos]==2) {
		keyState[g_sansPos] := 1
	}
	if(ShiftMode[g_Romaji] == "プレフィックスシフト") {
		if(g_prefixshift != "" )
		{
			SendKey(g_Romaji . g_prefixshift . KoyubiOrSans(g_Koyubi,g_sans), g_layoutPos)
			g_Timeout := 60000
			g_SendTick := INFINTE
			g_prefixshift := ""
			critical,off
			return
		}
		SendKey(g_Romaji . "N" . KoyubiOrSans(g_Koyubi,g_sans), g_layoutPos)
		g_Timeout := 60000
		g_SendTick := INFINTE
		critical,off
		return
	}
	if(ShiftMode[g_Romaji] == "小指シフト") {
		SendKey(g_Romaji . "N" . KoyubiOrSans(g_Koyubi,g_sans), g_layoutPos)
		clearQueue()
		critical,off
		return
	}
	; 親指シフトまたは文字同時打鍵の文字キーダウン
	if(g_KeyInPtn=="M")								;S2)Mオン状態
	{
		; M2キー押下
		if(g_MetaOnHold[1]=="M") {
			_mode := g_RomajiOnHold[1] . g_OyaOnHold[1] . g_KoyubiOnHold[1]
			if(ksc[_mode . g_layoutPos]<=1 
			|| (ksc[_mode . g_layoutPos]==2 && kdn[_mode . g_MojiOnHold[1] . g_layoutPos]=="")
			|| ksc[_mode . g_MojiOnHold[1] . g_layoutPos]==0) {
				; 保留中の１文字を確定（出力）
				g_keyInPtn := SendOnHoldM()
			}
		}
	}
	else
	if(RegExMatch(g_KeyInPtn, "^M[RLABCD]$")==1)	;S4)M-Oオン状態
	{
		; 3キー判定 M-O-M
		wOya := g_OyaOnHold[g_OnHoldIdx]
		g_Interval["M" . wOya] := g_TDownOnHold[g_OnHoldIdx] - g_TDownOnHold[g_OnHoldIdx-1]
		g_Interval[wOya . "M"] := keyTick[g_layoutPos] - g_TDownOnHold[g_OnHoldIdx]
		if(g_Interval["M" . wOya] < g_Interval[wOya . "M"]) {
			g_KeyInPtn := SendOnHoldMO()	; 保留キーの同時打鍵
		} else {
			g_KeyInPtn := SendOnHoldM()
		}
	}
	else
	if(RegExMatch(g_KeyInPtn, "^[RLABCD]M$")==1)	;S5)O-Mオン状態
	{
		_mode := g_RomajiOnHold[1] . g_OyaOnHold[1] . g_KoyubiOnHold[1]
		if(ksc[_mode . g_layoutPos]<=1 
		|| (ksc[_mode . g_layoutPos]==2 && kdn[_mode . g_MojiOnHold[g_OnHoldIdx] . g_layoutPos]=="")
		|| ksc[_mode . g_MojiOnHold[g_OnHoldIdx] . g_layoutPos]==0) {
			; 保留中の１文字を確定（出力）
			g_KeyInPtn := SendOnHoldOM()
		} else
		if(g_OnHoldIdx == 1) {	; 連続モードの２打目以降
			g_KeyInPtn := SendOnHoldOM()	; 保留キーの同時打鍵
		} else {
			; 3キー判定 O-M-O / キーバッファ OM
			wOya := g_OyaOnHold[1]
			g_Interval[wOya . "M"] := g_TDownOnHold[2] - g_TDownOnHold[1]
			g_Interval["S12"] := keyTick[g_layoutPos] - g_TDownOnHold[2]	; 前回の文字キー押しからの期間
			if(g_Interval[wOya . "M"] < g_Interval["S12"]) {
				g_KeyInPtn := SendOnHoldOM()	; 保留キーの同時打鍵
			} else {
				g_KeyInPtn := SendOnHoldO()
			}
		}
	}
	else 
	if(RegExMatch(g_KeyInPtn, "^(RMr|LMl|AMa|BMb|CMc|DMd)$")==1)	;S6)O-M-Oオフ状態
	{
		wOya := g_OyaOnHold[g_OnHoldIdx]
		g_Interval["M_" . wOya] := g_TUpOnHold[g_OnHoldIdx] - g_TDownOnHold[g_OnHoldIdx-1]
		g_Interval["MM"] := keyTick[g_layoutPos] - g_TDownOnHold[g_OnHoldIdx-1]
		if(g_Interval["MM"] > 0) {
			vOverlap := floor((g_Interval["M_" . wOya]*100)/g_Interval["MM"])
		} else {
			vOverlap := 0
		}
		if(vOverlap >= g_OverlapOMO) {
			g_KeyInPtn := SendOnHoldOM()	; 保留キーの同時打鍵
		} else {
			g_KeyInPtn := SendOnHoldO()	; 保留親指キーの単独打鍵
			g_KeyInPtn := SendOnHoldM()
		}
	}
	else
	if(g_KeyInPtn == "MM") 		; S7)MMオン状態
	{	
		; M3 キー押下
		_mode := g_RomajiOnHold[1] . g_OyaOnHold[1] . g_KoyubiOnHold[1]
		if(ksc[_mode . g_layoutPos]<=2 || (ksc[_mode . g_layoutPos]==3 && kdn[_mode . g_MojiOnHold[2] . g_MojiOnHold[1] . g_layoutPos] == "")) {
			g_Interval["S12"] := g_TDownOnHold[2] - g_TDownOnHold[1]	; 前回の文字キー押しからの期間
			g_Interval["S23"] := keyTick[g_layoutPos] - g_TDownOnHold[2]	; 前回の文字キー押しからの期間　3キー判定
			if(kdn[_mode . g_MojiOnHold[2] . g_MojiOnHold[1]]!="" && g_Interval["S12"] < g_Interval["S23"]) {
				; 保留中の同時打鍵を確定
				g_KeyInPtn := SendOnHoldMM()	; ２文字を同時打鍵として出力して初期状態に
				SubSendUp(g_MojiOnHold[1])
			} else {
				g_keyInPtn := SendOnHoldM()	; 保留した２文字前だけを打鍵してMオン状態に遷移
				SubSendUp(g_MojiOnHold[1])
			}
		}
	}
	else
	if(g_KeyInPtn == "MMm") 	; S8)MMオンmオフ状態
	{
		g_Interval["S12"] := g_TDownOnHold[2] - g_TDownOnHold[1]	; 前回の文字キー押しからの期間
		g_Interval["S23"] := keyTick[g_layoutPos] - g_TDownOnHold[2]	; 前回の文字キー押しからの期間　3キー判定
		_mode := g_RomajiOnHold[1] . g_OyaOnHold[1] . g_KoyubiOnHold[1]
		if(kdn[_mode . g_MojiOnHold[2] . g_MojiOnHold[1]]!="" && g_Interval["S12"] < g_Interval["S23"]) {
			; 保留中の同時打鍵を確定
			g_KeyInPtn := SendOnHoldMM()	; ２文字を同時打鍵として出力して初期状態に
			SubSendUp(g_MojiOnHold[1])
		} else {
			g_keyInPtn := SendOnHoldM()	; 保留した２文字前だけを打鍵してMオン状態に遷移
			SubSendUp(g_MojiOnHold[1])
		}
	}
	else
	if(g_KeyInPtn == "MMM")		; S9)MMMオン状態
	{
		; 同時打鍵を確定
		g_KeyInPtn := SendOnHoldMMM()	;３文字を同時打鍵として出力して初期状態に
	}
	;SetKeyDelay, -1
	Gosub,ChkIME

	if(g_Oya=="N")
	{
		if(g_KeyInPtn=="") {
			; 当該キーを単独打鍵として保留
			g_KeyInPtn := enqueueKey(g_Romaji, g_Oya, KoyubiOrSans(g_Koyubi,g_sans), g_layoutPos, g_metaKey, keyTick[g_layoutPos])
			g_Timeout := SetTimeout(g_KeyInPtn)
			g_SendTick :=  calcSendTick(keyTick[g_layoutPos], g_Timeout)

			; 連続打鍵の判定 
			JudgePushedKeys(g_RomajiOnHold[1] . g_OyaOnHold[1] . g_KoyubiOnHold[1], g_MojiOnHold[1])
			if(g_keyInPtn == "M") {
				SendZeroDelay(g_RomajiOnHold[1] . g_OyaOnHold[1] . g_KoyubiOnHold[1], g_MojiOnHold[1], g_ZeroDelay)
			}
		}
		else if(g_KeyInPtn=="M")	; S2)Mオン状態
		{
			g_KeyInPtn := enqueueKey(g_Romaji, g_Oya, KoyubiOrSans(g_Koyubi,g_sans), g_layoutPos, g_metaKey, keyTick[g_layoutPos])
			; 当該キーとその前を同時打鍵として保留
			g_Timeout := SetTimeout(g_KeyInPtn)
			g_SendTick := calcSendTick(keyTick[g_layoutPos], g_Timeout)
			
			; 連続打鍵の判定 
			JudgePushedKeys(g_RomajiOnHold[1] . g_OyaOnHold[1] . g_KoyubiOnHold[1], g_MojiOnHold[2] . g_MojiOnHold[1])
		}
		else if(g_KeyInPtn=="MM")	; S7)MMオン状態
		{
			enqueueKey(g_Romaji, g_Oya, KoyubiOrSans(g_Koyubi,g_sans), g_layoutPos, g_metaKey, keyTick[g_layoutPos])
			
			; 当該キーとその前を同時打鍵として保留
			g_KeyInPtn := SendOnHoldMMM()
			g_KeyInPtn := clearQueue()
			g_Timeout := 60000
			g_SendTick := calcSendTick(keyTick[g_layoutPos], g_Timeout)
		}
	}
	else
	{
		; 連続打鍵モード
		if(g_KeyInPtn=="") 		; S1)初期化モード
		{
			g_KeyInPtn := enqueueKey(g_Romaji, g_Oya, KoyubiOrSans(g_Koyubi,g_sans), g_layoutPos, g_metaKey, keyTick[g_layoutPos])
			g_Interval[g_KeyInPtn] := keyTick[g_layoutPos] - g_OyaTick[g_Oya]
			g_Timeout := g_MaxTimeout
			g_SendTick := calcSendTick(keyTick[g_layoutPos], g_Timeout)
			
			; 連続打鍵の判定 
			JudgePushedKeys(g_RomajiOnHold[1] . g_OyaOnHold[1] . g_KoyubiOnHold[1], g_MojiOnHold[1])
			if(g_keyInPtn == g_Oya . "M") {
				SendZeroDelayOM()
			}
		} else
		if(RegExMatch(g_KeyInPtn, "^[RLABCD]$")==1)		; S3)Oオン状態
		{
			wOya := g_OyaOnHold[1]
			g_KeyInPtn := enqueueKey(g_Romaji, wOya, KoyubiOrSans(g_Koyubi,g_sans), g_layoutPos, g_metaKey, keyTick[g_layoutPos])
			g_Interval[g_KeyInPtn] := keyTick[g_layoutPos] - g_TDownOnHold[1]
			g_Timeout := minimum(floor(g_Interval[g_KeyInPtn]*g_OverlapOM/(100-g_OverlapOM)),g_MaxTimeout)
			g_SendTick := calcSendTick(keyTick[g_layoutPos], g_Timeout)
			
			; 連続打鍵の判定 
			JudgePushedKeys(g_RomajiOnHold[1] . g_OyaOnHold[1] . g_KoyubiOnHold[1], g_MojiOnHold[1])
			if(g_keyInPtn == g_Oya . "M") {
				SendZeroDelayOM()
			}
		} else
		if(RegExMatch(g_KeyInPtn, "^[RLABCD]M$")==1)	; S5)O-Mオン状態		
		{
			mergeOMKey()
			g_KeyInPtn := enqueueKey(g_Romaji, g_Oya, KoyubiOrSans(g_Koyubi,g_sans), g_layoutPos, g_metaKey, keyTick[g_layoutPos])
			; 当該キーとその前を同時打鍵として保留
			g_Timeout := SetTimeout(g_KeyInPtn)
			g_SendTick := calcSendTick(keyTick[g_layoutPos], g_Timeout)
			; 連続打鍵の判定 
			JudgePushedKeys(g_RomajiOnHold[1] . g_OyaOnHold[1] . g_KoyubiOnHold[1], g_MojiOnHold[2] . g_MojiOnHold[1])
		} else
		if(RegExMatch(g_KeyInPtn, "^M[RLABCD]$")==1)	; S4)M-Oオン状態		
		{
			mergeMOKey()
			g_KeyInPtn := enqueueKey(g_Romaji, g_Oya, KoyubiOrSans(g_Koyubi,g_sans), g_layoutPos, g_metaKey, keyTick[g_layoutPos])
			; MMモードに遷移
			g_Timeout := SetTimeout(g_KeyInPtn)
			g_SendTick := calcSendTick(keyTick[g_layoutPos], g_Timeout)
		}
		else 
		if(g_KeyInPtn=="MM")							; S7)MMオン状態
		{
			g_KeyInPtn := enqueueKey(g_Romaji, g_Oya, KoyubiOrSans(g_Koyubi,g_sans), g_layoutPos, g_metaKey, keyTick[g_layoutPos])
			; MMMモードに遷移
			g_Timeout := SetTimeout(g_KeyInPtn)
			g_SendTick := calcSendTick(keyTick[g_layoutPos], g_Timeout)
			g_KeyInPtn := SendOnHoldMMM()
		}
	}
	critical,off
	return
;----------------------------------------------------------------------
; 小指シフトとSanSの論理和
;----------------------------------------------------------------------
KoyubiOrSans(_Koyubi, _sans)
{
	global

	if(g_sans=="S") {
		if(GetKeyState(keyNameHash[g_sansPos],"P")==0) {
			SansSend()
			_sans := "N"
		}
	}
	if (_Koyubi=="K")
	{
		return "K"
	}
	if (_sans=="S") 
	{
		return "S"
	}
	return "N"
}

;----------------------------------------------------------------------
; テンキー押下
;----------------------------------------------------------------------
keydownT:
	kName := TenkeyHash[GetKeyState("NumLock", "T")  . kName]
;----------------------------------------------------------------------
; 修飾キー押下
;----------------------------------------------------------------------
keydown:
keydownX:
	g_trigger := g_metaKey
	keyTick[g_layoutPos] := Pf_Count()
	RegLogs(kName . " down", g_KeyInPtn, g_trigger, g_Timeout, "")
	g_Timeout := ""

	if(g_KeyPause==kName) {
		Gosub,pauseKeyDown
	}
	keyState[g_layoutPos] := 2

	Gosub,ModeInitialize
	if(ShiftMode[g_Romaji] == "プレフィックスシフト") {
		SubSendOne(MnDown(kName))
		SetKeyupSave(MnUp(kName),g_layoutPos)
		g_LastKey["表層"] := ""
		g_prefixshift := ""
		critical,off
		return
	}
	g_ModifierTick := keyTick[g_layoutPos]
	SubSendOne(MnDown(kName))
	SetKeyupSave(MnUp(kName),g_layoutPos)

	Gosub,ChkIME
	; 現在の配列面が定義されていればキーフック
	if(LF[g_Romaji . "N" . KoyubiOrSans(g_Koyubi,g_sans)]!="") {
		SetHotkey("on")
		SetHotkeyFunction("on")
		Suspend,off
	} else {
		Suspend,on
		SetHotkey("off")
		SetHotkeyFunction("off")
	}
	g_LastKey["表層"] := ""
	g_KeyInPtn := ""
	critical,off
	return

;----------------------------------------------------------------------
; スペース＆シフトキー押下
;----------------------------------------------------------------------
keydownS:
	g_trigger := g_metaKey
	keyTick[g_layoutPos] := Pf_Count()
	RegLogs(kName . " down", g_KeyInPtn, g_trigger, g_Timeout, "")
	g_Timeout := ""
	keyState[g_layoutPos] := 2

	g_ModifierTick := keyTick[g_layoutPos]
	Gosub,ModeInitialize
	
	if(g_sans == "S" && g_sansTick != INFINITE) {
		SubSendOne(MnDown(kName))
		SetKeyupSave(MnUp(kName),g_layoutPos)
		g_LastKey["表層"] := ""
	}
	g_sans := "S"
	g_sansTick := keyTick[g_layoutPos] + g_MaxTimeout
	if(ShiftMode[g_Romaji] == "プレフィックスシフト") {
		g_prefixshift := ""
	} else {
		g_KeyInPtn := ""
	}
	critical,off
	return

;----------------------------------------------------------------------
; 月配列等のプレフィックスシフトキー押下
;----------------------------------------------------------------------
keydown0:
keydown1:
keydown2:
keydown3:
keydown4:
keydown5:
keydown6:
keydown7:
keydown8:
keydown9:
	keyTick[g_layoutPos] := Pf_Count()
	RegLogs(kName . " down", g_KeyInPtn, g_trigger, g_Timeout, "")
	g_Timeout := ""

	keyState[g_layoutPos] := 2
	g_trigger := g_metaKey
	if(g_prefixshift == "")
	{
		g_prefixshift := g_metaKey
		critical,off
		return
	}
	SendKey(g_Romaji . g_prefixshift . KoyubiOrSans(g_Koyubi,g_sans), g_layoutPos)
	clearQueue()

	g_prefixshift := ""
	critical,off
	return

;----------------------------------------------------------------------
; 濁点・半濁点の処理
;----------------------------------------------------------------------
nextDakuten(_mode, _MojiOnHold)
{
	global
	local _nextKey

	_nextKey := ""
	if(kLabel[_mode . _MojiOnHold]=="゛" || kLabel[_mode . _MojiOnHold]=="濁") {
		_nextKey := DakuonSurfaceHash[g_LastKey["表層"]]
	} else
	if(kLabel[_mode . _MojiOnHold]=="゜" || kLabel[_mode . _MojiOnHold]=="半") {
		_nextKey := HandakuonSurfaceHash[g_LastKey["表層"]]
	} else
	if(kLabel[_mode . _MojiOnHold]=="拗") {
		_nextKey := YouonSurfaceHash[g_LastKey["表層"]]
	} else
	if(kLabel[_mode . _MojiOnHold]=="修") {
		_nextKey := CorrectSurfaceHash[g_LastKey["表層"]]
	}
	return _nextKey
}

;----------------------------------------------------------------------
; キーアップ（押下終了）
;----------------------------------------------------------------------
keyupM:
	g_trigger := g_metaKeyUp[g_metaKey]
	g_MojiUpTick := Pf_Count()
	RegLogs(kName . " up", g_KeyInPtn, g_trigger, g_Timeout, "")
	g_Timeout := ""
	keyState[g_layoutPos] := 0
	
	if(ShiftMode[g_Romaji] == "プレフィックスシフト" || ShiftMode[g_Romaji] == "小指シフト") {
		SubSendUp(g_layoutPos)

		critical,off
		sleep,-1
		return
	}
	setKeyup(g_layoutPos,g_MojiUpTick)

	; 親指シフトの動作
	if(g_KeyInPtn=="M")	; S2)Mオン状態
	{
		if(g_layoutPos == g_MojiOnHold[1]) {	; 保留キーがアップされた
			g_keyInPtn := SendOnHoldM()
		}
	}
	else if(g_KeyInPtn == "MM")		; S7)MMオン状態
	{
		if(g_layoutPos == g_MojiOnHold[1]) {
			if(kdn[_mode . g_MojiOnHold[2] . g_MojiOnHold[1]]=="") {
				g_keyInPtn := SendOnHoldM()	; ２文字前を単独打鍵して確定
				SubSendUp(g_MojiOnHold[1])
				; １文字前の待機
				g_Timeout := SetTimeout(g_KeyInPtn)
				g_SendTick := calcSendTick(g_MojiUpTick, g_Timeout)
			} else {
				g_Interval["S1_1"] := g_TUpOnHold[1] - g_TDownOnHold[1]	; 前回の文字キー押しからの重なり期間
				g_Interval["S2_1"] := g_TUpOnHold[1] - g_TDownOnHold[2]	; 最初の文字だけをオンしていた期間
				if(g_Interval["S1_1"]>0) {
					vOverlap := floor((100*g_Interval["S2_1"])/g_Interval["S1_1"])	; 重なり厚み計算
				} else {
					vOverlap := 0
				}
				_mode := g_RomajiOnHold[1] . g_OyaOnHold[1] . g_KoyubiOnHold[1]
				if(g_Interval["S2_1"] > g_ThresholdSS || g_OverlapSS <= vOverlap) {
					; 押下キー判定 
					g_KeyInPtn := SendOnHoldMM()
					if(g_KeyInPtn == "M") {
						SubSendUp(g_MojiOnHold[1])
						g_keyInPtn := SendOnHoldM()
					}
				} else {
					; S4)M1M2オンM1オフモード (MMm) に遷移
					g_KeyInPtn := enqueueKey(g_Romaji, g_metaKey, KoyubiOrSans(g_Koyubi,g_sans), g_layoutPos, g_metaKeyUp[g_metaKey], 0)
					g_Timeout := SetTimeout(g_KeyInPtn)
					g_SendTick := calcSendTick(g_MojiUpTick, g_Timeout)
				}
			}
		} else
		if(g_layoutPos == g_MojiOnHold[2]) {
			g_KeyInPtn := SendOnHoldMM()
			if(g_KeyInPtn == "M") {
				SubSendUp(g_MojiOnHold[1])
				g_keyInPtn := SendOnHoldM()
			}
		}
	}
	else if(g_KeyInPtn == "MMm")	; S8)MMオンmオフ状態
	{
		if(g_layoutPos == g_MojiOnHold[2]) {
			g_Interval["S1_2"] := g_TUpOnHold[2] - g_TDownOnHold[1]	; 第１文字キーオンからの期間
			g_Interval["S2_1"] := g_TUpOnHold[1] - g_TDownOnHold[2]	; 重なり期間
			if (g_Interval["S1_2"] > 0) {
				vOverlap := floor((100*g_Interval["S2_1"])/g_Interval["S1_2"])	; 重なり厚み計算
			} else {
				vOverlap := 0
			}
			; 同時打鍵を確定
			if(g_OverlapSS <= vOverlap) {
				g_KeyInPtn := SendOnHoldMM()
				if(g_KeyInPtn == "M") {
					SubSendUp(g_MojiOnHold[1])
					g_keyInPtn := SendOnHoldM()
				}
			} else {
				g_keyInPtn := SendOnHoldM()
				SubSendUp(g_MojiOnHold[1])
				g_keyInPtn := SendOnHoldM()
			}
		}
	}
	else if(g_KeyInPtn == "MMM")
	{
		; 同時打鍵を確定
		g_KeyInPtn := SendOnHoldMMM()
	}
	else if(RegExMatch(g_KeyInPtn, "^M[RLABCD]$")==1)	; S4)M-Oオン状態
	{
		if(g_MetaOnHold[1]=="M" && g_layoutPos==g_MojiOnHold[1])	; 保留キーがアップされた
		{
			; 処理C
			wOya := g_OyaOnHold[g_OnHoldIdx]
			g_Interval["M_M"] := g_TUpOnHold[1] - g_TDownOnHold[1]
			g_Interval[wOya . "_M"] := g_TUpOnHold[1] - g_TDownOnHold[2]
			if(g_Interval["M_M"]>0) {
				vOverlap := floor((100*g_Interval[wOya . "_M"])/g_Interval["M_M"])
			} else {
				vOverlap := 0
			}
			if(vOverlap < g_OverlapMO && g_Interval[wOya . "_M"] < g_Threshold)	; g_Tau
			{
				g_keyInPtn := SendOnHoldM()
				g_Timeout := 60000
				g_SendTick := calcSendTick(g_MojiUpTick, g_Timeout)
			} else {
				g_KeyInPtn := SendOnHoldMO()
			}
		}
	}
	else if(RegExMatch(g_KeyInPtn, "^[RLABCD]M$")==1)	; ;S5)O-Mオン状態
	{
		; キューは、M または OM
		if((g_MetaOnHold[1]=="M" && g_layoutPos==g_MojiOnHold[1])
		|| (g_MetaOnHold[2]=="M" && g_layoutPos==g_MojiOnHold[2]))	; 保留キーがアップされた
		{
			; 処理E
			g_KeyInPtn := SendOnHoldOM()
		}
	}
	else if(RegExMatch(g_KeyInPtn, "^(RMr|LMl|AMa|BMb|CMc|DMd)$")==1)	;S6)O-M-Oオフ状態
	{
		; キューは、Mo または OMo
		if((g_MetaOnHold[1]=="M" && g_layoutPos==g_MojiOnHold[1])
		|| (g_MetaOnHold[2]=="M" && g_layoutPos==g_MojiOnHold[2]))	; 保留キーがアップされた
		{
			wOya := g_OyaOnHold[g_OnHoldIdx]
			g_Interval["M_" . wOya] := g_TUpOnHold[g_OnHoldIdx] - g_TDownOnHold[g_OnHoldIdx-1]	; 文字キー押しから右親指キー解除までの期間
			g_Interval["M_M"] := g_MojiUpTick - g_TDownOnHold[g_OnHoldIdx-1]
			if(g_Interval["M_M"] > 0)
			{
				vOverlap := floor((g_Interval["M_" . wOya]*100)/g_Interval["M_M"])
			} else {
				vOverlap := 0
			}
			if(vOverlap > g_OverlapOMO) {
				g_KeyInPtn := SendOnHoldOM()
			} else {
				g_KeyInPtn := SendOnHoldO()		; 保留親指キーの単独打鍵
				g_keyInPtn := SendOnHoldM()
				g_keyInPtn := clearQueue()
			}
		}
	}
	SubSendUp(g_layoutPos)
	g_trigger := ""
	critical,off
	sleep,-1
	return


;----------------------------------------------------------------------
; 文字コード以外のキーアップ（押下終了）
;----------------------------------------------------------------------
keyup:
keyupX:
keyupT:
	g_trigger := g_metaKeyUp[g_metaKey]
	RegLogs(kName . " up", g_KeyInPtn, g_trigger, g_Timeout, "")
	g_Timeout := ""
	SubSendUp(g_layoutPos)
	g_trigger := ""
	critical,off
	sleep,-1
	return

;----------------------------------------------------------------------
; スペース＆シフトキー（押下終了）
;----------------------------------------------------------------------
keyupS:
	g_trigger := g_metaKeyUp[g_metaKey]
	RegLogs(kName . " up", g_KeyInPtn, g_trigger, g_Timeout, "")
	g_Timeout := ""
	if(g_sansTick != INFINITE) {
		SubSendOne(MnDown(kName))
		SetKeyupSave(MnUp(kName), g_layoutPos)
		g_sansTick := INFINITE
	}
	SubSendUp(g_layoutPos)
	g_trigger := ""
	g_sans := "N"
	critical,off
	sleep,-1
	return

;----------------------------------------------------------------------
; 月配列等のプレフィックスシフトキー押下終了
;----------------------------------------------------------------------
keyup0:
keyup1:
keyup2:
keyup3:
keyup4:
keyup5:
keyup6:
keyup7:
keyup8:
keyup9:
	g_trigger := g_metaKeyUp[g_metaKey]
	RegLogs(kName . " up", g_KeyInPtn, g_trigger, g_Timeout, "")
	g_Timeout := ""
	SubSendUp(g_layoutPos)
	critical,off
	sleep,-1
	return

;----------------------------------------------------------------------
; プロセス監視割込処理
;----------------------------------------------------------------------
InterruptProcessPolling:
	g_intproc += 1
	if(mod(g_intproc,5)==0) {
		Process,Exist,yamabuki_r.exe
		_pid := ErrorLevel
		if(_pid!=0 && g_process["yamabuki_r"]==0) {
			Traytip,キーボード配列エミュレーションソフト「紅皿」,やまぶきRが動作中。干渉のおそれがあります。
		}
		g_process["yamabuki_r"] := _pid
	}
	if(mod(g_intproc,5)==1) {
		Process,Exist,yamabuki.exe
		_pid := ErrorLevel
		if(_pid!=0 &&  g_process["yamabuki"]==0) {
			Traytip,キーボード配列エミュレーションソフト「紅皿」,やまぶきが動作中。干渉のおそれがあります。
		}
		g_process["yamabuki"] := _pid
	}
	if(mod(g_intproc,5)==2) {
		Process,Exist,DvorakJ.exe
		_pid := ErrorLevel
		if(_pid!=0 &&  g_process["DvorakJ"]==0) {
			Traytip,キーボード配列エミュレーションソフト「紅皿」,DvorakJが動作中。干渉のおそれがあります。
		}
		g_process["DvorakJ"] := _pid
	}
	if(mod(g_intproc,5)==3) {
		Process,Exist,em1keypc.exe
		_pid := ErrorLevel
		if(_pid!=0 &&  g_process["em1keypc"]==0) {
			Traytip,キーボード配列エミュレーションソフト「紅皿」,em1keypcが動作中。干渉のおそれがあります。
		}
		g_process["em1keypc"] := _pid
	}
	if(mod(g_intproc,5)==4) {
		Process,Exist,姫踊子草2.exe
		_pid := ErrorLevel
		if(_pid!=0 &&  g_process["姫踊子草2"]==0) {
			Traytip,キーボード配列エミュレーションソフト「紅皿」,姫踊子草2が動作中。干渉のおそれがあります。
		}
		g_process["姫踊子草2"] := _pid
	}
	sleep,-1
	return

;----------------------------------------------------------------------
; 10[mSEC]ごとの割込処理
;----------------------------------------------------------------------
Interrupt10:
	critical
	Gosub,ScanModifier
	Gosub,ScanOyaKey
	Gosub,ScanPauseKey
	if(g_Modifier!=0) 
	{
		Gosub,ModeInitialize
	} else
	if(g_Pause==1) 
	{
		Gosub,ModeInitialize
		Suspend,on
		SetHotkey("off")
		SetHotkeyFunction("off")
	} else {
		Gosub,ChkIME
		; 現在の配列面が定義されていればキーフック
		if(LF[g_Romaji . "N" . KoyubiOrSans(g_Koyubi,g_sans)]!="") {
			SetHotkey("on")
			SetHotkeyFunction("on")
			Suspend,off
		} else {
			Suspend,on
			SetHotkey("off")
			SetHotkeyFunction("off")
		}
	}
	if(keyState["A04"] != 0)
	{
		_TickCount := Pf_Count()
		if(_TickCount > keyTick["A04"] + 100) 	; タイムアウト
		{
			; ひらがな／カタカナキーはキーアップを受信できないから、0.1秒でキーアップと見做す
			g_layoutPos := "A04"
			g_metaKey := keyAttribute3[g_Romaji . KoyubiOrSans(g_Koyubi,g_sans) . g_layoutPos]
			kName := keyNameHash[g_layoutPos]
			GuiControl,2:,vkeyDN%g_layoutPos%,　
			goto, keyup%g_metaKey%
		}
	}
	if(g_sans=="S") {
		if(GetKeyState(keyNameHash[g_sansPos],"P") == 0) {
			SansSend()
		}
	}
	Gosub,Polling
	critical,off
	if(A_IsCompiled != 1)
	{
		vImeConvMode := IME_GetConvMode()
		szConverting := IME_GetConverting()
		
		;g_debugout3 := ksc["RNNC01"] . ":" . kst["RNNC01"]
		g_debugout3 := g_HotKey
		g_debugout2 := g_LastKey["表層"]
		;g_debugout2 := GetKeyState(keyNameHash[g_sansPos],"P")
		_mode := g_Romaji . g_Oya . KoyubiOrSans(g_Koyubi,g_sans)
		g_debugout := vImeMode . ":" . vImeConvMode . szConverting . ":" . g_Romaji . g_Oya . KoyubiOrSans(g_Koyubi,g_sans) . ":" . g_layoutPos . ":" . g_KeyInPtn . ":" . g_debugout2 . ":" . g_debugout3
		;g_LastKey["status"] . ":" . g_LastKey["snapshot"]
		Tooltip, %g_debugout%, 0, 0, 2 ; debug
	}
	sleep,-1
	return

;----------------------------------------------------------------------
; Sansでスペースの出力
;----------------------------------------------------------------------
SansSend()
{
	global
	
	if(g_sansTick!=INFINITE)	; 未タイムアウト
	{
		SubSendOne(MnDown(keyNameHash[g_sansPos]))
		SubSendOne(MnUp(keyNameHash[g_sansPos]))
		g_sansTick := INFINITE
		kup_save[g_sansPos] := ""
		keyState[g_sansPos] := 0
	}
	g_sans := "N"
}

;----------------------------------------------------------------------
; 10mSECなどのポーリング
;----------------------------------------------------------------------
Polling:
	if(g_SendTick != INFINITE)
	{
		g_trigger := "TO"
		_TickCount := Pf_Count()
		if(_TickCount > g_SendTick) 	; タイムアウト
		{
			if(g_KeyInPtn=="M")			; S2)Mオン状態
			{
				g_keyInPtn := SendOnHoldM()
			}
			else if(g_KeyInPtn=="MM")	; S6)MMオン状態
			{
				g_KeyInPtn := SendOnHoldMM()
				if(g_KeyInPtn == "M") {
					SubSendUp(g_MojiOnHold[1])
					g_keyInPtn := SendOnHoldM()
				}
			}
			else if(g_KeyInPtn == "MMm")	; S7)MMオンmオフ状態
			{
				g_keyInPtn := SendOnHoldM()
				SubSendUp(g_MojiOnHold[1])
				g_keyInPtn := SendOnHoldM()
			}
			else if(g_KeyInPtn =="MMM")
			{
				g_KeyInPtn := SendOnHoldMMM()
			}
			else if(RegExMatch(g_KeyInPtn, "^[RLABCD]$")==1)	; S3)Oオン状態
			{
				if(g_MojiOnHold[1] == "A02" || g_KeySingle == "有効") {
					g_KeyInPtn := SendOnHoldO()		; 保留親指キーの単独打鍵
				} else {
					_layout := g_Oya2Layout[g_Oya]
					_keyName := keyNameHash[_layout]
					if(GetKeyState(_keyName,"P") == 0) {
						g_KeyInPtn := SendOnHoldO()	; 保留親指キーの単独打鍵
					}
				}
			}
			else if(RegExMatch(g_KeyInPtn, "^M[RLABCD]$")==1)	; S4)M-Oオン状態
			{
				g_KeyInPtn := SendOnHoldMO()	; 保留キーの同時打鍵
			}
			else if(RegExMatch(g_KeyInPtn, "^[RLABCD]M$")==1)	; S5)O-Mオン状態
			{
				g_KeyInPtn := SendOnHoldOM()	; 保留キーの同時打鍵
			}
			else if(RegExMatch(g_KeyInPtn, "^(RMr|LMl|AMa|BMb|CMc|DMd)$")==1)	; S6)O-M-Oオフ状態			
			{
				g_KeyInPtn := SendOnHoldO()	; 保留親指キーの単独打鍵
				g_keyInPtn := SendOnHoldM()	; 保留文字キーの単独打鍵
			}
			g_KeyInPtn := clearQueue()
			g_Timeout := 60000
			g_SendTick := INFINITE
		}
		if(_TickCount > g_sansTick) 	; タイムアウト
		{
			SubSendOne(MnDown(keyNameHash[g_sansPos]))
			g_sansTick := INFINITE
			SetKeyupSave(MnUp(keyNameHash[g_sansPos]),g_sansPos)
		}
	}
	g_trigger := ""
	return

;----------------------------------------------------------------------
; 修飾キー状態読み取り
;----------------------------------------------------------------------
ScanModifier:
	if(keyHook[fkeyPosHash["左Shift"]]=="off") {
		GetKeyStateWithLog5("左Shift")
	}
	if(keyHook[fkeyPosHash["右Shift"]]=="off") {
		GetKeyStateWithLog5("右Shift")
	}
	if(keyHook[fkeyPosHash["左Shift"]]=="off" || keyHook[fkeyPosHash["右Shift"]]=="off") {
		if(keyState[fkeyPosHash["左Shift"]]!=0 || keyState[fkeyPosHash["右Shift"]]!=0)
		{
			g_Koyubi := "K"
		} else {
			g_Koyubi := "N"
		}
	}
	if(keyHook[fkeyPosHash["左Ctrl"]]=="off") {
		GetKeyStateWithLog5("左Ctrl")
		if(keyState[fkeyPosHash["左Ctrl"]]!=0) {
			g_Modifier |= 0x0200
		} else {
			g_Modifier &= (~0x0200)
		}
	}
	if(keyHook[fkeyPosHash["右Ctrl"]]=="off") {
		GetKeyStateWithLog5("右Ctrl")	
		if(keyState[fkeyPosHash["右Ctrl"]]!=0) {
			g_Modifier |= 0x0400
		} else {
			g_Modifier &= (~0x0400)
		}
	}
	if(keyHook[fkeyPosHash["左Alt"]]=="off") {
		GetKeyStateWithLog5("左Alt")
		if(keyState[fkeyPosHash["左Alt"]]!=0) {
			g_Modifier |= 0x0800
		} else {
			g_Modifier &= (~0x0800)
		}
	}
	if(keyHook[fkeyPosHash["右Alt"]]=="off") {
		GetKeyStateWithLog5("右Alt")
		if(keyState[fkeyPosHash["右Alt"]]!=0) {
			g_Modifier |= 0x1000
		} else {
			g_Modifier &= (~0x1000)
		}
	}
	if(keyHook[fkeyPosHash["左Win"]]=="off") {
		GetKeyStateWithLog5("左Win")
		if(keyState[fkeyPosHash["左Win"]]!=0) {
			g_Modifier |= 0x2000
		} else {
			g_Modifier &= (~0x2000)
		}
	}
	if(keyHook[fkeyPosHash["右Win"]]=="off") {
		GetKeyStateWithLog5("右Win")
		if(keyState[fkeyPosHash["右Win"]]!=0) {
			g_Modifier |= 0x4000
		} else {
			g_Modifier &= (~0x4000)
		}
	}
	g_Modifier &= 0x7E00

	GetKeyStateWithLog5("Applications")
	return

;----------------------------------------------------------------------
; 親指キー読み取り
;----------------------------------------------------------------------
ScanOyaKey:
	_pos := g_Oya2Layout[g_Oya]
	if(_pos!="")
	{
		if(keyHook[_pos]=="off")
		{
			g_Oya := "N"
		} else 
		{
			_scanCode := scanCodeHash[_pos]
			if(_scanCode!="")
			{
				if(GetKeyState(_scanCode,"P")==0) {
					g_Oya := "N"
				}
			}
		}
	} else {
		g_Oya := "N"
	}
	return

;----------------------------------------------------------------------
; Pauseキー読み取り
;----------------------------------------------------------------------
ScanPauseKey:
	if(g_KeyPause != "") {
		if(GetKeyStateWithLog5(g_KeyPause)==1) {
			Gosub,pauseKeyDown
		}
	}
	if(g_KeyPause == "無効")
	{
		if(g_Pause == 1) {
			Gosub,pauseKeyDown
		}
	}
	return

;----------------------------------------------------------------------
; 初期化
;----------------------------------------------------------------------
ModeInitialize:
	if(g_KeyInPtn=="M")
	{
		g_keyInPtn := SendOnHoldM()
	}
	else if(g_KeyInPtn == "MM")
	{
		g_KeyInPtn := SendOnHoldMM()
		if(g_KeyInPtn == "M") {
			SubSendUp(g_MojiOnHold[1])
			g_keyInPtn := SendOnHoldM()
		}
	}
	else if(g_KeyInPtn == "MMm")
	{
		g_KeyInPtn := SendOnHoldMM()
		if(g_KeyInPtn == "M") {
			SubSendUp(g_MojiOnHold[1])
			g_keyInPtn := SendOnHoldM()
		}
	}
	else if(g_KeyInPtn == "MMM")
	{
		g_KeyInPtn := SendOnHoldMMM()
	}
	else if(RegExMatch(g_KeyInPtn, "^[RLABCD]$")==1)
	{
		g_KeyInPtn := SendOnHoldO()	; 保留キーの同時打鍵
	}
	else if(RegExMatch(g_KeyInPtn, "^M[RLABCD]$")==1)
	{
		g_KeyInPtn := SendOnHoldMO()	; 保留キーの同時打鍵
	}
	else if(RegExMatch(g_KeyInPtn, "^[RLABCD]M$")==1)
	{
		g_KeyInPtn := SendOnHoldOM()
	}
	else if(RegExMatch(g_KeyInPtn, "^(RMr|LMl|AMa|BMb|CMc|DMd)$")==1)
	{
		g_KeyInPtn := SendOnHoldOM()
	}
	g_KeyInPtn := clearQueue()
	g_Timeout := 60000
	g_SendTick := INFINITE
	return

;-----------------------------------------------------------------------
;	仮想キーの状態取得とログ
;-----------------------------------------------------------------------
GetKeyStateWithLog5(_fName) {
	global
	local _locationPos, _kDown

	_kDown := 0
	_locationPos := fkeyPosHash[_fName]
	if(_locationPos != "" && keyHook[_locationPos]=="off") {
		stCurr := GetKeyState(fkeyVkeyHash[_fName],"P")
		if(stCurr != 0 && keyState[_locationPos] == 0)	; keydown
		{
			_kDown := 1
			RegLogs(kName . " down", g_KeyInPtn, g_trigger, g_Timeout, "")
			g_Timeout := ""
		}
		else if(stCurr == 0 && keyState[_locationPos] != 0)	; keyup
		{
			RegLogs(kName . " up", g_KeyInPtn, g_trigger, g_Timeout, "")
			g_Timeout := ""
		}
		keyState[_locationPos] := stCurr
	}
	return 	_kDown
}

;-----------------------------------------------------------------------
;	ボーズキーが押された
;-----------------------------------------------------------------------
pauseKeyDown:
	if(g_Pause == 1) {
		Gosub, DoResume
	} else {
		Gosub, DoPause
	}
	return

;----------------------------------------------------------------------
; IME状態のチェックとローマ字モード判定
; 2019/3/3 ... IME_GetConvMode の上位31-15bitが立っている場合がある
;              よって、最下位ビットのみを見る
;----------------------------------------------------------------------
ChkIME:
	if(WinExist("ahk_class #32768")!=0) ; IMEメニュー表示中
	{
		vImeMode := 0
	} else 
	{
		vImeMode := IME_GET() & 32767
	}
	if(vImeMode==0)
	{
		vImeConvMode :=IME_GetConvMode()
		g_Romaji := "A"
	} else {
		vImeConvMode :=IME_GetConvMode()
		if((vImeConvMode & 0x01)==1) ;半角カナ・全角平仮名・全角カタカナ
		{
			g_Romaji := "R"
		}
		else ;ローマ字変換モード
		{
			g_Romaji := "A"
		}
	}
	;if(A_IsCompiled != 1)
	;{
		;vImeConverting := IME_GetConverting() & 32767
		;Tooltip, %g_Romaji% %vImeConvMode%, 0, 0, 2 ; debug
	;}
	return


;----------------------------------------------------------------------
; キーオンのイベント
;----------------------------------------------------------------------
;　Ｈ段目
gSC135:
gSC037:
gSC04E:
gSC04A:
gSC11C:
gSC052:
gSC04F:
gSC050:
gSC051:
gSC04B:
gSC04C:
gSC04D:
gSC047:
gSC048:
gSC049:
gSC053:
;　Ｇ段目
gSC137:	;PrintScreen
gSC046:	;ScreenLock
gSC045:	;Pause
gSC152:
gSC147:
gSC149:
gSC153:
gSC14F:
gSC151:
gSC148:
gSC14B:
gSC150:
gSC14D:
;　Ｆ段目
gSC001:	;Esc
gSC03B:	;F1
gSC03C:	;F2
gSC03D:	;F3
gSC03E:	;F4
gSC03F:	;F5
gSC040:	;F6
gSC041:	;F7
gSC042:	;F8
gSC043:	;F9
gSC044:	;F10
gSC057:	;F11
gSC058:	;F12
;　Ｅ段目
gSC029:	;半角／全角
gSC002:	;1
gSC003:	;2
gSC004:	;3
gSC005:	;4
gSC006:	;5
gSC007:	;6
gSC008:	;7
gSC009:	;8
gSC00A:	;9
gSC00B:	;0
gSC00C:	;-
gSC00D:	;^
gSC07D:	;\
gSC00E:	;\b
;　Ｄ段目
gSC00F:	;\t
gSC010:	;q
gSC011:	;w
gSC012:	;e
gSC013:	;r
gSC014:	;t
gSC015:	;y
gSC016:	;u
gSC017:	;i
gSC018:	;o
gSC019:	;p
gSC01A:	;@
gSC01B:	;[
; Ｃ段目
gSC01E:	;a
gSC01F:	;s
gSC020:	;d
gSC021:	;f
gSC022:	;g
gSC023:	;h
gSC024: ;j
gSC025: ;k
gSC026: ;l
gSC027: ;';'
gSC028: ;'*'
gSC02B: ;']'
gSC01C:	;Enter
;　Ｂ段目
gSC02C:	;z
gSC02D:	;x
gSC02E:	;c
gSC02F:	;v
gSC030:	;b
gSC031:	;n
gSC032:	;m
gSC033:	;,
gSC034:	;.
gSC035:	;/
gSC073:	;\
;Ａ段目
gSC01D:	;LCtrl
gSC07B:	;無変換キー（左）
gSC039:	;Space
gSC079:	;変換キー（右）
gSC070:	;ひらがな／カタカナ
gSC11D:	;RCtrl

gSC02A: ;左Shift
gSC15B: ;左Win
gSC038: ;左Alt
gSC138: ;右Alt
gSC15C: ;右Win
gSC15D: ;Applications
gSC136: ;右Shift
	critical
 	Gosub,ScanModifier
	g_layoutPos := layoutPosHash[A_ThisHotkey]
	g_KeyInPtn := getKeyinPtnFromQueue()
	kName := keyNameHash[g_layoutPos]
	if(kName=="LShift" || kName=="RShift") {
		g_Koyubi := "K"
	}	
	g_metaKey := keyAttribute3[g_Romaji . KoyubiOrSans(g_Koyubi,g_sans) . g_layoutPos]
	if(kName=="LShift" || kName=="RShift") {
		goto, keydown%g_metaKey%
	}	
	if(kName=="LCtrl") {	;左Ctrl
		g_Modifier |= 0x0200
		goto, keydown%g_metaKey%
	}
	if(kName=="RCtrl") {	;右Ctrl
		g_Modifier |= 0x0400
		goto, keydown%g_metaKey%
	}
	if(kName=="LAlt") {	;左Alt
		g_Modifier |= 0x0800
		goto, keydown%g_metaKey%
	}
	if(kName=="RAlt") {	;右Alt
		g_Modifier |= 0x1000
		goto, keydown%g_metaKey%
	}
	if(kName=="LWin") {	;左Win
		g_Modifier |= 0x2000
		goto, keydown%g_metaKey%
	}
	if(kName=="RWin") {	;右Win
		g_Modifier |= 0x4000
		goto, keydown%g_metaKey%
	}
	if(g_Modifier != 0) {
		GuiControl,2:,vkeyDN%g_layoutPos%,□
		RegLogs(kName . " down", g_KeyInPtn, g_trigger, g_Timeout, "")
		g_Timeout := ""
		Gosub,ModeInitialize
		; 修飾キー＋文字キーの同時押しのとき
		if(g_metaKey=="M" && kdn["ANN"]!="") {
			; 英数キー配列が定義されていればそれを出力
			SubSendOne(kdn["ANN" . g_layoutPos])
			SetKeyupSave(kup["ANN" . g_layoutPos],g_layoutPos)
		} else {
			SubSendOne(MnDown(kName))
			SetKeyupSave(MnUp(kName),g_layoutPos)
		}
		g_KeyInPtn := clearQueue()
		g_LastKey["表層"] := ""
		g_Timeout := 60000
		g_SendTick := INFINITE
		g_prefixshift := ""
		critical,off
		return
	}
	pf_TickCount := Pf_Count()
	if(keyState[g_layoutPos] != 0)
	{
		if((g_metaKey=="M" || g_metaKey=="S") && g_RepeatCount == 0 && pf_TickCount - keyTick[g_layoutPos]<g_MaxTimeoutM)
		{
			return
		}
		g_RepeatCount := g_RepeatCount + 1
	}
	GuiControl,2:,vkeyDN%g_layoutPos%,□
	goto, keydown%g_metaKey%

;----------------------------------------------------------------------
; キーオフのイベント
;----------------------------------------------------------------------
;　Ｈ段目
gSC135up:
gSC037up:
gSC04Eup:
gSC04Aup:
gSC11Cup:
gSC052up:
gSC04Fup:
gSC050up:
gSC051up:
gSC04Bup:
gSC04Cup:
gSC04Dup:
gSC047up:
gSC048up:
gSC049up:
gSC053up:
; Ｇ段目
gSC137up:	;PrintScreen
gSC046up:	;ScrollLock
gSC045up:	;Pause
gSC152up:
gSC147up:
gSC149up:
gSC153up:
gSC14Fup:
gSC151up:
gSC148up:
gSC14Bup:
gSC150up:
gSC14Dup:
; Ｆ段目
gSC001up:
gSC03Bup:
gSC03Cup:
gSC03Dup:
gSC03Eup:
gSC03Fup:
gSC040up:
gSC041up:
gSC042up:
gSC043up:
gSC044up:
gSC057up:
gSC058up:
; Ｅ段目
gSC029up:	;半角／全角
gSC002up:
gSC003up:
gSC004up:
gSC005up:
gSC006up:
gSC007up:
gSC008up:
gSC009up:
gSC00Aup:
gSC00Bup:
gSC00Cup:
gSC00Dup:
gSC07Dup:
gSC010up:
gSC00Eup:	;\b
; Ｄ段目
gSC00Fup:	;\t
gSC011up:	;w
gSC012up:	;e
gSC013up:	;r
gSC014up:	;t
gSC015up:	;y
gSC016up:	;u
gSC017up:	;i
gSC018up:	;o
gSC019up:	;p
gSC01Aup:	;@
gSC01Bup:	;[
; Ｃ段目
gSC01Eup:	;a
gSC01Fup:	;s
gSC020up:	;d
gSC021up:	;f
gSC022up:	;g
gSC023up:	;h
gSC024up:	;j
gSC025up:	;k
gSC026up:	;l
gSC027up:	;;
gSC028up:	;*
gSC02Bup:	;]
gSC01Cup:	;Enter
; Ｂ段目
gSC02Cup:	;z
gSC02Dup:	;x
gSC02Eup:	;c
gSC02Fup:	;v
gSC030up:	;b
gSC031up:	;n
gSC032up:	;m
gSC033up:	;,
gSC034up:	;.
gSC035up:	;/
gSC073up:	;_

gSC01Dup:	;LCtrl
gSC07Bup:	;無変換
gSC039up:	;Space
gSC079up:	;変換
gSC070up:	;ひらがな／カタカナ
gSC11Dup:	;RCtrl

gSC02Aup:	;左Shift
gSC15Bup:	;左Win
gSC038up:	;左Alt
gSC138up:	;右Alt
gSC15Cup:	;右Win
gSC15Dup:	;Applications
gSC136up:	;右Shift
	critical
	Gosub,ScanModifier
	g_layoutPos := layoutPosHash[A_ThisHotkey]
	g_KeyInPtn := getKeyinPtnFromQueue()
	kName := keyNameHash[g_layoutPos]
	if(kName=="LShift" || kName=="RShift") {
		g_Koyubi := "N"
	}
	g_metaKey := keyAttribute3[g_Romaji . KoyubiOrSans(g_Koyubi,g_sans) . g_layoutPos]
	if(kName=="LCtrl") {	;左Ctrl
		g_Modifier &= (~0x0200)
	}
	if(kName=="RCtrl") {	;右Ctrl
		g_Modifier &= (~0x0400)
	}
	if(kName=="LAlt") {	;左Alt
		g_Modifier &= (~0x0800)
	}
	if(kName=="RAlt") {	;右Alt
		g_Modifier &= (~0x1000)
	}
	if(kName=="LWin") {	;左Win
		g_Modifier &= (~0x2000)
	}
	if(kName=="RWin") {	;右Win
		g_Modifier &= (~0x4000)
	}
	GuiControl,2:,vkeyDN%g_layoutPos%,　
	gosub, keyup%g_metaKey%
	g_RepeatCount := 0
	return

