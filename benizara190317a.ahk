;-----------------------------------------------------------------------
;	名称：benizara / 紅皿
;	機能：Yet another NICOLA Emulaton Software
;         キーボード配列エミュレーションソフト
;	ver.0.1.3.1 .... 2019/3/17
;	作者：Ken'ichiro Ayaki
;-----------------------------------------------------------------------
	#InstallKeybdHook
	#MaxhotkeysPerInterval 200
	#KeyHistory
	SetWorkingDir, %A_ScriptDir%
	
	idxLogs := 0
	aLogCnt := 0
	loop, 64
	{
		_idx := A_Index - 1
		aLog%_idx% := "_"
	}
	full_command_line := DllCall("GetCommandLine", "str") 
	if (RegExMatch(full_command_line, " /create(?!\S)")) 
	{
		thisCmd = schtasks.exe /create /tn benizara /tr `"%A_ScriptFullPath%`" /sc onlogon /rl highest /F
		Run *Runas %thisCmd%
		ExitApp 
	}
	if (RegExMatch(full_command_line, " /delete(?!\S)")) 
	{
		thisCmd = schtasks.exe /delete /tn \benizara /F
		Run *Runas %thisCmd%
		ExitApp
	}
	if (RegExMatch(full_command_line, " /admin(?!\S)")) 
	{
		Run *Runas %A_ScriptFullPath%
		ExitApp
	}
	g_Romaji = A
	g_Oya  = N
	g_Koyubi = N
	g_Modifier = 0
	g_LayoutFile =.\NICOLA配列.bnz
	g_Continue = 1
	g_Threshold = 150	; 
	g_Overlap = 50
	g_ZeroDelay = 1		; 零遅延モード
	g_ZeroDelayOut =
	g_Offset = 20
	g_OyaR = 0
	g_OyaL = 0	
	vLayoutFile := g_LayoutFile
	g_Tau = 0
	Gosub,ReadLayout
	g_allTheLayout := vAllTheLayout
	g_LayoutFile := vLayoutFile
	
	g_SendTick =
	Menu, Tray, Add, 紅皿設定,Settings
	Menu, Tray, Add, ログ,Logs
	Menu, Tray, Icon
	SetBatchLines, -1
	fPf := Pf_Init()
	g_OyaRTick := Pf_Count()	;A_TickCount
	g_OyaLTick := Pf_Count()	;A_TickCount
	g_MojiTick := Pf_Count()	;A_TickCount
	VarSetCapacity(lpKeyState,256,0)
	SetTimer Interrupt10,10
	
	vIntKeyUp = 0
	vIntKeyDn = 0
	/*
	Hotkey,Space,gSpace
	Hotkey,Space up,gSpaceUp
	
	Hotkey,Space,off
	Hotkey,Space up,off
	
	Hotkey,*sc079,gOyaR
	Hotkey,*sc079 up,gOyaRUp
	kOyaR := "sc079"		; 単独打鍵
	
	Hotkey,*sc07B,gOyaL
	Hotkey,*sc07B up,gOyaLUp
	kOyaL := "sc07B"		; 単独打鍵
	fKeySingle = 0			; 単独打鍵無しモード
	*/
	GoSub,Init
	return


#include IME.ahk
#include ReadLayout6.ahk
#include Settings7.ahk
#include PfCount.ahk
#include Logs1.ahk

;-----------------------------------------------------------------------
; 機能：モディファイアキー
;-----------------------------------------------------------------------

LCtrl::
	kName = LCtrl
	MojiCode = 0
	;g_Modifier := g_Modifier | 1
	Goto, keydown
	
LCtrl up::
	kName = LCtrl
	MojiCode = 0
	;g_Modifier := g_Modifier & 254	; 0xFE
	Goto, keyup

RCtrl::
	kName = RCtrl
	MojiCode = 0
	;g_Modifier := g_Modifier | 2
	Goto, keydown

RCtrl up::
	kName = RCtrl
	MojiCode = 0
	;g_Modifier := g_Modifier & 253	; 0xFD
	Goto, keyup

LShift::
	kName = LShift
	MojiCode = 0
	;g_Koyubi = K
	Goto, keydown

LShift up::
	kName = LShift
	MojiCode = 0
	;g_Koyubi = N
	Goto, keyup

RShift::
	kName = RShift
	MojiCode = 0
	;g_Koyubi = K
	Goto, keydown

RShift up::
	kName = RShift
	MojiCode = 0
	;g_Koyubi = N
	Goto, keyup

;WindowsキーとAltキーをホットキー登録すると、WindowsキーやAltキーの単体押しが効かなくなるのでコメントアウトする。
;代わりにInterrupt10 でA_Priorkeyを見て、Windowsキーを監視する。
;但し、WindowsキーやAltキーを離したことを感知できないことに留意。
;ver.0.1.3 にて、GetKeyState でWindowsキーとAltキーとを監視

;LAlt::
	kName = LAlt
	MojiCode = 0
	g_Modifier = Alt
	Goto, keydown
	
;LAlt up::
	kName = LAlt
	MojiCode = 0
	g_Modifier = 
	Goto, keyup

;RAlt::
	kName = RAlt
	MojiCode = 0
	g_Modifier = Alt
	Goto, keydown

;RAlt up::
	kName = RAlt
	MojiCode = 0
	g_Modifier = 
	Goto, keyup

;LWin::
	kName = LWin
	MojiCode = 0
	g_Modifier = Win
	Goto, keydown

;LWin up::
	kName = LWin
	MojiCode = 0
	g_Modifier = 
	Goto, keyup

;RWin::
	kName = RWin
	MojiCode = 0
	g_Modifier = Win
	Goto, keydown

;RWin up::
	kName = RWin
	MojiCode = 0
	g_Modifier = 
	Goto, keyup

