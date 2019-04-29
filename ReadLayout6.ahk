;-----------------------------------------------------------------------
;	名称：ReadLayout6.ahk
;	機能：紅皿のキーレイアウトファイルの読み込み
;	ver.0.1.3.3 .... 2019/4/20
;-----------------------------------------------------------------------
ReadLayout:
	Gosub, InitControl

	Gosub, InitLayout
	Gosub, Layout2Key
	vLayoutFile := g_LayoutFile
	if(vLayoutFile = "")
		return

	_error := ""
	Gosub, ReadLayoutFile
	if(_error <> "")
	{
		Msgbox,%_error%
		Gosub, InitLayout
		Gosub, Layout2Key
	}
	return

#include Path.ahk

InitLayout:
	LFANN1 :="１,２,３,４,５,６,７,８,９,０,－,＾,￥"
	LFANN2 :="ｑ,ｗ,ｅ,ｒ,ｔ,ｙ,ｕ,ｉ,ｏ,ｐ,＠,［"
	LFANN3 :="ａ,ｓ,ｄ,ｆ,ｇ,ｈ,ｊ,ｋ,ｌ,；,：,］"
	LFANN4 :="ｚ,ｘ,ｃ,ｖ,ｂ,ｎ,ｍ,，,．,／,￥"

	LFALN1 :="１,２,３,４,５,６,７,８,９,０,－,＾,￥"
	LFALN2 :="ｑ,ｗ,ｅ,ｒ,ｔ,ｙ,ｕ,ｉ,ｏ,ｐ,＠,［"
	LFALN3 :="ａ,ｓ,ｄ,ｆ,ｇ,ｈ,ｊ,ｋ,ｌ,；,：,］"
	LFALN4 :="ｚ,ｘ,ｃ,ｖ,ｂ,ｎ,ｍ,，,．,／,￥"

	LFARN1 :="１,２,３,４,５,６,７,８,９,０,－,＾,￥"
	LFARN2 :="ｑ,ｗ,ｅ,ｒ,ｔ,ｙ,ｕ,ｉ,ｏ,ｐ,＠,［"
	LFARN3 :="ａ,ｓ,ｄ,ｆ,ｇ,ｈ,ｊ,ｋ,ｌ,；,：,］"
	LFARN4 :="ｚ,ｘ,ｃ,ｖ,ｂ,ｎ,ｍ,，,．,／,￥"

	LFANK1 :="！,”,＃,＄,％,＆,’,（,）,無,＝,～,｜"
	LFANK2 :="Ｑ,Ｗ,Ｅ,Ｒ,Ｔ,Ｙ,Ｕ,Ｉ,Ｏ,Ｐ,‘,｛"
	LFANK3 :="Ａ,Ｓ,Ｄ,Ｆ,Ｇ,Ｈ,Ｊ,Ｋ,Ｌ,＋,＊,｝"
	LFANK4 :="Ｚ,Ｘ,Ｃ,Ｖ,Ｂ,Ｎ,Ｍ,＜,＞,？,＿"

	LFALK1 :="！,”,＃,＄,％,＆,’,（,）,無,＝,～,｜"
	LFALK2 :="Ｑ,Ｗ,Ｅ,Ｒ,Ｔ,Ｙ,Ｕ,Ｉ,Ｏ,Ｐ,‘,｛"
	LFALK3 :="Ａ,Ｓ,Ｄ,Ｆ,Ｇ,Ｈ,Ｊ,Ｋ,Ｌ,＋,＊,｝"
	LFALK4 :="Ｚ,Ｘ,Ｃ,Ｖ,Ｂ,Ｎ,Ｍ,＜,＞,？,＿"

	LFARK1 :="！,”,＃,＄,％,＆,’,（,）,無,＝,～,｜"
	LFARK2 :="Ｑ,Ｗ,Ｅ,Ｒ,Ｔ,Ｙ,Ｕ,Ｉ,Ｏ,Ｐ,‘,｛"
	LFARK3 :="Ａ,Ｓ,Ｄ,Ｆ,Ｇ,Ｈ,Ｊ,Ｋ,Ｌ,＋,＊,｝"
	LFARK4 :="Ｚ,Ｘ,Ｃ,Ｖ,Ｂ,Ｎ,Ｍ,＜,＞,？,＿"

	LFRNN1 :="１,２,３,４,５,６,７,８,９,０,'－',＾,￥"
	LFRNN2 :="．,ｋａ,ｔａ,ｋｏ,ｓａ,ｒａ,ｔｉ,ｋｕ,ｔｕ,'，',，,「"
	LFRNN3 :="ｕ,ｓｉ,ｔｅ,ｋｅ,ｓｅ,ｈａ,ｔｏ,ｋｉ,ｉ,ｎｎ,：,」"
	LFRNN4 :="'．',ｈｉ,ｓｕ,ｆｕ,ｈｅ,ｍｅ,ｓｏ,ｎｅ,ｈｏ,／,￥"

	LFRLN1 :="？,'／',～,［,］,'［','］',（,）,｛,｝,＾,￥"
	LFRLN2 :="ｌａ,ｅ,ｒｉ,ｌｙａ,ｒｅ,ｐａ,ｄｉ,ｇｕ,ｄｕ,ｐｉ,＠,「"
	LFRLN3 :="ｗｏ,ａ,ｎａ,ｌｙｕ,ｍｏ,ｂａ,ｄｏ,ｇｉ,ｐｏ,；,：,」"
	LFRLN4 :="ｌｕ,－,ｒｏ,ｙａ,ｌｉ,ｐｕ,ｚｏ,ｐｅ,ｂｏ,'゛',＿"

	LFRRN1 :="？,'／',～,［,］,'［','］',（,）,｛,｝,＾,￥"
	LFRRN2 :="'゜',ｇａ,ｄａ,ｇｏ,ｚａ,ｙｏ,ｎｉ,ｒｕ,ｍａ,ｌｅ,＠,「"
	LFRRN3 :="ｖｕ,ｚｉ,ｄｅ,ｇｅ,ｚｅ,ｍｉ,ｏ,ｎｏ,ｌｙｏ,ｌｔｕ,：,」"
	LFRRN4 :="無,ｂｉ,ｚｕ,ｂｕ,ｂｅ,ｎｕ,ｙｕ,ｍｕ,ｗａ,ｌｏ,￥"

	LFRNK1 :="！,”,＃,＄,％,＆,’,（,）,無,＝,～,｜"
	LFRNK2 :="Ｑ,Ｗ,Ｅ,Ｒ,Ｔ,Ｙ,Ｕ,Ｉ,Ｏ,Ｐ,‘,｛"
	LFRNK3 :="Ａ,Ｓ,Ｄ,Ｆ,Ｇ,Ｈ,Ｊ,Ｋ,Ｌ,＋,＊,｝"
	LFRNK4 :="Ｚ,Ｘ,Ｃ,Ｖ,Ｂ,Ｎ,Ｍ,＜,＞,？,＿"

	LFRLK1 :="！,”,＃,＄,％,＆,’,（,）,無,＝,～,｜"
	LFRLK2 :="Ｑ,Ｗ,Ｅ,Ｒ,Ｔ,Ｙ,Ｕ,Ｉ,Ｏ,Ｐ,‘,｛"
	LFRLK3 :="Ａ,Ｓ,Ｄ,Ｆ,Ｇ,Ｈ,Ｊ,Ｋ,Ｌ,＋,＊,｝"
	LFRLK4 :="Ｚ,Ｘ,Ｃ,Ｖ,Ｂ,Ｎ,Ｍ,＜,＞,？,＿"

	LFRRK1 :="！,”,＃,＄,％,＆,’,（,）,無,＝,～,｜"
	LFRRK2 :="Ｑ,Ｗ,Ｅ,Ｒ,Ｔ,Ｙ,Ｕ,Ｉ,Ｏ,Ｐ,‘,｛"
	LFRRK3 :="Ａ,Ｓ,Ｄ,Ｆ,Ｇ,Ｈ,Ｊ,Ｋ,Ｌ,＋,＊,｝"
	LFRRK4 :="Ｚ,Ｘ,Ｃ,Ｖ,Ｂ,Ｎ,Ｍ,＜,＞,？,＿"
	return

