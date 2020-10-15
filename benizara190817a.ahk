;-----------------------------------------------------------------------
;	名称：benizara / 紅皿
;	機能：Yet another NICOLA Emulaton Software
;         キーボード配列エミュレーションソフト
;	ver.0.1.4.2 .... 2020/10/3
;	作者：Ken'ichiro Ayaki
;-----------------------------------------------------------------------
	#InstallKeybdHook
	#MaxhotkeysPerInterval 200
	#MaxThreads 64
	#KeyHistory
#SingleInstance, Off
	g_Ver := "ver.0.1.4.3"
	g_Date := "2020/10/5"
	MutexName := "benizara"
    If DllCall("OpenMutex", Int, 0x100000, Int, 0, Str, MutexName)
    {
		TrayTip,キーボード配列エミュレーションソフト「紅皿」,多重起動は禁止されています。
        ExitApp
	}
    hMutex := DllCall("CreateMutex", Int, 0, Int, False, Str, MutexName)
	
	TrayTip,キーボード配列エミュレーションソフト「紅皿」,benizara %g_Ver%
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
	g_Threshold := 150	; 
	g_Overlap := 50
	g_ZeroDelay := 1		; 零遅延モード
	g_ZeroDelayOut := ""
	g_Offset := 20
	g_OyaR := 0
	g_OyaRDown := 0
	g_OyaL := 0	
	g_OyaLDown := 0
	g_trigger := ""
	vLayoutFile := g_LayoutFile
	g_Tau := 0
	GoSub,Init
	Gosub,ReadLayout
	g_allTheLayout := vAllTheLayout
	g_LayoutFile := vLayoutFile
	
	g_SendTick := ""
	if(A_IsCompiled == 1)
	{
		Menu, Tray, NoStandard
	}
	Menu, Tray, Add, 紅皿設定,Settings
	Menu, Tray, Add, 配列,ShowLayout
	Menu, Tray, Add, ログ,Logs
	Menu, Tray, Add, 終了,Menu_Exit 	
	Menu, Tray, Icon
	SetBatchLines, -1
	SetHook("init")
	fPf := Pf_Init()
	g_OyaRTick := Pf_Count()	;A_TickCount
	g_OyaLTick := Pf_Count()	;A_TickCount
	g_MojiTick := Pf_Count()	;A_TickCount
	VarSetCapacity(lpKeyState,256,0)
	SetTimer,Interrupt10,10
	
	vIntKeyUp := 0
	vIntKeyDn := 0
	SetHook("off")
	return


Menu_Exit:
	DllCall("ReleaseMutex", Ptr, hMutex)
	exitapp

#include IME.ahk
#include ReadLayout6.ahk
#include Settings7.ahk
#include PfCount.ahk
#include Logs1.ahk
#include ShowLayout.ahk


;-----------------------------------------------------------------------
; 親指シフトキー
;-----------------------------------------------------------------------

gOyaR:
	Critical
	g_trigger := "R"
	gosub,Polling
	RegLogs("R down")
	if(g_OyaR = 1 && g_KeyRepeat = 1)
	{
		g_OyaR := 1
		g_OyaRDown := 1
		g_OyaRTick := Pf_Count()				; A_TickCount
		g_MRInterval := g_OyaRTick - g_MojiTick	; 文字キー押しから右親指キー押しまでの期間
		g_Oya := "R"

		Gosub, SendOnHoldO	; 保留キーの打鍵
		g_OyaOnHold := g_Oya
		g_SendTick := g_OyaRTick + g_Threshold
		g_KeyInPtn := g_Oya
		critical,off
		return
	}
	if(g_OyaR != 1) 	; キーリピートの抑止
	{
		g_OyaR := 1
		g_OyaRDown := 1
		g_OyaRTick := Pf_Count()				;A_TickCount
		g_MRInterval := g_OyaRTick - g_MojiTick	; 文字キー押しから右親指キー押しまでの期間
		g_Oya := "R"
		
		if(g_KeyInPtn = "") 			;初期状態
		{
			g_OyaOnHold := g_Oya
			g_SendTick := g_OyaRTick + g_Threshold
			g_KeyInPtn := g_KeyInPtn . g_Oya
		}
		else if(g_KeyInPtn = "M")		;Mオン状態
		{
			g_OyaOnHold := g_Oya
			g_SendTick := g_OyaRTick + g_MRInterval
			g_KeyInPtn := g_KeyInPtn . g_Oya
		}
		else if(g_KeyInPtn = "L")		;Oオン状態
		{
			Gosub, SendOnHoldO	; 保留キーの打鍵
			g_OyaOnHold := g_Oya
			g_SendTick := g_OyaRTick + g_Threshold
			g_KeyInPtn := g_KeyInPtn . g_Oya
		}
		else if(g_KeyInPtn = "ML")	; M-Oオン状態
		{
			Gosub, SendOnHoldMO	; 保留キーの打鍵
			g_OyaOnHold := g_Oya
			g_SendTick := g_OyaRTick + g_Threshold
			g_KeyInPtn := g_KeyInPtn . g_Oya
		}
		else if(g_KeyInPtn = "LM")		; O-Mオン状態
		{
			; 処理B 3キー判定
			g_LMInterval := g_MojiTick - g_OyaLTick		; 左親指キー押しから文字キー押しまでの期間
			g_MRInterval := g_OyaRTick - g_MojiTick		; 文字キー押しから右親指キー押しまでの期間
			if(g_MRInterval > g_LMInterval)
			{
				Gosub, SendOnHoldMO	; 保留キーの打鍵
				g_OyaOnHold := g_Oya
				g_SendTick := g_OyaRTick + g_Threshold
				g_KeyInPtn := g_KeyInPtn . g_Oya
			}
			else
			{
				if(g_ZeroDelayOut<>"")
				{
					SubSend(MnDown("Backspace") . MnUp("Backspace"))
				}
				Gosub, SendOnHoldO	; 保留キーの打鍵
				g_OyaOnHold := g_Oya
				g_SendTick := g_OyaRTick + g_MRInterval
				g_KeyInPtn := g_KeyInPtn . g_Oya
				Gosub,SendZeroDelay
			}
		}
		else if(g_KeyInPtn="RMr" || g_KeyInPtn="LMl")	; O-M-Oオフ状態
		{
			Gosub, SendOnHoldMO	; 保留キーの打鍵
			g_OyaOnHold := g_Oya
			g_SendTick := g_OyaRTick + g_MRInterval
			g_KeyInPtn := g_KeyInPtn . g_Oya
		}
	}
	critical,off
	return  

