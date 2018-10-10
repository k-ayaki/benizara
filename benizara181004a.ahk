;-----------------------------------------------------------------------
;	名称：benizara / 紅皿
;	機能：Yet another NICOLA Emulaton Software
;         キーボード配列エミュレーションソフト
;	ver.0.1.2 .... 2018/10/10
;	作者：Ken'ichiro Ayaki
;-----------------------------------------------------------------------
	#InstallKeybdHook
	#MaxhotkeysPerInterval 200
	#KeyHistory
	SetWorkingDir, %A_ScriptDir%
	g_Romaji = A
	g_Thumb  = N
	g_Koyubi = N
	g_Modifier = 
	g_LayoutFile =.\NICOLA配列.bnz
	g_Continue = 1
	g_Threshold = 150	; 
	g_Overlap = 50
	g_ZeroDelay = 1		; 零遅延モード
	g_ZeroDelayThumb = 
	g_Offset = 20
	GoSub,Init
	g_ThumbR = 0
	g_ThumbL = 0
	
	vLayoutFile := g_LayoutFile
	Gosub,ReadLayout
	g_allTheLayout := vAllTheLayout
	g_LayoutFile := vLayoutFile
	
	g_SendTick =
	Menu, Tray, Add, 紅皿設定,Settings
	SetBatchLines, -1
	g_ThumbRTick := A_TickCount
	g_ThumbLTick := A_TickCount
	g_CharTick := A_TickCount
	SetTimer Interrupt10,10
	
	vIntKeyUp = 0
	vIntKeyDn = 0
	Hotkey,Space,gSpace
	Hotkey,Space up,gSpaceUp
	Hotkey,*sc079,gThumbR
	Hotkey,*sc079 up,gThumbRUp
	Hotkey,*sc07B,gThumbL
	Hotkey,*sc07B up,gThumbLUp
	return

#include IME.ahk
#include ReadLayout6.ahk
#include Settings7.ahk

;-----------------------------------------------------------------------
; 機能：モディファイアキー
;-----------------------------------------------------------------------

LCtrl::
	kName = LCtrl
	kCode = 0
	g_Modifier = Ctrl
	Goto, keydown
	
LCtrl up::
	kName = LCtrl
	kCode = 0
	g_Modifier =
	Goto, keyup

RCtrl::
	kName = RCtrl
	kCode = 0
	g_Modifier = Ctrl
	Goto, keydown

RCtrl up::
	kName = RCtrl
	kCode = 0
	g_Modifier =
	Goto, keyup

LShift::
	kName = LShift
	kCode = 0
	g_Koyubi = K
	Goto, keydown

LShift up::
	kName = LShift
	kCode = 0
	g_Koyubi = N
	Goto, keyup

RShift::
	kName = RShift
	kCode = 0
	g_Koyubi = K
	Goto, keydown

RShift up::
	kName = RShift
	kCode = 0
	g_Koyubi = N
	Goto, keyup

;WindowsキーとAltキーをホットキー登録すると、WindowsキーやAltキーの単体押しが効かなくなるのでコメントアウトする。
;代わりにInterrupt10 でA_Priorkeyを見て、Windowsキーを監視する。
;但し、WindowsキーやAltキーを離したことを感知できないことに留意。

;LAlt::
	kName = LAlt
	kCode = 0
	g_Modifier = Alt
	Goto, keydown
	
;LAlt up::
	kName = LAlt
	kCode = 0
	g_Modifier = 
	Goto, keyup

;RAlt::
	kName = RAlt
	kCode = 0
	g_Modifier = Alt
	Goto, keydown

;RAlt up::
	kName = RAlt
	kCode = 0
	g_Modifier = 
	Goto, keyup

;LWin::
	kName = LWin
	kCode = 0
	g_Modifier = Win
	Goto, keydown

;LWin up::
	kName = LWin
	kCode = 0
	g_Modifier = 
	Goto, keyup

;RWin::
	kName = RWin
	kCode = 0
	g_Modifier = Win
	Goto, keydown