;----------------------------------------------------------------------
;	制御文字表の初期化
;----------------------------------------------------------------------
InitControl:
	cout039 := "Space"			;Space
	cout01C := "Enter"			;Enter
	cout00E	:= "Backspace"		;BS
	cout00F := "Tab"			;Tab
	cout029 := "vkF3sc029"		;半角／全角
	cout03A	:= "CapsLock"		;CapsLock
	cout02A := "LShift"			;Left-Shift
	cout136 := "RShift"			;Right-Shift
	cout01D := "LCtrl"			;Left-Ctrl
	cout038 := "LAlt"			;Left-Alt
	cout138 := "RAlt"			;Right-Alt
	cout11D := "RCtrl"			;Right-Ctrl
	cout152 := "Insert"			;Insert
	cout153 := "Delete"			;Delete
	cout14B := "Left"			;←
	cout147 := "Home"			;home
	cout14F := "End"			;End
	cout148 := "Up"				;↑
	cout150 := "Down"			;↓
	cout149 := "PgUp"			;Page up
	cout151 := "PgDn"			;Page down
	cout140 := "Right"			;→
	cout001 := "Esc"			;Esc
	cout03B := "F1"				;F1
	cout03C := "F2"				;F2
	cout03D := "F3"				;F3
	cout03E := "F4"				;F4
	cout03F := "F5"				;F5
	cout040 := "F6"				;F6
	cout041 := "F7"				;F7
	cout042 := "F8"				;F8
	cout043 := "F9"				;F9
	cout044 := "F10"			;F10
	cout057 := "F11"			;F11
	cout058 := "F12"			;F12
	cout137 := "PrintScreen"	;Print Screen
	cout046 := "ScrollLock" 	;scroll rock
	cout045 := "Pause"			;Pause
	return