gOyaRUp:
	Critical
	g_trigger := "R up"
	gosub,Polling
	if(g_OyaR = 1)	; 右親指シフトキーの単独シフト
	{
		RegLogs("R up")
		g_OyaR := 0
		g_OyarTick := Pf_Count()				;A_TickCount
		g_MrInterval := g_OyarTick - g_MojiTick	; 文字キー押しから右親指キー解除までの期間
		g_RrInterval := g_OyarTick - g_OyaRTick	; 右親指キー押しから右親指キー解除までの期間

		if(g_Continue = 1)
		{
			if(g_OyaL = 1)
				g_Oya := "L"
			else
				g_Oya := "N"
		}
		
		if(g_KeyInPtn = "R")		; Oオン状態
		{
			Gosub, SendOnHoldO		; 保留親指キーの打鍵
		}
		else if(g_KeyInPtn = "MR")	; M-Oオン状態
		{
			if(g_RrInterval > g_Threshold)
			{
				; タイムアウト状態：親指シフト文字の出力
				Gosub, SendOnHoldMO	; 保留キーの打鍵
			} else {
				; 処理F
				vOverlap := 100*g_RrInterval/g_MrInterval
				if(vOverlap <= g_Overlap && g_RrInterval <= g_Tau)
				{
					Gosub, SendOnHoldM	; 保留キーの単独打鍵
					Gosub, SendOnHoldO	; 保留キーの単独打鍵
				} else {
					Gosub, SendOnHoldMO	; 保留キーの同時打鍵
				}
			}
		}
		else if(g_KeyInPtn = "RM")		; O-Mオン状態
		{
			if(g_MrInterval > g_Threshold)
			{
				; タイムアウト状態：親指シフト文字の出力
				Gosub, SendOnHoldMO	; 保留キーの打鍵
			} else {
				; 処理D
				vOverlap := 100*g_MrInterval/g_RrInterval
				if(vOverlap <= g_Overlap && g_MrInterval <= g_Tau)
				{
					Gosub, SendOnHoldO	; 保留キーの単独打鍵
				} else {
					;g_MrTimeout := g_MrInterval*(100-g_Overlap)/g_Overlap
					;g_MrTimeout := g_MrInterval/2
					g_MrTimeout := g_MrInterval
					g_SendTick := g_OyarTick + g_MrTimeout
					g_KeyInPtn := "RMr"
				}
			}
		}
		else if(g_KeyInPtn="M" || g_KeyInPtn="RMr" || g_KeyInPtn="LMl") 		; O-M-Oオフ状態
		{
			; 何もしない
		}
		g_OyaRDown := 0
	}
	critical,off
	return

gOyaL:	; 無変換
	Critical
	g_trigger := "L"
	gosub,Polling
	RegLogs("L down")
	if(g_OyaL = 1 && g_KeyRepeat = 1)
	{
		g_OyaL := 1
		g_OyaLDown := 1
		g_OyaLTick := Pf_Count()	;A_TickCount
		g_MLInterval := g_OyaLTick - g_MojiTick		; 文字キー押しから左親指キー押しまでの期間
		g_Oya := "L"
		
		Gosub, SendOnHoldO	; 保留キーの打鍵
		g_OyaOnHold := g_Oya
		g_SendTick := g_OyaLTick + g_Threshold
		g_KeyInPtn := g_Oya
		critical,off
		return
	}
	if(g_OyaL != 1)	; キーリピートの抑止
	{
		g_OyaL := 1
		g_OyaLDown := 1
		g_OyaLTick := Pf_Count()	;A_TickCount
		g_MLInterval := g_OyaLTick - g_MojiTick		; 文字キー押しから左親指キー押しまでの期間
		g_Oya := "L"
				
		if(g_KeyInPtn = "")				; 初期状態
		{
			g_OyaOnHold := g_Oya
			g_SendTick := g_OyaLTick + g_Threshold
			g_KeyInPtn := g_Oya
		}
		else if(g_KeyInPtn = "M")		; Mオン状態
		{
			g_OyaOnHold := g_Oya
			g_SendTick := g_OyaLTick + g_MLInterval
			g_KeyInPtn := g_KeyInPtn . g_Oya
		}
		else if(g_KeyInPtn = "R")		; Oオン状態
		{
			Gosub, SendOnHoldO	; 保留キーの打鍵
			g_OyaOnHold := g_Oya
			g_SendTick := g_OyaLTick + g_Threshold
			g_KeyInPtn := g_KeyInPtn . g_Oya
		}
		else if(g_KeyInPtn = "MR")		; M-Oオン状態
		{
			Gosub, SendOnHoldMO	; 保留キーの打鍵
			g_OyaOnHold := g_Oya
			g_SendTick := g_OyaLTick + g_Threshold
			g_KeyInPtn := g_KeyInPtn . g_Oya
		}
		else if(g_KeyInPtn = "RM")		; O-Mオン状態
		{
			; 処理B 3キー判定
			g_RMInterval := g_MojiTick - g_OyaRTick		; 右親指キー押しから文字キー押しまでの期間
			g_MLInterval := g_OyaLTick - g_MojiTick		; 文字キー押しから左親指キー押しまでの期間
			if(g_MRInterval > g_LMInterval)
			{
				Gosub, SendOnHoldMO	; 文字キーを親指シフトして打鍵
				g_OyaOnHold := g_Oya
				g_SendTick := g_OyaLTick + g_Threshold
				g_KeyInPtn := g_KeyInPtn . g_Oya
			} else {
				if(g_ZeroDelayOut<>"")
				{
					SubSend(MnDown("Backspace") . MnUp("Backspace"))
				}
				Gosub, SendOnHoldO	; 親指キーの単独打鍵
				g_OyaOnHold := g_Oya
				g_SendTick := g_OyaLTick + g_MLInterval
				g_KeyInPtn := g_KeyInPtn . g_Oya
				Gosub,SendZeroDelay
			}
		}
		else if(g_KeyInPtn="RMr" || g_KeyInPtn="LMl")		; O-M-Oオフ状態
		{
			Gosub, SendOnHoldMO		; 文字キーを親指シフトして打鍵
			g_OyaOnHold := g_Oya
			g_SendTick := g_OyaLTick + g_MLInterval
			g_KeyInPtn := g_KeyInPtn . g_Oya
		}
	}
	critical,off
 	return

