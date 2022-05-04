;-----------------------------------------------------------------------
;	名称：benizara / 紅皿
;	機能：Yet another NICOLA Emulaton Software
;         キーボード配列エミュレーションソフト
;	ver.0.1.4.9 .... 2022/5/4
;	作者：Ken'ichiro Ayaki
;-----------------------------------------------------------------------
	#InstallKeybdHook
	#MaxhotkeysPerInterval 400
	#KeyHistory
#SingleInstance, Off
	SetStoreCapsLockMode,Off
	StringCaseSense, On			; 大文字小文字を区別
	g_Ver := "ver.0.1.4.9"
	g_Date := "2022/5/4"
	MutexName := "benizara"
    If DllCall("OpenMutex", Int, 0x100000, Int, 0, Str, MutexName)
    {
		Traytip,キーボード配列エミュレーションソフト「紅皿」,多重起動は禁止されています。
        ExitApp
	}
    hMutex := DllCall("CreateMutex", Int, 0, Int, False, Str, MutexName)
	SetWorkingDir, %A_ScriptDir%

	idxLogs := 0
	aLogCnt := 0
	loop, 64
	{
		_idx := A_Index - 1
		aLog%_idx% := "_"
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
	g_metaKeyUp["1"] := "_1"
	g_metaKeyUp["2"] := "_2"
	g_metaKeyUp["A"] := "a"
	g_metaKeyUp["B"] := "b"
	g_metaKeyUp["C"] := "c"
	g_metaKeyUp["D"] := "d"

	g_MojiCount := Object()	; 親指キーシフトの文字押下カウンター
	g_MojiCount["R"] := 0
	g_MojiCount["L"] := 0
	g_MojiCount["A"] := 0
	g_MojiCount["B"] := 0
	g_MojiCount["C"] := 0
	g_MojiCount["D"] := 0

	g_RomajiOnHold := Object()
	g_KoyubiOnHold := Object()
	g_OyaOnHold := Object()
	g_MojiOnHold := Object()
	g_TDownOnHold := Object()
	g_TUpOnHold := Object()
	g_MetaOnHold := Object()
	g_OnHoldIdx := 0
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

	SetHotkey("off")
	SetHotkeyFunction("off")
	return

;-----------------------------------------------------------------------
;	メニューからの終了
;-----------------------------------------------------------------------
MenuExit:
	SetTimer,Interrupt10,off
	SetTimer,InterruptProcessPolling,off
	DllCall("ReleaseMutex", Ptr, hMutex)
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
	RegLogs(g_metaKey . " down")
	if(keyState[g_layoutPos] != 0 && (g_KeyRepeat == 1 || g_layoutPos == "A02"))
	{
	 	; キーリピートの処理
		g_Oya := g_metaKey
		enqueueKey(g_Romaji, g_Oya, KoyubiOrSans(g_Koyubi,g_sans), g_layoutPos, g_metaKey, g_OyaTick[g_metaKey])
		keyState[g_layoutPos] := 2
		keyTick[g_layoutPos] := g_OyaTick[g_Oya]
		Gosub, SendOnHoldO	; 保留キーの打鍵
		; 連続モードでなければ押されていない状態に
		if(g_Continue == 1)
		{
			g_SendTick := INFINITE
			g_KeyInPtn := g_Oya
		}
		critical,off
		return
	}
	if(keyState[g_layoutPos] == 0) 	; キーリピートの抑止
	{
		g_MojiCount[g_metaKey] := 0
		g_Oya := g_metaKey
		keyState[g_layoutPos] := 2
		keyTick[g_layoutPos] := g_OyaTick[g_Oya]
		if(g_KeyInPtn == "MM" || g_KeyInPtn == "MMm")
		{
			_mode := g_RomajiOnHold[1] . g_OyaOnHold[1] . g_KoyubiOnHold[1]
			if(kdn[_mode . g_MojiOnHold[2] . g_MojiOnHold[1]] == "") {
				Gosub, SendOnHoldM		; 保留した２文字前だけを打鍵してMオン状態に遷移
				if(g_KeyInPtn == "M") {
					SubSendUp(g_MojiOnHold[0])
					g_SendTick := SetTimeout("M")
				}
			} else {
				; ３キー判定
				g_Interval["M" . g_metaKey] := g_OyaTick[g_metaKey] - g_TDownOnHold[2]
				g_Interval["S12"]  := g_TDownOnHold[2] - g_TDownOnHold[1]	; 前回の文字キー押しからの期間
				if(g_Interval["S12"] < g_Interval["M" . g_metaKey]) {
					Gosub, SendOnHoldMM
					if(g_KeyInPtn == "M") {
						SubSendUp(g_MojiOnHold[0])
						g_SendTick := SetTimeout("M")
					}
				} else {
					Gosub, SendOnHoldM		; 保留した２文字前だけを打鍵してMオン状態に遷移
					if(g_KeyInPtn == "M") {
						SubSendUp(g_MojiOnHold[0])
						g_SendTick := SetTimeout("M")
					}
				}
			}
		}
		else if(g_KeyInPtn == "MMM")	; M1M2M3オン状態
		{
			Gosub, SendOnHoldMMM
		}
		
		if(g_KeyInPtn == "") 		;S1)初期状態
		{
			enqueueKey(g_Romaji, g_Oya, KoyubiOrSans(g_Koyubi,g_sans), g_layoutPos, g_metaKey, g_OyaTick[g_metaKey])
			g_KeyInPtn := g_Oya	;S3に遷移
			g_SendTick := SetTimeout(g_KeyInPtn)
		}
		else if(g_KeyInPtn == "M")	;S2)Mオン状態
		{
			g_Interval["M" . g_Oya] := g_OyaTick[g_Oya] - g_TDownOnHold[g_OnHoldIdx]
			if(g_Interval["M" . g_Oya] > minimum(floor((g_Threshold*(100-g_OverlapMO))/g_OverlapMO),g_MaxTimeout)) {
				Gosub, SendOnHoldM	; タイムアウト・保留キーの打鍵
				enqueueKey(g_Romaji, g_Oya, KoyubiOrSans(g_Koyubi,g_sans), g_layoutPos, g_metaKey, g_OyaTick[g_metaKey])
				g_KeyInPtn := g_Oya	;Oオンに遷移
				g_SendTick := SetTimeout(g_KeyInPtn)
			} else {
				g_MojiCount[g_Oya] := g_MojiCount[g_Oya] + 1
				enqueueKey(g_Romaji, g_Oya, KoyubiOrSans(g_Koyubi,g_sans), g_layoutPos, g_metaKey, g_OyaTick[g_metaKey])
				g_KeyInPtn := g_KeyInPtn . g_Oya	;MOオンに遷移
				g_SendTick := SetTimeout(g_KeyInPtn)
			}
		}
		else if(RegExMatch(g_KeyInPtn, "^[RLABCD]$")==1 && g_KeyInPtn!=g_Oya)	;S3)Oオン状態　（既に他の親指キーオン）
		{
			Gosub, SendOnHoldO	; 他の親指キー（保留キー）の打鍵
			g_Oya := g_metaKey
			enqueueKey(g_Romaji, g_Oya, KoyubiOrSans(g_Koyubi,g_sans), g_layoutPos, g_metaKey, g_OyaTick[g_metaKey])
			g_KeyInPtn := g_Oya				;S4)Oオンに遷移
			g_SendTick := SetTimeout(g_KeyInPtn)
		}
		else if(RegExMatch(g_KeyInPtn, "^M[RLABCD]$")==1 && g_KeyInPtn!="M" . g_Oya)	;S4)M-Oオン状態で反対側のOキーオン
		{
			Gosub, SendOnHoldMO	; 保留キーの打鍵
			g_Oya := g_metaKey
			
			enqueueKey(g_Romaji, g_Oya, KoyubiOrSans(g_Koyubi,g_sans), g_layoutPos, g_metaKey, g_OyaTick[g_metaKey])
			g_KeyInPtn := g_Oya	; S3)Oオンに遷移
			g_SendTick := SetTimeout(g_KeyInPtn)
		}
		else if(RegExMatch(g_KeyInPtn, "^[RLABCD]M$")==1 && g_KeyInPtn!=g_Oya . "M")	;S5)O-Mオン状態で反対側のOキーオン
		{
			g_currentOya := substr(g_KeyInPtn,1,1)
			; 処理B 3キー判定
			g_Interval[g_currentOya . "M"] := g_TDownOnHold[1] - g_OyaTick[g_currentOya]	; 他の親指キー押しから文字キー押しまでの期間
			g_Interval["M" . g_Oya] := g_OyaTick[g_Oya] - g_TDownOnHold[g_OnHoldIdx]	; 文字キー押しから当該親指キー押しまでの期間
			if(g_Interval["M" . g_Oya] > g_Interval[g_currentOya . "M"] || g_Continue==1)
			{
				Gosub, SendOnHoldMO	; 保留キーの打鍵　L,Rモードに遷移
				g_Oya := g_metaKey

				enqueueKey(g_Romaji, g_Oya, KoyubiOrSans(g_Koyubi,g_sans), g_layoutPos, g_metaKey, g_OyaTick[g_metaKey])
				g_KeyInPtn := g_Oya	; S3)Oオンに遷移
				g_SendTick := SetTimeout(g_KeyInPtn)
			}
			else
			{
				if(g_ZeroDelayOut!="")
				{
					CancelZeroDelayOut(g_ZeroDelay)
				}
				Gosub, SendOnHoldO	; 保留キーの打鍵, Mモードに遷移
				g_Oya := g_metaKey
				enqueueKey(g_Romaji, g_Oya, KoyubiOrSans(g_Koyubi,g_sans), g_layoutPos, g_metaKey, g_OyaTick[g_metaKey])
				g_KeyInPtn := "M" . g_Oya	; S4)M-Oオンに遷移
				g_SendTick := SetTimeout(g_KeyInPtn)
				SendZeroDelay(g_RomajiOnHold[2] . g_OyaOnHold[2] . g_KoyubiOnHold[2], g_MojiOnHold[1], g_ZeroDelay)
			}
		}
		else if(RegExMatch(g_KeyInPtn, "^(RMr|LMl|AMa|BMb|CMc|DMd)$")==1)	;S6)O-M-Oオフ状態
		{
			if(g_Continue == 0 && g_OnHoldIdx >= 2) {
				Gosub, SendOnHoldO		; 保留親指キーの単独打鍵
				g_Oya := g_metaKey
			}
			enqueueKey(g_Romaji, g_Oya, KoyubiOrSans(g_Koyubi,g_sans), g_layoutPos, g_metaKey, g_OyaTick[g_metaKey])
			g_KeyInPtn := g_KeyInPtn . g_Oya		; S3)Oオンに遷移
			g_SendTick := SetTimeout(g_KeyInPtn)
		}
	}
	if(RegExMatch(g_KeyInPtn, "^[RLABCD]$")==1)
	{
		g_SendTick := INFINITE
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
	loop,4
	{
		if(g_layoutPos == g_MojiOnHold[A_Index]) {
			g_TUpOnHold[A_Index] := g_OyaUpTick[g_metaKey]
		}
	}
	if(keyState[g_layoutPos] != 0)	; 親指シフトキーの単独シフト
	{
		RegLogs(g_metaKey . " up")
		
		if(g_Oya == g_metaKey) {
			if(g_KeyInPtn == g_Oya)		;S3)Oオン状態
			{
				Gosub, SendOnHoldO	;保留親指キーの打鍵
			}
			else if(g_KeyInPtn == "M" . g_Oya)	;S4)M-Oオン状態
			{
				g_Interval["M" . g_Oya] := g_OyaTick[g_Oya] - g_TDownOnHold[g_OnHoldIdx]
				g_Interval[g_Oya . "_" . g_Oya] := g_OyaTick[g_Oya] - g_OyaUpTick[g_Oya]
				g_Overlap := (g_Interval[g_Oya . "_" . g_Oya]*100)/(g_Interval["M" . g_Oya] + g_Interval[g_Oya . "_" . g_Oya])
				if(g_Overlap >= g_OverlapMO) {
					Gosub, SendOnHoldMO	; 保留キーの同時打鍵
				} else {
					Gosub, SendOnHoldM	; 保留キーの同時打鍵
					if(g_Continue == 0) {
						Gosub, SendOnHoldO		; 保留親指キーの単独打鍵
					}
				}
			}
			else if(g_KeyInPtn == g_Oya . "M")	;S5)O-Mオン状態
			{
				g_Interval["M_" . g_Oya] := g_OyaUpTick[g_Oya] - g_TDownOnHold[g_OnHoldIdx]	; 文字キー押しから右親指キー解除までの期間
				g_Interval[g_Oya . "_" . g_Oya] := g_OyaUpTick[g_Oya] - g_OyaTick[g_Oya]	; 右親指キー押しから右親指キー解除までの期間
				if(g_Continue == 1) {
					if(g_Interval["M_" . g_Oya] > g_Threshold || g_MojiCount[g_Oya] == 1)
					{
						; タイムアウト状態または親指シフト１文字目：親指シフト文字の出力
						Gosub, SendOnHoldMO	; 保留キーの打鍵
					} else {
						g_KeyInPtn := g_KeyInPtn . g_metaKeyUp[g_Oya]	;"RMr" "LMl"
						g_SendTick := SetTimeout(g_KeyInPtn)
					}
				} else {
					; 処理D
					vOverlap := floor((100*g_Interval["M_" . g_Oya])/g_Interval[g_Oya . "_" . g_Oya])
					if(vOverlap < g_OverlapOM && g_Interval["M_" . g_Oya] <= g_Tau)
					{
						g_KeyInPtn := g_KeyInPtn . g_metaKeyUp[g_Oya]	;"RMr" "LMl"
						g_SendTick := SetTimeout(g_KeyInPtn)
					} else {
						Gosub, SendOnHoldMO	; 保留キーの打鍵
					}
				}
			}
			;else if(g_KeyInPtn="M" || g_KeyInPtn="RMr" || g_KeyInPtn="LMl") ; S2)Mオン状態 S6)O-M-Oオフ状態
			;{
				; 何もしない
			;}
		}
	}
	SubSendUp(g_layoutPos)
	
	if(g_Oya == g_metaKey) {
		if(g_Continue == 1) {
			; 他の親指キーが押されていなければ N に設定
			_oyaOther := "RLABCD"
			loop, Parse, _oyaOther
			{
				if(A_LoopField == g_metaKey) 
				{
					continue
				}
				g_Oya := "N"
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
		} else {
			g_Oya := "N"
		}
	}
	g_MojiCount[g_metaKey] := 0
	critical,off
	sleep,-1
	return
;----------------------------------------------------------------------
; 最小値
;----------------------------------------------------------------------
minimum(val0, val1) {
	if(val0 > val1)
	{
		return val1
	}
	else
	{
		return val0
	}
}
;----------------------------------------------------------------------
; 最大値
;----------------------------------------------------------------------
maximum(val0, val1) {
	if(val0 < val1)
	{
		return val1
	}
	else
	{
		return val0
	}
}
;----------------------------------------------------------------------
; 零遅延モード出力のキャンセル
;----------------------------------------------------------------------
CancelZeroDelayOut(g_ZeroDelay) {
	global g_ZeroDelaySurface, g_ZeroDelayOut
	if(g_ZeroDelay == 1) {
		_len := StrLen(g_ZeroDelaySurface)
		loop, %_len%
		{
			SubSendOne(MnDown("BS"))
			SubSendOne(MnUp("BS"))
		}
	}
	g_ZeroDelaySurface := ""
	g_ZeroDelayOut := ""
}

;----------------------------------------------------------------------
; キーダウン時にSendする文字列を設定する
; 引数　：aStr：対応するキー入力
; 戻り値：Sendの引数
;----------------------------------------------------------------------
MnDown(aStr) {
	vOut := ""
	if(aStr!="")
	{
		vOut := "{" . aStr . " down}"
	}
	return vOut
}
;----------------------------------------------------------------------
; キーアップ時にSendする文字列を設定する
; 引数　：aStr：対応するキー入力
; 戻り値：Sendの引数
;----------------------------------------------------------------------
MnUp(aStr) {
	vOut := ""
	if(aStr!="")
	{
		vOut := "{" . aStr . " up}"
	}
	return vOut
}

;----------------------------------------------------------------------
; 送信文字列の出力
;----------------------------------------------------------------------
SubSend(vOut)
{
	global g_KeyInPtn, g_trigger
	global g_Koyubi

	_stroke := ""
	_scnt := 0
	_len := strlen(vOut)
	_cnt := 0
	_sendch := ""
	_bsflg := 0
	loop, Parse, vOut
	{
		_cnt := _cnt + 1
		_stroke := _stroke . A_LoopField
		StringLeft, _left2c, _stroke, 2
		if(A_LoopField == "}" && _left2c != "{}") {	; ストロークの終わり
			if(g_Koyubi=="K" && isCapsLock(_sendch)==true && instr(_storoke,"{vk")==0) {
				if(_scnt>=4) 
				{
					SetKeyDelay, 16,-1
					_scnt := 0
				} else {
					SetKeyDelay, -1,-1
				}
				Send, {blind}{capslock}
				_scnt := _scnt + 1
				RegLogs("       " . substr(g_KeyInPtn . "    ",1,4) . substr(g_trigger . "    ",1,4) . "{capslock}")
				if(instr(_stroke,"^{M")>0 || instr(_stroke,"{Enter")>0) {
					_scnt := _scnt + 4
				}
				if(_scnt>=4)
				{
					SetKeyDelay, 64,-1
					_scnt := 0
				} else {
					SetKeyDelay, -1,-1
				}
				Send, %_stroke%
				_scnt := _scnt + 1
				RegLogs("       " . substr(g_KeyInPtn . "    ",1,4) . substr(g_trigger . "    ",1,4) . _stroke)
				
				if(_scnt>=4) 
				{
					SetKeyDelay,16,-1
					_scnt := 0
				} else {
					SetKeyDelay,-1,-1
				}
				Send, {blind}{capslock}
				_scnt := _scnt + 1
				RegLogs("       " . substr(g_KeyInPtn . "    ",1,4) . substr(g_trigger . "    ",1,4) . "{capslock}")
			} else {
				if(instr(_stroke,"^{M")>0 || instr(_stroke,"{Enter")>0) {
					_scnt := _scnt + 4
				}
				if(_scnt>=4)
				{
					SetKeyDelay, 64,-1
					_scnt := 0
				} else {
					SetKeyDelay, -1,-1
				}
				Send, %_stroke%
				_scnt := _scnt + 1
				RegLogs("       " . substr(g_KeyInPtn . "    ",1,4) . substr(g_trigger . "    ",1,4) . _stroke)
			}
			_stroke := ""
			_sendch := ""
		}
		if(_sendch=="" && substr(_left2c,1,1)=="{") {
			_sendch := substr(_left2c,2,1)
		}
	}
	SetKeyDelay, -1,-1
	if(_stroke != "") {
		Send, %_stroke%
		RegLogs("       " . substr(g_KeyInPtn . "    ",1,4) . substr(g_trigger . "    ",1,4) . _stroke)
	}
}
;----------------------------------------------------------------------
; 送信文字列の出力・１つだけ
;----------------------------------------------------------------------
SubSendOne(vOut)
{
	global g_KeyInPtn, g_trigger
	if(vOut!="") {
		SetKeyDelay, -1,-1
		Send, {blind}%vOut%
		RegLogs("       " . substr(g_KeyInPtn . "    ",1,4) . substr(g_trigger . "    ",1,4) . vOut)
	}
}
;----------------------------------------------------------------------
; キーダウン時の出力コードを保存
;----------------------------------------------------------------------
SetKeyupSave(_kup,_layoutPos)
{
	global kup_save, keyState
	
	kup_save[_layoutPos] := _kup
	keyState[_layoutPos] := 1
}
;----------------------------------------------------------------------
; キーアップ時の出力コードを送信
;----------------------------------------------------------------------
SubSendUp(_layoutPos)
{
	global kup_save, keyState
	
	SubSendOne(kup_save[_layoutPos])
	kup_save[_layoutPos] := ""
	keyState[_layoutPos] := 0
}

;----------------------------------------------------------------------
;	capslockが必要か
;----------------------------------------------------------------------
isCapsLock(_ch)
{
	_code := ASC(_ch)
	if(0x61<= _code && 0x7A <=_code) {
		return true
	}
	if(instr("1234567890-^\@[;:],./\", _ch)>0) {
		return true
	}
	return false
}
;----------------------------------------------------------------------
; キーから送信文字列に変換
;----------------------------------------------------------------------
MnDownUp(key)
{
	if(key!="")
		return "{" . key . " down}{" . key . " up}"
	else
		return ""
}
;----------------------------------------------------------------------
; ログ保存
;----------------------------------------------------------------------
RegLogs(thisLog)
{
	global aLog, idxLogs, aLogCnt
	static tickLast
	
	tickCount := Pf_Count()

	;SetFormat Integer,D
	_timeSinceLastLog := tickCount - tickLast
	_tmp := SubStr("      ",1,6-StrLen(_timeSinceLastLog)) . _timeSinceLastLog
	aLog%idxLogs% := _tmp . " " . thisLog
	idxLogs := idxLogs + 1
	idxLogs := idxLogs & 63
	if(aLogCnt < 64)
	{
		aLogCnt := aLogCnt + 1
	} else {
		aLogCnt := 64
	}
	tickLast := tickCount
}

;----------------------------------------------------------------------
; 保留キーの出力：セットされた文字のセットされた親指の出力
;----------------------------------------------------------------------
SendOnHoldMO:
	cntM := countMoji()
	if(g_OnHoldIdx < 1) {
		clearQueue()
		return
	}
	if(cntM >= 1) {
		if(g_MetaOnHold[1]=="M" && RegExMatch(g_MetaOnHold[2], "^[RLABCD]$")==1)
		{
			_mode := g_RomajiOnHold[2] . g_OyaOnHold[2] . g_KoyubiOnHold[2]
			SendOnHold(_mode, g_MojiOnHold[1], g_ZeroDelay)
			dequeueKey()
			dequeueKey()
			clearQueue()
		} else
		if(RegExMatch(g_MetaOnHold[1], "^[RLABCD]$")==1 && g_MetaOnHold[2]=="M")
		{
			_mode := g_RomajiOnHold[1] . g_OyaOnHold[1] . g_KoyubiOnHold[1]
			SendOnHold(_mode, g_MojiOnHold[2], g_ZeroDelay)
			dequeueKey()
			dequeueKey()
			clearQueue()
		} else
		if(g_MetaOnHold[1]=="M") {
			_mode := g_RomajiOnHold[1] . g_OyaOnHold[1] . g_KoyubiOnHold[1]
			SendOnHold(_mode, g_MojiOnHold[1], g_ZeroDelay)
			dequeueKey()
			clearQueue()
		}
	} else {
		; debugging
		clearQueue()
	}
	g_SendTick := INFINITE
	g_KeyInPtn := ""
	if(g_Continue == 0) {
		g_Oya := "N"
	}
	return

;----------------------------------------------------------------------
; 保留キーの出力関数：
; _mode : モードまたは文字同時打鍵の第１文字
; _MojiOnHold : 現在の打鍵文字の場所 A01-E14
;----------------------------------------------------------------------
SendOnHold(_mode, _MojiOnHold, g_ZeroDelay)
{
	global kdn, kup, kup_save, g_ZeroDelayOut, g_ZeroDelaySurface, kLabel, kst
	global g_LastKey, g_Koyubi, g_KeyOnHold

	g_KeyOnHold := GetPushedKeys()
	_MojiOnHoldLast := substr(_MojiOnHold,strlen(_MojiOnHold)-2)
	
	if(strlen(_MojiOnHold)==3 && strlen(g_KeyOnHold)==6 && kdn[_mode . g_KeyOnHold . _MojiOnHold] != "") {
		_MojiOnHold := g_KeyOnHold . _MojiOnHold
	} else
	if(strlen(_MojiOnHold)==3 && strlen(g_KeyOnHold)==3 && kdn[_mode . g_KeyOnHold . _MojiOnHold] != "") {
		_MojiOnHold := g_KeyOnHold . _MojiOnHold
	} else
	if(strlen(_MojiOnHold)==6 && strlen(g_KeyOnHold)==3 && kdn[_mode . g_KeyOnHold . _MojiOnHold] != "") {
		_MojiOnHold := g_KeyOnHold . _MojiOnHold
	}
	vOut := kdn[_mode . _MojiOnHold]
	kup_save[_MojiOnHoldLast] := kup[_mode . _MojiOnHold]
	_nextKey := nextDakuten(_mode,_MojiOnHold)
	if(_nextKey != "") {
		g_LastKey["表層"] := _nextKey
		_aStr := "後" . g_LastKey["表層"]
		GenSendStr3(_mode, _aStr, _down, _up, _status)
		vOut                   := _down
		kup_save[_MojiOnHoldLast]  := _up
	} else {
		g_LastKey["表層"] := kLabel[_mode . _MojiOnHold]
	}
	if(g_ZeroDelay == 1)
	{
		if(vOut!=g_ZeroDelayOut)
		{
			CancelZeroDelayOut(g_ZeroDelay)
			SubSend(vOut)
		}
		g_ZeroDelayOut := ""
		g_ZeroDelaySurface := ""
	} else {
		SubSend(vOut)
	}
}

;----------------------------------------------------------------------
; タイムアウト時間を設定
;----------------------------------------------------------------------
SetTimeout(_KeyInPtn)
{
	global g_TDownOnHold, g_OnHoldIdx, g_Threshold, g_OverlapMO, g_OverlapOM, g_MaxTimeout
	global g_SimulMode, g_ThresholdSS, g_OverlapSS, INFINITE, g_Interval
	global g_OyaTick, g_OyaUpTick, g_Oya, g_MojiCount
	global ksc, g_RomajiOnHold, g_OyaOnHold, g_KoyubiOnHold, g_MojiOnHold

	_mode := g_RomajiOnHold[1] . g_OyaOnHold[1] . g_KoyubiOnHold[1]	
	
	_SendTick := INFINITE
	if(_KeyInPtn=="") {
		_SendTick := INFINITE
	} else 
	if(_KeyInPtn=="M") {
		if(ksc[_mode . g_MojiOnHold[1]]<=1) {
			_SendTick := g_TDownOnHold[g_OnHoldIdx] + minimum(floor((g_Threshold*(100-g_OverlapMO))/g_OverlapMO),g_MaxTimeout)
			if(CountObject(g_SimulMode)!=0) {
				; 文字同時打鍵があればタイムアウトの大きい方に合わせる
				_SendTick := maximum(_SendTick, g_TDownOnHold[g_OnHoldIdx] + minimum(floor((g_ThresholdSS*(100-g_OverlapSS))/g_OverlapSS),g_MaxTimeout))
			}
		}
	} else
	if(_KeyInPtn=="MM") 
	{
		if(ksc[_mode . g_MojiOnHold[2] . g_MojiOnHold[1]]<=2) {
			_SendTick := g_TDownOnHold[g_OnHoldIdx] + maximum(g_ThresholdSS,g_Threshold)
		}
	} else
	if(_KeyInPtn=="MMm") 
	{
		g_Interval["S12"]  := g_TDownOnHold[2] - g_TDownOnHold[1]	; 最初の文字だけをオンしていた期間
		g_Interval["S2_1"] := g_TUpOnHold[1] - g_TDownOnHold[2]		; 前回の文字キー押しからの重なり期間
		_SendTick := g_TUpOnHold[1] + minimum(floor((g_Interval["S2_1"]*(100-g_OverlapSS))/g_OverlapSS)-g_Interval["S12"],g_MaxTimeout)
	} else
	if(_KeyInPtn=="MMM") 
	{
		_SendTick := g_TDownOnHold[g_OnHoldIdx]
	} else
	if(RegExMatch(g_KeyInPtn, "^[RLABCD]$")==1)
	{
		_SendTick := INFINITE	;g_OyaTick[g_Oya] + minimum(floor((g_Threshold*(100-g_OverlapOM))/g_OverlapOM),g_MaxTimeout)
	} else
	if(RegExMatch(g_KeyInPtn, "^[RLABCD]M$")==1)
	{
		if(g_MojiCount[g_Oya]==1) {
			g_Interval[g_Oya . "M"] := g_TDownOnHold[g_OnHoldIdx] - g_OyaTick[g_Oya]
			_SendTick := g_TDownOnHold[g_OnHoldIdx] + minimum(floor(g_Interval[g_Oya . "M"]*g_OverlapOM/(100-g_OverlapOM)),g_MaxTimeout)
		} else {
			_SendTick := g_TDownOnHold[g_OnHoldIdx] + minimum(g_Threshold,g_MaxTimeout)
		}
	} else
	if(RegExMatch(g_KeyInPtn, "^M[RLABCD]$")==1)
	{
		g_Interval["M" . g_Oya] := g_OyaTick[g_Oya] - g_TDownOnHold[g_OnHoldIdx]
		_SendTick := g_OyaTick[g_Oya] + minimum(floor(g_Interval["M" . g_Oya]*g_OverlapMO/(100-g_OverlapMO)),g_MaxTimeout)
	} else
	if(RegExMatch(g_KeyInPtn, "^(RMr|LMl|AMa|BMb|CMc|DMd)$")==1)
	{
		g_Interval["M_" . g_Oya] := g_OyaUpTick[g_Oya] - g_TDownOnHold[g_OnHoldIdx]	; 文字キー押しから右親指キー解除までの期間
		_SendTick := g_OyaUpTick[g_Oya] + minimum(floor((g_Interval["M_" . g_Oya]*(100-g_OverlapOM))/g_OverlapOM),g_MaxTimeout)
	}
	return _SendTick
}
;----------------------------------------------------------------------
; 保留キーの出力：セットされた文字の出力
;----------------------------------------------------------------------
SendOnHoldM:
	cntM := countMoji()
	if(g_OnHoldIdx < 1) {
		clearQueue()
		return
	}
	; debugging 
	if(cntM >= 1) {
		if(g_OnHoldIdx >= 2
		&& (RegExMatch(g_MetaOnHold[1], "^[RLABCD]$")==1 && g_MetaOnHold[2]=="M"))
		{
			_mode := g_RomajiOnHold[1] . g_OyaOnHold[1] . g_KoyubiOnHold[1]
			dequeueKey()
		} else
		if(g_MetaOnHold[1]=="M") {
			_mode := g_RomajiOnHold[1] . g_OyaOnHold[1] . g_KoyubiOnHold[1]
		}
		SendOnHold(_mode, g_MojiOnHold[1], g_ZeroDelay)
		dequeueKey()
		g_SendTick := INFINITE
		if(RegExMatch(g_KeyInPtn, "^M[RLABCD]$")==1) {
			g_keyInPtn := substr(g_keyInPtn,2,1)
		}
		else if(g_KeyInPtn=="M")
		{
			clearQueue()
			g_keyInPtn := ""		
		}
		else if(RegExMatch(g_KeyInPtn, "^(RMr|LMl|AMa|BMb|CMc|DMd)$")==1)
		{
			g_keyInPtn := ""
		}
		else if(g_KeyInPtn=="MM" || g_KeyInPtn=="MMm")
		{
			g_keyInPtn := "M"
		}
		else if(g_KeyInPtn=="MMM")
		{
			g_keyInPtn := "MM"
		}
	} else {
		; 不具合対策
		clearQueue()
		g_keyInPtn := ""
	}
	return

;----------------------------------------------------------------------
; 文字キー出力後のリセット
;----------------------------------------------------------------------
dequeueKey()
{
	global g_RomajiOnHold, g_OyaOnHold, g_KoyubiOnHold, g_MojiOnHold, g_OnHoldIdx
	global g_TDownOnHold, g_TUpOnHold, g_MetaOnHold
	global keyState

	if(g_OnHoldIdx > 4) {
		g_OnHoldIdx := 4
	}
	if(keyState[g_MojiOnHold[1]] == 2) {
		keyState[g_MojiOnHold[1]] := 1
	}
	loop,4
	{
		if(A_Index <= g_OnHoldIdx) {
			g_RomajiOnHold[A_Index-1] := g_RomajiOnHold[A_Index]
			g_OyaOnHold[A_Index-1]    := g_OyaOnHold[A_Index]
			g_KoyubiOnHold[A_Index-1] := g_KoyubiOnHold[A_Index]
			g_MojiOnHold[A_Index-1]   := g_MojiOnHold[A_Index]
			g_TDownOnHold[A_Index-1]  := g_TDownOnHold[A_Index]
			g_TUpOnHold[A_Index-1]    := g_TUpOnHold[A_Index]
			g_MetaOnHold[A_Index-1]   := g_MetaOnHold[A_Index]
		} else {
			g_RomajiOnHold[A_Index-1] := ""
			g_OyaOnHold[A_Index-1]    := ""
			g_KoyubiOnHold[A_Index-1] := ""
			g_MojiOnHold[A_Index-1]   := ""
			g_TDownOnHold[A_Index-1]  := 0
			g_TUpOnHold[A_Index-1]    := 0
			g_MetaOnHold[A_Index-1]   := ""
		}
	}
	if(g_OnHoldIdx > 0) {
		g_OnHoldIdx := g_OnHoldIdx - 1
	} 
	return g_OnHoldIdx
}
;----------------------------------------------------------------------
; 文字キーをキューにセット
;----------------------------------------------------------------------
enqueueKey(_Romaji, _Oya, _Koyubi, _Moji, _Meta, _Tick)
{
	global g_RomajiOnHold, g_OyaOnHold, g_KoyubiOnHold, g_MojiOnHold, g_OnHoldIdx
	global g_TDownOnHold, g_TUpOnHold, g_MetaOnHold
	if(g_OnHoldIdx < 0) {
		g_OnHoldIdx := 0
	}
	g_OnHoldIdx := g_OnHoldIdx + 1
	while(g_OnHoldIdx > 4) {
		dequeueKey()
	}
	g_RomajiOnHold[g_OnHoldIdx] := _Romaji
	g_OyaOnHold[g_OnHoldIdx]    := _Oya
	g_KoyubiOnHold[g_OnHoldIdx] := _Koyubi
	g_MojiOnHold[g_OnHoldIdx]   := _Moji
	g_TDownOnHold[g_OnHoldIdx]  := _Tick
	g_MetaOnHold[g_OnHoldIdx]   := _Meta
	g_TUpOnHold[g_OnHoldIdx]    := 0
	return g_OnHoldIdx
}
;----------------------------------------------------------------------
; 文字キーのOMを１つにマージ
;----------------------------------------------------------------------
mergeOMKey()
{
	global g_OnHoldIdx
	global g_TDownOnHold, g_TUpOnHold, g_MetaOnHold, g_MojiOnHold
	
	if(g_OnHoldIdx==2) {
		g_RomajiOnHold[2] := g_RomajiOnHold[1]
		g_OyaOnHold[2]    := g_OyaOnHold[1]
		g_KoyubiOnHold[2] := g_KoyubiOnHold[1]
		dequeueKey()
	}
}
;----------------------------------------------------------------------
; 文字キーのMOを１つにマージ
;----------------------------------------------------------------------
mergeMOKey()
{
	global g_OnHoldIdx
	global g_MetaOnHold, g_MojiOnHold, g_TDownOnHold, g_TUpOnHold
	
	if(g_OnHoldIdx==2) {
		g_MetaOnHold[2]   := g_MetaOnHold[1]
		g_MojiOnHold[2]   := g_MojiOnHold[1]
		g_TDownOnHold[2]  := g_TDownOnHold[1]
		g_TUpOnHold[2]    := g_TUpOnHold[1]			
		dequeueKey()
	}
}

;----------------------------------------------------------------------
; 文字キーキューの全クリア
;----------------------------------------------------------------------
clearQueue()
{
	global g_RomajiOnHold, g_OyaOnHold, g_KoyubiOnHold, g_MojiOnHold, g_OnHoldIdx
	global g_TDownOnHold, g_TUpOnHold, g_MetaOnHold
	global keyState
	
	loop,4
	{
		g_RomajiOnHold[A_Index] := ""
		g_OyaOnHold[A_Index]    := ""
		g_KoyubiOnHold[A_Index] := ""
		if(keyState[g_MojiOnHold[A_Index]] == 2) {
			keyState[g_MojiOnHold[A_Index]] := 1
		}
		g_MojiOnHold[A_Index]   := ""
		g_TDownOnHold[A_Index]  := 0
		g_TUpOnHold[A_Index]    := 0
		g_MetaOnHold[A_Index]   := 0
	}
	g_OnHoldIdx := 0
}

;----------------------------------------------------------------------
; 押されている文字キーの取得
;----------------------------------------------------------------------
GetMojiOnHold()
{
	global g_MojiOnHold, g_OnHoldIdx, g_MetaOnHold
	
	_Moji := ""
	loop,% g_OnHoldIdx
	{
		if(g_MetaOnHold[A_Index]=="M") {
			_Moji := _Moji . g_MojiOnHold[A_Index]
		}
	}
	return _Moji
}

;----------------------------------------------------------------------
; キュー中の文字数
;----------------------------------------------------------------------
countMoji()
{
	global g_OnHoldIdx
	global g_MetaOnHold

	cntM := 0
	loop,% g_OnHoldIdx
	{
		if(g_MetaOnHold[A_Index]=="M") {
			cntM := cntM + 1
		}
	}
	return cntM
}

;----------------------------------------------------------------------
; 保留キーの出力：セットされた文字の出力
;----------------------------------------------------------------------
SendOnHoldMM:
	cntM := countMoji()
	if(g_OnHoldIdx < 1) {
		clearQueue()
		g_SendTick := INFINITE
		g_keyInPtn := ""
		return
	}
	else if(cntM == 1) {
		Gosub, SendOnHoldM
		clearQueue()
		g_SendTick := INFINITE
		g_keyInPtn := ""
		return
	}
	if(cntM >= 2) {
		if(g_OnHoldIdx >= 3
		&& RegExMatch(g_MetaOnHold[1], "^[RLABCD]$")==1 
		&& g_MetaOnHold[2]=="M" && g_MetaOnHold[3]=="M")
		{
			g_RomajiOnHold[2] := g_RomajiOnHold[1]
			g_OyaOnHold[2]    := g_OyaOnHold[1]
			g_KoyubiOnHold[2] := g_KoyubiOnHold[1]
			dequeueKey()
		}
		_mode := g_RomajiOnHold[1] . g_OyaOnHold[1] . g_KoyubiOnHold[1]
		if(kdn[_mode . g_MojiOnHold[2] . g_MojiOnHold[1]] != "") {
			SendOnHold(_mode, g_MojiOnHold[2] . g_MojiOnHold[1], g_ZeroDelay)
			dequeueKey()
			dequeueKey()
			g_SendTick := INFINITE
			g_keyInPtn := ""
		} else {
			Gosub, SendOnHoldM
			g_keyInPtn := "M"
		}
	} else {
		Gosub, SendOnHoldM
		g_keyInPtn := "M"
	}
	return

;----------------------------------------------------------------------
; 保留キーの出力：セットされた文字の出力
;----------------------------------------------------------------------
SendOnHoldMMM:
	cntM := countMoji()
	if(g_OnHoldIdx < 1) {
		clearQueue()
		g_SendTick := INFINITE
		g_keyInPtn := ""
		return
	}
	else if(cntM == 1) {
		Gosub, SendOnHoldM
		return
	}
	else if(cntM == 2) {
		Gosub, SendOnHoldMM
		if(g_KeyInPtn == "M") {
			SubSendUp(g_MojiOnHold[0])
			Gosub, SendOnHoldM
		}
		return
	}
	; 異常時の対処
	if(RegExMatch(g_MetaOnHold[1], "^[RLABCD]$")==1 
	&& g_MetaOnHold[2]=="M" && g_MetaOnHold[3]=="M" && g_MetaOnHold[4]=="M")
	{
		g_RomajiOnHold[2] := g_RomajiOnHold[1]
		g_OyaOnHold[2]    := g_OyaOnHold[1]
		g_KoyubiOnHold[2] := g_KoyubiOnHold[1]
		dequeueKey()
	}
	_mode := g_RomajiOnHold[1] . g_OyaOnHold[1] . g_KoyubiOnHold[1]
	if(kdn[_mode . g_MojiOnHold[3] . g_MojiOnHold[2] . g_MojiOnHold[1]] != "") {
		SendOnHold(_mode, g_MojiOnHold[3] . g_MojiOnHold[2] . g_MojiOnHold[1], g_ZeroDelay)	
		clearQueue()
		g_SendTick := INFINITE
		g_keyInPtn := ""
	} else
	if(kdn[_mode . g_MojiOnHold[2] . g_MojiOnHold[1]] != "") {
		SendOnHold(_mode, g_MojiOnHold[2] . g_MojiOnHold[1], g_ZeroDelay)
		dequeueKey()
		dequeueKey()
		SubSendUp(g_MojiOnHold[0])
		Gosub,SendOnHoldM
		clearQueue()
		g_keyInPtn := ""
		return
	} else {
		SendOnHold(_mode, g_MojiOnHold[1], g_ZeroDelay)
		dequeueKey()
		SubSendUp(g_MojiOnHold[0])
		Gosub,SendOnHoldMM
		if(g_KeyInPtn == "M") {
			SubSendUp(g_MojiOnHold[0])
			Gosub,SendOnHoldM
			clearQueue()
			g_keyInPtn := ""
		}
	}
	return

;----------------------------------------------------------------------
; 保留された親指キーの出力
; 2020/10/16 : スペースキーをホールドしているときは単独打鍵する
;----------------------------------------------------------------------
SendOnHoldO:
	if(RegExMatch(g_MetaOnHold[1], "^[RLABCD]$")==1) 
	{
		if(g_KeySingle == "有効" || g_MojiOnHold[1] == "A02") {
			vOut := kdn[g_RomajiOnHold[1] . g_OyaOnHold[1] . g_KoyubiOnHold[1] . g_MojiOnHold[1]]
			SubSendOne(vOut)
			SetKeyupSave(kup[g_RomajiOnHold[1] . g_OyaOnHold[1] . g_KoyubiOnHold[1] . g_MojiOnHold[1]],g_MojiOnHold[1])
		}
		dequeueKey()
		if(RegExMatch(g_KeyInPtn, "^(RMr|LMl|AMa|BMb|CMc|DMd)$")==1
		|| RegExMatch(g_KeyInPtn, "^[RLABCD]M$")==1
		|| RegExMatch(g_KeyInPtn, "^M[RLABCD]$")==1)
		{
			g_keyInPtn := "M"
		}
		else if(RegExMatch(g_KeyInPtn, "^[RLABCD]$")==1)
		{
			g_keyInPtn := ""
		}
	} else
	if(RegExMatch(g_KeyInPtn, "^[RLABCD]M$")==1)
	{
		g_OyaOnHold[1] := "N"
		g_keyInPtn := "M"
	}
	; debugging 
	if(RegExMatch(g_MetaOnHold[1], "^[RLABCD]$")==1)
	{
		dequeueKey()
	}
	if(g_Continue == 0) 
	{
		g_Oya := "N"
	}
	return


;----------------------------------------------------------------------
; 文字キー押下
;----------------------------------------------------------------------
keydownM:
	g_trigger := g_metaKey
	keyTick[g_layoutPos] := Pf_Count()
	RegLogs(kName . " down")
	keyState[g_layoutPos] := 2
	g_sansTick := INFINITE
	if(keyState[g_sansPos]==2) {
		keyState[g_sansPos] := 1
	}
	if(ShiftMode[g_Romaji] == "プレフィックスシフト") {
		if(g_prefixshift != "" )
		{
			SendKey(g_Romaji . g_prefixshift . KoyubiOrSans(g_Koyubi,g_sans), g_layoutPos)
			g_SendTick := INFINTE
			g_prefixshift := ""
			critical,off
			return
		}
		SendKey(g_Romaji . "N" . KoyubiOrSans(g_Koyubi,g_sans), g_layoutPos)
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
	if(g_KeyInPtn=="M")		;S5)O-Mオン状態
	{
		; M2キー押下
		if(g_MetaOnHold[1]=="M") {
			_mode := g_RomajiOnHold[1] . g_OyaOnHold[1] . g_KoyubiOnHold[1]
			if(ksc[_mode . g_layoutPos]<=1 
			|| (ksc[_mode . g_layoutPos]==2 && kdn[_mode . g_MojiOnHold[1] . g_layoutPos]=="")
			|| ksc[_mode . g_MojiOnHold[1] . g_layoutPos]==0) {
				; 保留中の１文字を確定（出力）
				Gosub, SendOnHoldM
			}
		}
	}
	else
	if(RegExMatch(g_KeyInPtn, "^[RLABCD]M$")==1)	;S5)O-Mオン状態
	{
		; M2キー押下
		if(g_MetaOnHold[1]=="M") {
			_mode := g_RomajiOnHold[1] . g_OyaOnHold[1] . g_KoyubiOnHold[1]
			if(ksc[_mode . g_layoutPos]<=1 
			|| (ksc[_mode . g_layoutPos]==2 && kdn[_mode . g_MojiOnHold[1] . g_layoutPos]=="")
			|| ksc[_mode . g_MojiOnHold[1] . g_layoutPos]==0) {
				; 保留中の１文字を確定（出力）
				Gosub, SendOnHoldMO
			}
		} else 
		if(g_MetaOnHold[2]=="M") {
			_mode := g_RomajiOnHold[1] . g_OyaOnHold[1] . g_KoyubiOnHold[1]
			if(ksc[_mode . g_layoutPos]<=1 
			|| (ksc[_mode . g_layoutPos]==2 && kdn[_mode . g_MojiOnHold[2] . g_layoutPos]=="")
			|| ksc[_mode . g_MojiOnHold[1] . g_layoutPos]==0) {
				; 保留中の１文字を確定（出力）
				Gosub, SendOnHoldMO
			} else {
				; 3キー判定
				g_Interval[g_Oya . "M"] := g_TDownOnHold[g_OnHoldIdx] - g_OyaTick[g_Oya]
				g_Interval["S12"] := keyTick[g_layoutPos] - g_TDownOnHold[g_OnHoldIdx]	; 前回の文字キー押しからの期間
				if(g_Interval[g_Oya . "M"] < g_Interval["S12"]) {
					Gosub, SendOnHoldMO		; 保留キーの同時打鍵
				} else {
					Gosub, SendOnHoldO
				}
			}
		}
	}
	else if(g_KeyInPtn == "MM") {
		; M3 キー押下
		_mode := g_RomajiOnHold[1] . g_OyaOnHold[1] . g_KoyubiOnHold[1]
		if(ksc[_mode . g_layoutPos]<=2 || (ksc[_mode . g_layoutPos]==3 && kdn[_mode . g_MojiOnHold[2] . g_MojiOnHold[1] . g_layoutPos] == "")) {
			g_Interval["S12"] := g_TDownOnHold[2] - g_TDownOnHold[1]	; 前回の文字キー押しからの期間
			g_Interval["S23"] := keyTick[g_layoutPos] - g_TDownOnHold[2]	; 前回の文字キー押しからの期間　３キー判定
			if(kdn[_mode . g_MojiOnHold[2] . g_MojiOnHold[1]]!="" && g_Interval["S12"] < g_Interval["S23"]) {
				; 保留中の同時打鍵を確定
				Gosub, SendOnHoldMM		; ２文字を同時打鍵として出力して初期状態に
				SubSendUp(g_MojiOnHold[0])
			} else {
				Gosub, SendOnHoldM		; 保留した２文字前だけを打鍵してMオン状態に遷移
				SubSendUp(g_MojiOnHold[0])
			}
		}
	}
	else if(g_KeyInPtn == "MMm") {
		g_Interval["S12"] := g_TDownOnHold[2] - g_TDownOnHold[1]	; 前回の文字キー押しからの期間
		g_Interval["S23"] := keyTick[g_layoutPos] - g_TDownOnHold[2]	; 前回の文字キー押しからの期間　３キー判定
		_mode := g_RomajiOnHold[1] . g_OyaOnHold[1] . g_KoyubiOnHold[1]
		if(kdn[_mode . g_MojiOnHold[2] . g_MojiOnHold[1]]!="" && g_Interval["S12"] < g_Interval["S23"]) {
			; 保留中の同時打鍵を確定
			Gosub, SendOnHoldMM		; ２文字を同時打鍵として出力して初期状態に
			SubSendUp(g_MojiOnHold[0])
		} else {
			Gosub, SendOnHoldM		; 保留した２文字前だけを打鍵してMオン状態に遷移
			SubSendUp(g_MojiOnHold[0])
		}
	}
	else if(g_KeyInPtn == "MMM") {
		; 同時打鍵を確定
		Gosub, SendOnHoldMMM	;３文字を同時打鍵として出力して初期状態に
	}
	else if(g_KeyInPtn="M" . g_Oya)	; S4)M-Oオン状態
	{
		; 処理A 3キー判定
		g_Interval[g_Oya . "M"] := keyTick[g_layoutPos] - g_OyaTick[g_Oya]
		g_Interval["M" . g_Oya] := g_OyaTick[g_Oya] - g_TDownOnHold[g_OnHoldIdx]
		if(g_Interval[g_Oya . "M"] <= g_Interval["M" . g_Oya])	; 文字キーaから親指キーsまでの時間は、親指キーsから文字キーbまでの時間よりも長い
		{
			g_OyaOnHold[1] := "N"
			Gosub, SendOnHoldM		; 保留キーの単独打鍵
		} else {
			Gosub, SendOnHoldMO		; 保留キーの同時打鍵
		}
	}
	else if(RegExMatch(g_KeyInPtn, "^(RMr|LMl|AMa|BMb|CMc|DMd)$")==1)	;S6)O-M-Oオフ状態
	{
		if(g_MojiOnHold[g_OnHoldIdx]!="") {
			if(g_Continue == 0 && g_OnHoldIdx >= 2) {
				Gosub, SendOnHoldO		; 保留親指キーの単独打鍵
			}
			g_OyaOnHold[1] := "N"
			Gosub, SendOnHoldM		; 保留文字キーの単独打鍵
		}
	}
	;SetKeyDelay, -1
	Gosub,ChkIME

	if(g_Oya=="N")
	{
		if(g_KeyInPtn=="") {
			; 当該キーを単独打鍵として保留
			enqueueKey(g_Romaji, g_Oya, KoyubiOrSans(g_Koyubi,g_sans), g_layoutPos, g_metaKey, keyTick[g_layoutPos])
			g_KeyInPtn := "M"
			g_SendTick := SetTimeout(g_KeyInPtn)

			; 連続打鍵の判定 
			JudgePushedKeys(g_RomajiOnHold[1] . g_OyaOnHold[1] . g_KoyubiOnHold[1], g_MojiOnHold[1])
			if(g_keyInPtn == "M") {
				SendZeroDelay(g_RomajiOnHold[1] . g_OyaOnHold[1] . g_KoyubiOnHold[1], g_MojiOnHold[1], g_ZeroDelay)
			}
		}
		else if(g_KeyInPtn=="M")	; S2)Mオン状態
		{
			enqueueKey(g_Romaji, g_Oya, KoyubiOrSans(g_Koyubi,g_sans), g_layoutPos, g_metaKey, keyTick[g_layoutPos])
			; 当該キーとその前を同時打鍵として保留
			g_KeyInPtn := "MM"
			g_SendTick := SetTimeout(g_KeyInPtn)
			; 連続打鍵の判定 
			JudgePushedKeys(g_RomajiOnHold[1] . g_OyaOnHold[1] . g_KoyubiOnHold[1], g_MojiOnHold[2] . g_MojiOnHold[1])
		}
		else if(g_KeyInPtn=="MM")	; MMオン状態
		{
			enqueueKey(g_Romaji, g_Oya, KoyubiOrSans(g_Koyubi,g_sans), g_layoutPos, g_metaKey, keyTick[g_layoutPos])
			
			; 当該キーとその前を同時打鍵として保留
			g_KeyInPtn := "MMM"
			g_SendTick := SetTimeout(g_KeyInPtn)
			
			GoSub, SendOnHoldMMM
			clearQueue()
			g_SendTick := INFINITE
			g_keyInPtn := ""
		}
	}
	else
	{
		g_MojiCount[g_Oya] := g_MojiCount[g_Oya] + 1
		if(g_KeyInPtn==g_Oya || g_KeyInPtn=="") {
			enqueueKey(g_Romaji, g_Oya, KoyubiOrSans(g_Koyubi,g_sans), g_layoutPos, g_metaKey, keyTick[g_layoutPos])
			g_KeyInPtn := g_Oya . "M"
			g_SendTick := SetTimeout(g_KeyInPtn)

			; 連続打鍵の判定 
			JudgePushedKeys(g_RomajiOnHold[1] . g_OyaOnHold[1] . g_KoyubiOnHold[1], g_MojiOnHold[1])
			if(g_keyInPtn == g_Oya . "M") {
				Gosub, SendZeroDelayMO
			}
		} else
		if(g_KeyInPtn == g_Oya . "M") {
			mergeOMKey()
			enqueueKey(g_Romaji, g_Oya, KoyubiOrSans(g_Koyubi,g_sans), g_layoutPos, g_metaKey, keyTick[g_layoutPos])
			; 当該キーとその前を同時打鍵として保留
			g_KeyInPtn := "MM"
			g_SendTick := SetTimeout(g_KeyInPtn)

			; 連続打鍵の判定 
			JudgePushedKeys(g_RomajiOnHold[1] . g_OyaOnHold[1] . g_KoyubiOnHold[1], g_MojiOnHold[2] . g_MojiOnHold[1])
		} else
		if(g_KeyInPtn == "M" . g_Oya) {
			mergeMOKey()
			enqueueKey(g_Romaji, g_Oya, KoyubiOrSans(g_Koyubi,g_sans), g_layoutPos, g_metaKey, keyTick[g_layoutPos])
			; 当該キーとその前を同時打鍵として保留
			g_KeyInPtn := "MM"
			g_SendTick := SetTimeout(g_KeyInPtn)
		}
		else if(g_KeyInPtn=="MM")	; MMオン状態
		{
			enqueueKey(g_Romaji, g_Oya, KoyubiOrSans(g_Koyubi,g_sans), g_layoutPos, g_metaKey, keyTick[g_layoutPos])
			
			; 当該キーとその前を同時打鍵として保留
			g_KeyInPtn := "MMM"
			g_SendTick := SetTimeout(g_KeyInPtn)
			GoSub, SendOnHoldMMM
		}
	}
	critical,off
	return