;----------------------------------------------------------------------
;	キー配列ファイル読み込み
;----------------------------------------------------------------------
ReadLayoutFile:
	SetWorkingDir, %A_ScriptDir%
	vAllTheLayout := ""
	if(Path_FileExists(vLayoutFile) = 0)
	{
		_error := "ファイルが存在しません " . %vLayoutFile%
		return
	}
	_mode := ""
	_mline := 0
	Loop
	{
		FileReadLine, _line, %vLayoutFile%, %A_Index%
		If(ErrorLevel <> 0)
		{
			Break
		}
		; コメント部分の除去
	    cpos := InStr(_line,";")
    	if(cpos <> 0)
    	{
			_line2 := SubStr(_line,1,%cpos%-1)
		} else {
	    	_line2 := _line
	    }
	    if(StrLen(_line2) > 0)
		{
			cpos0 := Instr(_line2,"[")
			cpos1 := Instr(_line2,"]")
			if(cpos0 = 1 && cpos1 > cpos0)
			{
				_LayoutName := SubStr(_line2, cpos0+1, cpos1-cpos0-1)
				_mode := Layout2Mode(_LayoutName)
				if(_mode <> "")
				{
					_mline := 0
					if(vAllTheLayout = "")
					{
						vAllTheLayout := _LayoutName . "||"
					} else {
						vAllTheLayout := vAllTheLayout . _LayoutName . "|"
					}
				}
			}
			if(_mode <> "") 
			{
				if _mline between 1 and 4
				{
					LF%_mode%%_mline% := _line2
				}
				_mline += 1
				if(_mline > 4)
				{
					GoSub, Mode2Key
					if(_error <> "")
					{
						return
					}
					_layoutName := ""
					_mode := ""
				}
			}
		}
	}
	Return