gOyaLUp:
	Critical
	g_trigger := "L up"
	gosub,Polling
	if(g_OyaL != 0)	; 右親指シフトキーの単独シフト
	{
		RegLogs("L up")
		g_OyaL := 0
		g_OyalTick := Pf_Count()				;A_TickCount
		g_MlInterval := g_OyalTick - g_MojiTick	; 文字キー押しから左親指キー解除までの期間
		g_LlInterval := g_OyalTick - g_OyaLTick	; 右親指キー押しから右親指キー解除までの期間

		if(g_Continue = 1) 
		{
			if(g_OyaR = 1)
				g_Oya := "R"
			else
				g_Oya := "N"
		}

		if(g_KeyInPtn = "L")			; Oオン状態
		{
			Gosub, SendOnHoldO		; 保留親指キーの打鍵
		}
		else if(g_KeyInPtn = "ML")		;M-Oオン状態
		{
			if(g_LlInterval > g_Threshold)
			{
				; タイムアウト
				Gosub, SendOnHoldMO	; 保留キーの打鍵
			} else {
				; 処理F
				vOverlap := 100*g_LlInterval/g_MlInterval
				if(vOverlap <= g_Overlap && g_LlInterval <= g_Tau)
				{
					Gosub, SendOnHoldM	; 保留キーの単独打鍵
					Gosub, SendOnHoldO	; 保留キーの単独打鍵
				} else {
					Gosub, SendOnHoldMO	; 保留キーの同時打鍵
				}
			}
		}
		else if(g_KeyInPtn = "LM")		;O-Mオン状態
		{
			if(g_MlInterval > g_Threshold)
			{
				; タイムアウト
				Gosub, SendOnHoldMO	; 保留キーの打鍵
			} else {
				; 処理D
				vOverlap := 100*g_MlInterval/g_LlInterval
				if(vOverlap <= g_Overlap && g_MlInterval <= g_Tau)
				{
					Gosub, SendOnHoldO	; 保留キーの単独打鍵
					g_KeyInPtn := "M"
				} else {
					;g_MlTimeout := g_MlInterval*(100-g_Overlap)/g_Overlap
					;g_MlTimeout := g_MlInterval/2
					g_MlTimeout := g_MlInterval
					g_SendTick := g_OyalTick + g_MlTimeout
					g_KeyInPtn := "LMl"
				}
			}
		}
		else if(g_KeyInPtn="M" || g_KeyInPtn="RMr" || g_KeyInPtn="LMl")
		{
			; 何もしない
		}
		g_OyaLDown := 0
	}
	critical,off
	return

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
; キーダウン時にSendする文字列を設定する
; 引数　：aStr：対応するキー入力
; 戻り値：Sendの引数
;----------------------------------------------------------------------
MnDown(aStr) {
	vOut := ""
	if(aStr<>"")
	{
		vOut = {Blind}{%aStr% down}
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
		vOut = {Blind}{%aStr% up}
	}
	return vOut
}
;--------------------------------------------------------------------y-
; 送信文字列の出力
;----------------------------------------------------------------------
SubSend(vOut)
{
	global aLog,idxLogs, aLogCnt, g_KeyInPtn
	
	if(vOut<>"")
	{
		SetKeyDelay -1
		Send %vOut%
		RegLogs("       " . substr(g_KeyInPtn . "   ",1,3) . vOut)
	}
	return
}
;--------------------------------------------------------------------y-
; キーから送信文字列に変換
;----------------------------------------------------------------------
MnDownUp(key)
{
	if(key <> "")
		return "{Blind}{" . key . " down}{" . key . " up}"
	else
		return ""
}
;--------------------------------------------------------------------y-
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
	vOut :=                   kdn%g_RomajiOnHold%%g_OyaOnHold%%g_KoyubiOnHold%%g_MojiOnHold%
	kup_save%g_MojiOnHold% := kup%g_RomajiOnHold%%g_OyaOnHold%%g_KoyubiOnHold%%g_MojiOnHold%
	if(g_ZeroDelay = 1)
	{
		if(vOut <> g_ZeroDelayOut)
		{
			_save := g_KeyInPtn
			
			SubSend(MnDown("Backspace") . MnUp("Backspace"))
			SubSend(vOut)
		}
		g_ZeroDelayOut := ""
	} else {
		SubSend(vOut)
	}
	g_MojiOnHold := ""
	g_OyaOnHold := "N"
	g_KoyubiOnHold := "N"
	g_SendTick := ""
	g_KeyInPtn := ""
	if(g_Continue = 0)	; 連続モードではない
	{
		g_Oya := "N"
	}
	return

;----------------------------------------------------------------------
; 保留キーの出力：セットされた文字の出力
;----------------------------------------------------------------------
SendOnHoldM:
	vOut :=                   kdn%g_RomajiOnHold%N%g_KoyubiOnHold%%g_MojiOnHold%
	kup_save%g_MojiOnHold% := kup%g_RomajiOnHold%N%g_KoyubiOnHold%%g_MojiOnHold%

	if(g_ZeroDelay = 1)
	{
		if(vOut <> g_ZeroDelayOut)
		{
			_save := g_KeyInPtn
			;vOut1 := "{Blind}{Backspace down}{Backspace up}" 
			;SubSend(vOut1)
			SubSend(MnDown("Backspace") . MnUp("Backspace"))
			SubSend(vOut)
		}
		g_ZeroDelayOut := ""
	} else {
		SubSend(vOut)
	}
	g_MojiOnHold := ""
	g_KoyubiOnHold := "N"
	g_SendTick := ""
	if(g_KeyInPtn = "MR")
	{
		g_keyInPtn := "R"
	}
	else if(g_KeyInPtn = "ML")
	{
		g_keyInPtn := "L"
	}
	else if(g_KeyInPtn = "M")
	{
		g_keyInPtn := ""
	}
	else if(g_KeyInPtn = "RMr" || g_KeyInPtn = "LMl")
	{
		g_keyInPtn := ""
	}
	return

;----------------------------------------------------------------------
; 保留された親指キーの出力
;----------------------------------------------------------------------
SendOnHoldO:
	if(g_OyaOnHold = "R")
	{
		if(g_KeySingle = "有効")
		{
			if(g_OyaRDown=1)
			{
				SubSend(MnDown(kOyaR) . MnUp(kOyaR))
				g_OyaRDown := 0
			}
		}
		if(g_KeyInPtn="RM" || g_KeyInPtn="RMr" || g_KeyInPtn="MR")
		{
			g_keyInPtn := "M"
		}
		else if(g_KeyInPtn = "R")
		{
			g_keyInPtn := ""
		}
	}
	else if(g_OyaOnHold = "L")
	{
		if(g_KeySingle = "有効")
		{
			if(g_OyaLDown=1)
			{
				SubSend(MnDown(kOyaL) . MnUp(kOyaL))
				g_OyaLDown := 0
			}
		}
		if(g_KeyInPtn ="LM" || g_KeyInPtn ="LMl" || g_KeyInPtn ="ML")
		{
			g_keyInPtn := "M"
		}
		else if(g_KeyInPtn = "L")
		{
			g_keyInPtn := ""
		}
	}
	; 連続モードでなければ押されていない状態に
	if(g_Continue = 0)
	{
		g_OyaOnHold := "N"
		g_Oya := "N"
	}
	return