;RWin up::
	kName = RWin
	kCode = 0
	g_Modifier = 
	Goto, keyup

;*sc079::	; 変換
gThumbR:
	Critical
	if g_ThumbR <> 1	; キーリピートの抑止
	{
		g_ThumbR = 1
		g_ThumbRTick := A_TickCount
		g_CRInterval := g_ThumbRTick - g_CharTick

		g_Thumb = R
		if g_CharOnHold<>
		{
			if g_SendPtn = C
			{
				g_SendTick := g_ThumbRTick + g_CRInterval
				g_ThumbOnHold := g_Thumb
				g_SendPtn = CR
			}
		}
	}
	return

;*sc079 up::
gThumbRUp:
	Critical
	if g_ThumbR<>0	; 右親指シフトキーの単独シフト
	{
		g_ThumbR = 0
		g_ThumbRUpTick := A_TickCount
		g_CRuInterval := g_ThumbRUpTick - g_CharTick
		g_RRuInterval := g_ThumbRUpTick - g_ThumbRTick

		if g_ThumbL = 1
			g_Thumb = L
		else
			g_Thumb = N
			
		if g_SendPtn = RC
		{
			;Gosub, SendOnHoldKey	; 保留キーの打鍵
			;return

			if g_CRuInterval > %g_Threshold%
			{
				Gosub, SendOnHoldKey	; 保留キーの打鍵
			} else {
				vOverlap := 100*g_CRuInterval/minimum(g_Threshold, g_RRuInterval)
				if vOverlap > %g_Overlap%
				{
					Gosub, SendOnHoldKey	; 保留キーの打鍵
				} else {
					g_CRuTimeout := g_CRuInterval*(100-g_Overlap)/g_Overlap
					g_SendTick := g_ThumbRUpTick + g_CRuTimeout
					g_ThumbOnHold := "N"
					g_SendPtn = RCRu
				}
			}
		}
		else if g_SendPtn = CR
		{
			if g_RRuInterval > %g_Threshold%
			{
				Gosub, SendOnHoldKey	; 保留キーの打鍵
			} else {
				vOverlap := 100*g_RRuInterval/minimum(g_Threshold, g_CRuInterval)
				if vOverlap <= %g_Overlap%
				{
					g_ThumbOnHold = N
				}
				Gosub, SendOnHoldKey	; 保留キーの打鍵
			}
		}
		else if g_SendPtn = C	; 異常対応
		{
			g_ThumbOnHold = R
			g_SendPtn = CR
		}
	}
	return

;*sc07B::	; 無変換
gThumbL:
	Critical
	if g_ThumbL <> 1	; キーリピートの抑止
	{
		g_ThumbL = 1
		g_ThumbLTick := A_TickCount
		g_CLInterval := g_ThumbLTick - g_CharTick
		g_Thumb = L

		if g_CharOnHold<>
		{
			if g_SendPtn = C
			{
				g_SendTick := g_ThumbLTick + g_CLInterval
				g_ThumbOnHold := g_Thumb
				g_SendPtn = CL
			}
		}
	}
 	return

;*sc07B up::

gThumbLUp:
	Critical
	if g_ThumbL <> 0	; 右親指シフトキーの単独シフト
	{
		g_ThumbL = 0
		g_ThumbLUpTick := A_TickCount
		g_CLuInterval := g_ThumbLUpTick - g_CharTick
		g_LLuInterval := g_ThumbLUpTick - g_ThumbLTick

		if g_ThumbR = 1
			g_Thumb = R
		else
			g_Thumb = N

		if g_SendPtn = LC
		{
			;Gosub, SendOnHoldKey	; 保留キーの打鍵
			;return
			
			if g_CLuInterval > %g_Threshold%
			{
				Gosub, SendOnHoldKey	; 保留キーの打鍵
			} else {
				vOverlap := 100*g_CLuInterval/minimum(g_Threshold, g_LLuInterval)
				if vOverlap > %g_Overlap%
				{
					Gosub, SendOnHoldKey	; 保留キーの打鍵
				} else {
					g_CLuTimeout := g_CLuInterval*(100-g_Overlap)/g_Overlap
					g_SendTick := g_ThumbUpTick + g_CLuTimeout
					g_ThumbOnHold := "N"
					g_SendPtn = LCLu
				}
			}
		}
		else if g_SendPtn = CL
		{
			if g_LLuInterval > %g_Threshold%
			{
				Gosub, SendOnHoldKey	; 保留キーの打鍵
			} else {
				vOverlap := 100*g_LLuInterval/minimum(g_Threshold,g_CLuInterval)
				if vOverlap <= %g_Overlap%
				{
					g_ThumbOnHold = N
				}
				Gosub, SendOnHoldKey	; 保留キーの打鍵
			}
		}
		else if g_SendPtn = C	; 異常対応
		{
			g_ThumbOnHold = L
			g_SendPtn = CL
		}
	}
	return

