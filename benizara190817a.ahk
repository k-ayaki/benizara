;-----------------------------------------------------------------------
;	名称：benizara / 紅皿
;	機能：Yet another NICOLA Emulaton Software
;         キーボード配列エミュレーションソフト
;	ver.0.1.4.717 .... 2021/7/12
;	作者：Ken'ichiro Ayaki
;-----------------------------------------------------------------------
	#InstallKeybdHook
	#MaxhotkeysPerInterval 400
	#MaxThreads 64
	#KeyHistory
#SingleInstance, Off
	SetStoreCapsLockMode,Off
	StringCaseSense, On			; 大文字小文字を区別
	g_Ver := "ver.0.1.4.717"
	g_Date := "2021/7/12"
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
	g_keyboardDelay := Object()
	g_keyboardDelay[0] := 250
	g_keyboardDelay[1] := 500
	g_keyboardDelay[2] := 750
	g_keyboardDelay[3] := 1000
	g_MaxTimeout := g_keyboardDelay[_keyboardDelayIdx]
	if(g_MaxTimeout == 0) {
		g_MaxTimeout := 500
	}
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
	g_LastKey["状態"] := ""

	g_OyaAlt := Object()	; 反対側の親指キー
	g_OyaAlt["R"] := "L"
	g_OyaAlt["L"] := "R"

	g_metaKeyUp := Object()		; 親指キーを離す
	g_metaKeyUp["R"] := "r"
	g_metaKeyUp["L"] := "l"
	g_metaKeyUp["M"] := "m"
	g_metaKeyUp["S"] := "s"
	g_metaKeyUp["X"] := "x"
	g_metaKeyUp["1"] := "_1"
	g_metaKeyUp["2"] := "_2"

	g_MojiCount := Object()	; 親指キーシフトの文字押下カウンター
	g_MojiCount["R"] := 0
	g_MojiCount["L"] := 0

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
	;Menu, Tray, Add, 配列,ShowLayout
	Menu, Tray, Add, ログ,Logs
	Menu, Tray, Add, 一時停止,DoPause
	Menu, Tray, Add, 再開,DoResume
	Menu, Tray, Add, 終了,MenuExit
	Gosub,DoResume
	;Menu, Tray,disable,再開
	;if(Path_FileExists(A_ScriptDir . "\benizara_on.ico")==1)
	;{
	;	Menu, Tray, Icon, %A_ScriptDir%\benizara_on.ico , ,1
	;}
	SetBatchLines, -1
	SetHookInit()
	fPf := Pf_Init()
	_currentTick := Pf_Count()	;A_TickCount
	g_OyaTick["R"] := _currentTick
	g_OyaTick["L"] := _currentTick
	VarSetCapacity(lpKeyState,256,0)
	g_int10ctr := 0

	g_process := Object()	; 反対側の親指キー
	g_process["yamabuki_r"] := 0
	g_process["yamabuki"] := 0
	g_process["DvorakJ"] := 0
	g_process["em1keypc"] := 0
	g_process["姫踊子草2"] := 0
	SetTimer,Interrupt10,10

	SetHook("off")
	SetHookHenkan("off")
	g_hookShift := "off"
	SetHookFunction("off")
	return


MenuExit:
	SetTimer,Interrupt10,off
	DllCall("ReleaseMutex", Ptr, hMutex)
	SetHook("off")
	SetHookHenkan("off")
	SetHookFunction("off")
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

;-----------------------------------------------------------------------
; 親指シフトキー
; スペースキーに割り当てられていれば連続打鍵
;-----------------------------------------------------------------------

keydownR:
keydownL:
	g_trigger := g_metaKey
	g_OyaTick[g_metaKey] := Pf_Count()				; A_TickCount
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
					SendKeyUp()
					g_SendTick := SetTimeout("M")
				}
			} else {
				; ３キー判定
				g_Interval["M" . g_metaKey] := g_OyaTick[g_metaKey] - g_TDownOnHold[2]
				g_Interval["S12"]  := g_TDownOnHold[2] - g_TDownOnHold[1]	; 前回の文字キー押しからの期間
				if(g_Interval["S12"] < g_Interval["M" . g_metaKey]) {
					Gosub, SendOnHoldMM
					if(g_KeyInPtn == "M") {
						SendKeyUp()
						g_SendTick := SetTimeout("M")
					}
				} else {
					Gosub, SendOnHoldM		; 保留した２文字前だけを打鍵してMオン状態に遷移
					if(g_KeyInPtn == "M") {
						SendKeyUp()
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
		else if(g_KeyInPtn == g_OyaAlt[g_Oya])	;S3)Oオン状態　（既に他の親指キーオン）
		{
			Gosub, SendOnHoldO	; 他の親指キー（保留キー）の打鍵
			g_Oya := g_metaKey
			enqueueKey(g_Romaji, g_Oya, KoyubiOrSans(g_Koyubi,g_sans), g_layoutPos, g_metaKey, g_OyaTick[g_metaKey])
			g_KeyInPtn := g_Oya				;S4)Oオンに遷移
			g_SendTick := SetTimeout(g_KeyInPtn)
		}
		else if(g_KeyInPtn == "M" . g_OyaAlt[g_Oya])	;S4)M-Oオン状態で反対側のOキーオン
		{
			Gosub, SendOnHoldMO	; 保留キーの打鍵
			g_Oya := g_metaKey
			
			enqueueKey(g_Romaji, g_Oya, KoyubiOrSans(g_Koyubi,g_sans), g_layoutPos, g_metaKey, g_OyaTick[g_metaKey])
			g_KeyInPtn := g_Oya	; S3)Oオンに遷移
			g_SendTick := SetTimeout(g_KeyInPtn)
		}
		else if(g_KeyInPtn == g_OyaAlt[g_Oya] . "M")	;S5)O-Mオン状態で反対側のOキーオン
		{
			; 処理B 3キー判定
			g_Interval[g_OyaAlt[g_Oya] . "M"] := g_TDownOnHold[1] - g_OyaTick[g_OyaAlt[g_Oya]]	; 他の親指キー押しから文字キー押しまでの期間
			g_Interval["M" . g_Oya] := g_OyaTick[g_Oya] - g_TDownOnHold[g_OnHoldIdx]	; 文字キー押しから当該親指キー押しまでの期間
			if(g_Interval["M" . g_Oya] > g_Interval[g_OyaAlt[g_Oya] . "M"] || g_Continue==1)
			{
				Gosub, SendOnHoldMO	; 保留キーの打鍵　L,Rモードに遷移
				g_Oya := g_metaKey

				enqueueKey(g_Romaji, g_Oya, KoyubiOrSans(g_Koyubi,g_sans), g_layoutPos, g_metaKey, g_OyaTick[g_metaKey])
				g_KeyInPtn := g_Oya	; S3)Oオンに遷移
				g_SendTick := SetTimeout(g_KeyInPtn)
			}
			else
			{
				if(g_ZeroDelayOut<>"")
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
		else if(g_KeyInPtn="RMr" || g_KeyInPtn="LMl")	; S6)O-M-Oオフ状態
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
	if(g_KeyInPtn == "L" || g_KeyInPtn == "R") {
		g_SendTick := INFINITE
	}
	critical,off
	return  