;----------------------------------------------------------------------
; キー押下
;----------------------------------------------------------------------
keydown:
	Critical
	vkeyD%MojiCode% := "□"
	
	_ch := "□"
	GuiControl,4:,vkeyX%MojiCode%,%_ch%
	
	g_trigger := kName
	RegLogs(kName . " down")

	gosub,Polling
	if(MojiCode = 0)	; 文字キー以外(space,tab,Enter,Ctrl)
	{
		g_ModifierTick := Pf_Count()	;A_TickCount
		Gosub,ModeInitialize

		SubSend(MnDown(kName))
		g_KeyInPtn := ""
		critical,off
		return
	}
	if(g_MojiOnHold<>"")
	{
		; 文字キーダウン
		if(g_KeyInPtn = "M")
		{
			Gosub, SendOnHoldM
		}
		else if(g_KeyInPtn="ML" || g_KeyInPtn="MR")
		{
			; 処理A 3キー判定
			if(g_KeyInPtn = "MR")
			{
				g_OMInterval := g_MojiTick - g_OyaRTick
				g_MOInterval := g_MRInterval
			} else {
				g_OMInterval := g_MojiTick - g_OyaLTick
				g_MOInterval := g_MLInterval
			}
			if(g_OMInterval <= g_MOInterval)	; 文字キーaから親指キーsまでの時間は、親指キーsから文字キーbまでの時間よりも長い
			{
				Gosub, SendOnHoldM		; 保留キーの単独打鍵
			} else {
				Gosub, SendOnHoldMO		; 保留キーの同時打鍵
			}
		}
		else if(g_KeyInPtn="RM" || g_KeyInPtn="LM")
		{
			Gosub, SendOnHoldMO
		}
		else if(g_KeyInPtn="RMr" || g_KeyInPtn="LMl")
		{
			Gosub, SendOnHoldMO			; 同時打鍵
		}
	}
	g_MojiTick := Pf_Count()	;A_TickCount

	SetKeyDelay -1
	Gosub,ScanModifier
	if(g_Modifier != 0)		; 修飾キーが押されている
	{
		; 修飾キー＋文字キーの同時押しのときは、英数レイアウトで出力
		vOut               := mdnANN%MojiCode%
		kup_save%MojiCode% := mupANN%MojiCode%
		SubSend(vOut)
		
		g_MojiOnHold := ""
		g_OyaOnHold  := "N"
		g_KoyubiOnHold := "N"
		g_SendTick := ""
		g_KeyInPtn := ""
		critical,off
		return
	}
	Critical,5
	Gosub,ChkIME
	
	if(g_Oya = "N")
	{
		; 当該キーを単独打鍵として保留
		g_MojiOnHold := MojiCode
		g_RomajiOnHold := g_Romaji
		g_OyaOnHold := g_Oya
		g_KoyubiOnHold := g_Koyubi
		g_SendTick := g_MojiTick + g_Threshold
		g_KeyInPtn := "M"
	}
	else
	{
		if(g_Oya = "R")
		{
			g_OMInterval := g_MojiTick - g_OyaRTick
		}
		else if(g_Oya = "L")
		{
			g_OMInterval := g_MojiTick - g_OyaLTick
		}
		g_MojiOnHold := MojiCode
		g_RomajiOnHold := g_Romaji
		g_OyaOnHold := g_Oya
		g_KoyubiOnHold := g_Koyubi
		if(g_Continue = 0)	; 連続モードではない
		{
			g_SendTick := g_MojiTick + g_OMInterval
			g_KeyInPtn := g_Oya . "M"
		} else {
			g_SendTick := g_MojiTick + g_Threshold
			g_KeyInPtn := g_Oya . "M"
		}
	}
	Gosub,SendZeroDelay
	critical,off
	return

SendZeroDelay:
	if(g_MojiOnHold<>"")	; 当該キーの保留
	{
		; 左右親指シフト面と非シフト面の文字キーが同一ならば、保留しない
		if(kdn%g_RomajiOnHold%N%g_KoyubiOnHold%%g_MojiOnHold% == kdn%g_RomajiOnHold%R%g_KoyubiOnHold%%g_MojiOnHold%)
		{
			if(kdn%g_RomajiOnHold%N%g_KoyubiOnHold%%g_MojiOnHold% == kdn%g_RomajiOnHold%L%g_KoyubiOnHold%%g_MojiOnHold%)
			{
				vOut                   := kdn%g_RomajiOnHold%%g_OyaOnHold%%g_KoyubiOnHold%%g_MojiOnHold%
				kup_save%g_MojiOnHold% := kup%g_RomajiOnHold%%g_OyaOnHold%%g_KoyubiOnHold%%g_MojiOnHold%
				SubSend(vOut)
				g_MojiOnHold := ""
				g_OyaOnHold  := "N"
				g_KoyubiOnHold := "N"
				g_SendTick := ""
				g_KeyInPtn := ""
			}
		}
		; 左右親指シフト面と非シフト面の文字キーに制御コードが有れば、保留しない
		if(mod(strlen(kdn%g_RomajiOnHold%N%g_KoyubiOnHold%%g_MojiOnHold%),14)!=1 or mod(strlen(kdn%g_RomajiOnHold%R%g_KoyubiOnHold%%g_MojiOnHold%),14)!=1 or mod(strlen(kdn%g_RomajiOnHold%L%g_KoyubiOnHold%%g_MojiOnHold%),14)!=1)
		{
			vOut                   := kdn%g_RomajiOnHold%%g_OyaOnHold%%g_KoyubiOnHold%%g_MojiOnHold%
			kup_save%g_MojiOnHold% := kup%g_RomajiOnHold%%g_OyaOnHold%%g_KoyubiOnHold%%g_MojiOnHold%
			SubSend(vOut)
			g_MojiOnHold := ""
			g_OyaOnHold  := "N"
			g_KoyubiOnHold := "N"
			g_SendTick := ""
			g_KeyInPtn := ""
		}
	}
	if(g_MojiOnHold<>"")	; 保留キー有り
	{
		if(g_ZeroDelay = 1)
		{
			; 保留キーがあれば先行出力（零遅延モード）
			vOut :=                   kdn%g_RomajiOnHold%%g_OyaOnHold%%g_KoyubiOnHold%%g_MojiOnHold%
			kup_save%g_MojiOnHold% := kup%g_RomajiOnHold%%g_OyaOnHold%%g_KoyubiOnHold%%g_MojiOnHold%

			g_ZeroDelayOut := vOut
			SubSend(vOut)
		}
		else
		{
			g_ZeroDelayOut := ""
		}
	}
	return