;----------------------------------------------------------------------
; 連続打鍵の判定
;----------------------------------------------------------------------
JudgePushedKeys(_mode,_MojiOnHold)
{
	global g_KeyOnHold, kdn, ksc, g_SendTick, g_KeyInPtn, g_ZeroDelay

	g_KeyOnHold := GetPushedKeys()
	if((strlen(g_KeyOnHold)==6 && strlen(_MojiOnHold)==3 && kdn[_mode . g_KeyOnHold . _MojiOnHold] != "")
	|| (strlen(g_KeyOnHold)==3 && strlen(_MojiOnHold)==3 && ksc[_mode . _MojiOnHold]==2 && kdn[_mode . g_KeyOnHold . _MojiOnHold] != "")
	|| (strlen(g_KeyOnHold)==3 && strlen(_MojiOnHold)==6 && kdn[_mode . g_KeyOnHold . _MojiOnHold] != "")) {
		SendOnHold(_mode, g_KeyOnHold . _MojiOnHold, g_ZeroDelay)
		clearQueue()
		g_SendTick := INFINITE
		g_keyInPtn := ""
	}
	return
}
;----------------------------------------------------------------------
; 小指シフトとSanSの論理和
;----------------------------------------------------------------------
KoyubiOrSans(_Koyubi, _sans)
{
	global g_sans, keyNameHash, g_sansPos

	if(g_sans=="K") {
		if(GetKeyState(keyNameHash[g_sansPos],"P")==0) {
			SansSend()
			_sans := "N"
		}
	}
	if (_Koyubi=="K")
	{
		return "K"
	}
	if (_sans=="K") 
	{
		return "S"
	}
	return "N"
}

