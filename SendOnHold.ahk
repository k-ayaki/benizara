;-----------------------------------------------------------------------
;	名称：SendOnHold.ahk
;	機能：キューのキーコード送信
;	作者：Ken'ichiro Ayaki
;-----------------------------------------------------------------------

;----------------------------------------------------------------------
; 保留の出力：セットされた文字のセットされた親指の出力
;----------------------------------------------------------------------
SendOnHoldMO()
{
	global
	local _cntM,_mode, _KeyInPtn
	
	_cntM := countMoji()
	if(g_OnHoldIdx < 1) {
		clearQueue()
	} else if(_cntM >= 1) {
		if(g_MetaOnHold[1]=="M" && RegExMatch(g_MetaOnHold[2], "^[RLABCD]$")==1)
		{
			_mode := g_RomajiOnHold[2] . g_OyaOnHold[2] . g_KoyubiOnHold[2]
			SendOnHold(_mode, g_MojiOnHold[1], g_ZeroDelay)
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
	if(g_Continue == 0) {
		g_Oya := "N"
	}
	_KeyInPtn := getKeyInPtnFromQueue()
	return _KeyInPtn
}
;----------------------------------------------------------------------
; 保留の出力：セットされた文字のセットされた親指の出力
;----------------------------------------------------------------------
SendOnHoldOM()
{
	global
	local _cntM,_mode, _KeyInPtn
	
	_cntM := countMoji()
	if(g_OnHoldIdx < 1) {
		clearQueue()
	} else if(_cntM >= 1) {
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
	if(g_Continue == 0) {
		g_Oya := "N"
	}
	_KeyInPtn := getKeyInPtnFromQueue()
	return _KeyInPtn
}
;----------------------------------------------------------------------
; 保留キーの出力：セットされた文字の出力
;----------------------------------------------------------------------
SendOnHoldM()
{
	global
	local _cntM, _mode, _KeyInPtn
	
	_cntM := countMoji()
	if(_cntM >= 1) {
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
	}
	_KeyInPtn := getKeyinPtnFromQueue()
	return _KeyInPtn
}

;----------------------------------------------------------------------
; 保留キーの出力：セットされた文字の出力
;----------------------------------------------------------------------
SendOnHoldMM()
{
	global
	local _cntM, _keyInPtn, _mode

	_cntM := countMoji()
	if(g_OnHoldIdx < 1) {
		_keyInPtn := clearQueue()
		g_Timeout := 60000
		g_SendTick := INFINITE
		return _keyInPtn
	}
	else if(_cntM == 1) {
		_keyInPtn := SendOnHoldM()
		_keyInPtn := clearQueue()
		g_Timeout := 60000
		g_SendTick := INFINITE
		return _keyInPtn
	}
	if(_cntM >= 2) {
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
			_keyInPtn := clearQueue()
			g_Timeout := 60000
			g_SendTick := INFINITE
		} else {
			_keyInPtn := SendOnHoldM()
		}
	} else {
		_keyInPtn := SendOnHoldM()
	}
	return _keyInPtn
}

;----------------------------------------------------------------------
; 保留キーの出力：セットされた文字の出力
;----------------------------------------------------------------------
SendOnHoldMMM()
{
	global
	local _cntM, _KeyInPtn, _mode
	
	_cntM := countMoji()
	if(g_OnHoldIdx < 1) {
		_KeyInPtn := clearQueue()
		g_Timeout := 60000
		g_SendTick := INFINITE
		return _KeyInPtn
	}
	else if(_cntM == 1) {
		_KeyInPtn := SendOnHoldM()
		return _KeyInPtn
	}
	else if(_cntM == 2) {
		_KeyInPtn := SendOnHoldMM()
		if(_KeyInPtn == "M") {
			SubSendUp(g_MojiOnHold[1])
			_KeyInPtn := SendOnHoldM()
		}
		return _KeyInPtn
	}
	; 異常時の対処
	if(RegExMatch(g_MetaOnHold[1], "^[RLABCD]$")==1 
	&& g_MetaOnHold[2]=="M" && g_MetaOnHold[3]=="M" && g_MetaOnHold[4]=="M")
	{
		g_RomajiOnHold[2] := g_RomajiOnHold[1]
		g_OyaOnHold[2]    := g_OyaOnHold[1]
		g_KoyubiOnHold[2] := g_KoyubiOnHold[1]
		dequeueKey()
		_KeyInPtn := getKeyinPtnFromQueue()
	}
	_mode := g_RomajiOnHold[1] . g_OyaOnHold[1] . g_KoyubiOnHold[1]
	if(kdn[_mode . g_MojiOnHold[3] . g_MojiOnHold[2] . g_MojiOnHold[1]] != "") {
		SendOnHold(_mode, g_MojiOnHold[3] . g_MojiOnHold[2] . g_MojiOnHold[1], g_ZeroDelay)	
		_KeyInPtn := clearQueue()
		g_Timeout := 60000
		g_SendTick := INFINITE
	} else
	if(kdn[_mode . g_MojiOnHold[2] . g_MojiOnHold[1]] != "") {
		SendOnHold(_mode, g_MojiOnHold[2] . g_MojiOnHold[1], g_ZeroDelay)
		dequeueKey()
		dequeueKey()
		SubSendUp(g_MojiOnHold[1])
		_KeyInPtn := SendOnHoldM()
		_KeyInPtn := clearQueue()
		return _KeyInPtn
	} else {
		SendOnHold(_mode, g_MojiOnHold[1], g_ZeroDelay)
		dequeueKey()
		SubSendUp(g_MojiOnHold[1])
		
		_KeyInPtn := SendOnHoldMM()
		if(_KeyInPtn == "M") {
			SubSendUp(g_MojiOnHold[1])
			_KeyInPtn := SendOnHoldM()
			_KeyInPtn := clearQueue()
		} else {
			_KeyInPtn := clearQueue()
		}
	}
	return _KeyInPtn
}

;----------------------------------------------------------------------
; 保留された親指キーの出力
; 2020/10/16 : スペースキーをホールドしているときは単独打鍵する
;----------------------------------------------------------------------
SendOnHoldO()
{
	global
	local _KeyInPtn, _vOut

	if(RegExMatch(g_MetaOnHold[1], "^[RLABCD]$")==1) 
	{
		if(g_KeySingle == "有効" || g_MojiOnHold[1] == "A02") {
			_vOut := kdn[g_RomajiOnHold[1] . g_OyaOnHold[1] . g_KoyubiOnHold[1] . g_MojiOnHold[1]]
			SubSendOne(_vOut)
			SetKeyupSave(kup[g_RomajiOnHold[1] . g_OyaOnHold[1] . g_KoyubiOnHold[1] . g_MojiOnHold[1]] , g_MojiOnHold[1])
		}
		dequeueKey()
	}
	queueClearKeyup()

	if(g_MetaOnHold[1] == "M") {	; 直前の文字キーをシフトオフする
		g_OyaOnHold[1] := "N"
	}
	if(g_Continue == 0) 
	{
		g_Oya := "N"
	}
	_KeyInPtn := getKeyinPtnFromQueue()
	return _KeyInPtn
}

;----------------------------------------------------------------------
; 保留キーの出力関数：
; _mode : モードまたは文字同時打鍵の第１文字
; _MojiOnHold : 現在の打鍵文字の場所 A01-E14
; _ZeroDelay : 零遅延モード
;----------------------------------------------------------------------
SendOnHold(_mode, _MojiOnHold, _ZeroDelay)
{
	global
	local _MojiOnHoldLast, _vOut, _nextKey, _aStr

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
	_vOut := kdn[_mode . _MojiOnHold]
	kup_save[_MojiOnHoldLast] := kup[_mode . _MojiOnHold]
	_nextKey := nextDakuten(_mode,_MojiOnHold)
	if(_nextKey != "") {
		g_LastKey["表層"] := _nextKey
		_aStr := "後" . g_LastKey["表層"]
		GenSendStr3(_mode, _aStr, _down, _up, _status)
		_vOut                   := _down
		kup_save[_MojiOnHoldLast]  := _up
	} else {
		g_LastKey["表層"] := kLabel[_mode . _MojiOnHold]
	}
	if(_ZeroDelay == 1)
	{
		if(_vOut!=g_ZeroDelayOut)
		{
			CancelZeroDelayOut(_ZeroDelay)
			SubSend(_vOut)
		} else {
			RegLogs("", g_KeyInPtn, g_trigger, g_Timeout, "")
		}
		g_ZeroDelayOut := ""
		g_ZeroDelaySurface := ""
	} else {
		SubSend(_vOut)
	}
}
;----------------------------------------------------------------------
; 送信文字列の出力
;----------------------------------------------------------------------
SubSend(_vOut)
{
	global g_KeyInPtn, g_trigger
	global g_Koyubi, g_Timeout
	global g_vOut

	g_vOut := _vOut
	_strokes := StrSplit(_vOut,chr(9))
	_scnt := 0
	_len := strlen(_vOut)
	_sendch := ""
	loop, % _strokes.MaxIndex()
	{
		_stroke := _strokes[A_Index]
		_idx := InStr(_stroke, "{")
		if (_idx>0 && _idx+1 <= StrLen(_stroke))
		{
			_sendch := SubStr(_stroke,_idx + 1,1)
		} else {
			_sendch := ""
		}
		if(g_Koyubi=="K" && isCapsLock(_sendch)==true && instr(_stroke,"{vk")==0) {
			if(_scnt>=4) 
			{
				SetKeyDelay, 16,-1
				_scnt := 0
			} else {
				SetKeyDelay, -1,-1
			}
			Send, {blind}{capslock}
			_scnt +=  1
			RegLogs("", g_KeyInPtn, g_trigger, g_Timeout, "{capslock}")
			g_Timeout := ""
			if(instr(_stroke,"^{M")>0 || instr(_stroke,"{Enter")>0) {
				_scnt += 4
			}
			if(_scnt>=4)
			{
				SetKeyDelay, 64,-1
				_scnt := 0
			} else {
				SetKeyDelay, -1,-1
			}
			Send,% _stroke
			_scnt += 1
			RegLogs("", g_KeyInPtn, g_trigger, g_Timeout, _stroke)
			g_Timeout := ""
			
			if(_scnt>=4) 
			{
				SetKeyDelay,16,-1
				_scnt := 0
			} else {
				SetKeyDelay,-1,-1
			}
			Send, {blind}{capslock}
			_scnt += 1
			RegLogs("", g_KeyInPtn, g_trigger, g_Timeout, "{capslock}")
			g_Timeout := ""
		} else {
			if(instr(_stroke,"^{M")>0 || instr(_stroke,"{Enter")>0) {
				_scnt += 4
			}
			if(_scnt>=4)
			{
				SetKeyDelay, 64,-1
				_scnt := 0
			} else {
				SetKeyDelay, -1,-1
			}
			if WinActive("ahk_class ApplicationFrameWindow")
			{
				if (_stroke == "{Up down}")	; Microsoft OneNote 対策
				{
					dllcall("keybd_event", int, 0x26, int, 0, int, 1, int, 0) ;Up
				} else
				if (_stroke == "{Down down}")
				{
					dllcall("keybd_event", int, 0x28, int, 0, int, 1, int, 0) ;Down
				} else {
					Send,% _stroke
				}
			} else {
				Send,% _stroke
			}
			_scnt += 1
			RegLogs("", g_KeyInPtn, g_trigger, g_Timeout, _stroke)
			g_Timeout := ""
		}
	}
}
;----------------------------------------------------------------------
; 送信文字列の出力・１つだけ
;----------------------------------------------------------------------
SubSendOne(_vOut)
{
	global
	
	if(_vOut!="") {
		SetKeyDelay, -1,-1
;		Send, {blind}%_vOut%
		_vOut2 := "{blind}" . _vOut
		Send, % _vOut2
		RegLogs("", g_KeyInPtn, g_trigger, g_Timeout, _vOut)
		g_Timeout := ""
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
	local _code

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
MnDownUp(_key)
{
	if(_key!="")
		return "{" . _key . " down}{" . _key . " up}"
	else
		return ""
}

;----------------------------------------------------------------------
; 零遅延モード出力のキャンセル
;----------------------------------------------------------------------
CancelZeroDelayOut(_ZeroDelay) {
	global

	if(_ZeroDelay == 1) {
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
MnDown(_aStr) {
	_vOut := ""
	if(_aStr!="")
	{
		_vOut := "{" . _aStr . " down}"
	}
	return _vOut
}
;----------------------------------------------------------------------
; キーアップ時にSendする文字列を設定する
; 引数　：aStr：対応するキー入力
; 戻り値：Sendの引数
;----------------------------------------------------------------------
MnUp(_aStr) {
	_vOut := ""
	if(_aStr!="")
	{
		_vOut := "{" . _aStr . " up}"
	}
	return _vOut
}
;----------------------------------------------------------------------
; キーをすぐさま出力
;----------------------------------------------------------------------
SendKey(_mode, _MojiOnHold){
	global
	local _vOut, _nextKey, _aStr
	
	_vOut                 := kdn[_mode . _MojiOnHold]
	kup_save[_MojiOnHold] := kup[_mode . _MojiOnHold]
	_nextKey := nextDakuten(_mode,_MojiOnHold)
	if(_nextKey != "") {
		g_LastKey["表層"] := _nextKey
		_aStr := "後" . g_LastKey["表層"]
		GenSendStr3(_mode, _aStr, _down, _up, _status)
		_vOut                 := _down
		kup_save[_MojiOnHold] := _up
	} else {
		g_LastKey["表層"] := kLabel[_mode . _MojiOnHold]
	}
	SubSend(_vOut)
}
;----------------------------------------------------------------------
; 親指シフトと同時打鍵の零遅延モードの先行出力
;----------------------------------------------------------------------
SendZeroDelayOM()
{
	global
	local _cntM

	_cntM := countMoji()
	if(_cntM >= 1) {
		if(RegExMatch(g_MetaOnHold[1], "^[RLABCD]$")==1 && g_MetaOnHold[2]=="M")
		{
			SendZeroDelay(g_RomajiOnHold[1] . g_OyaOnHold[1] . g_KoyubiOnHold[1], g_MojiOnHold[2], g_ZeroDelay)
		} else 
		if(g_MetaOnHold[1]=="M") {
			SendZeroDelay(g_RomajiOnHold[1] . g_OyaOnHold[1] . g_KoyubiOnHold[1], g_MojiOnHold[1], g_ZeroDelay)
		}
	}
	return
}
;----------------------------------------------------------------------
; 親指シフトと同時打鍵の零遅延モードの先行出力
;----------------------------------------------------------------------
SendZeroDelay(_mode, _MojiOnHold, _ZeroDelay)
{
	global
	local _MojiOnHoldLast, _nextKey, _aStr, _vOut

	if(_ZeroDelay == 1)
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
			_vOut := kdn[_mode . _MojiOnHold]
			kup_save[_MojiOnHoldLast] := kup[_mode . _MojiOnHold]
			
			_nextKey := nextDakuten(_mode,_MojiOnHold)
			if(_nextKey!="") {
				_aStr := "後" . _nextKey
				GenSendStr3(_mode, _aStr, _down, _up, _status)
				_vOut                 := _down
				kup_save[_MojiOnHold] := _up
			}
			g_ZeroDelayOut := _vOut
			SubSend(_vOut)
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
; タイムアウト時間を設定
;----------------------------------------------------------------------
SetTimeout(_KeyInPtn)
{
	global
	local _mode, _Timeout

	_mode := g_RomajiOnHold[1] . g_OyaOnHold[1] . g_KoyubiOnHold[1]	
	
	if(_KeyInPtn=="") {
		_Timeout := 60000
	} else 
	if(_KeyInPtn=="M") {
		if(g_OnHoldIdx == 0) {
			_Timeout := minimum(floor((g_Threshold*(100-g_OverlapMO))/g_OverlapMO),g_MaxTimeout)
		} else if(ksc[_mode . g_MojiOnHold[g_OnHoldIdx]]<=1) {
			_Timeout := minimum(floor((g_Threshold*(100-g_OverlapMO))/g_OverlapMO),g_MaxTimeout)
			if(CountObject(g_SimulMode)!=0) {
				; 文字同時打鍵があればタイムアウトの大きい方に合わせる
				_Timeout := maximum(_Timeout, minimum(floor((g_ThresholdSS*(100-g_OverlapSS))/g_OverlapSS),g_MaxTimeout))
			}
		} else {
			_Timeout := 60000
		}
	} else
	if(_KeyInPtn=="MM") 
	{
		if(g_OnHoldIdx <= 1) {
			_Timeout := maximum(g_ThresholdSS,g_Threshold)
		} else if(ksc[_mode . g_MojiOnHold[g_OnHoldIdx] . g_MojiOnHold[g_OnHoldIdx - 1]]<=2) {
			_Timeout := maximum(g_ThresholdSS, g_Threshold)
		} else {
			_Timeout := 60000
		}
	} else
	if(_KeyInPtn=="MMm") 
	{
		g_Interval["S12"]  := g_TDownOnHold[2] - g_TDownOnHold[1]	; 最初の文字だけをオンしていた期間
		g_Interval["S2_1"] := g_TUpOnHold[1] - g_TDownOnHold[2]		; 前回の文字キー押しからの重なり期間
		_Timeout := minimum(floor((g_Interval["S2_1"]*(100-g_OverlapSS))/g_OverlapSS)-g_Interval["S12"],g_MaxTimeout)
	} else
	if(_KeyInPtn=="MMM") 
	{
		_Timeout := 0
	} else
	if(RegExMatch(_KeyInPtn, "^[RLABCD]$")==1)
	{
		_Timeout := 60000
	} else
	if(RegExMatch(_KeyInPtn, "^[RLABCD]M$")==1)
	{
		if(g_OnHoldIdx==2) {
			g_Interval[g_Oya . "M"] := g_TDownOnHold[g_OnHoldIdx] - g_OyaTick[g_Oya]
			_Timeout := minimum(floor(g_Interval[g_Oya . "M"]*g_OverlapOM/(100-g_OverlapOM)),g_MaxTimeout)
		} else {
			_Timeout := minimum(g_Threshold, g_MaxTimeout)
		}
	} else
	if(RegExMatch(_KeyInPtn, "^[RLABCD]M[RLABCD]$")==1)
	{
		g_Interval["M" . g_Oya] := g_OyaTick[g_Oya] - g_TDownOnHold[g_OnHoldIdx-1]
		_Timeout := minimum(floor(g_Interval["M" . g_Oya]*g_OverlapMO/(100-g_OverlapMO)),g_MaxTimeout)
	} else
	if(RegExMatch(_KeyInPtn, "^M[RLABCD]$")==1)
	{
		g_Interval["M" . g_Oya] := g_OyaTick[g_Oya] - g_TDownOnHold[g_OnHoldIdx-1]
		_Timeout := minimum(floor(g_Interval["M" . g_Oya]*g_OverlapMO/(100-g_OverlapMO)),g_MaxTimeout)
	} else
	if(RegExMatch(_KeyInPtn, "^[RLABCD]M[rlabcd]$")==1)
	{
		wOya := g_OyaOnHold[g_OnHoldIdx]
		g_Interval["M_" . wOya] := g_TDownOnHold[g_OnHoldIdx-1] - g_TUpOnHold[g_OnHoldIdx]	; 文字キーオンから親指キーオフまでの期間
		_Timeout := minimum(floor((g_Interval["M_" . wOya]*(100-g_OverlapOMO))/g_OverlapOMO),g_MaxTimeout)
	} else 
	if(RegExMatch(_KeyInPtn, "^[RLABCD]M[RLABCD][rlabcd]$")==1)
	{
		wOya := g_OyaOnHold[g_OnHoldIdx-1]
		g_Interval[wOya] := g_TDownOnHold[g_OnHoldIdx-1] - g_TUpOnHold[g_OnHoldIdx]	; 親指キーオンから現在までの期間
		_Timeout := minimum(floor((g_Interval[wOya]*(100-g_OverlapOMO))/g_OverlapOMO),g_MaxTimeout)
	} else 
	{
		_Timeout := 60000
	}
	return _Timeout
}
;----------------------------------------------------------------------
; タイムアウト時間を設定
;----------------------------------------------------------------------
calcSendTick(_currentTick, _Timeout)
{
	global
	local _SendTick

	if(_Timeout >= 60000) {
		_SendTick := INFINITE
	} else {
		_SendTick := _currentTick + _Timeout
	}
	return _SendTick
}
;----------------------------------------------------------------------
; 連続打鍵の判定
;----------------------------------------------------------------------
JudgePushedKeys(_mode,_MojiOnHold)
{
	global

	g_KeyOnHold := GetPushedKeys()
	if((strlen(g_KeyOnHold)==6 && strlen(_MojiOnHold)==3 && kdn[_mode . g_KeyOnHold . _MojiOnHold] != "")
	|| (strlen(g_KeyOnHold)==3 && strlen(_MojiOnHold)==3 && ksc[_mode . _MojiOnHold]==2 && kdn[_mode . g_KeyOnHold . _MojiOnHold] != "")
	|| (strlen(g_KeyOnHold)==3 && strlen(_MojiOnHold)==6 && kdn[_mode . g_KeyOnHold . _MojiOnHold] != "")) {
		SendOnHold(_mode, g_KeyOnHold . _MojiOnHold, g_ZeroDelay)
		_KeyInPtn := clearQueue()
		g_Timeout := 60000
		g_SendTick := INFINITE
	}
	return _KeyInPtn
}
;-----------------------------------------------------------------------
;	押下キー取得
;-----------------------------------------------------------------------
GetPushedKeys()
{
	global
	local _pushedKeys, _cont

	_pushedKeys := ""
	for index, element in layoutArys
	{
		if(keyState[element] == 1) {
			if(GetKeyState(keyNameHash[element],"P")==0) {
				keyState[element] := 0
			} else {
				_cont := g_colPushedHash[substr(element,1,1)] . substr(element,2,2)
				_pushedKeys .= _cont
			}
		}
	}
	return _pushedKeys
}