;----------------------------------------------------------------------
; キーアップ（押下終了）
;----------------------------------------------------------------------
keyup:
	Critical
	vkeyD%MojiCode% := "　"
	_ch := "　"
	GuiControl,4:,vkeyX%MojiCode%,%_ch%

	g_trigger := kName
	RegLogs(kName . " up")

	gosub,Polling
	g_MojiUpTick := Pf_Count()	;A_TickCount
	if(MojiCode = g_MojiOnHold)	; 保留キーがアップされた
	{
		if(g_KeyInPtn = "M")	; Mオン状態
		{
			Gosub, SendOnHoldM
		}
		if(g_KeyInPtn="MR" || g_KeyInPtn="ML")	; M-Oオン状態
		{
			; 処理C
			g_MmInterval := g_MojiUpTick - g_MojiTick
			if(g_KeyInPtn="MR")
			{
				g_OmInterval := g_MojiUpTick - g_OyaRTick
			} else {
				g_OmInterval := g_MojiUpTick - g_OyaLTick
			}
			vOverlap := 100*g_OmInterval/g_MmInterval
			if(vOverlap <= g_Overlap && g_OmInterval < g_Threshold)	; g_Tau
			{
				Gosub, SendOnHoldM
				g_SendTick := g_MojiUpTick - g_OmInterval + g_Threshold
			} else {
				Gosub, SendOnHoldMO
			}
		}
		if(g_KeyInPtn="RM" || g_KeyInPtn="LM")	; O-Mオン状態
		{
			; 処理E
			Gosub, SendOnHoldMO
		}
		else if(g_KeyInPtn="RMr" || g_KeyInPtn="LMl")	;O-M-Oオフ状態
		{
			Gosub, SendOnHoldMO
		}
	}
	if(MojiCode = 0)	; 文字キー以外（Space,Tab,Insert,...)
	{
		vOut := MnUp(kName)
		SubSend(vOut)
		critical,off
		return
	}
	vOut := kup_save%MojiCode%
	SubSend(vOut)
	kup_save%MojiCode% := ""
	critical,off
	return
	
;----------------------------------------------------------------------
; 10[mSEC]ごとの割込処理
;----------------------------------------------------------------------
Interrupt10:
	Gosub,ScanModifier
	if(A_IsCompiled <> 1)
	{
		;Tooltip, %g_Modifier%, 0, 0, 2 ; debug	
	}
	if(g_Modifier!=0) 
	{
		Gosub,ModeInitialize
		SetHook("off")
	} else {
		Gosub,ChkIME
		if((g_Romaji="A" && LFA=0x77)
		|| (g_Romaji="R" && LFR=0x77)) {
			SetHook("on")
		} else {
			SetHook("off")
		}
	}
Polling:
	if(g_SendTick <> "")
	{
		_TickCount := Pf_Count()	;A_TickCount
		if(_TickCount > g_SendTick) 	; タイムアウト
		{
			if g_KeyInPtn in M			; Mオン状態
			{
				Gosub, SendOnHoldM
			}
			else if g_KeyInPtn in L,R	; Oオン状態
			{
				; タイムアウトせずに留まる
				if(g_Continue = 0)	; 連続モードではない
				{
					g_Oya := "N"
				}
			}
			else if g_KeyInPtn in ML,MR,RM,LM	; M-Oオン状態、O-Mオン状態
			{
				Gosub, SendOnHoldMO		; 保留キーの同時打鍵
			}
			else if g_KeyInPtn in RMr,LMl	; O-M-Oオフ状態
			{
				if(g_Continue = 0)		; 連続モードてはない
				{
					Gosub, SendOnHoldO		; 保留親指キーの単独打鍵
				}
				Gosub, SendOnHoldM		; 保留文字キーの単独打鍵
			}
		}
	}
	return

ScanModifier:
	stLShift := GetKeyStateWithLog(stLShift,160,"LShift")
	stRShift := GetKeyStateWithLog(stRShift,161,"RShift")
	if(stLShift = 0x80 or stRShift = 0x80)
	{
		g_Koyubi := "K"
	} else {
		g_Koyubi := "N"
	}
	g_trigger := "Int"
	Critical
	g_Modifier := 0x00
	stLCtrl := GetKeyStateWithLog(stLCtrl,162,"LCtrl")
	g_Modifier := g_Modifier | stLCtrl
	g_Modifier := g_Modifier >> 1			; 0x02
	stRCtrl := GetKeyStateWithLog(stRCtrl,163,"RCtrl")
	g_Modifier := g_Modifier | stRCtrl
	g_Modifier := g_Modifier >> 1			; 0x04
	stLAlt  := GetKeyStateWithLog(stLAlt,164,"LAlt")
	g_Modifier := g_Modifier | stLAlt
	g_Modifier := g_Modifier >> 1			; 0x08
	stRAlt  := GetKeyStateWithLog(stRAlt,165,"RAlt")
	g_Modifier := g_Modifier | stRAlt
	g_Modifier := g_Modifier >> 1			; 0x10
	stLWin  := GetKeyStateWithLog(stLWin,91,"LWin")
	g_Modifier := g_Modifier | stLWin
	g_Modifier := g_Modifier >> 1			; 0x20
	stRWin  := GetKeyStateWithLog(stRWin,92,"RWin")
	g_Modifier := g_Modifier | stRWin
	g_Modifier := g_Modifier >> 1			; 0x40
	stAppsKey   := GetKeyStateWithLog(stApp,93,"AppsKey")
	g_Modifier := g_Modifier | stAppsKey	; 0x80
	critical,off
	return

ModeInitialize:
	if(g_KeyInPtn = "M")
	{
		Gosub, SendOnHoldM
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
		Gosub, SendOnHoldMO			; 同時打鍵
	}
	return

;-----------------------------------------------------------------------
;	仮想キーの状態取得とログ
;-----------------------------------------------------------------------
GetKeyStateWithLog(stLast, vkey0, kName) {
	stCurr := DllCall("GetKeyState", "UInt", vkey0) & 128
	if(stCurr = 128 && stLast = 0)	; keydown
	{
		RegLogs(kName . " down")
	}
	else if(stCurr = 0 && stLast = 128)	; keyup
	{
		RegLogs(kName . " up")
	}
	return stCurr
}