;----------------------------------------------------------------------
;	レイアウトをキー配列に変更
;----------------------------------------------------------------------
Layout2Key:
	_LayoutName := "英数シフト無し"
	_mode := Layout2Mode(_LayoutName)
	_error := ""
	GoSub, Mode2Key
	if(_error <> "")
		return

	_LayoutName := "英数左親指シフト"
	_mode := Layout2Mode(_LayoutName)
	_error := ""
	GoSub, Mode2Key
	if(_error <> "")
		return
	
	_LayoutName := "英数右親指シフト"
	_mode := Layout2Mode(_LayoutName)
	_error := ""
	GoSub, Mode2Key
	if(_error <> "")
		return

	_LayoutName := "英数小指シフト"
	_mode := Layout2Mode(_LayoutName)
	_error := ""
	GoSub, Mode2Key
	if(_error <> "")
		return

	_LayoutName := "英数小指左親指シフト"
	_mode := Layout2Mode(_LayoutName)
	_error := ""
	GoSub, Mode2Key
	if(_error <> "")
		return

	_LayoutName := "英数小指右親指シフト"
	_mode := Layout2Mode(_LayoutName)
	_error := ""
	GoSub, Mode2Key
	if(_error <> "")
		return

	_LayoutName := "ローマ字シフト無し"
	_mode := Layout2Mode(_LayoutName)
	_error := ""
	GoSub, Mode2Key
	if(_error <> "")
		return

	_LayoutName := "ローマ字左親指シフト"
	_mode := Layout2Mode(_LayoutName)
	_error := ""
	GoSub, Mode2Key
	if(_error <> "")
		return

	_LayoutName := "ローマ字右親指シフト"
	_mode := Layout2Mode(_LayoutName)
	_error := ""
	GoSub, Mode2Key
	if(_error <> "")
		return

	_LayoutName := "ローマ字小指シフト"
	_mode := Layout2Mode(_LayoutName)
	_error := ""
	GoSub, Mode2Key
	if(_error <> "")
		return

	_LayoutName := "ローマ字小指左親指シフト"
	_mode := Layout2Mode(_LayoutName)
	_error := ""
	GoSub, Mode2Key
	if(_error <> "")
		return

	_LayoutName := "ローマ字小指右親指シフト"
	_mode := Layout2Mode(_LayoutName)
	_error := ""
	GoSub, Mode2Key
	if(_error <> "")
		return
	return

;----------------------------------------------------------------------
;	各モードのレイアウトを処理
;----------------------------------------------------------------------
Mode2Key:
	_col := "1"
	StringSplit org,LF%_mode%%_col%,`,
	if(org0 <> 13)
	{
		_cnt := org0
		_error := _LayoutName . "の１段目にエラーがあります。要素数が" . _cnt . "です。"
		return
	}
	Gosub, TrimSpace
	Gosub, SetKeyTable
	if(_mode = "ANN")
		Gosub, SetAlphabet
	
	_col := "2"
	StringSplit org,LF%_mode%%_col%,`,
	if(org0 <> 12)
	{
		_cnt := org0
		_error := _LayoutName . "の２段目にエラーがあります。要素数が" . _cnt . "です。"
		return
	}
	Gosub, TrimSpace
	Gosub, SetKeyTable
	if(_mode = "ANN")
		Gosub, SetAlphabet
	
	_col := "3"
	StringSplit org,LF%_mode%%_col%,`,
	if(org0 <> 12)
	{
		_cnt := org0
		_error := _LayoutName . "の３段目にエラーがあります。要素数が" . _cnt . "です。"
		return
	}
	Gosub, TrimSpace
	Gosub, SetKeyTable
	if(_mode = "ANN")
		Gosub, SetAlphabet

	_col := "4"
	StringSplit org,LF%_mode%%_col%,`,
	if(org0 <> 11)
	{
		_cnt := org0
		_error := _LayoutName . "の４段目にエラーがあります。要素数が" . _cnt . "です。"
		return
	}
	Gosub, TrimSpace
	Gosub, SetKeyTable
	if(_mode = "ANN")
		Gosub, SetAlphabet
	return