;*sc079::	; 変換
gOyaR:
	Critical
	gosub,Interrupt10
	RegLogs("R down")
	if(g_KeyRepeat == 1 && g_KeyInPtn == "R")
	{
		g_OyaR = 1
		g_OyaRTick := Pf_Count()				;A_TickCount   
		g_MRInterval := g_OyaRTick - g_MojiTick	; 文字キー押しから右親指キー押しまでの期間
		g_Oya = R

		Gosub, SendOnHoldO	; 保留キーの打鍵
		g_OyaOnHold := g_Oya
		g_SendTick := g_OyaRTick + g_Threshold
		g_KeyInPtn := g_Oya
	}
	if g_OyaR <> 1 	; キーリピートの抑止
	{
		g_OyaR = 1
		g_OyaRTick := Pf_Count()				;A_TickCount   
		g_MRInterval := g_OyaRTick - g_MojiTick	; 文字キー押しから右親指キー押しまでの期間
		g_Oya = R
		
		if g_KeyInPtn = 			;初期状態
		{
			g_OyaOnHold := g_Oya
			g_SendTick := g_OyaRTick + g_Threshold
			g_KeyInPtn := g_KeyInPtn . g_Oya
		}
		else if g_KeyInPtn = M		;Mオン状態
		{
			g_OyaOnHold := g_Oya
			g_SendTick := g_OyaRTick + g_MRInterval
			g_KeyInPtn := g_KeyInPtn . g_Oya
		}
		else if g_KeyInPtn = L		;Oオン状態
		{
			Gosub, SendOnHoldO	; 保留キーの打鍵
			g_OyaOnHold := g_Oya
			g_SendTick := g_OyaRTick + g_Threshold
			g_KeyInPtn := g_KeyInPtn . g_Oya
		}
		else if g_KeyInPtn = ML		; M-Oオン状態
		{
			Gosub, SendOnHoldMO	; 保留キーの打鍵
			g_OyaOnHold := g_Oya
			g_SendTick := g_OyaRTick + g_Threshold
			g_KeyInPtn := g_KeyInPtn . g_Oya
		}
		else if g_KeyInPtn = LM		; O-Mオン状態
		{
			; 処理B 3キー判定
			g_LMInterval := g_MojiTick - g_OyaLTick		; 左親指キー押しから文字キー押しまでの期間
			g_MRInterval := g_OyaRTick - g_MojiTick		; 文字キー押しから右親指キー押しまでの期間
			if g_MRInterval > %g_LMInterval%
			{
				Gosub, SendOnHoldMO	; 保留キーの打鍵
				g_OyaOnHold := g_Oya
				g_SendTick := g_OyaRTick + g_Threshold
				g_KeyInPtn := g_KeyInPtn . g_Oya
			}
			else
			{
				if g_Continue = 0
				{
					Gosub, SendOnHoldO	; 保留キーの打鍵
				}
				g_OyaOnHold := g_Oya
				g_SendTick := g_OyaRTick + g_MRInterval
				g_KeyInPtn := g_KeyInPtn . g_Oya
			}
		}
		else if g_KeyInPtn in RMr,LMl	; O-M-Oオフ状態
		{
			if g_Continue = 0
			{
				Gosub, SendOnHoldO	; 保留キーの打鍵
			}
			g_OyaOnHold := g_Oya
			g_SendTick := g_OyaRTick + g_MRInterval
			g_KeyInPtn := g_KeyInPtn . g_Oya
		}
	}
	return  

;*sc079 up::
gOyaRUp:
	Critical
	gosub,Interrupt10
	if g_OyaR = 1	; 右親指シフトキーの単独シフト
	{
		RegLogs("R up")
		g_OyaR = 0
		g_OyarTick := Pf_Count()				;A_TickCount
		g_MrInterval := g_OyarTick - g_MojiTick	; 文字キー押しから右親指キー解除までの期間
		g_RrInterval := g_OyarTick - g_OyaRTick	; 右親指キー押しから右親指キー解除までの期間

		if g_OyaL = 1
			g_Oya = L
		else
			g_Oya = N
		
		if g_KeyInPtn = R			; Oオン状態
		{
			Gosub, SendOnHoldO		; 保留親指キーの打鍵
		}
		else if g_KeyInPtn = MR		; M-Oオン状態
		{
			if g_RrInterval > %g_Threshold%
			{
				; タイムアウト状態：親指シフト文字の出力
				Gosub, SendOnHoldMO	; 保留キーの打鍵
			} else {
				; 処理F
				vOverlap := 100*g_RrInterval/g_MrInterval
				if vOverlap >= %g_Overlap%
				{
					if g_RrInterval <= %g_Tau%
					{
						Gosub, SendOnHoldM	; 保留キーの単独打鍵
						Gosub, SendOnHoldO	; 保留キーの単独打鍵
					} else {
						Gosub, SendOnHoldMO	; 保留キーの同時打鍵
					}
				} else {
					Gosub, SendOnHoldMO	; 保留キーの同時打鍵
				}
			}
		}
		else if g_KeyInPtn = RM		; O-Mオン状態
		{
			if g_MrInterval > %g_Threshold%
			{
				; タイムアウト状態：親指シフト文字の出力
				Gosub, SendOnHoldMO	; 保留キーの打鍵
			} else {
				; 処理D
				vOverlap := 100*g_MrInterval/g_RrInterval
				if vOverlap >= %g_Overlap%
				{
					if g_MrInterval <= %g_Tau%
					{
						Gosub, SendOnHoldO	; 保留キーの単独打鍵
					} else {
						;g_MrTimeout := g_MrInterval*(100-g_Overlap)/g_Overlap
						g_MrTimeout := g_MrInterval/2
						g_SendTick := g_OyarTick + g_MrTimeout
						g_KeyInPtn = RMr
					}
				} else {
					;g_MrTimeout := g_MrInterval*(100-g_Overlap)/g_Overlap
					g_MrTimeout := g_MrInterval/2
					g_SendTick := g_OyarTick + g_MrTimeout
					g_KeyInPtn = RMr
				}
			}
		}
		else if g_KeyInPtn in M,RMr,LMl 		; O-M-Oオフ状態
		{
			; 何もしない
		}
	}
	return

