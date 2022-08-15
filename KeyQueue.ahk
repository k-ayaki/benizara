;-----------------------------------------------------------------------
;	名称：KeyQueue.ahk
;	機能：キーコードのキュー
;	作者：Ken'ichiro Ayaki
;-----------------------------------------------------------------------

InitKeyQueue:
	g_RomajiOnHold := Object()
	g_KoyubiOnHold := Object()
	g_OyaOnHold    := Object()
	g_MojiOnHold   := Object()
	g_TDownOnHold  := Object()
	g_TUpOnHold    := Object()
	g_MetaOnHold   := Object()
	g_OnHoldIdx    := 1
	return
	
;----------------------------------------------------------------------
; 文字キー・親指キー出力後のキューの取り出し
;----------------------------------------------------------------------
dequeueKey()
{
	global

	if(g_OnHoldIdx >= 3) {
		g_OnHoldIdx := 3
	}
	if(keyState[g_MojiOnHold[1]] == 2) {
		keyState[g_MojiOnHold[1]] := 1
	}
	loop,4
	{
		if(A_Index < g_OnHoldIdx && RegExMatch(g_MetaOnHold[A_Index+1], "^[rlabcdm]$")!=1) {
			g_RomajiOnHold[A_Index] := g_RomajiOnHold[A_Index+1]
			g_OyaOnHold[A_Index]    := g_OyaOnHold[A_Index+1]
			g_KoyubiOnHold[A_Index] := g_KoyubiOnHold[A_Index+1]
			g_MojiOnHold[A_Index]   := g_MojiOnHold[A_Index+1]
			g_TDownOnHold[A_Index]  := g_TDownOnHold[A_Index+1]
			g_TUpOnHold[A_Index]    := g_TUpOnHold[A_Index+1]
			g_MetaOnHold[A_Index]   := g_MetaOnHold[A_Index+1]
		} else {
			g_RomajiOnHold[A_Index] := ""
			g_OyaOnHold[A_Index]    := ""
			g_KoyubiOnHold[A_Index] := ""
			g_MojiOnHold[A_Index]   := ""
			g_TDownOnHold[A_Index]  := 0
			g_TUpOnHold[A_Index]    := 0
			g_MetaOnHold[A_Index]   := ""
		}
	}
	g_OnHoldIdx := countQueue()
	return g_OnHoldIdx
}
;----------------------------------------------------------------------
; 文字キー・親指キーをキューにセット
;----------------------------------------------------------------------
enqueueKey(_Romaji, _Oya, _Koyubi, _Moji, _Meta, _Tick)
{
	global
	local _KeyInPtn

	g_OnHoldIdx := countQueue()
	if(RegExMatch(g_MetaOnHold[g_OnHoldIdx], "^[rlabcdm]$")==1) {
		g_RomajiOnHold[g_OnHoldIdx] := ""
		g_OyaOnHold[g_OnHoldIdx]    := ""
		g_KoyubiOnHold[g_OnHoldIdx] := ""
		g_MojiOnHold[g_OnHoldIdx]   := ""
		g_TDownOnHold[g_OnHoldIdx]  := 0
		g_TUpOnHold[g_OnHoldIdx]    := 0
		g_MetaOnHold[g_OnHoldIdx]   := ""
		g_OnHoldIdx -= 1
	}
	if(RegExMatch(_Meta, "^[rlabcdm]$")==1) {
		g_OnHoldIdx += 1
		g_RomajiOnHold[g_OnHoldIdx] := _Romaji
		g_OyaOnHold[g_OnHoldIdx]    := _Oya
		g_KoyubiOnHold[g_OnHoldIdx] := _Koyubi
		g_MojiOnHold[g_OnHoldIdx]   := _Moji
		g_TDownOnHold[g_OnHoldIdx]  := 0
		g_TUpOnHold[g_OnHoldIdx]    := _Tick
		g_MetaOnHold[g_OnHoldIdx]   := _Meta
	} else {
		g_OnHoldIdx += 1
		g_RomajiOnHold[g_OnHoldIdx] := _Romaji
		g_OyaOnHold[g_OnHoldIdx]    := _Oya
		g_KoyubiOnHold[g_OnHoldIdx] := _Koyubi
		g_MojiOnHold[g_OnHoldIdx]   := _Moji
		g_TDownOnHold[g_OnHoldIdx]  := _Tick
		g_MetaOnHold[g_OnHoldIdx]   := _Meta
		g_TUpOnHold[g_OnHoldIdx]    := 0
	}
	_KeyInPtn := getKeyinPtnFromQueue()
	return _KeyInPtn
}
;----------------------------------------------------------------------
; キーアップを設定
;----------------------------------------------------------------------
queueClearKeyup()
{
	global

	g_OnHoldIdx := countQueue()
	if(RegExMatch(g_MetaOnHold[g_OnHoldIdx], "^[rlabcdm]$")==1) {
		g_RomajiOnHold[g_OnHoldIdx] := ""
		g_OyaOnHold[g_OnHoldIdx]    := ""
		g_KoyubiOnHold[g_OnHoldIdx] := ""
		g_MojiOnHold[g_OnHoldIdx]   := ""
		g_TDownOnHold[g_OnHoldIdx]  := 0
		g_TUpOnHold[g_OnHoldIdx]    := 0
		g_MetaOnHold[g_OnHoldIdx]   := ""
		g_OnHoldIdx -= 1
	}
}
;----------------------------------------------------------------------
; キーアップを設定
;----------------------------------------------------------------------
setKeyup(_Moji, _UpTick)
{
	global

	loop,4
	{
		if(_Moji == g_MojiOnHold[A_Index]) {
			g_TUpOnHold[A_Index] := _UpTick
		}
	}
}
;----------------------------------------------------------------------
; キューをカウント
;----------------------------------------------------------------------
countQueue()
{
	global
	local _onHoldIdx
	
	_onHoldIdx := 0
	loop,4
	{
		if(g_MetaOnHold[A_Index] != "") {
			_onHoldIdx := A_Index
		}
	}
	return _onHoldIdx
}
;----------------------------------------------------------------------
; キューからキー入力パターンを取得
;----------------------------------------------------------------------
getKeyinPtnFromQueue()
{
	global
	local _keyInPtn
	
	_KeyInPtn := ""
	loop,4
	{
		if(g_MetaOnHold[A_Index] != "") {
			_KeyInPtn .= g_MetaOnHold[A_Index]
		}
	}
	if((_keyInPtn == "M" || RegExMatch(_keyInPtn, "^M[rlabcd]$")==1)
	&& RegExMatch(g_OyaOnHold[1], "^[RLABCD]$")==1)
	{
		_keyInPtn := g_OyaOnHold[1] . _keyInPtn
	}
	return _KeyInPtn
}
;----------------------------------------------------------------------
; 文字キーのOMを１つにマージ
;----------------------------------------------------------------------
mergeOMKey()
{
	global
	
	if(RegExMatch(g_MetaOnHold[1], "^[RLABCD]$")==1 && g_MetaOnHold[2]=="M") {
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
	global
	
	if(g_MetaOnHold[1]=="M" && RegExMatch(g_MetaOnHold[2], "^[RLABCD]$")==1) {
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
	global
	
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
		g_MetaOnHold[A_Index]   := ""
	}
	g_OnHoldIdx := 0
	return ""
}
;----------------------------------------------------------------------
; 押されている文字キーの取得
;----------------------------------------------------------------------
GetMojiOnHold()
{
	global
	local _Moji
	
	_Moji := ""
	loop,% g_OnHoldIdx
	{
		if(g_MetaOnHold[A_Index]=="M") {
			_Moji .= g_MojiOnHold[A_Index]
		}
	}
	return _Moji
}
;----------------------------------------------------------------------
; キュー中の文字数
;----------------------------------------------------------------------
countMoji()
{
	global
	local _cntM

	_cntM := 0
	loop,% g_OnHoldIdx
	{
		if(g_MetaOnHold[A_Index]=="M") {
			_cntM += 1
		}
	}
	return _cntM
}