;----------------------------------------------------------------------
; IME状態のチェックとローマ字モード判定
; 2019/3/3 ... IME_GetConvMode の上位31-15bitが立っている場合がある
;              よって、最下位ビットのみを見る
;----------------------------------------------------------------------
ChkIME:
	vImeMode := IME_GET() & 32767
	if(vImeMode = 0)
	{
		vImeConvMode :=IME_GetConvMode()
		g_Romaji := "A"
	} else {
		vImeConvMode :=IME_GetConvMode()
		if( vImeConvMode & 0x01 == 1) ;半角カナ・全角平仮名・全角カタカナ
		{
			g_Romaji := "R"
		}
		else ;ローマ字変換モード
		{
			g_Romaji := "A"
		}
	}
	if(A_IsCompiled <> 1)
	{
		;vImeConverting := IME_GetConverting() & 32767
		Tooltip, %g_Romaji% %vImeConvMode%, 0, 0, 2 ; debug
	}
	return


;----------------------------------------------------------------------
; キーを押下されたときに呼び出されるGotoラベルを定義して、
; 動的にホットキーをオン・オフする
;----------------------------------------------------------------------
SetHook(flg)
{
	Critical
	if(flg="init") {
		hotkey,*sc002,gSC002		;1
		hotkey,*sc002 up,gSC002up
		hotkey,*sc003,gSC003		;2
		hotkey,*sc003 up,gSC003up
		hotkey,*sc004,gSC004		;3
		hotkey,*sc004 up,gSC004up
		hotkey,*sc005,gSC005		;4
		hotkey,*sc005 up,gSC005up
		hotkey,*sc006,gSC006		;5
		hotkey,*sc006 up,gSC006up
		hotkey,*sc007,gSC007		;6
		hotkey,*sc007 up,gSC007up
		hotkey,*sc008,gSC008		;7
		hotkey,*sc008 up,gSC008up
		hotkey,*sc009,gSC009		;8
		hotkey,*sc009 up,gSC009up
		hotkey,*sc00A,gSC00A		;9
		hotkey,*sc00A up,gSC00Aup
		hotkey,*sc00B,gSC00B		;0
		hotkey,*sc00B up,gSC00Bup
		hotkey,*sc00C,gSC00C		;-
		hotkey,*sc00C up,gSC00Cup
		hotkey,*sc00D,gSC00D		;^
		hotkey,*sc00D up,gSC00Dup
		hotkey,*sc07D,gSC07D		;\
		hotkey,*sc07D up,gSC07Dup
		hotkey,*sc010,gSC010		;q
		hotkey,*sc010 up,gSC010up
		hotkey,*sc011,gSC011		;w
		hotkey,*sc011 up,gSC011up
		hotkey,*sc012,gSC012		;e
		hotkey,*sc012 up,gSC012up
		hotkey,*sc013,gSC013		;r
		hotkey,*sc013 up,gSC013up
		hotkey,*sc014,gSC014		;t
		hotkey,*sc014 up,gSC014up
		hotkey,*sc015,gSC015		;y
		hotkey,*sc015 up,gSC015up
		hotkey,*sc016,gSC016		;u
		hotkey,*sc016 up,gSC016up
		hotkey,*sc017,gSC017		;i
		hotkey,*sc017 up,gSC017up
		hotkey,*sc018,gSC018		;o
		hotkey,*sc018 up,gSC018up
		hotkey,*sc019,gSC019		;p
		hotkey,*sc019 up,gSC019up
		hotkey,*sc01A,gSC01A		;@
		hotkey,*sc01A up,gSC01Aup
		hotkey,*sc01B,gSC01B		;[
		hotkey,*sc01B up,gSC01Bup
		hotkey,*sc01E,gSC01E		;a
		hotkey,*sc01E up,gSC01Eup
		hotkey,*sc01F,gSC01F		;s
		hotkey,*sc01F up,gSC01Fup
		hotkey,*sc020,gSC020		;d
		hotkey,*sc020 up,gSC020up
		hotkey,*sc021,gSC021		;f
		hotkey,*sc021 up,gSC021up
		hotkey,*sc022,gSC022		;g
		hotkey,*sc022 up,gSC022up
		hotkey,*sc023,gSC023		;h
		hotkey,*sc023 up,gSC023up
		hotkey,*sc024,gSC024 		;j
		hotkey,*sc024 up,gSC024up
		hotkey,*sc025,gSC025 		;k
		hotkey,*sc025 up,gSC025up
		hotkey,*sc026,gSC026 		;l
		hotkey,*sc026 up,gSC026up
		hotkey,*sc027,gSC027 		;';'
		hotkey,*sc027 up,gSC027up
		hotkey,*sc028,gSC028 		;'*'
		hotkey,*sc028 up,gSC028up
		hotkey,*sc02B,gSC02B 		;']'
		hotkey,*sc02B up,gSC02Bup
		hotkey,*sc02C,gSC02C		;z
		hotkey,*sc02C up,gSC02Cup
		hotkey,*sc02D,gSC02D		;x
		hotkey,*sc02D up,gSC02Dup
		hotkey,*sc02E,gSC02E		;c
		hotkey,*sc02E up,gSC02Eup
		hotkey,*sc02F,gSC02F		;v
		hotkey,*sc02F up,gSC02Fup
		hotkey,*sc030,gSC030		;b
		hotkey,*sc030 up,gSC030up
		hotkey,*sc031,gSC031		;n
		hotkey,*sc031 up,gSC031up
		hotkey,*sc032,gSC032		;m
		hotkey,*sc032 up,gSC032up
		hotkey,*sc033,gSC033		;,
		hotkey,*sc033 up,gSC033up
		hotkey,*sc034,gSC034		;.
		hotkey,*sc034 up,gSC034up
		hotkey,*sc035,gSC035		;/
		hotkey,*sc035 up,gSC035up
		hotkey,*sc073,gSC073		;\
		hotkey,*sc073 up,gSC073up
		hotkey,Tab,gTAB				; \t
		hotkey,Tab up,gTABup
		hotkey,Enter,gENTER			; \r
		hotkey,Enter up,gENTERup
		hotkey,Backspace,gBACKSPACE	; \b
		hotkey,Backspace up,gBACKSPACEup
		hotkey,*sc029,gSC029		;半角／全角
		hotkey,*sc029 up,gSC029up
		hotkey,*sc070,gSC070		;ひらがな／カタカナ
		hotkey,*sc070 up,gSC070up
		hotkey,LCtrl,gLCTRL
		hotkey,LCtrl up,gLCTRLup
		hotkey,RCtrl,gRCTRL
		hotkey,RCtrl up,gRCTRLup
		Hotkey,Space,gSpace
		Hotkey,Space up,gSpaceUp
		Hotkey,*sc079,gSC079
		Hotkey,*sc079 up,gSC079up
		Hotkey,*sc07B,gSC07B
		Hotkey,*sc07B up,gSC07Bup
	} else {
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
		hotkey,*sc01E,%flg%	;a
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
		hotkey,Tab,%flg%
		hotkey,Tab up,%flg%
		hotkey,Enter,%flg%
		hotkey,Enter up,%flg%
		hotkey,Backspace,%flg%
		hotkey,Backspace up,%flg%
		hotkey,*sc029,%flg%
		hotkey,*sc029 up,%flg%
		hotkey,*sc070,%flg%		;ひらがな／カタカナ
		hotkey,*sc070 up,%flg%
		;hotkey,LCtrl,%flg%
		;hotkey,LCtrl up,%flg%
		;hotkey,RCtrl,%flg%
		;hotkey,RCtrl up,%flg%
		
		Hotkey,Space,%flg%
		Hotkey,Space up,%flg%
		Hotkey,*sc079,%flg%
		Hotkey,*sc079 up,%flg%
		Hotkey,*sc07B,%flg%
		Hotkey,*sc07B up,%flg%
	}
	Critical,off
	return
}

; １段目
gSC002:	;1
	kName := "1"
	MojiCode := 11
	Goto, keydown
gSC002up:
	kName := "1"
	MojiCode := 11
	Goto, keyup
gSC003:	;2
	kName := "2"
	MojiCode := 12
	Goto, keydown
gSC003up:
	kName := "2"
	MojiCode := 12
	Goto, keyup
gSC004:	;3
	kName := "3"
	MojiCode := 13
	Goto, keydown
gSC004up:
	kName := "3"
	MojiCode := 13
	Goto, keyup
gSC005:	;4
	kName := "4"
	MojiCode := 14
	Goto, keydown
gSC005up:
	kName := "4"
	MojiCode := 14
	Goto, keyup
gSC006:	;5
	kName := "5"
	MojiCode := 15
	Goto, keydown
gSC006up:
	kName := "5"
	MojiCode := 15
	Goto, keyup
gSC007:	;6
	kName := "6"
	MojiCode := 16
	Goto, keydown
gSC007up:
	kName := "6"
	MojiCode := 16
	Goto, keyup
gSC008:	;7
	kName := "7"
	MojiCode := 17
	Goto, keydown
gSC008up:
	kName := "7"
	MojiCode := 17
	Goto, keyup
gSC009:	;8
	kName := "8"
	MojiCode := 18
	Goto, keydown
gSC009up:
	kName := "8"
	MojiCode := 18
	Goto, keyup
gSC00A:	;9
	kName := "9"
	MojiCode := 19
	Goto, keydown
gSC00Aup:
	kName := "9"
	MojiCode := 19
	Goto, keyup
gSC00B:	;0
	kName := "10"
	MojiCode := 110
	Goto, keydown
gSC00Bup:
	kName := "10"
	MojiCode := 110
	Goto, keyup
gSC00C:	;-
	kName := "-"
	MojiCode := 111
	Goto, keydown
gSC00Cup:
	kName := "-"
	MojiCode := 111
	Goto, keyup
gSC00D:	;^
	kName := "^"
	MojiCode := 112
	Goto, keydown
gSC00Dup:
	kName := "^"
	MojiCode := 112
	Goto, keyup
gSC07D:	;\
	kName := "\"
	MojiCode := 113
	Goto, keydown
gSC07Dup:
	kName := "\"
	MojiCode := 113
	Goto, keyup
;　２段目
gSC010:	;q
	kName := "q"
	MojiCode := 21
	Goto, keydown
gSC010up:
	kName := "q"
	MojiCode := 21
	Goto, keyup
gSC011:	;w
	kName := "w"
	MojiCode := 22
	Goto, keydown
gSC011up:	;w
	kName := "w"
	MojiCode := 22
	Goto, keyup
gSC012:	;e
	kName := "e"
	MojiCode := 23
	Goto, keydown
gSC012up:	;e
	kName := "e"
	MojiCode := 23
	Goto, keyup
gSC013:	;r
	kName := "r"
	MojiCode := 24
	Goto, keydown
gSC013up:	;r
	kName := "r"
	MojiCode := 24
	Goto, keyup
gSC014:	;t
	kName := "t"
	MojiCode := 25
	Goto, keydown
gSC014up:	;t
	kName := "t"
	MojiCode := 25
	Goto, keyup
gSC015:	;y
	kName := "y"
	MojiCode := 26
	Goto, keydown
gSC015up:	;y
	kName := "y"
	MojiCode := 26
	Goto, keyup
gSC016:	;u
	kName := "u"
	MojiCode := 27
	Goto, keydown
gSC016up:	;u
	kName := "u"
	MojiCode := 27
	Goto, keyup
gSC017:	;i
	kName := "i"
	MojiCode := 28
	Goto, keydown
gSC017up:	;i
	kName := "i"
	MojiCode := 28
	Goto, keyup
gSC018:	;o
	kName := "o"
	MojiCode := 29
	Goto, keydown
gSC018up:	;o
	kName := "o"
	MojiCode := 29
	Goto, keyup
gSC019:	;p
	kName := "p"
	MojiCode := 210
	Goto, keydown
gSC019up:	;p
	kName := "p"
	MojiCode := 210
	Goto, keyup
gSC01A:	;@
	kName := "@"
	MojiCode := 211
	Goto, keydown
gSC01Aup:	;@
	kName := "@"
	MojiCode := 211
	Goto, keyup
gSC01B:	;[
	kName := "["
	MojiCode := 212
	Goto, keydown
gSC01Bup:	;[
	kName := "["
	MojiCode := 212
	Goto, keyup
; ３段目
gSC01E:	;a
	kName := "a"
	MojiCode := 31
	Goto, keydown
gSC01Eup:	;a
	kName := "a"
	MojiCode := 31
	Goto, keyup
gSC01F:	;s
	kName := "s"
	MojiCode := 32
	Goto, keydown
gSC01Fup:	;s
	kName := "s"
	MojiCode := 32
	Goto, keyup
gSC020:	;d
	kName := "d"
	MojiCode := 33
	Goto, keydown
gSC020up:	;d
	kName := "d"
	MojiCode := 33
	Goto, keyup
gSC021:	;f
	kName := "f"
	MojiCode := 34
	Goto, keydown
gSC021up:	;f
	kName := "f"
	MojiCode := 34
	Goto, keyup
gSC022:	;g
	kName := "g"
	MojiCode := 35
	Goto, keydown
gSC022up:	;g
	kName := "g"
	MojiCode := 35
	Goto, keyup
gSC023:	;h
	kName := "h"
	MojiCode := 36
	Goto, keydown
gSC023up:	;h
	kName := "h"
	MojiCode := 36
	Goto, keyup
gSC024: ;j
	kName := "j"
	MojiCode := 37
	Goto, keydown
gSC024up: ;j
	kName := "j"
	MojiCode := 37
	Goto, keyup
gSC025: ;k
	kName := "k"
	MojiCode := 38
	Goto, keydown
gSC025up: ;k
	kName := "k"
	MojiCode := 38
	Goto, keyup
gSC026: ;l
	kName := "l"
	MojiCode := 39
	Goto, keydown
gSC026up: ;l
	kName := "l"
	MojiCode := 39
	Goto, keyup
gSC027: ;';'
	kName := ";"
	MojiCode := 310
	Goto, keydown
gSC027up: ;';'
	kName := ";"
	MojiCode := 310
	Goto, keyup
gSC028: ;'*'
	kName := "*"
	MojiCode := 311
	Goto, keydown
gSC028up: ;'*'
	kName := "*"
	MojiCode := 311
	Goto, keyup
gSC02B: ;']'
	kName := "]"
	MojiCode := 312
	Goto, keydown
gSC02Bup: ;']'
	kName := "]"
	MojiCode := 312
	Goto, keyup
;４段目
gSC02C:	;z
	kName := "z"
	MojiCode := 41
	Goto, keydown
gSC02Cup:	;z
	kName := "z"
	MojiCode := 41
	Goto, keyup
gSC02D:	;x
	kName := "x"
	MojiCode := 42
	Goto, keydown
gSC02Dup:	;x
	kName := "x"
	MojiCode := 42
	Goto, keyup
gSC02E:	;c
	kName := "c"
	MojiCode := 43
	Goto, keydown
gSC02Eup:	;c
	kName := "c"
	MojiCode := 43
	Goto, keyup
gSC02F:	;v
	kName := "v"
	MojiCode := 44
	Goto, keydown
gSC02Fup:	;v
	kName := "v"
	MojiCode := 44
	Goto, keyup
gSC030:	;b
	kName := "b"
	MojiCode := 45
	Goto, keydown
gSC030up:	;b
	kName := "b"
	MojiCode := 45
	Goto, keyup
gSC031:	;n
	kName := "n"
	MojiCode := 46
	Goto, keydown
gSC031up:	;n
	kName := "n"
	MojiCode := 46
	Goto, keyup
gSC032:	;m
	kName := "m"
	MojiCode := 47
	Goto, keydown
gSC032up:	;m
	kName := "m"
	MojiCode := 47
	Goto, keyup
gSC033:	;,
	kName := "`,"
	MojiCode := 48
	Goto, keydown
gSC033up:	;,
	kName := "`,"
	MojiCode := 48
	Goto, keyup
gSC034:	;.
	kName := "."
	MojiCode := 49
	Goto, keydown
gSC034up:	;.
	kName := "."
	MojiCode := 49
	Goto, keyup
gSC035:	;/
	kName := "/"
	MojiCode := 410
	Goto, keydown
gSC035up:	;/
	kName := "/"
	MojiCode := 410
	Goto, keyup
gSC073:	;\
	kName := "\"
	MojiCode := 411
	Goto, keydown
gSC073up:	;_
	kName := "\"
	MojiCode := 411
	Goto, keyup

gTAB:
	kName := "Tab"
	MojiCode := 0
	Goto, keydown
gTABup:
	kName := "Tab"
	MojiCode := 0
	Goto, keyup
gENTER:
	kName := "Enter"
	MojiCode := 0
	Goto, keydown
gENTERup:
	kName := "Enter"
	MojiCode := 0
	Goto, keyup
gBACKSPACE:
	kName := "Backspace"
	MojiCode := 0
	Goto, keydown
gBACKSPACEup:
	kName := "Backspace"
	MojiCode := 0
	Goto, keyup
gSC029:	;半角／全角
	kName := "sc029"
	MojiCode := 0
	Goto, keydown
gSC029up:	;半角／全角
	kName := "sc029"
	MojiCode := 0
	Goto, keyup
gSC070:	;ひらがな／カタカナ
	kName := "sc070"
	MojiCode := 0
	Goto, keydown
gSC070up:	;ひらがな／カタカナ
	kName := "sc070"
	MojiCode := 0
	Goto, keyup

gSpace:
	kName := "Space"
	MojiCode := 0
	GuiControl,4:,vkeyX52,□
	if(kOyaL==kName) {
		Goto, gOyaL
	}
	if(kOyaR==kName) {
		Goto, gOyaR
	}
	Goto, keydown
gSpaceUp:
	kName := "Space"
	MojiCode := 0
	GuiControl,4:,vkeyX52,　
	if(kOyaL=="Space") {
		Goto, gOyaLUp
	}
	if(kOyaR=="Space") {
		Goto, gOyaRUp
	}
	Goto, keyup
gSC07B:					; 無変換キー（左）
	kName := "sc07B"
	MojiCode := 0
	GuiControl,4:,vkeyX51,□
	if(kOyaL==kName) {
		Goto, gOyaL
	}
	if(kOyaR==kName) {
		Goto, gOyaR
	}
	Goto, keydown
gSC07Bup:
	kName := "sc07B"
	MojiCode := 0
	GuiControl,4:,vkeyX51,　
	if(kOyaL==kName) {
		Goto, gOyaLUp
	}
	if(kOyaR==kName) {
		Goto, gOyaRUp
	}
	Goto, keyup
gSC079:				; 変換キー（右）
	kName := "sc079"
	MojiCode := 0
	GuiControl,4:,vkeyX53,□
	if(kOyaL==kName) {
		Goto, gOyaL
	}
	if(kOyaR==kName) {
		Goto, gOyaR
	}
	Goto, keydown
gSC079up:
	kName := "sc079"
	MojiCode := 0
	GuiControl,4:,vkeyX53,　
	if(kOyaL=kName) {
		Goto, gOyaLUp
	}
	if(kOyaR=kName) {
		Goto, gOyaRUp
	}
	Goto, keyup

;-----------------------------------------------------------------------
; 機能：モディファイアキー
;-----------------------------------------------------------------------
;WindowsキーとAltキーをホットキー登録すると、WindowsキーやAltキーの単体押しが効かなくなるのでコメントアウトする。
;代わりにInterrupt10 でA_Priorkeyを見て、Windowsキーを監視する。
;但し、WindowsキーやAltキーを離したことを感知できないことに留意。
;ver.0.1.3 にて、GetKeyState でWindowsキーとAltキーとを監視
;ver.0.1.3.7 ... Ctrlはやはり必要なので戻す

gLCTRL:
	kName := "LCtrl"
	MojiCode = 0
	Goto, keydown
gLCTRLup:
	kName := "LCtrl"
	MojiCode = 0
	Goto, keyup
gRCTRL:
	kName := "RCtrl"
	MojiCode = 0
	Goto, keydown
gRCTRLup:
	kName := "RCtrl"
	MojiCode = 0
	Goto, keyup