;*sc07B::	; 無変換
gOyaL:
	Critical
	gosub,Interrupt10
	RegLogs("L down")
	if(g_KeyRepeat == 1 && g_KeyInPtn == "L")
	{
		g_OyaL = 1
		g_OyaLTick := Pf_Count()	;A_TickCount
		g_MLInterval := g_OyaLTick - g_MojiTick		; 文字キー押しから左親指キー押しまでの期間
		g_Oya = L
		
		Gosub, SendOnHoldO	; 保留キーの打鍵
		g_OyaOnHold := g_Oya
		g_SendTick := g_OyaLTick + g_Threshold
		g_KeyInPtn := g_Oya
	}
	if g_OyaL <> 1	; キーリピートの抑止
	{
		g_OyaL = 1
		g_OyaLTick := Pf_Count()	;A_TickCount
		g_MLInterval := g_OyaLTick - g_MojiTick		; 文字キー押しから左親指キー押しまでの期間
		g_Oya = L
				
		if g_KeyInPtn = 				; 初期状態
		{
			g_OyaOnHold := g_Oya
			g_SendTick := g_OyaLTick + g_Threshold
			g_KeyInPtn := g_Oya
		}
		else if g_KeyInPtn = M			; Mオン状態
		{
			g_OyaOnHold := g_Oya
			g_SendTick := g_OyaLTick + g_MLInterval
			g_KeyInPtn := g_KeyInPtn . g_Oya
		}
		else if g_KeyInPtn = R			; Oオン状態
		{
			Gosub, SendOnHoldO	; 保留キーの打鍵
			g_OyaOnHold := g_Oya
			g_SendTick := g_OyaLTick + g_Threshold
			g_KeyInPtn := g_KeyInPtn . g_Oya
		}
		else if g_KeyInPtn = MR			; M-Oオン状態
		{
			Gosub, SendOnHoldMO	; 保留キーの打鍵
			g_OyaOnHold := g_Oya
			g_SendTick := g_OyaLTick + g_Threshold
			g_KeyInPtn := g_KeyInPtn . g_Oya
		}
		else if g_KeyInPtn = RM			; O-Mオン状態
		{
			; 処理B 3キー判定
			g_RMInterval := g_MojiTick - g_OyaRTick		; 右親指キー押しから文字キー押しまでの期間
			g_MLInterval := g_OyaLTick - g_MojiTick		; 文字キー押しから左親指キー押しまでの期間
			if g_MRInterval > %g_LMInterval%
			{
				Gosub, SendOnHoldMO	; 保留キーの打鍵
				g_OyaOnHold := g_Oya
				g_SendTick := g_OyaLTick + g_Threshold
				g_KeyInPtn := g_KeyInPtn . g_Oya
			} else {
				if g_Continue = 0
				{
					Gosub, SendOnHoldO	; 保留キーの打鍵
				}
				g_OyaOnHold := g_Oya
				g_SendTick := g_OyaLTick + g_MLInterval
				g_KeyInPtn := g_KeyInPtn . g_Oya
			}
		}
		else if g_KeyInPtn in RMr,LMl		; O-M-Oオフ状態
		{
			if g_Continue = 0
			{
				Gosub, SendOnHoldO	; 保留キーの打鍵
			}
			g_OyaOnHold := g_Oya
			g_SendTick := g_OyaLTick + g_MLInterval
			g_KeyInPtn := g_KeyInPtn . g_Oya
		}
	}
 	return

;*sc07B up::

gOyaLUp:
	Critical
	gosub,Interrupt10
	if g_OyaL <> 0	; 右親指シフトキーの単独シフト
	{
		RegLogs("L up")
		g_OyaL = 0
		g_OyalTick := Pf_Count()				;A_TickCount
		g_MlInterval := g_OyalTick - g_MojiTick	; 文字キー押しから左親指キー解除までの期間
		g_LlInterval := g_OyalTick - g_OyaLTick	; 右親指キー押しから右親指キー解除までの期間

		if g_OyaR = 1
			g_Oya = R
		else
			g_Oya = N

		if g_KeyInPtn = L			; Oオン状態
		{
			Gosub, SendOnHoldO		; 保留親指キーの打鍵
		}
		else if g_KeyInPtn = ML		;M-Oオン状態
		{
			if g_LlInterval > %g_Threshold%
			{
				; タイムアウト
				Gosub, SendOnHoldMO	; 保留キーの打鍵
			} else {
				; 処理F
				vOverlap := 100*g_LlInterval/g_MlInterval
				if vOverlap <= %g_Overlap%
				{
					if g_LlInterval <= %g_Tau%
					{
						Gosub, SendOnHoldM	; 保留キーの単独打鍵
						Gosub, SendOnHoldO	; 保留キーの単独打鍵
					} else {
						Gosub, SendOnHoldMO	; 保留キーの同時打鍵
					}
				} else {
					Gosub, SendOnHoldMO	; 保留キーの同時打鍵
				}
			}
		}
		else if g_KeyInPtn = LM		;O-Mオン状態
		{
			if g_MlInterval > %g_Threshold%
			{
				; タイムアウト
				Gosub, SendOnHoldMO	; 保留キーの打鍵
			} else {
				; 処理D
				vOverlap := 100*g_MlInterval/g_LlInterval
				if vOverlap >= %g_Overlap%
				{
					if g_MlInterval <= %g_Tau%
					{
						Gosub, SendOnHoldO	; 保留キーの単独打鍵
						g_KeyInPtn = M
					} else {
						;g_MlTimeout := g_MlInterval*(100-g_Overlap)/g_Overlap
						g_MlTimeout := g_MlInterval/2
						g_SendTick := g_OyaUpTick + g_MlTimeout
						g_KeyInPtn = LMl
					}
				} else {
					;g_MlTimeout := g_MlInterval*(100-g_Overlap)/g_Overlap
					g_MlTimeout := g_MlInterval/2
					g_SendTick := g_OyaUpTick + g_MlTimeout
					g_KeyInPtn = LMl
				}
			}
		}
		else if g_KeyInPtn in M, RMr,LMl
		{
			; 何もしない
		}
	}
	return

;Space::
gSpace:
	kName = Space
	MojiCode = 0
	Goto, keydown


;Space up::
gSpaceUp:
	kName = Space
	MojiCode = 0
	Goto, keyup