;-----------------------------------------------------------------------
; 親指シフトキーのオフ
;-----------------------------------------------------------------------
keyupR:
keyupL:
	g_trigger := g_metaKeyUp[g_metaKey]

	g_OyaUpTick[g_metaKey] := Pf_Count()				;A_TickCount
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
	keyState[g_layoutPos] := 0
	
	if(g_Oya == g_metaKey) {
		if(g_Continue == 1) {
			; 反対側の親指キーが押されていなければ N に設定
			g_Oya := g_OyaAlt[g_Oya]
			_layout := g_Oya2Layout[g_Oya]
			_keyName := keyNameHash[_layout]
			_keyState := GetKeyState(_keyName,"P")
			if(_keyState == 0) {
				g_Oya := "N"
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
			SubSend(MnDown("BS") . MnUp("BS"))
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
	if(aStr<>"")
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
	if(aStr<>"")
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
	loop, Parse, vOut
	{
		_cnt := _cnt + 1
		_stroke := _stroke . A_LoopField
		StringLeft, _left2c, _stroke, 2
		if(A_LoopField == "}" && _left2c != "{}") {	; ストロークの終わり
			if(instr(_stroke,"{Enter")>0) {
				_scnt := _scnt + 4
			} else {
				_scnt := _scnt + 1
			}
			if(g_Koyubi=="K" && isCapsLock(_sendch)==true && instr(_storoke,"{vk")==0) {
				Send, {capslock}
				RegLogs("       " . substr(g_KeyInPtn . "    ",1,4) . substr(g_trigger . "    ",1,4) . "{capslock}")
			}
			SetKeyDelay, -1
			Send, %_stroke%
			RegLogs("       " . substr(g_KeyInPtn . "    ",1,4) . substr(g_trigger . "    ",1,4) . _stroke)
			_stroke := ""
			if(_cnt != _len && _scnt>=4) {
				DllCall("kernel32.dll\Sleep", "UInt", 10)
				_scnt := 0
			}
			if(g_Koyubi=="K" && isCapsLock(_sendch)==true && instr(_storoke,"{vk")==0) {
				Send, {capslock}
				RegLogs("       " . substr(g_KeyInPtn . "    ",1,4) . substr(g_trigger . "    ",1,4) . "{capslock}")
			}
			_sendch := ""
		}
		if(_sendch=="" && substr(_left2c,1,1)=="{") {
			_sendch := substr(_left2c,2,1)
		}
	}
	if(_stroke != "") {
		SetKeyDelay, -1
		Send, %_stroke%
		RegLogs("       " . substr(g_KeyInPtn . "    ",1,4) . substr(g_trigger . "    ",1,4) . _stroke)
	}
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
	if(key <> "")
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
	
	tickCount := Pf_Count()	;A_TickCount

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
		if((g_MetaOnHold[1]=="M" && g_MetaOnHold[2]=="L")
		|| (g_MetaOnHold[1]=="M" && g_MetaOnHold[2]=="R")) {
			_mode := g_RomajiOnHold[2] . g_OyaOnHold[2] . g_KoyubiOnHold[2]
			SendOnHold(_mode, g_MojiOnHold[1], g_ZeroDelay)
			dequeueKey()
			dequeueKey()
			clearQueue()
		} else 
		if((g_MetaOnHold[1]=="L" && g_MetaOnHold[2]=="M")
		|| (g_MetaOnHold[1]=="R" && g_MetaOnHold[2]=="M")) {
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
	_kLabel := kLabel[_mode . _MojiOnHold]
	_kst    := kst[_mode . _MojiOnHold]
	_nextKey := nextDakuten(_mode,_MojiOnHold)
	if(_nextKey != "") {
		g_LastKey["表層"] := _nextKey
		_aStr := "後" . g_LastKey["表層"]
		GenSendStr3(_mode, _aStr, _down, _up, _status)
		vOut                   := _down
		kup_save[_MojiOnHoldLast]  := _up
		_kLabel := g_LastKey["表層"]
		_kst    := g_LastKey["状態"]
	} else {
		g_LastKey["表層"] := kLabel[_mode . _MojiOnHold]
		g_LastKey["状態"] := kst[_mode . _MojiOnHold]
	}
	if(g_ZeroDelay == 1)
	{
		if(vOut <> g_ZeroDelayOut)
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
; キーアップ
; g_MojiOnHold[0]には、直前に出力したキーの場所が入っている
;----------------------------------------------------------------------
SendKeyUp()
{
	global kup_save, g_MojiOnHold
	
	if(kup_save[g_MojiOnHold[0]]!="") {
		SubSend(kup_save[g_MojiOnHold[0]])
		kup_save[g_MojiOnHold[0]] := ""
	}
}
;----------------------------------------------------------------------
; タイムアウト時間を設定
;----------------------------------------------------------------------
SetTimeout(_KeyInPtn)
{
	global g_TDownOnHold, g_OnHoldIdx, g_Threshold, g_OverlapMO, g_OverlapOM, g_MaxTimeout, g_OnHoldIdx
	global g_SimulMode, g_ThresholdSS, g_OverlapSS, INFINITE, g_Interval
	global g_OyaTick, g_OyaUpTick, g_Oya, g_MojiCount
	
	_SendTick := INFINITE
	if(_KeyInPtn=="") {
		_SendTick := INFINITE
	} else 
	if(_KeyInPtn=="M") {
		_SendTick := g_TDownOnHold[g_OnHoldIdx] + minimum(floor((g_Threshold*(100-g_OverlapMO))/g_OverlapMO),g_MaxTimeout)
		if(CountObject(g_SimulMode)!=0) {
			; 文字同時打鍵があればタイムアウトの大きい方に合わせる
			_SendTick := maximum(_SendTick, g_TDownOnHold[g_OnHoldIdx] + minimum(floor((g_ThresholdSS*(100-g_OverlapSS))/g_OverlapSS),g_MaxTimeout))
		}
	} else
	if(_KeyInPtn=="MM") {
		_SendTick := g_TDownOnHold[g_OnHoldIdx] + maximum(g_ThresholdSS,g_Threshold)
	} else
	if(_KeyInPtn=="MMm") {
		g_Interval["S12"]  := g_TDownOnHold[2] - g_TDownOnHold[1]	; 最初の文字だけをオンしていた期間
		g_Interval["S2_1"] := g_TUpOnHold[1] - g_TDownOnHold[2]		; 前回の文字キー押しからの重なり期間
		_SendTick := g_TUpOnHold[1] + minimum(floor((g_Interval["S2_1"]*(100-g_OverlapSS))/g_OverlapSS)-g_Interval["S12"],g_MaxTimeout)
	} else
	if(_KeyInPtn=="MMM") {
		_SendTick := g_TDownOnHold[g_OnHoldIdx]
	} else
	if(_KeyInPtn=="L" || _KeyInPtn=="R") {
		_SendTick := INFINITE	;g_OyaTick[g_Oya] + minimum(floor((g_Threshold*(100-g_OverlapOM))/g_OverlapOM),g_MaxTimeout)
	} else
	if(_KeyInPtn=="LM" || _KeyInPtn=="RM") {
		if(g_MojiCount[g_Oya]==1) {
			g_Interval[g_Oya . "M"] := g_TDownOnHold[g_OnHoldIdx] - g_OyaTick[g_Oya]
			_SendTick := g_TDownOnHold[g_OnHoldIdx] + minimum(floor(g_Interval[g_Oya . "M"]*g_OverlapOM/(100-g_OverlapOM)),g_MaxTimeout)
		} else {
			_SendTick := g_TDownOnHold[g_OnHoldIdx] + minimum(g_Threshold,g_MaxTimeout)
		}
	} else
	if(_KeyInPtn=="ML" || _KeyInPtn=="MR") {
		g_Interval["M" . g_Oya] := g_OyaTick[g_Oya] - g_TDownOnHold[g_OnHoldIdx]
		_SendTick := g_OyaTick[g_Oya] + minimum(floor(g_Interval["M" . g_Oya]*g_OverlapMO/(100-g_OverlapMO)),g_MaxTimeout)
	} else
	if(_KeyInPtn=="RMr" || _KeyInPtn=="LMl") {
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
		&& ((g_MetaOnHold[1]=="L" && g_MetaOnHold[2]=="M")
		||  (g_MetaOnHold[1]=="R" && g_MetaOnHold[2]=="M"))) {
			_mode := g_RomajiOnHold[1] . g_OyaOnHold[1] . g_KoyubiOnHold[1]
			dequeueKey()
		} else
		if(g_MetaOnHold[1]=="M") {
			_mode := g_RomajiOnHold[1] . g_OyaOnHold[1] . g_KoyubiOnHold[1]
		}
		SendOnHold(_mode, g_MojiOnHold[1], g_ZeroDelay)
		dequeueKey()
		g_SendTick := INFINITE
		if(g_KeyInPtn=="MR")
		{
			g_keyInPtn := "R"
		}
		else if(g_KeyInPtn=="ML")
		{
			g_keyInPtn := "L"
		}
		else if(g_KeyInPtn=="M")
		{
			clearQueue()
			g_keyInPtn := ""		
		}
		else if(g_KeyInPtn=="RMr" || g_KeyInPtn=="LMl")
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
; 文字キーのMO/OMを１つにマージ
;----------------------------------------------------------------------
mergeKey()
{
	global g_RomajiOnHold, g_OyaOnHold, g_KoyubiOnHold, g_MojiOnHold, g_OnHoldIdx
	global g_TDownOnHold, g_TUpOnHold, g_MetaOnHold
	
	if(g_OnHoldIdx==2) {
		if(g_MetaOnHold[1]=="L" || g_MetaOnHold[1]=="R") {
			g_RomajiOnHold[2] := g_RomajiOnHold[1]
			g_OyaOnHold[2]    := g_OyaOnHold[1]
			g_KoyubiOnHold[2] := g_KoyubiOnHold[1]
			dequeueKey()
		} else
		if(g_MetaOnHold[1]=="L" || g_MetaOnHold[1]=="R") {
			g_MetaOnHold[2]   := g_MetaOnHold[1]
			g_MojiOnHold[2]   := g_MojiOnHold[1]
			g_TDownOnHold[2]  := g_TDownOnHold[1]
			g_TUpOnHold[2]    := g_TUpOnHold[1]			
			dequeueKey()
		}
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
		&& ((g_MetaOnHold[1]=="L" && g_MetaOnHold[2]=="M" && g_MetaOnHold[3]=="M")
		||  (g_MetaOnHold[1]=="R" && g_MetaOnHold[2]=="M" && g_MetaOnHold[3]=="M"))) {
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
			SendKeyUp()
			Gosub, SendOnHoldM
		}
		return
	}
	; 異常時の対処
	if((g_MetaOnHold[1]=="L" && g_MetaOnHold[2]=="M" && g_MetaOnHold[3]=="M" && g_MetaOnHold[4]=="M")
	|| (g_MetaOnHold[1]=="R" && g_MetaOnHold[2]=="M" && g_MetaOnHold[3]=="M" && g_MetaOnHold[4]=="M")) {
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
		SendKeyUp()
		Gosub,SendOnHoldM
		clearQueue()
		g_keyInPtn := ""
		return
	} else {
		SendOnHold(_mode, g_MojiOnHold[1], g_ZeroDelay)
		dequeueKey()
		SendKeyUp()
		Gosub,SendOnHoldMM
		if(g_KeyInPtn == "M") {
			SendKeyUp()
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
	if(g_MetaOnHold[1]=="L" || g_MetaOnHold[1]=="R") {
		if(g_KeySingle == "有効" || g_MojiOnHold[1] == "A02") {
			_mode := g_RomajiOnHold[1] . g_OyaOnHold[1] . g_KoyubiOnHold[1]
			SendOnHold(_mode, g_MojiOnHold[1], g_ZeroDelay)
		}
		dequeueKey()
		if(g_KeyInPtn=="RM" || g_KeyInPtn=="RMr" || g_KeyInPtn=="MR"
		|| g_KeyInPtn=="LM" || g_KeyInPtn=="LMl" || g_KeyInPtn=="ML")
		{
			g_keyInPtn := "M"
		}
		else if(g_KeyInPtn=="L" || g_KeyInPtn=="R")
		{
			g_keyInPtn := ""
		}
	} else
	if(g_KeyInPtn=="RM" || g_KeyInPtn=="LM") {
		g_OyaOnHold[1] := "N"
		g_keyInPtn := "M"
	}
	; debugging 
	if(g_MetaOnHold[1]=="L" || g_MetaOnHold[1]=="R") {
		dequeueKey()
	}
	if(g_Continue == 0) {
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
		if(g_prefixshift <> "" )
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
	if(g_KeyInPtn="RM" || g_KeyInPtn="LM")	;S5)O-Mオン状態
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
				SendKeyUp()
			} else {
				Gosub, SendOnHoldM		; 保留した２文字前だけを打鍵してMオン状態に遷移
				SendKeyUp()
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
			SendKeyUp()
		} else {
			Gosub, SendOnHoldM		; 保留した２文字前だけを打鍵してMオン状態に遷移
			SendKeyUp()
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
	else if(g_KeyInPtn="RMr" || g_KeyInPtn="LMl")	;S6)O-M-Oオフ状態
	{
		if(g_MojiOnHold[g_OnHoldIdx]!="") {
			if(g_Continue == 0 && g_OnHoldIdx >= 2) {
				Gosub, SendOnHoldO		; 保留親指キーの単独打鍵
			}
			g_OyaOnHold[1] := "N"
			Gosub, SendOnHoldM		; 保留文字キーの単独打鍵
		}
	}
	SetKeyDelay, -1
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
			mergeKey()
			enqueueKey(g_Romaji, g_Oya, KoyubiOrSans(g_Koyubi,g_sans), g_layoutPos, g_metaKey, keyTick[g_layoutPos])
			; 当該キーとその前を同時打鍵として保留
			g_KeyInPtn := "MM"
			g_SendTick := SetTimeout(g_KeyInPtn)

			; 連続打鍵の判定 
			JudgePushedKeys(g_RomajiOnHold[1] . g_OyaOnHold[1] . g_KoyubiOnHold[1], g_MojiOnHold[2] . g_MojiOnHold[1])
		} else
		if(g_KeyInPtn == "M" . g_Oya) {
			mergeKey()
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
	if(_Koyubi=="K" || _sans=="K") 
	{
		return "K"
	}
	return "N"
}

;----------------------------------------------------------------------
; 元の109レイアウトで出力
;----------------------------------------------------------------------
SendModifier(_symbol, _kName)
{
	global kup_save, g_LastKey

	vOut := _symbol . "{" . _kName . "}"
	kup_save[g_layoutPos] := ""
	SubSend(vOut)
	g_LastKey["表層"] := ""
	g_LastKey["状態"] := ""
}
;----------------------------------------------------------------------
; キーをすぐさま出力
;----------------------------------------------------------------------
SendKey(_mode, _MojiOnHold){
	global kdn, kup, kup_save,kLabel
	global g_LastKey, kst, g_Koyubi
	
	vOut                  := kdn[_mode . _MojiOnHold]
	kup_save[_MojiOnHold] := kup[_mode . _MojiOnHold]
	_kLabel := kLabel[_mode . _MojiOnHold]
	_kst    := kst[_mode . _MojiOnHold]
	
	_nextKey := nextDakuten(_mode,_MojiOnHold)
	if(_nextKey != "") {
		g_LastKey["表層"] := _nextKey
		_aStr := "後" . g_LastKey["表層"]
		GenSendStr3(_mode, _aStr, _down, _up, _status)
		vOut                  := _down
		kup_save[_MojiOnHold] := _up
		
		_kLabel := g_LastKey["表層"]
		_kst    := g_LastKey["状態"]
	} else {
		g_LastKey["表層"] := kLabel[_mode . _MojiOnHold]
		g_LastKey["状態"] := kst[_mode . _MojiOnHold]
	}
	SubSend(vOut)
}
;----------------------------------------------------------------------
; 修飾キー押下
;----------------------------------------------------------------------
keydown:
keydownX:
	g_trigger := g_metaKey
	keyTick[g_layoutPos] := Pf_Count()
	RegLogs(kName . " down")
	keyState[g_layoutPos] := 2
	if(ShiftMode[g_Romaji] == "プレフィックスシフト") {
		SubSend(MnDown(kName))
		keyState[g_layoutPos] := 1
		g_LastKey["表層"] := ""
		g_LastKey["状態"] := ""
		g_prefixshift := ""
		critical,off
		return
	}
	g_ModifierTick := keyTick[g_layoutPos]
	;Gosub,ModeInitialize
	SubSend(MnDown(kName))
	keyState[g_layoutPos] := 1
	g_LastKey["表層"] := ""
	g_LastKey["状態"] := ""
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
	;Gosub,ModeInitialize
	if(g_sans == "K" && g_sansTick != INFINITE) {
		SubSend(MnDown(kName) . MnUp(kName))
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
keydown1:
keydown2:
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
		if((g_MetaOnHold[1]=="L" && g_MetaOnHold[2]=="M")
		|| (g_MetaOnHold[1]=="R" && g_MetaOnHold[2]=="M")) {
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
			_kLabel := kLabel[_mode . _MojiOnHold]
			_kst    := kst[_mode . _MojiOnHold]			
			
			_nextKey := nextDakuten(_mode,_MojiOnHold)
			if(_nextKey!="") {
				_aStr := "後" . _nextKey
				GenSendStr3(_mode, _aStr, _down, _up, _status)
				vOut                  := _down
				kup_save[_MojiOnHold] := _up
				
				_kLabel := g_LastKey["表層"]
				_kst    := g_LastKey["状態"]
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
	if(g_LastKey["状態"]=="") {
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
	}
	return _nextKey
}

;----------------------------------------------------------------------
; キーアップ（押下終了）
;----------------------------------------------------------------------
keyupM:
	g_trigger := g_metaKeyUp[g_metaKey]
	g_MojiUpTick := Pf_Count()	;A_TickCount
	RegLogs(kName . " up")
	keyState[g_layoutPos] := 0
	
	if(ShiftMode[g_Romaji] == "プレフィックスシフト" || ShiftMode[g_Romaji] == "小指シフト") {
		vOut := kup_save[g_layoutPos]
		SubSend(vOut)
		kup_save[g_layoutPos] := ""
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
				SendKeyUp()
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
						SendKeyUp()
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
				SendKeyUp()
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
					SendKeyUp()
					Gosub, SendOnHoldM
				}
			} else {
				Gosub, SendOnHoldM
				SendKeyUp()
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
	else if(g_KeyInPtn="RM" || g_KeyInPtn="LM")	; O-Mオン状態
	{
		if((g_OnHoldIdx>=1 && g_MetaOnHold[1]=="M" && g_layoutPos==g_MojiOnHold[1])
		|| (g_OnHoldIdx>=2 && g_MetaOnHold[2]=="M" && g_layoutPos==g_MojiOnHold[2]))	; 保留キーがアップされた
		{
			; 処理E
			Gosub, SendOnHoldMO
		}
	}
	else if(g_KeyInPtn="RMr" || g_KeyInPtn="LMl")	;O-M-Oオフ状態
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
	SubSend(kup_save[g_layoutPos])
	kup_save[g_layoutPos] := ""
	g_trigger := ""
	critical,off
	sleep,-1
	return


;----------------------------------------------------------------------
; 文字コード以外のキーアップ（押下終了）
;----------------------------------------------------------------------
keyup:
keyupX:
	g_trigger := g_metaKeyUp[g_metaKey]

	RegLogs(kName . " up")
	keyState[g_layoutPos] := 0
	vOut := MnUp(kName)
	SubSend(vOut)
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
		SubSend(MnDown(kName) . MnUp(kName))
		g_sansTick := INFINITE
	}
	keyState[g_layoutPos] := 0
	g_sans := "N"
	critical,off
	sleep,-1
	return

;----------------------------------------------------------------------
; 月配列等のプレフィックスシフトキー押下終了
;----------------------------------------------------------------------
keyup1:
keyup2:
	g_trigger := g_metaKeyUp[g_metaKey]

	RegLogs(kName . " up")
	keyState[g_layoutPos] := 0
	SubSend(kup_save[g_layoutPos])
	kup_save[g_layoutPos] := ""
	critical,off
	sleep,-1
	return


;----------------------------------------------------------------------
; 10[mSEC]ごとの割込処理
;----------------------------------------------------------------------
Interrupt10:
	critical
	g_int10ctr := g_int10ctr + 1
	Gosub,ScanModifier
	Gosub,ScanPauseKey
	if(g_Modifier!=0) 
	{
		Gosub,ModeInitialize
		SetHook("off")
		SetHookHenkan("on")
		SetHookFunction("on")
	} else
	if(g_Pause==1) 
	{
		Gosub,ModeInitialize
		SetHook("off")
		SetHookHenkan("off")
		SetHookFunction("off")
	} else {
		Gosub,ChkIME

		; 現在の配列面が定義されていればキーフック
		if(LF[g_Romaji . "N" . g_Koyubi]!="") {
			SetHook("on")
		} else {
			SetHook("off")
		}
		SetHookHenkan("on")
		SetHookFunction("on")
	}
	if(keyState["A04"] != 0)
	{
		_TickCount := Pf_Count()	;A_TickCount
		if(_TickCount > keyTick["A04"] + 100) 	; タイムアウト
		{
			; ひらがな／カタカナキーはキーアップを受信できないから、0.1秒でキーアップと見做す
			g_layoutPos := "A04"
			g_metaKey := keyAttribute3[g_Romaji . g_Koyubi . g_layoutPos]
			kName := keyNameHash[g_layoutPos]
			goto, keyup%g_metaKey%
		}
	}
	if(g_sans=="K") {
		if(GetKeyState(keyNameHash[g_sansPos],"P") == 0) {
			if(g_sansTick!=INFINITE)	; 未タイムアウト
			{
				SubSend(MnDown(keyNameHash[g_sansPos]) . MnUp(keyNameHash[g_sansPos]))
				g_sansTick := INFINITE
				keyState[g_sansPos] := 0
			}
			g_sans := "N"
		}
	}
	Gosub,Polling
	critical,off
	sleep,-1
	if(mod(g_int10ctr,10)==0) {
		Process,Exist,yamabuki_r.exe
		_pid := ErrorLevel
		if(_pid!=0 && g_process["yamabuki_r"]==0) {
			Traytip,キーボード配列エミュレーションソフト「紅皿」,やまぶきRが動作中。干渉のおそれがあります。
		}
		g_process["yamabuki_r"] := _pid
	}
	if(mod(g_int10ctr,10)==2) {
		Process,Exist,yamabuki.exe
		_pid := ErrorLevel
		if(_pid!=0 &&  g_process["yamabuki"]==0) {
			Traytip,キーボード配列エミュレーションソフト「紅皿」,やまぶきが動作中。干渉のおそれがあります。
		}
		g_process["yamabuki"] := _pid
	}
	if(mod(g_int10ctr,10)==4) {
		Process,Exist,DvorakJ.exe
		_pid := ErrorLevel
		if(_pid!=0 &&  g_process["DvorakJ"]==0) {
			Traytip,キーボード配列エミュレーションソフト「紅皿」,DvorakJが動作中。干渉のおそれがあります。
		}
		g_process["DvorakJ"] := _pid
	}
	if(mod(g_int10ctr,10)==6) {
		Process,Exist,em1keypc.exe
		_pid := ErrorLevel
		if(_pid!=0 &&  g_process["em1keypc"]==0) {
			Traytip,キーボード配列エミュレーションソフト「紅皿」,em1keypcが動作中。干渉のおそれがあります。
		}
		g_process["em1keypc"] := _pid
	}
	if(mod(g_int10ctr,10)==8) {
		Process,Exist,姫踊子草2.exe
		_pid := ErrorLevel
		if(_pid!=0 &&  g_process["姫踊子草2"]==0) {
			Traytip,キーボード配列エミュレーションソフト「紅皿」,姫踊子草2が動作中。干渉のおそれがあります。
		}
		g_process["姫踊子草2"] := _pid
	}
	if(A_IsCompiled != 1)
	{
		vImeMode := IME_GET() & 32767
		vImeConvMode := IME_GetConvMode()
		szConverting := IME_GetConverting()
		
		;g_debugout3 := ksc["RNNC01"] . ":" . kst["RNNC01"]
		g_debugout3 := g_Modifier
		g_debugout2 := GetPushedKeys()
		;g_debugout2 := GetKeyState(keyNameHash[g_sansPos],"P")
		_mode := g_Romaji . g_Oya . g_Koyubi
		g_debugout := vImeMode . ":" . vImeConvMode . szConverting . ":" . g_Romaji . g_Oya . g_Koyubi . g_layoutPos . ":" . g_KeyInPtn . ":" . g_debugout2 . ":" . g_debugout3
		;g_LastKey["status"] . ":" . g_LastKey["snapshot"]
		Tooltip, %g_debugout%, 0, 0, 2 ; debug
	}
	return
	
;----------------------------------------------------------------------
; 10mSECなどのポーリング
;----------------------------------------------------------------------
Polling:
	if(g_SendTick != INFINITE)
	{
		g_trigger := "TO"
		_TickCount := Pf_Count()	;A_TickCount
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
					SendKeyUp()
					Gosub, SendOnHoldM
				}
			}
			else if(g_KeyInPtn == "MMm")
			{
				Gosub, SendOnHoldM
				SendKeyUp()
				Gosub, SendOnHoldM
			}
			else if(g_KeyInPtn =="MMM")
			{
				Gosub, SendOnHoldMMM
			}
			else if(g_KeyInPtn=="L" || g_KeyInPtn=="R")	; Oオン状態
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
			else if(g_KeyInPtn=="ML" || g_KeyInPtn=="MR" || g_KeyInPtn=="LM" || g_KeyInPtn=="RM" )	; M-Oオン状態、O-Mオン状態
			{
				Gosub, SendOnHoldMO		; 保留キーの同時打鍵
			}
			else if(g_KeyInPtn=="RMr" || g_KeyInPtn=="LMl")	; O-M-Oオフ状態
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
			SubSend(MnDown(keyNameHash[g_sansPos]) . MnUp(keyNameHash[g_sansPos]))
			g_sansTick := INFINITE
			keyState[g_sansPos] := 1
		}
	}
	g_trigger := ""
	return

;----------------------------------------------------------------------
; 修飾キー状態読み取り
;----------------------------------------------------------------------
ScanModifier:
	if(g_hookShift == "off") {
		stLShift := GetKeyStateWithLog4(stLShift,fkeyVkeyHash["左Shift"],_kDown)
		stRShift := GetKeyStateWithLog4(stRShift,fkeyVkeyHash["右Shift"],_kDown)
		if(stLShift!=0 || stRShift!=0)
		{
			g_Koyubi := "K"
		} else {
			g_Koyubi := "N"
		}
	}
	g_Modifier := 0x00
	stLCtrl := GetKeyStateWithLog4(stLCtrl,fkeyVkeyHash["左Ctrl"],_kDown)
	g_Modifier := g_Modifier | stLCtrl
	g_Modifier := g_Modifier >> 1			; 0x0200
	stRCtrl := GetKeyStateWithLog4(stRCtrl,fkeyVkeyHash["右Ctrl"],_kDown)
	g_Modifier := g_Modifier | stRCtrl
	g_Modifier := g_Modifier >> 1			; 0x0400
	stLAlt  := GetKeyStateWithLog4(stLAlt,fkeyVkeyHash["左Alt"],_kDown)
	g_Modifier := g_Modifier | stLAlt
	g_Modifier := g_Modifier >> 1			; 0x0800
	stRAlt  := GetKeyStateWithLog4(stRAlt,fkeyVkeyHash["右Alt"],_kDown)
	g_Modifier := g_Modifier | stRAlt
	g_Modifier := g_Modifier >> 1			; 0x1000
	stLWin  := GetKeyStateWithLog4(stLWin,fkeyVkeyHash["左Win"],_kDown)
	g_Modifier := g_Modifier | stLWin
	g_Modifier := g_Modifier >> 1			; 0x2000
	stRWin  := GetKeyStateWithLog4(stRWin,fkeyVkeyHash["右Win"],_kDown)
	g_Modifier := g_Modifier | stRWin
	g_Modifier := g_Modifier >> 1			; 0x4000
	stAppsKey  := GetKeyStateWithLog4(stAppsKey,fkeyVkeyHash["Applications"],_kDown)
	g_Modifier := g_Modifier | stAppsKey	; 0x8000
	return
	

;----------------------------------------------------------------------
; Pauseキー読み取り
;----------------------------------------------------------------------
ScanPauseKey:
	stPause := GetKeyStateWithLog4(stPause,"Pause", _kDown)
	if(_kDown == 1 && g_KeyPause == "Pause") {
		Gosub,pauseKeyDown
	}
	stScrollLock := GetKeyStateWithLog4(stScrollLock,"ScrollLock",_kDown)
	if(_kDown == 1 && g_KeyPause == "ScrollLock") {
		Gosub,pauseKeyDown
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
			SendKeyUp()
			Gosub, SendOnHoldM
		}
	}
	else if(g_KeyInPtn == "MMm")
	{
		Gosub, SendOnHoldMM
		if(g_KeyInPtn == "M") {
			SendKeyUp()
			Gosub, SendOnHoldM
		}
	}
	else if(g_KeyInPtn == "MMM")
	{
		Gosub, SendOnHoldMMM
	}
	else if(g_KeyInPtn="L" || g_KeyInPtn="R")
	{
		Gosub, SendOnHoldO		; 保留キーの同時打鍵
	}
	else if(g_KeyInPtn="ML" || g_KeyInPtn="MR")
	{
		Gosub, SendOnHoldMO		; 保留キーの同時打鍵
	}
	else if(g_KeyInPtn="RM" || g_KeyInPtn="LM")
	{
		Gosub, SendOnHoldMO
	}
	else if(g_KeyInPtn="RMr" || g_KeyInPtn="LMl")
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
GetKeyStateWithLog4(stLast, kName, byRef kDown) {
	kDown := 0
	stCurr := 0
	_keyState := GetKeyState(kName,"P")
	if(_keyState!=0) {
		stCurr := 0x8000
	}
	if(stCurr != 0 && stLast == 0)	; keydown
	{
		kDown := 1
		RegLogs(kName . " down")
	}
	else if(stCurr == 0 && stLast != 0)	; keyup
	{
		RegLogs(kName . " up")
	}
	return stCurr
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
			_keyName := keyNameHash[element]
			if(GetKeyState(_keyName,"P")==0) {
				keyState[element] := 0
			}
			_cont := g_colPushedHash[substr(element,1,1)] . substr(element,2,2)
			_pushedKeys := _pushedKeys . _cont
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
	if(LF[g_Romaji . "NK"]=="" || g_Koyubi == "N") {		
		; 小指シフトオン時に、MS-IMEは英数モードを、Google日本語入力はローマ字モードを返す
		; 両方とも小指シフト面を反映させるため、変換モードは見ない
		; 小指シフト面が設定されていなければ変換モードを見る
		vImeMode := IME_GET() & 32767
		if(vImeMode==0)
		{
			vImeConvMode :=IME_GetConvMode()
			g_Romaji := "A"
		} else {
			vImeConvMode :=IME_GetConvMode()
			if( vImeConvMode & 0x01==1) ;半角カナ・全角平仮名・全角カタカナ
			{
				g_Romaji := "R"
			}
			else ;ローマ字変換モード
			{
				g_Romaji := "A"
			}
		}
	}
	;if(A_IsCompiled <> 1)
	;{
		;vImeConverting := IME_GetConverting() & 32767
		;Tooltip, %g_Romaji% %vImeConvMode%, 0, 0, 2 ; debug
	;}
	return

;----------------------------------------------------------------------
; キーを押下されたときに呼び出されるGotoラベルにフックする
;----------------------------------------------------------------------
SetHookInit()
{
	SetHookInitOne("sc001")		;Esc
	SetHookInitOne("sc03B")		;F1
	SetHookInitOne("sc03C")		;F2
	SetHookInitOne("sc03D")		;F3
	SetHookInitOne("sc03E")		;F4
	SetHookInitOne("sc03F")		;F5
	SetHookInitOne("sc040")		;F6
	SetHookInitOne("sc041")		;F7
	SetHookInitOne("sc042")		;F8
	SetHookInitOne("sc043")		;F9
	SetHookInitOne("sc044")		;F10
	SetHookInitOne("sc057")		;F11
	SetHookInitOne("sc058")		;F12
	SetHookInitOne("sc029")		;半角／全角
	SetHookInitOne("sc002")		;1
	SetHookInitOne("sc003")		;2
	SetHookInitOne("sc004")		;3
	SetHookInitOne("sc005")		;4
	SetHookInitOne("sc006")		;5
	SetHookInitOne("sc007")		;6
	SetHookInitOne("sc008")		;7
	SetHookInitOne("sc009")		;8
	SetHookInitOne("sc00A")		;9
	SetHookInitOne("sc00B")		;0
	SetHookInitOne("sc00C")		;-
	SetHookInitOne("sc00D")		;^
	SetHookInitOne("sc07D")		;\
	SetHookInitOne("sc00E")		;\b
	
	SetHookInitOne("sc00F")		;\t
	SetHookInitOne("sc010")		;q
	SetHookInitOne("sc011")		;w
	SetHookInitOne("sc012")		;e
	SetHookInitOne("sc013")		;r
	SetHookInitOne("sc014")		;t
	SetHookInitOne("sc015")		;y
	SetHookInitOne("sc016")		;u
	SetHookInitOne("sc017")		;i
	SetHookInitOne("sc018")		;o
	SetHookInitOne("sc019")		;p
	SetHookInitOne("sc01A")		;@
	SetHookInitOne("sc01B")		;[

	SetHookInitOne("sc01E")		;a
	SetHookInitOne("sc01F")		;s
	SetHookInitOne("sc020")		;d
	SetHookInitOne("sc021")		;f
	SetHookInitOne("sc022")		;g
	SetHookInitOne("sc023")		;h
	SetHookInitOne("sc024")		;j
	SetHookInitOne("sc025") 	;k
	SetHookInitOne("sc026") 	;l
	SetHookInitOne("sc027")		;';'
	SetHookInitOne("sc028")		;'*'
	SetHookInitOne("sc02B")		;']'
	SetHookInitOne("sc01C")		;\r
	
	SetHookInitOne("sc02C")		;z
	SetHookInitOne("sc02D")		;x
	SetHookInitOne("sc02E")		;c
	SetHookInitOne("sc02F")		;v
	SetHookInitOne("sc030")		;b
	SetHookInitOne("sc031")		;n
	SetHookInitOne("sc032")		;m
	SetHookInitOne("sc033")		;,
	SetHookInitOne("sc034")		;.
	SetHookInitOne("sc035")		;/
	SetHookInitOne("sc073")		;\
	;-----------------------------------------------------------------------
	; 機能：モディファイアキー
	;-----------------------------------------------------------------------
	;WindowsキーとAltキーをホットキー登録すると、
	;WindowsキーやAltキーの単体押しが効かなくなるのでコメントアウトする。
	;代わりにInterrupt10 でA_Priorkeyを見て、Windowsキーを監視する。
	;但し、WindowsキーやAltキーを離したことを感知できないことに留意。
	;ver.0.1.3 にて、GetKeyState でWindowsキーとAltキーとを監視
	;ver.0.1.3.7 ... Ctrlはやはり必要なので戻す
	SetHookInitOne("sc01D")		;LCtrl
	SetHookInitOne("sc07B")		;無変換
	SetHookInitOne("sc039")		;Space
	SetHookInitOne("sc079")		;変換
	SetHookInitOne("sc070")		;ひらがな／カタカナ
	SetHookInitOne("sc11D")		;RCtrl
	SetHookInitOne("sc02A")		;左Shift
	SetHookInitOne("sc15B")		;左Win
	SetHookInitOne("sc038")		;左Alt
	SetHookInitOne("sc138")		;右Alt
	SetHookInitOne("sc15C")		;右Win
	SetHookInitOne("sc15D")		;Applications
	SetHookInitOne("sc136")		;右Shift
	return
}
;----------------------------------------------------------------------
; 一つのキーを初期化する
;----------------------------------------------------------------------
SetHookInitOne(sCode)
{
	hotkey,*%sCode%,g%sCode%
	hotkey,*%sCode%,off
	hotkey,*%sCode% up,g%sCode%up
	hotkey,*%sCode% up,off
}

;----------------------------------------------------------------------
; ファンクションキーをオン・オフする
;----------------------------------------------------------------------
SetHookFunction(flg)
{
	SetHookFunctionByName("Escape", flg)
	SetHookFunctionByName("F1", flg)
	SetHookFunctionByName("F2", flg)
	SetHookFunctionByName("F3", flg)
	SetHookFunctionByName("F4", flg)
	SetHookFunctionByName("F5", flg)
	SetHookFunctionByName("F6", flg)
	SetHookFunctionByName("F7", flg)
	SetHookFunctionByName("F8", flg)
	SetHookFunctionByName("F9", flg)
	SetHookFunctionByName("F10", flg)
	SetHookFunctionByName("F11", flg)
	SetHookFunctionByName("F12", flg)
	SetHookFunctionByName("半角/全角", flg)
	SetHookFunctionByName("左Ctrl", flg)
	SetHookFunctionByName("カタカナ/ひらがな", flg)
	SetHookFunctionByName("右Ctrl", flg)
	SetHookFunctionByName("左Shift", flg)
	SetHookFunctionByName("左Win", flg)
	SetHookFunctionByName("左Alt", flg)
	SetHookFunctionByName("右Alt", flg)
	SetHookFunctionByName("右Win", flg)
	SetHookFunctionByName("Applications", flg)
	SetHookFunctionByName("右Shift", flg)
}
;----------------------------------------------------------------------
; 指定された名称のキーのHotkeyをオン・オフする
;----------------------------------------------------------------------
SetHookFunctionByName(kName, flg)
{
	global keyAttribute3, fkeyPosHash, fkeyCodeHash

	_pos := fkeyPosHash[kName]
	_scode := fkeyCodeHash[kName]
	if(_pos=="" || _scode=="") {
		return
	}
	if(keyAttribute3["RK" . _pos]!="") {
		hotkey,*%_scode%,%flg%		;Esc
		hotkey,*%_scode% up,%flg%
	} else {
		hotkey,*%_scode%,off
		hotkey,*%_scode% up,off
	}
}
;----------------------------------------------------------------------
; 動的にホットキーをオン・オフする
; flg : 文字キーと機能キー
;----------------------------------------------------------------------
SetHook(flg)
{
	hotkey,*sc002,%flg%		;1
	hotkey,*sc002 up,%flg%
	hotkey,*sc003,%flg%		;2
	hotkey,*sc003 up,%flg%
	hotkey,*sc004,%flg%		;3
	hotkey,*sc004 up,%flg%
	hotkey,*sc005,%flg%		;4
	hotkey,*sc005 up,%flg%
	hotkey,*sc006,%flg%		;5
	hotkey,*sc006 up,%flg%
	hotkey,*sc007,%flg%		;6
	hotkey,*sc007 up,%flg%
	hotkey,*sc008,%flg%		;7
	hotkey,*sc008 up,%flg%
	hotkey,*sc009,%flg%		;8
	hotkey,*sc009 up,%flg%
	hotkey,*sc00A,%flg%		;9
	hotkey,*sc00A up,%flg%
	hotkey,*sc00B,%flg%		;0
	hotkey,*sc00B up,%flg%
	hotkey,*sc00C,%flg%		;-
	hotkey,*sc00C up,%flg%
	hotkey,*sc00D,%flg%		;^
	hotkey,*sc00D up,%flg%
	hotkey,*sc07D,%flg%		;\
	hotkey,*sc07D up,%flg%
	hotkey,*sc00E,%flg%		;\b
	hotkey,*sc00E up,%flg%
	
	hotkey,*sc00F,%flg%		;\t
	hotkey,*sc00F up,%flg%
	hotkey,*sc010,%flg%		;q
	hotkey,*sc010 up,%flg%
	hotkey,*sc011,%flg%		;w
	hotkey,*sc011 up,%flg%
	hotkey,*sc012,%flg%		;e
	hotkey,*sc012 up,%flg%
	hotkey,*sc013,%flg%		;r
	hotkey,*sc013 up,%flg%
	hotkey,*sc014,%flg%		;t
	hotkey,*sc014 up,%flg%
	hotkey,*sc015,%flg%		;y
	hotkey,*sc015 up,%flg%
	hotkey,*sc016,%flg%		;u
	hotkey,*sc016 up,%flg%
	hotkey,*sc017,%flg%		;i
	hotkey,*sc017 up,%flg%
	hotkey,*sc018,%flg%		;o
	hotkey,*sc018 up,%flg%
	hotkey,*sc019,%flg%		;p
	hotkey,*sc019 up,%flg%
	hotkey,*sc01A,%flg%		;@
	hotkey,*sc01A up,%flg%
	hotkey,*sc01B,%flg%		;[
	hotkey,*sc01B up,%flg%
	
	hotkey,*sc01E,%flg%		;a
	hotkey,*sc01E up,%flg%
	hotkey,*sc01F,%flg%		;s
	hotkey,*sc01F up,%flg%
	hotkey,*sc020,%flg%		;d
	hotkey,*sc020 up,%flg%
	hotkey,*sc021,%flg%		;f
	hotkey,*sc021 up,%flg%
	hotkey,*sc022,%flg%		;g
	hotkey,*sc022 up,%flg%
	hotkey,*sc023,%flg%		;h
	hotkey,*sc023 up,%flg%
	hotkey,*sc024,%flg% 	;j
	hotkey,*sc024 up,%flg%
	hotkey,*sc025,%flg% 	;k
	hotkey,*sc025 up,%flg%
	hotkey,*sc026,%flg% 	;l
	hotkey,*sc026 up,%flg%
	hotkey,*sc027,%flg% 	;';'
	hotkey,*sc027 up,%flg%
	hotkey,*sc028,%flg% 	;'*'
	hotkey,*sc028 up,%flg%
	hotkey,*sc02B,%flg% 	;']'
	hotkey,*sc02B up,%flg%
	hotkey,*sc01C,%flg%		;Enter
	hotkey,*sc01C up,%flg%
	
	hotkey,*sc02C,%flg%		;z
	hotkey,*sc02C up,%flg%
	hotkey,*sc02D,%flg%		;x
	hotkey,*sc02D up,%flg%
	hotkey,*sc02E,%flg%		;c
	hotkey,*sc02E up,%flg%
	hotkey,*sc02F,%flg%		;v
	hotkey,*sc02F up,%flg%
	hotkey,*sc030,%flg%		;b
	hotkey,*sc030 up,%flg%
	hotkey,*sc031,%flg%		;n
	hotkey,*sc031 up,%flg%
	hotkey,*sc032,%flg%		;m
	hotkey,*sc032 up,%flg%
	hotkey,*sc033,%flg%		;,
	hotkey,*sc033 up,%flg%
	hotkey,*sc034,%flg%		;.
	hotkey,*sc034 up,%flg%
	hotkey,*sc035,%flg%		;/
	hotkey,*sc035 up,%flg%
	hotkey,*sc073,%flg%		;\
	hotkey,*sc073 up,%flg%
	SetHookFunctionByName("Space", flg)
	return
}

;----------------------------------------------------------------------
; 動的に変換・無変換キーをオン・オフする
;----------------------------------------------------------------------
SetHookHenkan(flg)
{
	SetHookFunctionByName("無変換", flg)
	SetHookFunctionByName("変換", flg)
}

;----------------------------------------------------------------------
; キーオンのイベント
;----------------------------------------------------------------------
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
;	Ａ段目
gSC01D:	;LCtrl
gSC11D:	;RCtrl

gSC02A:	;左Shift
gSC15B:	;左Win
gSC038:	;左Alt
gSC138:	;右Alt
gSC15C:	;右Win
gSC15D:	;Applications
gSC136:	;右Shift
	critical
	Gosub,ScanModifier
	g_layoutPos := layoutPosHash[A_ThisHotkey]
	g_metaKey := keyAttribute3[g_Romaji . KoyubiOrSans(g_Koyubi,g_sans) . g_layoutPos]
	kName := keyNameHash[g_layoutPos]
	if(g_Modifier != 0) {
		Gosub,ModeInitialize
	}
	if(kName=="sc02A" || kName=="sc136") {
		g_Koyubi := "K"
	}
	goto, keydown%g_metaKey%

;　Ｅ段目
;gSC029:	;半角／全角
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
;gSC01D:	;LCtrl
gSC07B:	;無変換キー（左）
gSC039:	;Space
gSC079:	;変換キー（右）
gSC070:	;ひらがな／カタカナ
;gSC11D:	;RCtrl

;gSC02A: ;左Shift
;gSC15B: ;左Win
;gSC038: ;左Alt
;gSC138: ;右Alt
;gSC15C: ;右Win
;gSC15D: ;Applications
;gSC136: ;右Shift
	critical
	Gosub,ScanModifier
	g_layoutPos := layoutPosHash[A_ThisHotkey]
	g_metaKey := keyAttribute3[g_Romaji . KoyubiOrSans(g_Koyubi,g_sans) . g_layoutPos]
	kName := keyNameHash[g_layoutPos]
	if(g_Modifier != 0) {
		RegLogs(kName . " down")
		Gosub,ModeInitialize
		; 修飾キー＋文字キーの同時押しのときに
		SendModifier(SetModifierSymbol(g_Modifier),kName)
		clearQueue()
		g_SendTick := INFINITE
		g_KeyInPtn := ""
		g_prefixshift := ""
		critical,off
		return
	}
	GuiControl,2:,vkeyDN%g_layoutPos%,□
	goto, keydown%g_metaKey%

;----------------------------------------------------------------------
; 修飾シンボルの設定
;----------------------------------------------------------------------
SetModifierSymbol(_modifier) {
	_symbol := ""
	if((_modifier & 0x6000)!=0){
		_symbol := "#"
	}
	if((_modifier & 0x1800)!=0) {
		_symbol := _symbol . "!"
	}
	if((_modifier & 0x0600)!=0) {
		_symbol := _symbol . "^"
	}
	return _symbol
}
;----------------------------------------------------------------------
; キーオフのイベント
;----------------------------------------------------------------------
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
	g_layoutPos := layoutPosHash[A_ThisHotkey]
	g_metaKey := keyAttribute3[g_Romaji . KoyubiOrSans(g_Koyubi,g_sans) . g_layoutPos]
	kName := keyNameHash[g_layoutPos]
	if(kName=="sc02A" || kName=="sc136") {
		g_Koyubi := "N"
	}
	GuiControl,2:,vkeyDN%g_layoutPos%,　
	goto, keyup%g_metaKey%