;Space::
gSpace:
	kName = Space
	kCode = 0
	Goto, keydown


;Space up::
gSpaceUp:
	kName = Space
	kCode = 0
	Goto, keyup

minimum(val0, val1) {
	if val0 > %val1%
		return val1
	else
		return val0

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
;----------------------------------------------------------------------
; キー出力
;----------------------------------------------------------------------
SubSend:
	if vOut<>
	{
		SetKeyDelay -1
		Send %vOut%
	}
	return

;----------------------------------------------------------------------
; 保留キーの出力
;----------------------------------------------------------------------
SendOnHoldKey:
	vOut =
	if g_ZeroDelay = 1
	{
		if g_ThumbOnHold <> %g_ZeroDelayThumb%
		{
			_save := g_SendPtn
			vOut = {Blind}{Backspace down}{Backspace up}
			vOut := vOut . kdn%g_RomajiOnHold%%g_ThumbOnHold%%g_KoyubiOnHold%%g_CharOnHold%
			vOut := vOut . kup%g_RomajiOnHold%%g_ThumbOnHold%%g_KoyubiOnHold%%g_CharOnHold%
			GoSub, SubSend
		}
		g_ZeroDelayThumb =
	} else {
		vOut := vOut . kdn%g_RomajiOnHold%%g_ThumbOnHold%%g_KoyubiOnHold%%g_CharOnHold%
		vOut := vOut . kup%g_RomajiOnHold%%g_ThumbOnHold%%g_KoyubiOnHold%%g_CharOnHold%
		GoSub, SubSend
	}
	g_CharOnHold =
	g_RomajiOnHold =
	g_ThumbOnHold =
	g_KoyubiOnHold =
	g_SendTick =
	g_SendPtn =
	return

;----------------------------------------------------------------------
; キー押下
;----------------------------------------------------------------------
keydown:
	Critical
	if g_CharOnHold<>
	{
		if g_SendPtn not in CL,CR
		{
			if g_SendPtn in RCRu,RC
			{
				g_ThumbOnHold = R	; 保留キーの単独打鍵
			}
			else if g_SendPtn in LCLu,LC
			{
				g_ThumbOnHold = L	; 保留キーの単独打鍵
			}
			else if g_SendPtn in C
			{
				g_ThumbOnHold = N
			}
			Gosub, SendOnHoldKey
		}
	}
	if(kCode = 0)
	{
		vOut := MnDown(kName)
		GoSub, SubSend
		return
	}
	g_CharTick := A_TickCount

	
	SetKeyDelay -1
	if g_Modifier =
	{
		Gosub,ChkIME
		if g_Thumb = N
		{
			; 当該キーを単独打鍵として保留
			g_CharOnHold := kCode
			g_RomajiOnHold := g_Romaji
			g_ThumbOnHold := g_Thumb
			g_KoyubiOnHold := g_Koyubi
			g_SendTick := g_CharTick + g_Threshold
			g_SendPtn = C
		}
		else
		{
			if g_SendPtn in CR
			{
				if g_Thumb in R
				{
					g_TCInterval := g_CharTick - g_ThumbRTick
					g_TCTimeout := g_TCInterval*g_Overlap/(100-g_Overlap)
					g_CTInterval := g_CRInterval
				}
				else
				{
					;CRLと押下された
					Gosub, SendOnHoldKey
				}
			}
			else if g_SendPtn in CL
			{
				if g_Thumb in L
				{
					g_TCInterval := g_CharTick - g_ThumbLTick
					g_TCTimeout := g_TCInterval*g_Overlap/(100-g_Overlap)
					g_CTInterval := g_CLInterval
				}
				else
				{
					;CLRと押下された
					Gosub, SendOnHoldKey
				}
			}
			
			; Ptn = CR,CL
			if g_CharOnHold <>
			{					
				if g_Continue = 0	; 連続モードではない
				{
					if g_TCInterval <= %g_CTInterval%	; 文字キーaから親指キーsまでの時間は、親指キーsから文字キーbまでの時間よりも長い
					{
						g_ThumbOnHold = N
						; 保留キーの単独打鍵
						Gosub, SendOnHoldKey
					
						; 当該キーを同時打鍵として保留
						g_CharOnHold := kCode
						g_RomajiOnHold := g_Romaji
						g_ThumbOnHold := g_Thumb
						g_KoyubiOnHold := g_Koyubi
						g_SendTick := g_CharTick + g_TCTimeout
						g_SendPtn := g_Thumb . "C"
						g_Thumb = N			; 親指シフトが押されていない状態に遷移
					} else {
						; 保留キーの同時打鍵
						Gosub, SendOnHoldKey

						g_Thumb = N			; 親指シフトが押されていない状態に遷移
						; 当該キーを単独打鍵として保留
						g_CharOnHold := kCode
						g_RomajiOnHold := g_Romaji
						g_ThumbOnHold := g_Thumb
						g_KoyubiOnHold := g_Koyubi
						g_SendTick := g_CharTick + g_Threshold
						g_SendPtn = C
					}
				} else {
					if g_TCInterval <= %g_CTInterval%	; 文字キーaから親指キーsまでの時間は、親指キーsから文字キーbまでの時間よりも長い
					{
						g_ThumbOnHold = N	; 単独打鍵
					}
					; 保留キーの打鍵
					Gosub, SendOnHoldKey
					
					; 当該キーを同時打鍵として保留
					g_CharOnHold := kCode
					g_RomajiOnHold := g_Romaji
					g_ThumbOnHold := g_Thumb
					g_KoyubiOnHold := g_Koyubi
					g_SendTick := g_CharTick + g_TCTimeout
					g_SendPtn := g_Thumb . "C"
				}
			}
			else
			{
				if g_Continue = 0	; 連続モードではない
				{
					if g_TCInterval > %g_Threshold%	; 親指シフトsから当該文字キーまでの時間が閾値以上
					{
						g_Thumb = N			; 親指シフトが押されていない状態に遷移
						; 当該キーの単独打鍵
						vOut := kdn%g_Romaji%%g_Thumb%%g_Koyubi%%kCode%
						GoSub, SubSend
						g_CharOnHold =
						g_RomajiOnHold =
						g_ThumbOnHold =
						g_KoyubiOnHold =
						g_SendTick =
						g_SendPtn =
					} else {
						; 当該キーを同時打鍵として保留
						g_CharOnHold := kCode
						g_RomajiOnHold := g_Romaji
						g_ThumbOnHold := g_Thumb
						g_KoyubiOnHold := g_Koyubi
						g_SendTick := g_CharTick + g_TCTimeout
						g_SendPtn := g_Thumb . "C"
						g_Thumb = N			; 親指シフトが押されていない状態に遷移
					}
				} else {
					; 当該キーを同時打鍵として保留
					g_CharOnHold := kCode
					g_RomajiOnHold := g_Romaji
					g_ThumbOnHold := g_Thumb
					g_KoyubiOnHold := g_Koyubi
					g_SendTick := g_CharTick + g_TCTimeout
					g_SendPtn := g_Thumb . "C"
				}
			}
		}
		if g_CharOnHold<>	; 当該キーの保留
		{
			; 左右親指シフト時のキーが同一ならば、保留しない
			_cn := key%g_RomajiOnHold%N%g_KoyubiOnHold%%g_CharOnHold%
			_cr := key%g_RomajiOnHold%R%g_KoyubiOnHold%%g_CharOnHold%
			if _cn = %_cr% 
			{
				_cl := key%g_RomajiOnHold%L%g_KoyubiOnHold%%g_CharOnHold%
				if _cn = %_cl%
				{
					vOut := kdn%g_RomajiOnHold%%g_ThumbOnHold%%g_KoyubiOnHold%%g_CharOnHold%
					GoSub, SubSend
					g_CharOnHold =
					g_RomajiOnHold =
					g_ThumbOnHold =
					g_KoyubiOnHold =
					g_SendTick =
					g_SendPtn =
				}
			}
		}
		if g_CharOnHold<>
		{
			if g_ZeroDelay = 1
			{
				; 保留キーがあれば先行出力
				vOut := kdn%g_RomajiOnHold%%g_ThumbOnHold%%g_KoyubiOnHold%%g_CharOnHold%
				GoSub, SubSend
				g_ZeroDelayThumb := g_ThumbOnHold
			}
		}
	}
	else
	{
		vOut := mdnANN%kCode%
		GoSub, SubSend
		g_CharOnHold =
		g_RomajiOnHold =
		g_ThumbOnHold =
		g_KoyubiOnHold =
		g_SendTick =
		g_SendPtn =
	}
	return

;----------------------------------------------------------------------
; キーアップ（押下終了）
;----------------------------------------------------------------------
keyup:
	Critical
	g_CharUpTick := A_TickCount
	if kCode = %g_CharOnHold%	; 保留キーがアップされた
	{
		if g_SendPtn in C,CR,CL,RC,LC
		{
			g_ThumbOnHold = N	; 保留キーの単独打鍵
		}
		else if g_SendPtn in RCRu
		{
			g_ThumbOnHold = R	; 保留キーの単独打鍵
		}
		else if g_SendPtn in LCLu
		{
			g_ThumbOnHold = L	; 保留キーの単独打鍵
		}
		Gosub, SendOnHoldKey
	}
	if kCode = 0
	{
		vOut := MnUp(kName)
		GoSub, SubSend
		return
	}
	if g_Modifier =
	{
		if kCode<>
		{
			vOut := kup%g_Romaji%%g_Thumb%%g_Koyubi%%kCode%
			GoSub, SubSend
			return
		}
	}
	else
	{
		vOut := mupANN%kCode%
		GoSub, SubSend
		g_CharOnHold =
		g_RomajiOnHold =
		g_ThumbOnHold =
		g_KoyubiOnHold =
		g_SendTick =
		g_SendPtn =
	}
	if g_Modifier in Win,Alt
	{
		IME_SET(0)
	}
	return
	
;----------------------------------------------------------------------
; 10[mSEC]ごとの割込処理
;----------------------------------------------------------------------
Interrupt10:
	if g_CharOnHold<>
	{
		if A_TickCount >%g_SendTick% 
		{
			Gosub, SendOnHoldKey
		}
	}
	if A_PriorKey in LWin,RWin
	{
		g_Modifier = Win
	}
	else if A_PriorKey in LAlt,RAlt
	{
		g_Modifier = Alt
	}
	else if g_Modifier in Win,Alt
	{
		g_Modifier = 
	}
	return

;----------------------------------------------------------------------
; IME状態のチェックとローマ字モード判定
;----------------------------------------------------------------------
ChkIME:
	vImeMode := IME_GET()
	if(vImeMode = 0)
	{
		g_Romaji = A
	} else {
		g_Romaji = R
		vImeConvMode :=IME_GetConvMode()
		if(vImeConvMode <= 16)	; かなモード+半英数
		{
			g_Romaji = A
		} 
		else if(vImeConvMode = 24)	;全英数
		{
			g_Romaji = A
		}
	}
	return


; １段目
*sc002::	;1
	kCode = 11
	Goto, keydown
*sc002 up::
	kCode = 11
	Goto, keyup
*sc003::	;2
	kCode = 12
	Goto, keydown
*sc003 up::
	kCode = 12
	Goto, keyup
*sc004::	;3
	kCode = 13
	Goto, keydown
*sc004 up::
	kCode = 13
	Goto, keyup
*sc005::	;4
	kCode = 14
	Goto, keydown
*sc005 up::
	kCode = 14
	Goto, keyup
*sc006::	;5
	kCode = 15
	Goto, keydown
*sc006 up::
	kCode = 15
	Goto, keyup
*sc007::	;6
	kCode = 16
	Goto, keydown
*sc007 up::
	kCode = 16
	Goto, keyup
*sc008::	;7
	kCode = 17
	Goto, keydown
*sc008 up::
	kCode = 17
	Goto, keyup
*sc009::	;8
	kCode = 18
	Goto, keydown
*sc009 up::
	kCode = 18
	Goto, keyup
*sc00A::	;9
	kCode = 19
	Goto, keydown
*sc00A up::
	kCode = 19
	Goto, keyup
*sc00B::	;0
	kCode = 110
	Goto, keydown
*sc00B up::
	kCode = 110
	Goto, keyup
*sc00C::	;-
	kCode = 111
	Goto, keydown
*sc00C up::
	kCode = 111
	Goto, keyup
*sc00D::	;^
	kCode = 112
	Goto, keydown
*sc00D up::
	kCode = 112
	Goto, keyup
*sc07D::	;\
	kCode = 113
	Goto, keydown
*sc07D up::
	kCode = 113
	Goto, keyup
;　２段目
*sc010::	;q
	kCode = 21
	Goto, keydown
*sc010 up::
	kCode = 21
	Goto, keyup
*sc011::	;w
	kCode = 22
	Goto, keydown
*sc011 up::	;w
	kCode = 22
	Goto, keyup
*sc012::	;e
	kCode = 23
	Goto, keydown
*sc012 up::	;e
	kCode = 23
	Goto, keyup
*sc013::	;r
	kCode = 24
	Goto, keydown
*sc013 up::	;r
	kCode = 24
	Goto, keyup
*sc014::	;t
	kCode = 25
	Goto, keydown
*sc014 up::	;t
	kCode = 25
	Goto, keyup
*sc015::	;y
	kCode = 26
	Goto, keydown
*sc015 up::	;y
	kCode = 26
	Goto, keyup
*sc016::	;u
	kCode = 27
	Goto, keydown
*sc016 up::	;u
	kCode = 27
	Goto, keyup
*sc017::	;i
	kCode = 28
	Goto, keydown
*sc017 up::	;i
	kCode = 28
	Goto, keyup
*sc018::	;o
	kCode = 29
	Goto, keydown
*sc018 up::	;o
	kCode = 29
	Goto, keyup
*sc019::	;p
	kCode = 210
	Goto, keydown
*sc019 up::	;p
	kCode = 210
	Goto, keyup
*sc01A::	;@
	kCode = 211
	Goto, keydown
*sc01A up::	;@
	kCode = 211
	Goto, keyup
*sc01B::	;[
	kCode = 212
	Goto, keydown
*sc01B up::	;[
	kCode = 212
	Goto, keyup
; ３段目
*sc01E::	;a
	kCode = 31
	Goto, keydown
*sc01E up::	;a
	kCode = 31
	Goto, keyup
*sc01F::	;s
	kCode = 32
	Goto, keydown
*sc01F up::	;s
	kCode = 32
	Goto, keyup
*sc020::	;d
	kCode = 33
	Goto, keydown
*sc020 up::	;d
	kCode = 33
	Goto, keyup
*sc021::	;f
	kCode = 34
	Goto, keydown
*sc021 up::	;f
	kCode = 34
	Goto, keyup
*sc022::	;g
	kCode = 35
	Goto, keydown
*sc022 up::	;g
	kCode = 35
	Goto, keyup
*sc023::	;h
	kCode = 36
	Goto, keydown
*sc023 up::	;h
	kCode = 36
	Goto, keyup
*sc024:: ;j
	kCode = 37
	Goto, keydown
*sc024 up:: ;j
	kCode = 37
	Goto, keyup
*sc025:: ;k
	kCode = 38
	Goto, keydown
*sc025 up:: ;k
	kCode = 38
	Goto, keyup
*sc026:: ;l
	kCode = 39
	Goto, keydown
*sc026 up:: ;l
	kCode = 39
	Goto, keyup
*sc027:: ;';'
	kCode = 310
	Goto, keydown
*sc027 up:: ;';'
	kCode = 310
	Goto, keyup
*sc028:: ;'*'
	kCode = 311
	Goto, keydown
*sc028 up:: ;'*'
	kCode = 311
	Goto, keyup
*sc02B::
	kCode = 312
	Goto, keydown
*sc02B up:: ;']'
	kCode = 312
	Goto, keyup
;４段目
*sc02C::	;z
	kCode = 41
	Goto, keydown
*sc02C up::	;z
	kCode = 41
	Goto, keyup
*sc02D::	;x
	kCode = 42
	Goto, keydown
*sc02D up::	;x
	kCode = 42
	Goto, keyup
*sc02E::	;c
	kCode = 43
	Goto, keydown
*sc02E up::	;c
	kCode = 43
	Goto, keyup
*sc02F::	;v
	kCode = 44
	Goto, keydown
*sc02F up::	;v
	kCode = 44
	Goto, keyup
*sc030::	;b
	kCode = 45
	Goto, keydown
*sc030 up::	;b
	kCode = 45
	Goto, keyup
*sc031::	;n
	kCode = 46
	Goto, keydown
*sc031 up::	;n
	kCode = 46
	Goto, keyup
*sc032::	;m
	kCode = 47
	Goto, keydown
*sc032 up::	;m
	kCode = 47
	Goto, keyup
*sc033::	;,
	kCode = 48
	Goto, keydown
*sc033 up::	;,
	kCode = 48
	Goto, keyup
*sc034::	;.
	kCode = 49
	Goto, keydown
*sc034 up::	;.
	kCode = 49
	Goto, keyup
*sc035::	;/
	kCode = 410
	Goto, keydown
*sc035 up::	;/
	kCode = 410
	Goto, keyup
*sc073::	;\
	kCode = 411
	Goto, keydown
*sc073 up::	;_
	kCode = 411
	Goto, keyup

Tab::
	kName = Tab
	kCode = 0
	Goto, keydown

Enter::
	kName = Enter
	kCode = 0
	Goto, keydown
Backspace::
	kName = Backspace
	kCode = 0
	Goto, keydown
CapsLock::
	kName = CapsLock
	kCode = 0
	Goto, keydown
Insert::
	kName = Insert
	kCode = 0
	Goto, keydown
Delete::
	kName = Delete
	kCode = 0
	Goto, keydown
Left::
	kName = Left
	kCode = 0
	Goto, keydown
Home::
	kName = Home
	kCode = 0
	Goto, keydown
End::
	kName = End
	kCode = 0
	Goto, keydown
;Up::
;Down::
PgUp::
	kName = PgUp
	kCode = 0
	Goto, keydown
PgDn::
	kName = PgDn
	kCode = 0
	Goto, keydown
Right::
	kName = Right
	kCode = 0
	Goto, keydown
Esc::
	kName = Esc
	kCode = 0
	Goto, keydown
F1::
	kName = F1
	kCode = 0
	Goto, keydown
F2::
	kName = F2
	kCode = 0
	Goto, keydown
F3::
	kName = F3
	kCode = 0
	Goto, keydown
F4::
	kName = F4
	kCode = 0
	Goto, keydown
F5::
	kName = F5
	kCode = 0
	Goto, keydown
F6::
	kName = F6
	kCode = 0
	Goto, keydown
F7::
	kName = F7
	kCode = 0
	Goto, keydown
F8::
	kName = F8
	kCode = 0
	Goto, keydown
F9::
	kName = F9
	kCode = 0
	Goto, keydown
F10::
	kName = F10
	kCode = 0
	Goto, keydown
F11::
	kName = F11
	kCode = 0
	Goto, keydown
F12::
	kName = F12
	kCode = 0
	Goto, keydown
AppsKey::
	kName = AppsKey
	kCode = 0
	Goto, keydown
PrintScreen::
	kName = PrintScreen
	kCode = 0
	Goto, keydown

	kName := A_ThisHotkey
	kCode = 0
	Goto, keydown


Enter up::
	kName = Enter
	kCode = 0
	Goto, keyup
Tab up::
	kName = Tab
	kCode = 0
	Goto, keyup
Backspace up::
	kName = Backspace
	kCode = 0
	Goto, keyup
CapsLock up::
	kName = CapsLock
	kCode = 0
	Goto, keyup
Insert up::
	kName = Insert
	kCode = 0
	Goto, keyup
Delete up::
	kName = Delete
	kCode = 0
	Goto, keyup
Left up::
	kName = Left
	kCode = 0
	Goto, keyup
Home up::
	kName = Home
	kCode = 0
	Goto, keyup
End up::
	kName = End
	kCode = 0
	Goto, keyup
;Up up::
;Down up::
PgUp up::
	kName = PgUp
	kCode = 0
	Goto, keyup
PgDn up::
	kName = PgDn
	kCode = 0
	Goto, keyup
Right up::
	kName = Right
	kCode = 0
	Goto, keyup
Esc up::
	kName = Esc
	kCode = 0
	Goto, keyup
F1 up::
	kName = F1
	kCode = 0
	Goto, keyup
F2 up::
	kName = F2
	kCode = 0
	Goto, keyup
F3 up::
	kName = F3
	kCode = 0
	Goto, keyup
F4 up::
	kName = F4
	kCode = 0
	Goto, keyup
F5 up::
	kName = F5
	kCode = 0
	Goto, keyup
F6 up::
	kName = F6
	kCode = 0
	Goto, keyup
F7 up::
	kName = F7
	kCode = 0
	Goto, keyup
F8 up::
	kName = F8
	kCode = 0
	Goto, keyup
F9 up::
	kName = F9
	kCode = 0
	Goto, keyup
F10 up::
	kName = F10
	kCode = 0
	Goto, keyup
F11 up::
	kName = F11
	kCode = 0
	Goto, keyup
F12 up::
	kName = F12
	kCode = 0
	Goto, keyup
AppsKey up::
	kName = AppsKey
	kCode = 0
	Goto, keyup
PrintScreen up::
	kName = PrintScreen
	kCode = 0
	Goto, keyup

	kName := A_ThisHotkey
	kCode = 0
	Goto, keyup

;*sc039::	;Space
;*sc01C::	;Enter
;*sc00E::	;BS
;*sc00F::	;Tab
*sc029::	;半角／全角
	kName = sc029
	kCode = 0
	Goto, keydown
*sc070::	;ひらがな／カタカナ
	kName = sc070
	kCode = 0
	Goto, keydown
;*sc03A::	;CapsLock
;*sc152::	;Insert
;*sc153::	;Delete
;*sc14B::	;←
;*sc147::	;home
;*sc14F::	;End
*sc148::	;↑
	kName = sc148
	kCode = 0
	Goto, keydown
*sc150::	;↓
	kName = sc150
	kCode = 0
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
	kCode = 0
	Goto, keydown

;*sc039 up::	;Space
;*sc01C up::	;Enter
;*sc00E up::	;BS
;*sc00F up::	;Tab
*sc029 up::	;半角／全角
	kName = sc029
	kCode = 0
	Goto, keyup
*sc070 up::	;ひらがな／カタカナ
	kName = sc070
	kCode = 0
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
	kCode = 0
	Goto, keyup
*sc150 up::	;↓
	kName = sc150
	kCode = 0
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
	kCode = 0
	Goto, keyup