;----------------------------------------------------------------------
;	行内のスペースを除去
;----------------------------------------------------------------------
TrimSpace:
	loop, %org0%
	{
		StringReplace, org%A_Index%, org%A_Index%, %A_Space%,, All
	}
	return

;----------------------------------------------------------------------
;	ローマ字・英数のときのキーダウン・キーアップの際に送信する内容を作成
;----------------------------------------------------------------------
SetKeyTable:
	kdn%_mode%0 := org0
	kup%_mode%0 := org0
	loop, %org0%
	{
		_qstr := QuotedStr(org%A_Index%)
		if(_error <> "")
		{
			break
		}
		if(_qstr <> "")
		{
			kdn%_mode%%_col%%A_Index% := _qstr
			kup%_mode%%_col%%A_Index% := 
			continue
		}
		ret := Kanji2KeySymbol(org%A_Index%,_symbol)
		if(ret = 1)
		{
			kdn%_mode%%_col%%A_Index% := MnDown(_symbol)
			kup%_mode%%_col%%A_Index% := MnUp(_symbol)
			continue
		}
		_vk := ConvVkey(org%A_Index%)
		if(_vk <> "")
		{
			kdn%_mode%%_col%%A_Index% := "{" . _vk . "}"
			kup%_mode%%_col%%A_Index% := ""
			continue
		}
		ret := ConvNarrow(org%A_Index%, _nc)
		if(ret = 0)
		{
			if(substr(_mode,1,1)="A" && StrLen(aStr) >= 2)
			{
				_error := "英数モードのキーに２文字以上が設定されています"
			} else {
				GenSendStr(_nc,_dn,_up)
				kdn%_mode%%_col%%A_Index% := _dn
				kup%_mode%%_col%%A_Index% := _up
			}
		} else {
			kdn%_mode%%_col%%A_Index% := _nc
			kup%_mode%%_col%%A_Index% := ""
		}
	}
	return

;----------------------------------------------------------------------
;	修飾キー＋文字キーの出力の際に送信する内容を作成
;----------------------------------------------------------------------
SetAlphabet:
	mdn%_mode%0 := org0
	mup%_mode%0 := org0
	loop, %org0%
	{
		mdn%_mode%%_col%%A_Index% := kdn%_mode%%_col%%A_Index%
		mup%_mode%%_col%%A_Index% := kup%_mode%%_col%%A_Index%
	}
	return