minimum(val0, val1) {
	if val0 > %val1%
	{
		return val1
	}
	else
	{
		return val0
	}
}
;----------------------------------------------------------------------
; 通常のキーダウン時にSendする引数の文字列を設定する
; 引数　：aStr：対応するキー入力
; 戻り値：Sendの引数
;----------------------------------------------------------------------
MnDown(aStr) {
	vOut =
	if aStr<>
		vOut = {Blind}{%aStr% down}
	return vOut
}
;----------------------------------------------------------------------
; 通常のキーアップ時にSendする引数の文字列を設定する
; 引数　：aStr：対応するキー入力
; 戻り値：Sendの引数
;----------------------------------------------------------------------
MnUp(aStr) {
	vOut =
	if aStr<>
		vOut = {Blind}{%aStr% up}
	return vOut
}
;--------------------------------------------------------------------y-
; キー出力
;----------------------------------------------------------------------
SubSend(vOut)
{
	global aLog,idxLogs, aLogCnt, g_KeyInPtn
	
	if vOut<>
	{
		SetKeyDelay -1
		Send %vOut%
		RegLogs("       " . substr(g_KeyInPtn . "   ",1,3) . vOut)
	}
	return
}
;--------------------------------------------------------------------y-
; ログ保存
;----------------------------------------------------------------------
RegLogs(thisLog)
{
	global aLog,idxLogs, aLogCnt
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
	if g_ZeroDelay = 1
	{
		if vOut <> %g_ZeroDelayOut%
		{
			_save := g_KeyInPtn
			vOut1 := "{Blind}{Backspace down}{Backspace up}"
			SubSend(vOut1)
			SubSend(vOut)
		}
		g_ZeroDelayOut = 
	} else {
		SubSend(vOut)
	}
	g_MojiOnHold =
	g_OyaOnHold = N
	g_KoyubiOnHold = N
	g_SendTick =
	g_KeyInPtn =
	return

;----------------------------------------------------------------------
; 保留キーの出力：セットされた文字の出力
;----------------------------------------------------------------------
SendOnHoldM:
	vOut :=                   kdn%g_RomajiOnHold%N%g_KoyubiOnHold%%g_MojiOnHold%
	kup_save%g_MojiOnHold% := kup%g_RomajiOnHold%N%g_KoyubiOnHold%%g_MojiOnHold%
	if g_ZeroDelay = 1
	{
		if vOut <> %g_ZeroDelayOut%
		{
			_save := g_KeyInPtn
			vOut1 := "{Blind}{Backspace down}{Backspace up}" 
			SubSend(vOut1)
			SubSend(vOut)
		}
		g_ZeroDelayOut =
	} else {
		SubSend(vOut)
	}
	g_MojiOnHold =
	g_KoyubiOnHold = N
	g_SendTick =
	if g_KeyInPtn in MR
	{
		g_keyInPtn = R
	}
	else if g_KeyInPtn in ML
	{
		g_keyInPtn = L
	}
	else if g_KeyInPtn in M
	{
		g_keyInPtn = 
	}
	return

;----------------------------------------------------------------------
; 保留された親指キーの出力
;----------------------------------------------------------------------
SendOnHoldO:
	if g_OyaOnHold = R
	{
		if g_KeySingle = 有効
		{
			vOut = {Blind}{%kOyaR%}{Blind}{%kOyaR% up}
			SubSend(vOut)
		}
		if g_KeyInPtn in RM,RMr
		{
			g_keyInPtn = M
		}
		else if g_KeyInPtn in R
		{
			g_keyInPtn = 
		}
	}
	else if g_OyaOnHold = L
	{
		if g_KeySingle = 有効
		{
			vOut = {Blind}{%kOyaL%}{Blind}{%kOyaL% up}
			SubSend(vOut)
		}
		if g_KeyInPtn in LM,LMl
		{
			g_keyInPtn = M
		}
		else if g_KeyInPtn in L
		{
			g_keyInPtn = 
		}
	}
	g_OyaOnHold = N
	return

;----------------------------------------------------------------------
; キー押下
;----------------------------------------------------------------------
keydown:
	Critical
	RegLogs(kName . " down")
	gosub,Interrupt10
	if g_MojiOnHold<>
	{
		if g_KeyInPtn in M
		{
			Gosub, SendOnHoldM
		}
		else if g_KeyInPtn in ML,MR
		{
			; 処理A 3キー判定
			if g_KeyInPtn in MR
			{
				g_OMInterval := g_MojiTick - g_OyaRTick
				g_MOInterval := g_MRInterval
			}
			else if g_KeyInPtn in ML
			{
				g_OMInterval := g_MojiTick - g_OyaLTick
				g_MOInterval := g_MLInterval
			}
			if g_OMInterval <= %g_MOInterval%	; 文字キーaから親指キーsまでの時間は、親指キーsから文字キーbまでの時間よりも長い
			{
				Gosub, SendOnHoldM		; 保留キーの単独打鍵
			} else {
				Gosub, SendOnHoldMO		; 保留キーの同時打鍵
			}
		}
		else if g_KeyInPtn in RM,LM
		{
			Gosub, SendOnHoldMO
		}
		else if g_KeyInPtn in RMr,LMl
		{
			Gosub, SendOnHoldO
			Gosub, SendOnHoldM
		}
	}
	if(MojiCode = 0)	; 文字キー以外(space,tab,Enter)
	{
		g_ModifierTick := Pf_Count()	;A_TickCount
		vOut := MnDown(kName)
		SubSend(vOut)
		g_KeyInPtn =
		return
	}
	g_MojiTick := Pf_Count()	;A_TickCount

	SetKeyDelay -1
	if(g_Modifier != 0)		; 修飾キー
	{
		vOut := mdnANN%MojiCode%
		SubSend(vOut)
		g_MojiOnHold =
		g_OyaOnHold = N
		g_KoyubiOnHold = N
		g_SendTick =
		g_KeyInPtn =
		return
	}
	
	Gosub,ChkIME
	
	if g_Oya = N
	{
		; 当該キーを単独打鍵として保留
		g_MojiOnHold := MojiCode
		g_RomajiOnHold := g_Romaji
		g_OyaOnHold := g_Oya
		g_KoyubiOnHold := g_Koyubi
		g_SendTick := g_MojiTick + g_Threshold
		g_KeyInPtn = M
	}
	else
	{
		if g_Oya = R
		{
			g_OMInterval := g_MojiTick - g_OyaRTick
		}
		else if g_Oya = L
		{
			g_OMInterval := g_MojiTick - g_OyaLTick
		}
		g_MojiOnHold := MojiCode
		g_RomajiOnHold := g_Romaji
		g_OyaOnHold := g_Oya
		g_KoyubiOnHold := g_Koyubi
		if g_Continue = 0	; 連続モードではない
		{
			g_SendTick := g_MojiTick + g_OMInterval
			g_KeyInPtn := g_Oya . "M"
			g_Oya = N			; 親指シフトが押されていない状態に遷移
		} else {
			g_SendTick := g_MojiTick + g_Threshold
			g_KeyInPtn := g_Oya . "M"
		}
	}
	if g_MojiOnHold<>	; 当該キーの保留
	{
		; 左右親指シフト面と非シフト面の文字キーが同一ならば、保留しない
		_cn := key%g_RomajiOnHold%N%g_KoyubiOnHold%%g_MojiOnHold%
		_cr := key%g_RomajiOnHold%R%g_KoyubiOnHold%%g_MojiOnHold%
		if _cn = %_cr% 
		{
			_cl := key%g_RomajiOnHold%L%g_KoyubiOnHold%%g_MojiOnHold%
			if _cn = %_cl%
			{
				vOut := kdn%g_RomajiOnHold%%g_OyaOnHold%%g_KoyubiOnHold%%g_MojiOnHold%
				SubSend(vOut)
				g_MojiOnHold =
				g_OyaOnHold = N
				g_KoyubiOnHold = N
				g_SendTick =
				g_KeyInPtn =
			}
		}
	}
	if g_MojiOnHold<>	; 保留キー有り
	{
		if g_ZeroDelay = 1
		{
			; 保留キーがあれば先行出力（零遅延モード）
			vOut :=                   kdn%g_RomajiOnHold%%g_OyaOnHold%%g_KoyubiOnHold%%g_MojiOnHold%
			kup_save%g_MojiOnHold% := kup%g_RomajiOnHold%%g_OyaOnHold%%g_KoyubiOnHold%%g_MojiOnHold%
			g_ZeroDelayOut := vOut
			SubSend(vOut)
		}
		else
		{
			g_ZeroDelayOut =
		}
	}
	return

;----------------------------------------------------------------------
; キーアップ（押下終了）
;----------------------------------------------------------------------
keyup:
	Critical
	RegLogs(kName . " up")
	gosub,Interrupt10
	g_MojiUpTick := Pf_Count()	;A_TickCount
	if MojiCode = %g_MojiOnHold%	; 保留キーがアップされた
	{
		if g_KeyInPtn in M	; Mオン状態
		{
			Gosub, SendOnHoldM
		}
		if g_KeyInPtn in MR,ML	; M-Oオン状態
		{
			; 処理C
			g_MmInterval := g_MojiUpTick - g_MojiTick
			if g_KeyInPtn in MR
			{
				g_OmInterval := g_MojiUpTick - g_OyaRTick
			} else {
				g_OmInterval := g_MojiUpTick - g_OyaLTick
			}
			vOverlap := 100*g_OmInterval/g_MmInterval
			if vOverlap <= %g_Overlap%
			{
				if g_OmInterval < %g_Tau%
				{
					Gosub, SendOnHoldM
				} else {
					Gosub, SendOnHoldMO
				}
			} else {
				Gosub, SendOnHoldMO
			}
		}
		if g_KeyInPtn in RM,LM	; O-Mオン状態
		{
			if g_Continue = 0	; 連続モードではない
			{
				; 処理E
				g_MmInterval := g_MojiUpTick - g_MojiTick
				if g_KeyInPtn in RM
				{
					g_OmInterval := g_MojiUpTick - g_OyaRTick
				} else {
					g_OmInterval := g_MojiUpTick - g_OyaLTick
				}
				vOverlap := 100*(g_MmInterval)/g_OmInterval
				if vOverlap <= %g_Overlap%
				{
					if g_MmInterval <= %g_Tau%
					{
						Gosub, SendOnHoldO
						Gosub, SendOnHoldM
					} else {
						Gosub, SendOnHoldMO
					}
				} else {
					Gosub, SendOnHoldMO
				}
			} else {
				Gosub, SendOnHoldMO
			}
		}
		else if g_KeyInPtn in RMr,LMl	;O-M-Oオフ状態
		{
			Gosub, SendOnHoldMO
		}
	}
	if(MojiCode = 0)	; 文字キー以外（Space,Tab,Insert,...)
	{
		vOut := MnUp(kName)
		SubSend(vOut)
		return
	}
	if(g_Modifier != 0)	; 修飾キー
	{
		vOut := mupANN%MojiCode%
		SubSend(vOut)
		g_MojiOnHold =
		g_OyaOnHold = N
		g_KoyubiOnHold = N
		g_SendTick =
		return
	}
	vOut := kup_save%MojiCode%
	SubSend(vOut)
	kup_save%MojiCode% = 
	return
	