;----------------------------------------------------------------------
; キーをすぐさま出力
;----------------------------------------------------------------------
SendKey(_mode, _MojiOnHold){
	global kdn, kup, kup_save,kLabel
	global g_LastKey, kst, g_Koyubi
	
	vOut                  := kdn[_mode . _MojiOnHold]
	kup_save[_MojiOnHold] := kup[_mode . _MojiOnHold]
	_nextKey := nextDakuten(_mode,_MojiOnHold)
	if(_nextKey != "") {
		g_LastKey["表層"] := _nextKey
		_aStr := "後" . g_LastKey["表層"]
		GenSendStr3(_mode, _aStr, _down, _up, _status)
		vOut                  := _down
		kup_save[_MojiOnHold] := _up
	} else {
		g_LastKey["表層"] := kLabel[_mode . _MojiOnHold]
	}
	SubSend(vOut)
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
	RegLogs(kName . " down")

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

	Gosub,GetImeStatus
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
	RegLogs(kName . " down")
	keyState[g_layoutPos] := 2

	g_ModifierTick := keyTick[g_layoutPos]
	Gosub,ModeInitialize
	
	if(g_sans == "K" && g_sansTick != INFINITE) {
		SubSendOne(MnDown(kName))
		SetKeyupSave(MnUp(kName),g_layoutPos)
		g_LastKey["表層"] := ""
	}
	g_sans := "K"
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
	RegLogs(kName . " down")
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
; 親指シフトと同時打鍵の零遅延モードの先行出力
;----------------------------------------------------------------------
SendZeroDelayMO:
	cntM := countMoji()
	if(cntM >= 1) {
		if(RegExMatch(g_MetaOnHold[1], "^[RLABCD]$")==1 && g_MetaOnHold[2]=="M")
		{
			SendZeroDelay(g_RomajiOnHold[1] . g_OyaOnHold[1] . g_KoyubiOnHold[1], g_MojiOnHold[2], g_ZeroDelay)
		} else 
		if(g_MetaOnHold[1]=="M") {
			SendZeroDelay(g_RomajiOnHold[1] . g_OyaOnHold[1] . g_KoyubiOnHold[1], g_MojiOnHold[1], g_ZeroDelay)
		}
	}
	return

;----------------------------------------------------------------------
; 親指シフトと同時打鍵の零遅延モードの先行出力
;----------------------------------------------------------------------
SendZeroDelay(_mode, _MojiOnHold, g_ZeroDelay) {
	global g_ZeroDelaySurface, g_ZeroDelayOut, kup_save, kdn, kup, kLabel
	global g_LastKey, ctrlKeyHash, kst, g_Koyubi, g_KeyOnHold

	if(g_ZeroDelay == 1)
	{
		g_KeyOnHold := GetPushedKeys()
		_MojiOnHoldLast := substr(_MojiOnHold,strlen(_MojiOnHold)-2)
		
		if(strlen(_MojiOnHold)==3 && strlen(g_KeyOnHold)==6 && kdn[_mode . g_KeyOnHold . _MojiOnHold] != "") {
			_MojiOnHold := g_KeyOnHold . _MojiOnHold
		} else
		if(strlen(_MojiOnHold)==3 && strlen(g_KeyOnHold)==3 && kdn[_mode . g_KeyOnHold . _MojiOnHold] != "") {
			_MojiOnHold := g_KeyOnHold . _MojiOnHold
		} else
		if(strlen(_MojiOnHold)==6 && strlen(g_KeyOnHold)==3 && kdn[_mode . g_KeyOnHold . _MojiOnHold] != "") {
			_MojiOnHold := g_KeyOnHold . _MojiOnHold
		}
		g_ZeroDelaySurface := kLabel[_mode . _MojiOnHold]
		
		; 保留キーがあれば先行出力（零遅延モード）
		if(kst[_mode . _MojiOnHoldLast]==""
		&& strlen(g_ZeroDelaySurface)==1 && ctrlKeyHash[g_ZeroDelaySurface]=="") {
			vOut := kdn[_mode . _MojiOnHold]
			kup_save[_MojiOnHoldLast] := kup[_mode . _MojiOnHold]
			
			_nextKey := nextDakuten(_mode,_MojiOnHold)
			if(_nextKey!="") {
				_aStr := "後" . _nextKey
				GenSendStr3(_mode, _aStr, _down, _up, _status)
				vOut                  := _down
				kup_save[_MojiOnHold] := _up
			}
			g_ZeroDelayOut := vOut
			SubSend(vOut)
		} else {
			g_ZeroDelaySurface := ""
		}
	}
	else
	{
		g_ZeroDelaySurface := ""
		g_ZeroDelayOut := ""
	}
	return
}
;----------------------------------------------------------------------
; 濁点・半濁点の処理
;----------------------------------------------------------------------
nextDakuten(_mode,_MojiOnHold)
{
	global g_LastKey, kLabel
	global DakuonSurfaceHash, HandakuonSurfaceHash, YouonSurfaceHash, CorrectSurfaceHash

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
	RegLogs(kName . " up")
	keyState[g_layoutPos] := 0
	
	if(ShiftMode[g_Romaji] == "プレフィックスシフト" || ShiftMode[g_Romaji] == "小指シフト") {
		SubSendUp(g_layoutPos)

		critical,off
		sleep,-1
		return
	}
	loop,4
	{
		if(g_layoutPos == g_MojiOnHold[A_Index]) {
			g_TUpOnHold[A_Index] := g_MojiUpTick
		}
	}
	; 親指シフトの動作
	if(g_KeyInPtn=="M")	; Mオン状態
	{
		if(g_layoutPos == g_MojiOnHold[1]) {	; 保留キーがアップされた
			Gosub, SendOnHoldM
		}
	}
	else if(g_KeyInPtn == "MM")
	{
		if(g_layoutPos == g_MojiOnHold[1]) {
			if(kdn[_mode . g_MojiOnHold[2] . g_MojiOnHold[1]]=="") {
				Gosub, SendOnHoldM	; ２文字前を単独打鍵して確定
				SubSendUp(g_MojiOnHold[0])
				; １文字前の待機
				g_KeyInPtn := "M"
				g_SendTick := SetTimeout(g_KeyInPtn)
			} else {
				g_Interval["S1_1"] := g_TUpOnHold[1] - g_TDownOnHold[1]	; 前回の文字キー押しからの重なり期間
				g_Interval["S2_1"] := g_TUpOnHold[1] - g_TDownOnHold[2]	; 最初の文字だけをオンしていた期間
				vOverlap := floor((100*g_Interval["S2_1"])/g_Interval["S1_1"])	; 重なり厚み計算
				_mode := g_RomajiOnHold[1] . g_OyaOnHold[1] . g_KoyubiOnHold[1]
				if(g_Interval["S2_1"] > g_ThresholdSS || g_OverlapSS <= vOverlap) {
					; 押下キー判定 
					Gosub, SendOnHoldMM
					if(g_KeyInPtn == "M") {
						SubSendUp(g_MojiOnHold[0])
						Gosub, SendOnHoldM
					}
				} else {
					; S4)M1M2オンM1オフモードに遷移
					g_KeyInPtn := "MMm"
					g_SendTick := SetTimeout(g_KeyInPtn)
				}
			}
		} else
		if(g_layoutPos == g_MojiOnHold[2]) {
			Gosub, SendOnHoldMM
			if(g_KeyInPtn == "M") {
				SubSendUp(g_MojiOnHold[0])
				Gosub, SendOnHoldM
			}
		}
	}
	else if(g_KeyInPtn == "MMm")
	{
		if(g_layoutPos == g_MojiOnHold[2]) {
			g_Interval["S1_2"] := g_TUpOnHold[2] - g_TDownOnHold[1]	; 第１文字キーオンからの期間
			g_Interval["S2_1"] := g_TUpOnHold[1] - g_TDownOnHold[2]	; 重なり期間
			vOverlap := floor((100*g_Interval["S2_1"])/g_Interval["S1_2"])	; 重なり厚み計算
			; 同時打鍵を確定
			if(g_OverlapSS <= vOverlap) {
				Gosub, SendOnHoldMM
				if(g_KeyInPtn == "M") {
					SubSendUp(g_MojiOnHold[0])
					Gosub, SendOnHoldM
				}
			} else {
				Gosub, SendOnHoldM
				SubSendUp(g_MojiOnHold[0])
				Gosub, SendOnHoldM
			}
		}
	}
	else if(g_KeyInPtn == "MMM")
	{
		; 同時打鍵を確定
		Gosub, SendOnHoldMMM
	}
	else if(g_KeyInPtn="M" . g_Oya)	; M-Oオン状態
	{
		if(g_MetaOnHold[1]=="M" && g_layoutPos==g_MojiOnHold[1])	; 保留キーがアップされた
		{
			; 処理C
			g_Interval["M_M"] := g_TUpOnHold[1] - g_TDownOnHold[1]
			g_Interval[g_Oya . "_M"] := g_TUpOnHold[1] - g_OyaTick[g_Oya]
			vOverlap := floor((100*g_Interval[g_Oya . "_M"])/g_Interval["M_M"])
			if(vOverlap < g_OverlapMO && g_Interval[g_Oya . "_M"] < g_Threshold)	; g_Tau
			{
				Gosub, SendOnHoldM
				g_SendTick := SetTimeout(g_Oya)
			} else {
				Gosub, SendOnHoldMO
			}
		}
	}
	else if(RegExMatch(g_KeyInPtn, "^[RLABCD]M$")==1)	; O-Mオン状態
	{
		if((g_OnHoldIdx>=1 && g_MetaOnHold[1]=="M" && g_layoutPos==g_MojiOnHold[1])
		|| (g_OnHoldIdx>=2 && g_MetaOnHold[2]=="M" && g_layoutPos==g_MojiOnHold[2]))	; 保留キーがアップされた
		{
			; 処理E
			Gosub, SendOnHoldMO
		}
	}
	else if(RegExMatch(g_KeyInPtn, "^(RMr|LMl|AMa|BMb|CMc|DMd)$")==1)	;O-M-Oオフ状態
	{
		if((g_OnHoldIdx>=1 && g_MetaOnHold[1]=="M" && g_layoutPos==g_MojiOnHold[1])
		|| (g_OnHoldIdx>=2 && g_MetaOnHold[2]=="M" && g_layoutPos==g_MojiOnHold[2]))	; 保留キーがアップされた
		{
			g_Interval["M_" . g_Oya] := g_OyaUpTick[g_Oya] - g_TDownOnHold[g_OnHoldIdx]	; 文字キー押しから右親指キー解除までの期間
			g_Interval["_" . g_Oya . "_M"] := g_MojiUpTick - g_OyaUpTick[g_Oya]
			if(g_Interval["M_" . g_Oya] > g_Interval["_" . g_Oya . "_M"]) {
				Gosub, SendOnHoldMO
			} else {
				if(g_Continue == 0 && g_OnHoldIdx >= 2) {
					Gosub, SendOnHoldO		; 保留親指キーの単独打鍵
				}
				g_OyaOnHold[1] := "N"
				Gosub, SendOnHoldM
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
	RegLogs(kName . " up")
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

	RegLogs(kName . " up")
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
	RegLogs(kName . " up")
	SubSendUp(g_layoutPos)
	critical,off
	sleep,-1
	return

;----------------------------------------------------------------------
; プロセス監視割込処理
;----------------------------------------------------------------------
InterruptProcessPolling:
	g_intproc := g_intproc + 1
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
		SetHotkey("off")
		SetHotkeyFunction("off")
	} else {
		Gosub,GetImeStatus
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
			goto, keyup%g_metaKey%
		}
	}
	if(g_sans=="K") {
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
	global g_sansTick, INFINITE
	global keyNameHash, g_sansPos
	global kup_save, keyState, g_sans
	
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
; IME状態設定
;----------------------------------------------------------------------
GetImeStatus:
	Gosub,ChkIME
	; 現在の配列面が定義されていればキーフック
	if(LF[g_Romaji . "N" . KoyubiOrSans(g_Koyubi,g_sans)]!="") {
		SetHotkey("on")
		SetHotkeyFunction("on")
	} else {
		SetHotkey("off")
		SetHotkeyFunction("off")
	}
	return

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
			if(g_KeyInPtn=="M")			; Mオン状態
			{
				Gosub, SendOnHoldM
			}
			else if(g_KeyInPtn=="MM")
			{
				Gosub, SendOnHoldMM
				if(g_KeyInPtn == "M") {
					SubSendUp(g_MojiOnHold[0])
					Gosub, SendOnHoldM
				}
			}
			else if(g_KeyInPtn == "MMm")
			{
				Gosub, SendOnHoldM
				SubSendUp(g_MojiOnHold[0])
				Gosub, SendOnHoldM
			}
			else if(g_KeyInPtn =="MMM")
			{
				Gosub, SendOnHoldMMM
			}
			else if(RegExMatch(g_KeyInPtn, "^[RLABCD]$")==1)	; Oオン状態
			{
				if(g_MojiOnHold[1] == "A02" || g_KeySingle == "有効") {
					Gosub, SendOnHoldO		; 保留親指キーの単独打鍵
				} else {
					_layout := g_Oya2Layout[g_Oya]
					_keyName := keyNameHash[_layout]
					if(GetKeyState(_keyName,"P") == 0) {
						Gosub, SendOnHoldO		; 保留親指キーの単独打鍵
					}
				}
			}
			else if(RegExMatch(g_KeyInPtn, "^M[RLABCD]$")==1
			||      RegExMatch(g_KeyInPtn, "^[RLABCD]M$")==1)	; M-Oオン状態、O-Mオン状態
			{
				Gosub, SendOnHoldMO		; 保留キーの同時打鍵
			}
			else if(RegExMatch(g_KeyInPtn, "^(RMr|LMl|AMa|BMb|CMc|DMd)$")==1)	; O-M-Oオフ状態			
			{
				if(g_Continue == 0 && g_OnHoldIdx >= 2) {
					Gosub, SendOnHoldO		; 保留親指キーの単独打鍵
				}
				g_OyaOnHold[1] := "N"
				Gosub, SendOnHoldM		; 保留文字キーの単独打鍵
			}
			clearQueue()
			g_SendTick := INFINITE
			g_KeyInPtn := ""
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
	GetKeyStateWithLog5("左Shift")
	GetKeyStateWithLog5("右Shift")
	if(keyAttribute3[fkeyPosHash["右Shift"]]=="off"	|| keyAttribute3[fkeyPosHash["右Shift"]]=="off") {
		if(keyState[fkeyPosHash["左Shift"]]!=0 || keyState[fkeyPosHash["右Shift"]]!=0)
		{
			g_Koyubi := "K"
		} else {
			g_Koyubi := "N"
		}
	}
	GetKeyStateWithLog5("左Ctrl")
	if(keyAttribute3[fkeyPosHash["左Ctrl"]]=="off") {
		if(keyState[fkeyPosHash["左Ctrl"]]!=0) {
			g_Modifier := g_Modifier | 0x0200
		} else {
			g_Modifier := g_Modifier & (~0x0200)
		}
	}
	GetKeyStateWithLog5("右Ctrl")	
	if(keyAttribute3[fkeyPosHash["右Ctrl"]]=="off") {
		if(keyState[fkeyPosHash["右Ctrl"]]!=0) {
			g_Modifier := g_Modifier | 0x0400
		} else {
			g_Modifier := g_Modifier & (~0x0400)
		}
	}
	GetKeyStateWithLog5("左Alt")
	if(keyAttribute3[fkeyPosHash["左Alt"]]=="off") {
		if(keyState[fkeyPosHash["左Alt"]]!=0) {
			g_Modifier := g_Modifier | 0x0800
		} else {
			g_Modifier := g_Modifier & (~0x0800)
		}
	}
	GetKeyStateWithLog5("右Alt")
	if(keyAttribute3[fkeyPosHash["右Alt"]]=="off") {
		if(keyState[fkeyPosHash["右Alt"]]!=0) {
			g_Modifier := g_Modifier | 0x1000
		} else {
			g_Modifier := g_Modifier & (~0x1000)
		}
	}
	GetKeyStateWithLog5("左Win")
	if(keyAttribute3[fkeyPosHash["左Win"]]=="off") {
		if(keyState[fkeyPosHash["左Win"]]!=0) {
			g_Modifier := g_Modifier | 0x2000
		} else {
			g_Modifier := g_Modifier & (~0x2000)
		}
	}
	GetKeyStateWithLog5("右Win")
	if(keyAttribute3[fkeyPosHash["右Win"]]=="off") {
		if(keyState[fkeyPosHash["右Win"]]!=0) {
			g_Modifier := g_Modifier | 0x4000
		} else {
			g_Modifier := g_Modifier & (~0x4000)
		}
	}
	g_Modifier := g_Modifier & 0x7E00

	GetKeyStateWithLog5("Applications")
	return

;----------------------------------------------------------------------
; 親指キー読み取り
;----------------------------------------------------------------------
ScanOyaKey:
	_pos := g_Oya2Layout[g_Oya]
	if(_pos!="")
	{
		if(keyAttribute3[_pos]=="off")
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
		Gosub, SendOnHoldM
	}
	else if(g_KeyInPtn == "MM")
	{
		Gosub, SendOnHoldMM
		if(g_KeyInPtn == "M") {
			SubSendUp(g_MojiOnHold[0])
			Gosub, SendOnHoldM
		}
	}
	else if(g_KeyInPtn == "MMm")
	{
		Gosub, SendOnHoldMM
		if(g_KeyInPtn == "M") {
			SubSendUp(g_MojiOnHold[0])
			Gosub, SendOnHoldM
		}
	}
	else if(g_KeyInPtn == "MMM")
	{
		Gosub, SendOnHoldMMM
	}
	else if(RegExMatch(g_KeyInPtn, "^[RLABCD]$")==1)
	{
		Gosub, SendOnHoldO		; 保留キーの同時打鍵
	}
	else if(RegExMatch(g_KeyInPtn, "^M[RLABCD]$")==1)
	{
		Gosub, SendOnHoldMO		; 保留キーの同時打鍵
	}
	else if(RegExMatch(g_KeyInPtn, "^[RLABCD]M$")==1)
	{
		Gosub, SendOnHoldMO
	}
	else if(RegExMatch(g_KeyInPtn, "^(RMr|LMl|AMa|BMb|CMc|DMd)$")==1)
	{
		Gosub, SendOnHoldMO
	}
	clearQueue()
	g_SendTick := INFINITE
	g_KeyInPtn := ""
	return

;-----------------------------------------------------------------------
;	仮想キーの状態取得とログ
;-----------------------------------------------------------------------
GetKeyStateWithLog5(fName) {
	global keyState, fkeyPosHash, fkeyVkeyHash
	global keyAttribute3

	kDown := 0
	_locationPos := fkeyPosHash[fName]
	if(_locationPos != "" && keyAttribute3[_locationPos]=="off") {
		stCurr := GetKeyState(fkeyVkeyHash[fName],"P")
		if(stCurr != 0 && keyState[_locationPos] == 0)	; keydown
		{
			kDown := 1
			RegLogs(fkeyVkeyHash[fName] . " down")
		}
		else if(stCurr == 0 && keyState[_locationPos] != 0)	; keyup
		{
			RegLogs(fkeyVkeyHash[fName] . " up")
		}
		keyState[_locationPos] := stCurr
	}
	return 	kDown
}

;-----------------------------------------------------------------------
;	押下キー取得
;-----------------------------------------------------------------------
GetPushedKeys()
{
	global layoutArys, keyState
	global g_colPushedHash

	_pushedKeys := ""
	for index, element in layoutArys
	{
		if(keyState[element] == 1) {
			if(GetKeyState(keyNameHash[element],"P")==0) {
				keyState[element] := 0
			} else {
				_cont := g_colPushedHash[substr(element,1,1)] . substr(element,2,2)
				_pushedKeys := _pushedKeys . _cont
			}
		}
	}
	return _pushedKeys
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
; キーを押下されたときに呼び出されるGotoラベルにフックする
;----------------------------------------------------------------------
SetHotkeyInit()
{
	SetHotkeyInitByPos("H01")	;NumpadDiv
	SetHotkeyInitByPos("H02")	;NumpadMult
	SetHotkeyInitByPos("H03")	;NumpadAdd
	SetHotkeyInitByPos("H04")	;NumpadSub
	SetHotkeyInitByPos("H05")	;NumpadEnter
	SetHotkeyInitByPos("H06")	;Numpad0
	SetHotkeyInitByPos("H07")	;Numpad1
	SetHotkeyInitByPos("H08")	;Numpad2
	SetHotkeyInitByPos("H09")	;Numpad3
	SetHotkeyInitByPos("H10")	;Numpad4
	SetHotkeyInitByPos("H11")	;Numpad5
	SetHotkeyInitByPos("H12")	;Numpad6
	SetHotkeyInitByPos("H13")	;Numpad7
	SetHotkeyInitByPos("H14")	;Numpad8
	SetHotkeyInitByPos("H15")	;Numpad9
	SetHotkeyInitByPos("H16")	;NumpadDot

	SetHotkeyInitByPos("G01")	;PrintScreen
	SetHotkeyInitByPos("G02")	;ScrollLock
	SetHotkeyInitByPos("G03")	;Pause
	SetHotkeyInitByPos("G04")	;Insert
	SetHotkeyInitByPos("G05")	;Home
	SetHotkeyInitByPos("G06")	;PgUp
	SetHotkeyInitByPos("G07")	;Delete
	SetHotkeyInitByPos("G08")	;End
	SetHotkeyInitByPos("G09")	;PgDn
	SetHotkeyInitByPos("G10")	;Up
	SetHotkeyInitByPos("G11")	;Left
	SetHotkeyInitByPos("G12")	;Down
	SetHotkeyInitByPos("G13")	;Right

	SetHotkeyInitByPos("F00")	;Esc
	SetHotkeyInitByPos("F01")	;F1
	SetHotkeyInitByPos("F02")	;F2
	SetHotkeyInitByPos("F03")	;F3
	SetHotkeyInitByPos("F04")	;F4
	SetHotkeyInitByPos("F05")	;F5
	SetHotkeyInitByPos("F06")	;F6
	SetHotkeyInitByPos("F07")	;F7
	SetHotkeyInitByPos("F08")	;F8
	SetHotkeyInitByPos("F09")	;F9
	SetHotkeyInitByPos("F10")	;F10
	SetHotkeyInitByPos("F11")	;F11
	SetHotkeyInitByPos("F12")	;F12

	SetHotkeyInitByPos("E00")	;半角／全角
	SetHotkeyInitByPos("E01")	;1
	SetHotkeyInitByPos("E02")	;2
	SetHotkeyInitByPos("E03")	;3
	SetHotkeyInitByPos("E04")	;4
	SetHotkeyInitByPos("E05")	;5
	SetHotkeyInitByPos("E06")	;6
	SetHotkeyInitByPos("E07")	;7
	SetHotkeyInitByPos("E08")	;8
	SetHotkeyInitByPos("E09")	;9
	SetHotkeyInitByPos("E10")	;0
	SetHotkeyInitByPos("E11")	;-
	SetHotkeyInitByPos("E12")	;^
	SetHotkeyInitByPos("E13")	;\
	SetHotkeyInitByPos("E14")	;\b
	
	SetHotkeyInitByPos("D00")	;\t
	SetHotkeyInitByPos("D01")	;q
	SetHotkeyInitByPos("D02")	;w
	SetHotkeyInitByPos("D03")	;e
	SetHotkeyInitByPos("D04")	;r
	SetHotkeyInitByPos("D05")	;t
	SetHotkeyInitByPos("D06")	;y
	SetHotkeyInitByPos("D07")	;u
	SetHotkeyInitByPos("D08")	;i
	SetHotkeyInitByPos("D09")	;o
	SetHotkeyInitByPos("D10")	;p
	SetHotkeyInitByPos("D11")	;@
	SetHotkeyInitByPos("D12")	;[

	SetHotkeyInitByPos("C01")	;a
	SetHotkeyInitByPos("C02")	;s
	SetHotkeyInitByPos("C03")	;d
	SetHotkeyInitByPos("C04")	;f
	SetHotkeyInitByPos("C05")	;g
	SetHotkeyInitByPos("C06")	;h
	SetHotkeyInitByPos("C07")	;j
	SetHotkeyInitByPos("C08") 	;k
	SetHotkeyInitByPos("C09") 	;l
	SetHotkeyInitByPos("C10")	;';'
	SetHotkeyInitByPos("C11")	;'*'
	SetHotkeyInitByPos("C12")	;']'
	SetHotkeyInitByPos("C13")	;\r
	
	SetHotkeyInitByPos("B01")	;z
	SetHotkeyInitByPos("B02")	;x
	SetHotkeyInitByPos("B03")	;c
	SetHotkeyInitByPos("B04")	;v
	SetHotkeyInitByPos("B05")	;b
	SetHotkeyInitByPos("B06")	;n
	SetHotkeyInitByPos("B07")	;m
	SetHotkeyInitByPos("B08")	;,
	SetHotkeyInitByPos("B09")	;.
	SetHotkeyInitByPos("B10")	;/
	SetHotkeyInitByPos("B11")	;\
	;-----------------------------------------------------------------------
	; 機能：モディファイアキー
	;-----------------------------------------------------------------------
	;WindowsキーとAltキーをホットキー登録すると、
	;WindowsキーやAltキーの単体押しが効かなくなるのでコメントアウトする。
	;代わりにInterrupt10 でA_Priorkeyを見て、Windowsキーを監視する。
	;但し、WindowsキーやAltキーを離したことを感知できないことに留意。
	;ver.0.1.3 にて、GetKeyState でWindowsキーとAltキーとを監視
	;ver.0.1.3.7 ... Ctrlはやはり必要なので戻す
	SetHotkeyInitByPos("A00")	;LCtrl
	SetHotkeyInitByPos("A01")	;無変換
	SetHotkeyInitByPos("A02")	;Space
	SetHotkeyInitByPos("A03")	;変換
	SetHotkeyInitByPos("A04")	;ひらがな／カタカナ
	SetHotkeyInitByPos("A05")	;RCtrl
	SetHotkeyInitByPos("A06")	;左Shift
	SetHotkeyInitByPos("A07")	;左Win
	SetHotkeyInitByPos("A08")	;左Alt
	SetHotkeyInitByPos("A09")	;右Alt
	SetHotkeyInitByPos("A10")	;右Win
	SetHotkeyInitByPos("A11")	;Applications
	SetHotkeyInitByPos("A12")	;右Shift
	return
}
;----------------------------------------------------------------------
; 一つのキーを初期化する
;----------------------------------------------------------------------
SetHotkeyInitByPos(_pos)
{
	global ScanCodeHash, keyAttribute3
	
	sCode := ScanCodeHash[_pos]
	if(sCode!="") {
		keyAttribute3[_pos] := "off"
		hotkey,*%sCode%,g%sCode%
		hotkey,*%sCode%,off
		hotkey,*%sCode% up,g%sCode%up
		hotkey,*%sCode% up,off
	}
}
;----------------------------------------------------------------------
; ファンクションキーをオン・オフする
;----------------------------------------------------------------------
SetHotkeyFunction(flg)
{
	SetHotkeyFunctionByName("Esc", flg)
	SetHotkeyFunctionByName("F1", flg)
	SetHotkeyFunctionByName("F2", flg)
	SetHotkeyFunctionByName("F3", flg)
	SetHotkeyFunctionByName("F4", flg)
	SetHotkeyFunctionByName("F5", flg)
	SetHotkeyFunctionByName("F6", flg)
	SetHotkeyFunctionByName("F7", flg)
	SetHotkeyFunctionByName("F8", flg)
	SetHotkeyFunctionByName("F9", flg)
	SetHotkeyFunctionByName("F10", flg)
	SetHotkeyFunctionByName("F11", flg)
	SetHotkeyFunctionByName("F12", flg)

	SetHotkeyFunctionByName("半角/全角", flg)

	SetHotkeyFunctionByName("左Ctrl", flg)
	SetHotkeyFunctionByName("無変換", flg)
	SetHotkeyFunctionByName("Space", flg)
	SetHotkeyFunctionByName("変換", flg)
	SetHotkeyFunctionByName("カタカナ/ひらがな", flg)
	SetHotkeyFunctionByName("右Ctrl", flg)
	SetHotkeyFunctionByName("左Shift", flg)
	SetHotkeyFunctionByName("左Win", flg)
	SetHotkeyFunctionByName("左Alt", flg)
	SetHotkeyFunctionByName("右Alt", flg)
	SetHotkeyFunctionByName("右Win", flg)
	SetHotkeyFunctionByName("Applications", flg)
	SetHotkeyFunctionByName("右Shift", flg)

	SetHotkeyFunctionByName("PrintScreen", flg)
	SetHotkeyFunctionByName("ScrollLock", flg)
	SetHotkeyFunctionByName("Pause", flg)
	SetHotkeyFunctionByName("Insert", flg)
	SetHotkeyFunctionByName("Home", flg)
	SetHotkeyFunctionByName("PageUp", flg)
	SetHotkeyFunctionByName("Delete", flg)
	SetHotkeyFunctionByName("End", flg)
	SetHotkeyFunctionByName("PageDown", flg)
	SetHotkeyFunctionByName("上", flg)
	SetHotkeyFunctionByName("左", flg)
	SetHotkeyFunctionByName("右", flg)
	SetHotkeyFunctionByName("下", flg)

	SetHotkeyFunctionByName("NumpadDiv", flg)
	SetHotkeyFunctionByName("NumpadMult", flg)
	SetHotkeyFunctionByName("NumpadAdd", flg)
	SetHotkeyFunctionByName("NumpadSub", flg)
	SetHotkeyFunctionByName("HNumpadEnter", flg)
	SetHotkeyFunctionByName("Numpad0", flg)
	SetHotkeyFunctionByName("Numpad1", flg)
	SetHotkeyFunctionByName("Numpad2", flg)
	SetHotkeyFunctionByName("Numpad3", flg)
	SetHotkeyFunctionByName("Numpad4", flg)
	SetHotkeyFunctionByName("Numpad5", flg)
	SetHotkeyFunctionByName("Numpad6", flg)
	SetHotkeyFunctionByName("Numpad7", flg)
	SetHotkeyFunctionByName("Numpad8", flg)
	SetHotkeyFunctionByName("Numpad9", flg)
	SetHotkeyFunctionByName("NumpadDot", flg)

	SetHotkeyFunctionByName("Tab", flg)
	SetHotkeyFunctionByName("Enter", flg)
}
;----------------------------------------------------------------------
; 指定された名称のキーのHotkeyをオン・オフする
;----------------------------------------------------------------------
SetHotkeyFunctionByName(kName, flg)
{
	global keyAttribute3, fkeyPosHash, fkeyCodeHash
	global g_Romaji, g_Koyubi, g_sans, kup_save
	
	_pos := fkeyPosHash[kName]
	_scode := fkeyCodeHash[kName]
	if(_pos=="" || _scode=="")
	{
		return
	}
	if(keyAttribute3[g_Romaji . KoyubiOrSans(g_Koyubi,g_sans) . _pos]!="") {
		keyAttribute3[_pos] := flg
		hotkey,*%_scode%,%flg%
		if(kup_save[_pos]=="" || _scode == "sc029")
		{
			hotkey,*%_scode% up,%flg%
		}
	} else {
		keyAttribute3[_pos] := "off"
		hotkey,*%_scode%,off
		if(kup_save[_pos]=="" || _scode == "sc029")
		{
			hotkey,*%_scode% up,off
		}
	}
}
;----------------------------------------------------------------------
; 動的にホットキーをオン・オフする
; flg : 文字キーと機能キー
;----------------------------------------------------------------------
SetHotkey(flg)
{
	SetHotkeyByPos("E01",flg)	;1
	SetHotkeyByPos("E02",flg)	;2
	SetHotkeyByPos("E03",flg)	;3
	SetHotkeyByPos("E04",flg)	;4
	SetHotkeyByPos("E05",flg)	;5
	SetHotkeyByPos("E06",flg)	;6
	SetHotkeyByPos("E07",flg)	;7
	SetHotkeyByPos("E08",flg)	;8
	SetHotkeyByPos("E09",flg)	;9
	SetHotkeyByPos("E10",flg)	;0
	SetHotkeyByPos("E11",flg)	;-
	SetHotkeyByPos("E12",flg)	;^
	SetHotkeyByPos("E13",flg)	;\
	SetHotkeyByPos("E14",flg)	;\b
	
	SetHotkeyByPos("D01",flg)	;q
	SetHotkeyByPos("D02",flg)	;w
	SetHotkeyByPos("D03",flg)	;e
	SetHotkeyByPos("D04",flg)	;r
	SetHotkeyByPos("D05",flg)	;t
	SetHotkeyByPos("D06",flg)	;y
	SetHotkeyByPos("D07",flg)	;u
	SetHotkeyByPos("D08",flg)	;i
	SetHotkeyByPos("D09",flg)	;o
	SetHotkeyByPos("D10",flg)	;p
	SetHotkeyByPos("D11",flg)	;@
	SetHotkeyByPos("D12",flg)	;[
	
	SetHotkeyByPos("C01",flg)	;a
	SetHotkeyByPos("C02",flg)	;s
	SetHotkeyByPos("C03",flg)	;d
	SetHotkeyByPos("C04",flg)	;f
	SetHotkeyByPos("C05",flg)	;g
	SetHotkeyByPos("C06",flg)	;h
	SetHotkeyByPos("C07",flg)	;j
	SetHotkeyByPos("C08",flg)	;k
	SetHotkeyByPos("C09",flg)	;l
	SetHotkeyByPos("C10",flg)	;';'
	SetHotkeyByPos("C11",flg)	;*
	SetHotkeyByPos("C12",flg)	;]
	
	SetHotkeyByPos("B01",flg)	;z
	SetHotkeyByPos("B02",flg)	;x
	SetHotkeyByPos("B03",flg)	;c
	SetHotkeyByPos("B04",flg)	;v
	SetHotkeyByPos("B05",flg)	;b
	SetHotkeyByPos("B06",flg)	;n
	SetHotkeyByPos("B07",flg)	;m
	SetHotkeyByPos("B08",flg)	;,
	SetHotkeyByPos("B09",flg)	;.
	SetHotkeyByPos("B10",flg)	;/
	SetHotkeyByPos("B11",flg)	;\
	return
}
;----------------------------------------------------------------------
; 動的にキーをオン・オフする
;----------------------------------------------------------------------
SetHotkeyByPos(_pos, flg)
{
	global scanCodeHash
	global keyAttribute3, g_Romaji, g_Koyubi, g_sans, kup_save
	
	_scode := scanCodeHash[_pos]
	if(_pos=="" || _scode=="") {
		return
	}
	if(keyAttribute3[g_Romaji . KoyubiOrSans(g_Koyubi,g_sans) . _pos]!="") {
		keyAttribute3[_pos] := flg
		hotkey,*%_scode%,%flg%
		if(kup_save[_pos]=="")
		{
			hotkey,*%_scode% up,%flg%
		}
	} else {
		keyAttribute3[_pos] := "off"
		hotkey,*%_scode%,off
		if(kup_save[_pos]=="")
		{
			hotkey,*%_scode% up,off
		}
	}
}

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
	kName := keyNameHash[g_layoutPos]
	if(kName=="LShift" || kName=="RShift") {
		g_Koyubi := "K"
	}
	g_metaKey := keyAttribute3[g_Romaji . KoyubiOrSans(g_Koyubi,g_sans) . g_layoutPos]
	if(kName=="LCtrl") {	;左Ctrl
		g_Modifier := g_Modifier | 0x0200
		goto, keydown%g_metaKey%
	}
	if(kName=="RCtrl") {	;右Ctrl
		g_Modifier := g_Modifier | 0x0400
		goto, keydown%g_metaKey%
	}
	if(kName=="LAlt") {	;左Alt
		g_Modifier := g_Modifier | 0x0800
		goto, keydown%g_metaKey%
	}
	if(kName=="RAlt") {	;右Alt
		g_Modifier := g_Modifier | 0x1000
		goto, keydown%g_metaKey%
	}
	if(kName=="LWin") {	;左Win
		g_Modifier := g_Modifier | 0x2000
		goto, keydown%g_metaKey%
	}
	if(kName=="RWin") {	;右Win
		g_Modifier := g_Modifier | 0x4000
		goto, keydown%g_metaKey%
	}
	if(g_Modifier != 0) {
		RegLogs(kName . " down")
		Gosub,ModeInitialize
		; 修飾キー＋文字キーの同時押しのときに
		if(g_metaKey=="M" && kdn["ANN"]!="") {
			SubSendOne(kdn["ANN" . g_layoutPos])
			SetKeyupSave(kup["ANN" . g_layoutPos],g_layoutPos)
		} else {
			SubSendOne(MnDown(kName))
			SetKeyupSave(MnUp(kName),g_layoutPos)
		}
		clearQueue()
		g_LastKey["表層"] := ""
		g_SendTick := INFINITE
		g_KeyInPtn := ""
		g_prefixshift := ""
		critical,off
		return
	}
	pf_TickCount := Pf_Count()
	if(keyState[g_layoutPos] != 0 && g_KeyRepeat == 1)
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
	kName := keyNameHash[g_layoutPos]
	if(kName=="LShift" || kName=="RShift") {
		g_Koyubi := "N"
	}
	g_metaKey := keyAttribute3[g_Romaji . KoyubiOrSans(g_Koyubi,g_sans) . g_layoutPos]
	if(kName=="LCtrl") {	;左Ctrl
		g_Modifier := g_Modifier & (~0x0200)
	}
	if(kName=="RCtrl") {	;右Ctrl
		g_Modifier := g_Modifier & (~0x0400)
	}
	if(kName=="LAlt") {	;左Alt
		g_Modifier := g_Modifier & (~0x0800)
	}
	if(kName=="RAlt") {	;右Alt
		g_Modifier := g_Modifier & (~0x1000)
	}
	if(kName=="LWin") {	;左Win
		g_Modifier := g_Modifier & (~0x2000)
	}
	if(kName=="RWin") {	;右Win
		g_Modifier := g_Modifier & (~0x4000)
	}
	GuiControl,2:,vkeyDN%g_layoutPos%,　
	gosub, keyup%g_metaKey%
	g_RepeatCount := 0
	if(keyAttribute3[g_layoutPos] == "off")
	{
		SetHotkeyByPos(g_layoutpos,"off")	
	}
	return