;----------------------------------------------------------------------
;	引用文字
;----------------------------------------------------------------------
QuotedStr(aStr) {
	global _error
	
	vOut := ""
	StringLeft, _cl, aStr, 1
	if(_cl = "'" || _cl = """") {
		if(strlen(aStr) < 3)
		{
			_error := "引用符が閉じられていません"
		}
		else
		{
			StringRight, _cr, aStr, 1
			if(_cr = _cl)
			{
				aQuo := SubStr(aStr, 2, StrLen(aStr) - 2)
				vOut := ParseEscSeq(aQuo)
			} else {
				_error := "引用符が閉じられていません"
			}
		}
	}
	return vOut
}

;----------------------------------------------------------------------
;	引用符内文字のエスケープ処理
;----------------------------------------------------------------------
ParseEscSeq(aQuo) {
	global _error

	StringLen _len, aQuo
	vOut := ""
	c1 := ""
	uc := 0
	loop,%_len%
	{
		StringMid, c, aQuo, A_Index, 1
		c1 := c1 . c
		if(substr(c1,1,1) = "\")	; backslash
		{
			_len := StrLen(c1)
			if(_len = 2) {
				if(c1 = "\n") {
					;vOut := vOut . Chr(10)
					vOut := vOut . "{ASC 10}"
					c1 := ""
				} else if(c1 = "\r")	;\r
				{
					;vOut := vOut . Chr(14)
					vOut := vOut . "{ASC 14}"
					c1 := ""
				} else if(c1 = "\t")		;\t
				{
					;vOut := vOut . Chr(9)
					vOut := vOut . "{ASC 9}"
					c1 := ""
				} else if(c1 = "\\")	; \\ backslash
				{
					vOut := vOut . "\"
					c1 := ""
				} else if(c1 = "\'")	; \' single quotation
				{
					vOut := vOut . "'"
					c1 := ""
				} else if(c1 = "\""")	; \" double quotation
				{
					vOut := vOut . """"
					c1 := ""
				} else if(c1 = "\u")
				{
					uc := 0
				} else {
					_error := "引用符付き文字列のエスケープ文字の書式が誤っています。"
					break
				}
			}
			else if _len in 3,4,5,6
			{
				if c not in 0,1,2,3,4,5,6,7,8,9,A,B,C,D,E,F,a,b,c,d,e,f
				{
					_error := "引用符付き文字列のエスケープ文字の書式が誤っています。"
					break
				}
			} 
			if(_len = 6)
			{
				; \u???? ならば、16進数に変換したのちユニコード変換
				c1 := "0x" . substr(c1,3,4)
				SetFormat, INTEGER, H 
				uc := c1 + 0
				vOut := vOut . Chr(uc)
				SetFormat, INTEGER, D
				c1 := ""
			}
		} else {
			vOut := vOut . c1
			c1 := ""
		}
	}
	if(c1 <> "") {
		_error := "引用符付き文字列の書式が誤っています。"
	}
	return vOut
}
;----------------------------------------------------------------------
;	漢字シンボルをAutoHotKeyのシンボルに変更
;----------------------------------------------------------------------
Kanji2KeySymbol(_ch,BYREF vSymbol)
{
	ret := 0
	if(_ch = "")
		return 0
	if(StrLen(_ch) <> 1)
		return 0

	if(_ch = "後")
		vSymbol := "Backspace"
	else if(_ch = "逃")
		vSymbol := "Esc"
	else if(_ch = "入")
		vSymbol := "Enter"
	else if(_ch = "空")
		vSymbol := "Space"
	else if(_ch = "消")
		vSymbol := "Delete"
	else if(_ch = "挿")
		vSymbol := "Insert"
	else if(_ch = "上")
		vSymbol := "Up"
	else if(_ch = "左")
		vSymbol := "Left"
	else if(_ch = "右")
		vSymbol := "Right"
	else if(_ch = "下")
		vSymbol := "Down"
	else if(_ch = "家")
		vSymbol := "Home"
	else if(_ch = "終")
		vSymbol := "End"
	else if(_ch = "前")
		vSymbol := "PgUp"
	else if(_ch = "次")
		vSymbol := "PgDn"
	if(StrLen(vSymbol)>0) {
		ret := 1
	}
	if(_ch = "無") {
		vSymbol := ""
		ret := 1
	}
	return ret
}
;----------------------------------------------------------------------
;	bnz/yabファイルの仮想キーコードを、AutoHotKeyでsendできる形式に変換
;	入力：v??
;	出力：vk??
;----------------------------------------------------------------------
ConvVkey(aStr) {
	StringLen _len, aStr
	if(_len <> 3)
		return

	c0 := SubStr(aStr,1,1)
	if c0 in V,v
	{
		c1 := SubStr(aStr,2,1)
		if c1 in 0,1,2,3,4,5,6,7,8,9,A,B,C,D,E,F,a,b,c,d,e,f
		{
			c2 := SubStr(aStr,3,1)
			if c2 in 0,1,2,3,4,5,6,7,8,9,A,B,C,D,E,F,a,b,c,d,e,f
			{
				vOut := "vk" . c1 . c2
				return vOut
			}
		}
	}
	return
}
;----------------------------------------------------------------------
; 全角文字列が半角に変換可能ならば変換
; 引数　：aStr：変換前の文字列
; 戻り値：変換後の文字列
;----------------------------------------------------------------------
ConvNarrow(aStr,BYREF nStr) {
	nStr := ""
	rVal := 0
	StringLen _len,aStr
	loop,%_len%
	{
		StringMid, c, aStr, A_Index, 1
		code := Asc(c)
		if code between 65280 and 65376	; 全角
		{
			nStr := nStr . chr((code & 0xFF) + 0x20)
		}
		else if(code = 65509)		; backslash
		{
			nStr := nStr . "\"
		}
		else if code in 8220,8221	; 二重引用符
		{
			nStr := nStr . """"
		}
		else if code in 8217		; 一重引用符
		{
			nStr := nStr . "'"
		}
		else if code in 8216		; 一重引用符
		{
			nStr := nStr . "``"
		}
		else if code in 12288		;全角スペース
		{
			nStr := nStr . " "
		}
		else
		{
			; 変換に失敗したら、その個数をカウント
			nStr := nStr . c
			rVal := rVal + 1
		}
	}
	return rVal
}

;----------------------------------------------------------------------
; 通常のキーdown時にSendする引数の文字列を設定する
; 引数　：aStr：対応するキー入力
; 戻り値：Sendの引数
;----------------------------------------------------------------------
GenSendStr(aStr,BYREF _dn,BYREF _up)
{
	_len := strlen(aStr)
	if(_len = 0)
	{
		return ""
	}
	_dn := "{Blind}"
	_up := ""
	loop,%_len%
	{
		StringMid, _ch, aStr, A_Index, 1
		_c2 := Char2KeySymbol(_ch)
		if(_c2 <> "")
		{
			if(Asc(_c2) <= 255)
			{
				if(A_Index = _len)
				{
					_dn := _dn . "{" . _c2 . " Down}"
					_up := "{Blind}{" . _c2 . " up}"
				} else {
					_dn := _dn . "{" . _c2 . " Down}{" . _c2 . " up}"
				}
			} else {
				_dn := _dn . "{" . _ch . "}"
			}
		}
	}
	if(_dn = "{Blind}")
		_dn := ""
	return _dn
}

;----------------------------------------------------------------------
;	半角文字のうち制御コードをAutoHotKeyのシンボルに変換
;----------------------------------------------------------------------
Char2KeySymbol(vCh) {
	if(vCh = "")
		return
		
	_code := Asc(vCh)
	if(_code = 0x7F)
		return "Del"
	if(_code > 32)
		return vCh
	if(_code= 32)
		return "Space"
	if(_code= 9)
		return "Tab"
	if(_code= 10 || _code=14)
		return "Enter"
	if(_code=0x1B)
		return "Esc"
	if(_code=0x08)
		return "Backspace"
	return
}

;----------------------------------------------------------------------
; レイアウト名からモード名を取得
; 引数　：_LayoutName：レイアウト名
; 戻り値：モード名
;----------------------------------------------------------------------
Layout2Mode(_LayoutName) 
{
	if(_LayoutName = "英数シフト無し")
		return "ANN"
	else if(_LayoutName = "英数左親指シフト")
		return "ALN"
	else if(_LayoutName = "英数右親指シフト")
		return "ARN"
	else if(_LayoutName = "英数小指シフト")
		return "ANK"
	else if(_LayoutName = "英数小指左親指シフト")
		return "ALK"
	else if(_LayoutName = "英数小指右親指シフト")
		return "ARK"
	else if(_LayoutName = "ローマ字シフト無し")
		return "RNN"
	else if(_LayoutName = "ローマ字左親指シフト")
		return "RLN"
	else if(_LayoutName = "ローマ字右親指シフト")
		return "RRN"
	else if(_LayoutName = "ローマ字小指シフト")
		return "RNK"
	else if(_LayoutName = "ローマ字小指左親指シフト")
		return "RRK"
	else if(_LayoutName = "ローマ字小指右親指シフト")
		return "RLK"
	else
		return ""
	return ""
}