;----------------------------------------------------------------------
; 10[mSEC]ごとの割込処理
;----------------------------------------------------------------------
Interrupt10:
	if g_SendTick <>
	{
		_TickCount := Pf_Count()	;A_TickCount
		if _TickCount >%g_SendTick% 	; タイムアウト
		{
			if g_KeyInPtn in M			; Mオン状態
			{
				Gosub, SendOnHoldM
			}
			else if g_KeyInPtn in L,R	; Oオン状態
			{
				if g_Continue = 0		; 連続モードてはない
				{
					Gosub, SendOnHoldO
				}
			}
			else if g_KeyInPtn in ML,MR,RM,LM	; M-Oオン状態、O-Mオン状態
			{
				Gosub, SendOnHoldMO		; 保留キーの同時打鍵
			}
			else if g_KeyInPtn in RMr,LMl	; O-M-Oオフ状態
			{
				if g_Continue = 0		; 連続モードてはない
				{
					Gosub, SendOnHoldO		; 保留親指キーの単独打鍵
				}
				Gosub, SendOnHoldM		; 保留文字キーの単独打鍵
			}
		}
	}
	g_Koyubi := ShiftState()
	stWin  := ModifierState(4,stWin, 91, 92)
	stCtrl := ModifierState(8,stCtrl, 162, 163)
	stAlt  := ModifierState(16,stAlt, 164, 165)
	stApp  := ModifierState(32,stApp, 93, 93)
	return

;-----------------------------------------------------------------------
;	モディファイアキーの状態取得
;-----------------------------------------------------------------------
ModifierState(bMod, stLast, vkey0, vkey1) {
	global g_Modifier
	global g_MojiOnHold, g_RomajiOnHold, g_OyaOnHold
	global g_KoyubiOnHold, g_SendTick, g_KeyInPtn
	
	stCurr := DllCall("GetKeyState", "UInt", vkey0) & 128
	stCurr :=(DllCall("GetKeyState", "UInt", vkey1) & 128) | stCurr
	if(stCurr = 128 && stLast = 0)	; keydown
	{
		g_Modifier := g_Modifier | bMod

		; 保留キーをクリア
		g_MojiOnHold =
		g_OyaOnHold = N
		g_KoyubiOnHold = N
		g_SendTick =
		g_KeyInPtn =
	}
	else if(stCurr = 0 && stLast = 128)	; keyup
	{
		if(g_Modifier & bMod <> 0)
		{
			g_Modifier := g_Modifier & (255 ^ bMod)
		}
	}
	; Tooltip, %g_Modifier%, 0, 0, 2 ; debug
	return stCurr
}

;-----------------------------------------------------------------------
;	シフトキーの状態取得
;-----------------------------------------------------------------------
ShiftState() {
	stCurr := DllCall("GetKeyState", "UInt", 160) & 128
	stCurr :=(DllCall("GetKeyState", "UInt", 161) & 128) | stCurr
	if(stCurr = 128)	; keydown
	{
		ret_Koyubi = K
	}
	else				; keyup
	{
		ret_Koyubi = N
	}
	;Tooltip, %ret_Koyubi%, 0, 0, 2 ; debug	
	return ret_Koyubi
}

;----------------------------------------------------------------------
; IME状態のチェックとローマ字モード判定
; 2019/3/3 ... IME_GetConvMode の上位31-15bitが立っている場合がある
;              よって、14-0bitのみを有効とする
;----------------------------------------------------------------------
ChkIME:
	vImeConverting := IME_GetConverting() & 32767

	vImeMode := IME_GET() & 32767
	if(vImeMode = 0)
	{
		vImeConvMode :=IME_GetConvMode() & 32767
		g_Romaji = A
	} else {
		vImeConvMode :=IME_GetConvMode() & 32767
		if vImeConvMode in 0,3,8,9,11,16,24,256,265,272,281,1025 ; かなモード+半英数
		{
			g_Romaji = A
		}
		else if vImeConvMode in 19,25,27	;全英数
		{
			g_Romaji = R
		}
	}
	if A_IsCompiled <> 1
	{
		Tooltip, %g_Romaji% %vImeMode% %vImeConvMode% %vImeConverting%, 0, 0, 2 ; debug
	}
	return


; １段目
*sc002::	;1
	kName = 1
	MojiCode = 11
	Goto, keydown
*sc002 up::
	kName = 1
	MojiCode = 11
	Goto, keyup
*sc003::	;2
	kName = 2
	MojiCode = 12
	Goto, keydown
*sc003 up::
	kName = 2
	MojiCode = 12
	Goto, keyup
*sc004::	;3
	kName = 3
	MojiCode = 13
	Goto, keydown
*sc004 up::
	kName = 3
	MojiCode = 13
	Goto, keyup
*sc005::	;4
	kName = 4
	MojiCode = 14
	Goto, keydown
*sc005 up::
	kName = 4
	MojiCode = 14
	Goto, keyup
*sc006::	;5
	kName = 5
	MojiCode = 15
	Goto, keydown
*sc006 up::
	kName = 5
	MojiCode = 15
	Goto, keyup
*sc007::	;6
	kName = 6
	MojiCode = 16
	Goto, keydown
*sc007 up::
	kName = 6
	MojiCode = 16
	Goto, keyup
*sc008::	;7
	kName = 7
	MojiCode = 17
	Goto, keydown
*sc008 up::
	kName = 7
	MojiCode = 17
	Goto, keyup
*sc009::	;8
	kName = 8
	MojiCode = 18
	Goto, keydown
*sc009 up::
	kName = 8
	MojiCode = 18
	Goto, keyup
*sc00A::	;9
	kName = 9
	MojiCode = 19
	Goto, keydown
*sc00A up::
	kName = 9
	MojiCode = 19
	Goto, keyup
*sc00B::	;0
	kName = 10
	MojiCode = 110
	Goto, keydown
*sc00B up::
	kName = 10
	MojiCode = 110
	Goto, keyup
*sc00C::	;-
	kName = -
	MojiCode = 111
	Goto, keydown
*sc00C up::
	kName = -
	MojiCode = 111
	Goto, keyup
*sc00D::	;^
	kName = ^
	MojiCode = 112
	Goto, keydown
*sc00D up::
	kName = ^
	MojiCode = 112
	Goto, keyup
*sc07D::	;\
	kName = \
	MojiCode = 113
	Goto, keydown
*sc07D up::
	kName = \
	MojiCode = 113
	Goto, keyup
;　２段目
*sc010::	;q
	kName = q
	MojiCode = 21
	Goto, keydown
*sc010 up::
	kName = q
	MojiCode = 21
	Goto, keyup
*sc011::	;w
	kName = w
	MojiCode = 22
	Goto, keydown
*sc011 up::	;w
	kName = w
	MojiCode = 22
	Goto, keyup
*sc012::	;e
	kName = e
	MojiCode = 23
	Goto, keydown
*sc012 up::	;e
	kName = e
	MojiCode = 23
	Goto, keyup
*sc013::	;r
	kName = r
	MojiCode = 24
	Goto, keydown
*sc013 up::	;r
	kName = r
	MojiCode = 24
	Goto, keyup
*sc014::	;t
	kName = t
	MojiCode = 25
	Goto, keydown
*sc014 up::	;t
	kName = t
	MojiCode = 25
	Goto, keyup
*sc015::	;y
	kName = y
	MojiCode = 26
	Goto, keydown
*sc015 up::	;y
	kName = y
	MojiCode = 26
	Goto, keyup
*sc016::	;u
	kName = u
	MojiCode = 27
	Goto, keydown
*sc016 up::	;u
	kName = u
	MojiCode = 27
	Goto, keyup
*sc017::	;i
	kName = i
	MojiCode = 28
	Goto, keydown
*sc017 up::	;i
	kName = i
	MojiCode = 28
	Goto, keyup
*sc018::	;o
	kName = o
	MojiCode = 29
	Goto, keydown
*sc018 up::	;o
	kName = o
	MojiCode = 29
	Goto, keyup
*sc019::	;p
	kName = p
	MojiCode = 210
	Goto, keydown
*sc019 up::	;p
	kName = p
	MojiCode = 210
	Goto, keyup
*sc01A::	;@
	kName = @
	MojiCode = 211
	Goto, keydown
*sc01A up::	;@
	kName = @
	MojiCode = 211
	Goto, keyup
*sc01B::	;[
	kName = [
	MojiCode = 212
	Goto, keydown
*sc01B up::	;[
	kName = [
	MojiCode = 212
	Goto, keyup
; ３段目
*sc01E::	;a
	kName = a
	MojiCode = 31
	Goto, keydown
*sc01E up::	;a
	kName = a
	MojiCode = 31
	Goto, keyup
*sc01F::	;s
	kName = s
	MojiCode = 32
	Goto, keydown
*sc01F up::	;s
	kName = s
	MojiCode = 32
	Goto, keyup
*sc020::	;d
	kName = d
	MojiCode = 33
	Goto, keydown
*sc020 up::	;d
	kName = d
	MojiCode = 33
	Goto, keyup
*sc021::	;f
	kName = f
	MojiCode = 34
	Goto, keydown
*sc021 up::	;f
	kName = f
	MojiCode = 34
	Goto, keyup
*sc022::	;g
	kName = g
	MojiCode = 35
	Goto, keydown
*sc022 up::	;g
	kName = g
	MojiCode = 35
	Goto, keyup
*sc023::	;h
	kName = h
	MojiCode = 36
	Goto, keydown
*sc023 up::	;h
	kName = h
	MojiCode = 36
	Goto, keyup
*sc024:: ;j
	kName = j
	MojiCode = 37
	Goto, keydown
*sc024 up:: ;j
	kName = j
	MojiCode = 37
	Goto, keyup
*sc025:: ;k
	kName = k
	MojiCode = 38
	Goto, keydown
*sc025 up:: ;k
	kName = k
	MojiCode = 38
	Goto, keyup
*sc026:: ;l
	kName = l
	MojiCode = 39
	Goto, keydown
*sc026 up:: ;l
	kName = l
	MojiCode = 39
	Goto, keyup
*sc027:: ;';'
	kName = `;
	MojiCode = 310
	Goto, keydown
*sc027 up:: ;';'
	kName = `;
	MojiCode = 310
	Goto, keyup
*sc028:: ;'*'
	kName = *
	MojiCode = 311
	Goto, keydown
*sc028 up:: ;'*'
	kName = *
	MojiCode = 311
	Goto, keyup
*sc02B:: ;']'
	kName = ]
	MojiCode = 312
	Goto, keydown
*sc02B up:: ;']'
	kName = ]
	MojiCode = 312
	Goto, keyup
;４段目
*sc02C::	;z
	kName = z
	MojiCode = 41
	Goto, keydown
*sc02C up::	;z
	kName = z
	MojiCode = 41
	Goto, keyup
*sc02D::	;x
	kName = x
	MojiCode = 42
	Goto, keydown
*sc02D up::	;x
	kName = x
	MojiCode = 42
	Goto, keyup
*sc02E::	;c
	kName = c
	MojiCode = 43
	Goto, keydown
*sc02E up::	;c
	kName = c
	MojiCode = 43
	Goto, keyup
*sc02F::	;v
	kName = v
	MojiCode = 44
	Goto, keydown
*sc02F up::	;v
	kName = v
	MojiCode = 44
	Goto, keyup
*sc030::	;b
	kName = b
	MojiCode = 45
	Goto, keydown
*sc030 up::	;b
	kName = b
	MojiCode = 45
	Goto, keyup
*sc031::	;n
	kName = n
	MojiCode = 46
	Goto, keydown
*sc031 up::	;n
	kName = n
	MojiCode = 46
	Goto, keyup
*sc032::	;m
	kName = m
	MojiCode = 47
	Goto, keydown
*sc032 up::	;m
	kName = m
	MojiCode = 47
	Goto, keyup
*sc033::	;,
	kName = `,
	MojiCode = 48
	Goto, keydown
*sc033 up::	;,
	kName = `,
	MojiCode = 48
	Goto, keyup
*sc034::	;.
	kName = .
	MojiCode = 49
	Goto, keydown
*sc034 up::	;.
	kName = .
	MojiCode = 49
	Goto, keyup
*sc035::	;/
	kName = /
	MojiCode = 410
	Goto, keydown
*sc035 up::	;/
	kName = /
	MojiCode = 410
	Goto, keyup
*sc073::	;\
	kName = \
	MojiCode = 411
	Goto, keydown
*sc073 up::	;_
	kName = \
	MojiCode = 411
	Goto, keyup

Tab::
	kName = Tab
	MojiCode = 0
	Goto, keydown

Enter::
	kName = Enter
	MojiCode = 0
	Goto, keydown
Backspace::
	kName = Backspace
	MojiCode = 0
	Goto, keydown
CapsLock::
	kName = CapsLock
	MojiCode = 0
	Goto, keydown
Insert::
	kName = Insert
	MojiCode = 0
	Goto, keydown
Delete::
	kName = Delete
	MojiCode = 0
	Goto, keydown
Left::
	kName = Left
	MojiCode = 0
	Goto, keydown
Home::
	kName = Home
	MojiCode = 0
	Goto, keydown
End::
	kName = End
	MojiCode = 0
	Goto, keydown
;Up::
;Down::
PgUp::
	kName = PgUp
	MojiCode = 0
	Goto, keydown
PgDn::
	kName = PgDn
	MojiCode = 0
	Goto, keydown
Right::
	kName = Right
	MojiCode = 0
	Goto, keydown
Esc::
	kName = Esc
	MojiCode = 0
	Goto, keydown
F1::
	kName = F1
	MojiCode = 0
	Goto, keydown
F2::
	kName = F2
	MojiCode = 0
	Goto, keydown
F3::
	kName = F3
	MojiCode = 0
	Goto, keydown
F4::
	kName = F4
	MojiCode = 0
	Goto, keydown
F5::
	kName = F5
	MojiCode = 0
	Goto, keydown
F6::
	kName = F6
	MojiCode = 0
	Goto, keydown
F7::
	kName = F7
	MojiCode = 0
	Goto, keydown
F8::
	kName = F8
	MojiCode = 0
	Goto, keydown
F9::
	kName = F9
	MojiCode = 0
	Goto, keydown
F10::
	kName = F10
	MojiCode = 0
	Goto, keydown
F11::
	kName = F11
	MojiCode = 0
	Goto, keydown
F12::
	kName = F12
	MojiCode = 0
	Goto, keydown
;AppsKey::
	;kName = AppsKey
	;MojiCode = 0
	;Goto, keydown
PrintScreen::
	kName = PrintScreen
	MojiCode = 0
	Goto, keydown

	kName := A_ThisHotkey
	MojiCode = 0
	Goto, keydown


Enter up::
	kName = Enter
	MojiCode = 0
	Goto, keyup
Tab up::
	kName = Tab
	MojiCode = 0
	Goto, keyup
Backspace up::
	kName = Backspace
	MojiCode = 0
	Goto, keyup
CapsLock up::
	kName = CapsLock
	MojiCode = 0
	Goto, keyup
Insert up::
	kName = Insert
	MojiCode = 0
	Goto, keyup
Delete up::
	kName = Delete
	MojiCode = 0
	Goto, keyup
Left up::
	kName = Left
	MojiCode = 0
	Goto, keyup
Home up::
	kName = Home
	MojiCode = 0
	Goto, keyup
End up::
	kName = End
	MojiCode = 0
	Goto, keyup
;Up up::
;Down up::
PgUp up::
	kName = PgUp
	MojiCode = 0
	Goto, keyup
PgDn up::
	kName = PgDn
	MojiCode = 0
	Goto, keyup
Right up::
	kName = Right
	MojiCode = 0
	Goto, keyup
Esc up::
	kName = Esc
	MojiCode = 0
	Goto, keyup
F1 up::
	kName = F1
	MojiCode = 0
	Goto, keyup
F2 up::
	kName = F2
	MojiCode = 0
	Goto, keyup
F3 up::
	kName = F3
	MojiCode = 0
	Goto, keyup
F4 up::
	kName = F4
	MojiCode = 0
	Goto, keyup
F5 up::
	kName = F5
	MojiCode = 0
	Goto, keyup
F6 up::
	kName = F6
	MojiCode = 0
	Goto, keyup
F7 up::
	kName = F7
	MojiCode = 0
	Goto, keyup
F8 up::
	kName = F8
	MojiCode = 0
	Goto, keyup
F9 up::
	kName = F9
	MojiCode = 0
	Goto, keyup
F10 up::
	kName = F10
	MojiCode = 0
	Goto, keyup
F11 up::
	kName = F11
	MojiCode = 0
	Goto, keyup
F12 up::
	kName = F12
	MojiCode = 0
	Goto, keyup
AppsKey up::
	kName = AppsKey
	MojiCode = 0
	Goto, keyup
PrintScreen up::
	kName = PrintScreen
	MojiCode = 0
	Goto, keyup

	kName := A_ThisHotkey
	MojiCode = 0
	Goto, keyup

;*sc039::	;Space
;*sc01C::	;Enter
;*sc00E::	;BS
;*sc00F::	;Tab
*sc029::	;半角／全角
	kName = sc029
	MojiCode = 0
	Goto, keydown
*sc070::	;ひらがな／カタカナ
	kName = sc070
	MojiCode = 0
	Goto, keydown
;*sc03A::	;CapsLock
;*sc152::	;Insert
;*sc153::	;Delete
;*sc14B::	;←
;*sc147::	;home
;*sc14F::	;End
*sc148::	;↑
	kName = sc148
	MojiCode = 0
	Goto, keydown
*sc150::	;↓
	kName = sc150
	MojiCode = 0
	Goto, keydown
;*sc149::	;Page up
;*sc151::	;Page down
;*sc140::	;→
;*sc001::	;Esc
;*sc03B::	;F1
;*sc03C::	;F2
;*sc03D::	;F3
;*sc03E::	;F4
;*sc03F::	;F5
;*sc040::	;F6
;*sc041::	;F7
;*sc042::	;F8
;*sc043::	;F9
;*sc044::	;F10
;*sc057::	;F11
;*sc058::	;F12
	_sc := SubStr(A_ThisHotkey,4,3)
	kName := cout%_sc%
	MojiCode = 0
	Goto, keydown

;*sc039 up::	;Space
;*sc01C up::	;Enter
;*sc00E up::	;BS
;*sc00F up::	;Tab
*sc029 up::	;半角／全角
	kName = sc029
	MojiCode = 0
	Goto, keyup
*sc070 up::	;ひらがな／カタカナ
	kName = sc070
	MojiCode = 0
	Goto, keyup
;*sc03A up::	;CapsLock
;*sc001 up::	;Esc
;*sc152 up::	;Insert
;*sc153 up::	;Delete
;*sc14B up::	;←
;*sc147 up::	;home
;*sc14F up::	;End
*sc148 up::	;↑
	kName = sc148
	MojiCode = 0
	Goto, keyup
*sc150 up::	;↓
	kName = sc150
	MojiCode = 0
	Goto, keyup
;*sc149 up::	;Page up
;*sc151 up::	;Page down
;*sc140 up::	;→
;*sc001 up::	;Esc
;*sc03B up::	;F1
;*sc03C up::	;F2
;*sc03D up::	;F3
;*sc03E up::	;F4
;*sc03F up::	;F5
;*sc040 up::	;F6
;*sc041 up::	;F7
;*sc042 up::	;F8
;*sc043 up::	;F9
;*sc044 up::	;F10
;*sc057 up::	;F11
;*sc058 up::	;F12
	_sc := SubStr(A_ThisHotkey,4,3)
	kName := cout%_sc%
	;kName =
	MojiCode = 0
	Goto, keyup
