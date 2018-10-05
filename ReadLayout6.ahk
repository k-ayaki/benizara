;-----------------------------------------------------------------------
;	名称：ReadLayout6.ahk
;	機能：紅皿のキーレイアウトファイルの読み込み
;	ver.0.1.0 .... 2018/10/04
;-----------------------------------------------------------------------
ReadLayout:
	Gosub, InitControl

	Gosub, InitLayout
	Gosub, Layout2Key
	if vLayoutFile =
		return

	_error =
	Gosub, ReadLayoutFile
	if _error <>
	{
		Msgbox,%_error%
		Gosub, InitLayout
		Gosub, Layout2Key
	}
	return

#include Path.ahk

InitLayout:
	LFANN1 =１,２,３,４,５,６,７,８,９,０,－,＾,￥
	LFANN2 =ｑ,ｗ,ｅ,ｒ,ｔ,ｙ,ｕ,ｉ,ｏ,ｐ,＠,［
	LFANN3 =ａ,ｓ,ｄ,ｆ,ｇ,ｈ,ｊ,ｋ,ｌ,；,：,］
	LFANN4 =ｚ,ｘ,ｃ,ｖ,ｂ,ｎ,ｍ,，,．,／,￥

	LFALN1 =１,２,３,４,５,６,７,８,９,０,－,＾,￥
	LFALN2 =ｑ,ｗ,ｅ,ｒ,ｔ,ｙ,ｕ,ｉ,ｏ,ｐ,＠,［
	LFALN3 =ａ,ｓ,ｄ,ｆ,ｇ,ｈ,ｊ,ｋ,ｌ,；,：,］
	LFALN4 =ｚ,ｘ,ｃ,ｖ,ｂ,ｎ,ｍ,，,．,／,￥

	LFARN1 =１,２,３,４,５,６,７,８,９,０,－,＾,￥
	LFARN2 =ｑ,ｗ,ｅ,ｒ,ｔ,ｙ,ｕ,ｉ,ｏ,ｐ,＠,［
	LFARN3 =ａ,ｓ,ｄ,ｆ,ｇ,ｈ,ｊ,ｋ,ｌ,；,：,］
	LFARN4 =ｚ,ｘ,ｃ,ｖ,ｂ,ｎ,ｍ,，,．,／,￥
	
	LFANK1 =！,”,＃,＄,％,＆,’,（,）,無,＝,～,｜
	LFANK2 =Ｑ,Ｗ,Ｅ,Ｒ,Ｔ,Ｙ,Ｕ,Ｉ,Ｏ,Ｐ,‘,｛
	LFANK3 =Ａ,Ｓ,Ｄ,Ｆ,Ｇ,Ｈ,Ｊ,Ｋ,Ｌ,＋,＊,｝
	LFANK4 =Ｚ,Ｘ,Ｃ,Ｖ,Ｂ,Ｎ,Ｍ,＜,＞,？,＿

	LFALK1 =！,”,＃,＄,％,＆,’,（,）,無,＝,～,｜
	LFALK2 =Ｑ,Ｗ,Ｅ,Ｒ,Ｔ,Ｙ,Ｕ,Ｉ,Ｏ,Ｐ,‘,｛
	LFALK3 =Ａ,Ｓ,Ｄ,Ｆ,Ｇ,Ｈ,Ｊ,Ｋ,Ｌ,＋,＊,｝
	LFALK4 =Ｚ,Ｘ,Ｃ,Ｖ,Ｂ,Ｎ,Ｍ,＜,＞,？,＿

	LFARK1 =！,”,＃,＄,％,＆,’,（,）,無,＝,～,｜
	LFARK2 =Ｑ,Ｗ,Ｅ,Ｒ,Ｔ,Ｙ,Ｕ,Ｉ,Ｏ,Ｐ,‘,｛
	LFARK3 =Ａ,Ｓ,Ｄ,Ｆ,Ｇ,Ｈ,Ｊ,Ｋ,Ｌ,＋,＊,｝
	LFARK4 =Ｚ,Ｘ,Ｃ,Ｖ,Ｂ,Ｎ,Ｍ,＜,＞,？,＿

	LFRNN1 =１,２,３,４,５,６,７,８,９,０,'－',＾,￥
	LFRNN2 =．,ｋａ,ｔａ,ｋｏ,ｓａ,ｒａ,ｔｉ,ｋｕ,ｔｕ,'，',，,「
	LFRNN3 =ｕ,ｓｉ,ｔｅ,ｋｅ,ｓｅ,ｈａ,ｔｏ,ｋｉ,ｉ,ｎｎ,：,」
	LFRNN4 ='．',ｈｉ,ｓｕ,ｆｕ,ｈｅ,ｍｅ,ｓｏ,ｎｅ,ｈｏ,／,￥

	LFRLN1 =？,'／',～,［,］,'［','］',（,）,｛,｝,＾,￥
	LFRLN2 =ｌａ,ｅ,ｒｉ,ｌｙａ,ｒｅ,ｐａ,ｄｉ,ｇｕ,ｄｕ,ｐｉ,＠,「
	LFRLN3 =ｗｏ,ａ,ｎａ,ｌｙｕ,ｍｏ,ｂａ,ｄｏ,ｇｉ,ｐｏ,；,：,」
	LFRLN4 =ｌｕ,－,ｒｏ,ｙａ,ｌｉ,ｐｕ,ｚｏ,ｐｅ,ｂｏ,'゛',＿

	LFRRN1 =？,'／',～,［,］,'［','］',（,）,｛,｝,＾,￥
	LFRRN2 ='゜',ｇａ,ｄａ,ｇｏ,ｚａ,ｙｏ,ｎｉ,ｒｕ,ｍａ,ｌｅ,＠,「
	LFRRN3 =ｖｕ,ｚｉ,ｄｅ,ｇｅ,ｚｅ,ｍｉ,ｏ,ｎｏ,ｌｙｏ,ｌｔｕ,：,」
	LFRRN4 =無,ｂｉ,ｚｕ,ｂｕ,ｂｅ,ｎｕ,ｙｕ,ｍｕ,ｗａ,ｌｏ,￥

	LFRNK1 =！,”,＃,＄,％,＆,’,（,）,無,＝,～,｜
	LFRNK2 =Ｑ,Ｗ,Ｅ,Ｒ,Ｔ,Ｙ,Ｕ,Ｉ,Ｏ,Ｐ,‘,｛
	LFRNK3 =Ａ,Ｓ,Ｄ,Ｆ,Ｇ,Ｈ,Ｊ,Ｋ,Ｌ,＋,＊,｝
	LFRNK4 =Ｚ,Ｘ,Ｃ,Ｖ,Ｂ,Ｎ,Ｍ,＜,＞,？,＿

	LFRLK1 =！,”,＃,＄,％,＆,’,（,）,無,＝,～,｜
	LFRLK2 =Ｑ,Ｗ,Ｅ,Ｒ,Ｔ,Ｙ,Ｕ,Ｉ,Ｏ,Ｐ,‘,｛
	LFRLK3 =Ａ,Ｓ,Ｄ,Ｆ,Ｇ,Ｈ,Ｊ,Ｋ,Ｌ,＋,＊,｝
	LFRLK4 =Ｚ,Ｘ,Ｃ,Ｖ,Ｂ,Ｎ,Ｍ,＜,＞,？,＿

	LFRRK1 =！,”,＃,＄,％,＆,’,（,）,無,＝,～,｜
	LFRRK2 =Ｑ,Ｗ,Ｅ,Ｒ,Ｔ,Ｙ,Ｕ,Ｉ,Ｏ,Ｐ,‘,｛
	LFRRK3 =Ａ,Ｓ,Ｄ,Ｆ,Ｇ,Ｈ,Ｊ,Ｋ,Ｌ,＋,＊,｝
	LFRRK4 =Ｚ,Ｘ,Ｃ,Ｖ,Ｂ,Ｎ,Ｍ,＜,＞,？,＿
	return

;----------------------------------------------------------------------
;	制御文字表の初期化
;----------------------------------------------------------------------
InitControl:
	cout039 = Space			;Space
	cout01C = Enter			;Enter
	cout00E	= Backspace		;BS
	cout00F = Tab			;Tab
	cout029 = vkF3sc029		;半角／全角
	cout03A	= CapsLock		;CapsLock
	cout02A = LShift		;Left-Shift
	cout136 = RShift		;Right-Shift
	cout01D = LCtrl			;Left-Ctrl
	cout038 = LAlt			;Left-Alt
	cout138 = RAlt			;Right-Alt
	cout11D = RCtrl			;Right-Ctrl
	cout152 = Insert		;Insert
	cout153 = Delete		;Delete
	cout14B = Left			;←
	cout147 = Home			;home
	cout14F = End			;End
	cout148 = Up			;↑
	cout150 = Down			;↓
	cout149 = PgUp			;Page up
	cout151 = PgDn			;Page down
	cout140 = Right			;→
	cout001 = Esc			;Esc
	cout03B = F1			;F1
	cout03C = F2			;F2
	cout03D = F3			;F3
	cout03E = F4			;F4
	cout03F = F5			;F5
	cout040 = F6			;F6
	cout041 = F7			;F7
	cout042 = F8			;F8
	cout043 = F9			;F9
	cout044 = F10			;F10
	cout057 = F11			;F11
	cout058 = F12			;F12
	cout137 = PrintScreen	;Print Screen
	cout046 = ScrollLock 	;scroll rock
	cout045 = Pause			;Pause
	return

;----------------------------------------------------------------------
;	キー配列ファイル読み込み
;----------------------------------------------------------------------
ReadLayoutFile:
	SetWorkingDir, %A_ScriptDir%
	vAllTheLayout =
	if Path_FileExists(vLayoutFile) = 0
	{
		_error = ファイルが存在しません %vLayoutFile%
		return
	}
	_mode = 
	_mline = 0
	Loop
	{
		FileReadLine, _line, %vLayoutFile%, %A_Index%
		If ErrorLevel <> 0
		{
			Break
		}
		; コメント部分の除去
	    cpos := InStr(_line,";")
    	if cpos <> 0 
			_line2 := SubStr(_line,1,%cpos%-1)
		else
	    	_line2 := _line
	    
	    if StrLen(_line2) > 0
		{
			cpos0 := Instr(_line2,"[")
			cpos1 := Instr(_line2,"]")
			if cpos0 = 1
			{
				if cpos1 > %cpos0%
				{
					_LayoutName := SubStr(_line2, cpos0+1, cpos1-cpos0-1)
					_tmpMode := Layout2Mode(_LayoutName)
					if _tmpMode <>
					{
						_mode := _tmpMode
						_mline = 0
						if vAllTheLayout =
							vAllTheLayout := _LayoutName . "||"
						else
							vAllTheLayout := vAllTheLayout . _LayoutName . "|"
					}
				}
			}
			if _mode <>
			{
				if _mline between 1 and 4
				{
					LF%_mode%%_mline% = %_line2%
				}
				_mline += 1
				if(_mline > 4)
				{
					GoSub, Mode2Key
					if _error <>
						return
					_layoutName =
					_mode =
				}
			}
		}
	}
	Return

;----------------------------------------------------------------------
;	レイアウトをキー配列に変更
;----------------------------------------------------------------------
Layout2Key:
	_LayoutName =英数シフト無し
	_mode := Layout2Mode(_LayoutName)
	_error =
	GoSub, Mode2Key
	if _error <>
		return

	_LayoutName =英数左親指シフト
	_mode := Layout2Mode(_LayoutName)
	_error =
	GoSub, Mode2Key
	if _error <>
		return
	
	_LayoutName =英数右親指シフト
	_mode := Layout2Mode(_LayoutName)
	_error =
	GoSub, Mode2Key
	if _error <>
		return

	_LayoutName =英数小指シフト
	_mode := Layout2Mode(_LayoutName)
	GoSub, Mode2Key
	if _error <>
		return

	_LayoutName =英数小指左親指シフト
	_mode := Layout2Mode(_LayoutName)
	GoSub, Mode2Key
	if _error <>
		return

	_LayoutName =英数小指右親指シフト
	_mode := Layout2Mode(_LayoutName)
	GoSub, Mode2Key
	if _error <>
		return

	_LayoutName =ローマ字シフト無し
	_mode := Layout2Mode(_LayoutName)
	GoSub, Mode2Key
	if _error <>
		return

	_LayoutName =ローマ字左親指シフト
	_mode := Layout2Mode(_LayoutName)
	GoSub, Mode2Key
	if _error <>
		return

	_LayoutName =ローマ字右親指シフト
	_mode := Layout2Mode(_LayoutName)
	GoSub, Mode2Key
	if _error <>
		return

	_LayoutName =ローマ字小指シフト
	_mode := Layout2Mode(_LayoutName)
	GoSub, Mode2Key
	if _error <>
		return

	_LayoutName =ローマ字小指左親指シフト
	_mode := Layout2Mode(_LayoutName)
	GoSub, Mode2Key
	if _error <>
		return

	_LayoutName =ローマ字小指右親指シフト
	_mode := Layout2Mode(_LayoutName)
	GoSub, Mode2Key
	if _error <>
		return
	return

;----------------------------------------------------------------------
;	各モードきレイアウトを処理
;----------------------------------------------------------------------
Mode2Key:
	StringSplit org%_mode%1,LF%_mode%1,`,
	_org  = org%_mode%1		; キー配列の元テーブル
	_akey = key%_mode%1		; キー配列を半角化したもの
	_bkey = quo%_mode%1		; 引用符
	if org%_mode%10 <> 13
	{
		_cnt := org%_mode%10
		_error = %_LayoutName%の１段目にエラーがあります。要素数が%_cnt%です。
		return
	}
	Gosub, TrimSpace
	Gosub, Wide2Narrow
	Gosub, SetOutS
	if _mode = ANN
		Gosub, SetOutM
	
	StringSplit org%_mode%2,LF%_mode%2,`,
	_org  = org%_mode%2
	_akey = key%_mode%2
	_bkey = quo%_mode%2
	if org%_mode%20 <> 12
	{
		_cnt := org%_mode%20
		_error = %_LayoutName%の２段目にエラーがあります。要素数が%_cnt%です。
		return
	}
	Gosub, TrimSpace
	Gosub, Wide2Narrow
	Gosub, SetOutS
	if _mode = ANN
		Gosub, SetOutM
	
	StringSplit org%_mode%3,LF%_mode%3,`,
	_org  = org%_mode%3
	_akey = key%_mode%3
	_bkey = quo%_mode%3
	if org%_mode%30 <> 12
	{
		_cnt := org%_mode%30
		_error = %_LayoutName%の３段目にエラーがあります。要素数が%_cnt%です。
		return
	}
	Gosub, TrimSpace
	Gosub, Wide2Narrow
	Gosub, SetOutS
	if _mode = ANN
		Gosub, SetOutM

	StringSplit org%_mode%4,LF%_mode%4,`,
	_org  = org%_mode%4
	_akey = key%_mode%4
	_bkey = quo%_mode%4
	if org%_mode%40 <> 11
	{
		_cnt := org%_mode%40
		_error = %_LayoutName%の４段目にエラーがあります。要素数が%_cnt%です。
		return
	}
	Gosub, TrimSpace
	Gosub, Wide2Narrow
	Gosub, SetOutS
	if _mode = ANN
		Gosub, SetOutM
	return

TrimSpace:
	_cnt := %_org%0
	loop, %_cnt%
	{
		StringReplace, %_org%%A_Index%, %_org%%A_Index%, %A_Space%,, All
	}
	return
	
Wide2Narrow:
	_cnt := %_org%0
	%_akey%0 := _cnt
	%_bkey%0 := _cnt
	loop, %_cnt%
	{
		_ch := ConvNarrow(%_org%%A_Index%)
		%_akey%%A_Index% := _ch
		_ch := QuotedStr(%_org%%A_Index%)
		%_bkey%%A_Index% := _ch
	}
	return

SetOutS:
	_cnt := %_akey%0
	kdn%_mode%0 := _cnt
	kup%_mode%0 := _cnt
	_col := SubStr(_akey,7,1)
	loop, %_cnt%
	{
		if %_bkey%%A_Index% =
		{
			_vk := ConvVkey(%_org%%A_Index%)
			if _vk <>
			{
				kdn%_mode%%_col%%A_Index% = {Blind}{%_vk% down}
				kup%_mode%%_col%%A_Index% = {Blind}{%_vk% up}
			}
			else
			{
				kdn%_mode%%_col%%A_Index% := TSDownStr(%_akey%%A_Index%)
				kup%_mode%%_col%%A_Index% := TSUpStr(%_akey%%A_Index%)
			}
		} else {
			kdn%_mode%%_col%%A_Index% := TSDownStr(%_bkey%%A_Index%)
			kup%_mode%%_col%%A_Index% := TSUpStr(%_bkey%%A_Index%)
		}
	}
	return

SetOutM:
	_cnt := %_akey%0
	mdn%_mode%0 := _cnt
	mup%_mode%0 := _cnt
	_col := SubStr(_akey,7,1)
	loop, %_cnt%
	{
		if %_bkey%%A_Index% =
		{
			mdn%_mode%%_col%%A_Index% := ModifierDownStr(%_akey%%A_Index%)
			mup%_mode%%_col%%A_Index% := ModifierUpStr(%_akey%%A_Index%)
		} else {
			mdn%_mode%%_col%%A_Index% := ModifierDownStr(%_bkey%%A_Index%)
			mup%_mode%%_col%%A_Index% := ModifierUpStr(%_bkey%%A_Index%)
		}
	}
	return
;----------------------------------------------------------------------
;	bnz/yabファイルの仮想キーコードを、AutoHotKeyでsendできる形式に変換
;----------------------------------------------------------------------
ConvVkey(aStr) {
	StringLen _len, aStr
	if _len <> 3
		return

	c0 := SubStr(aStr,1,1)
	if c0 in V,v
	{
		c1 := SubStr(aStr,2,1)
		if c1 in 0,1,2,3,4,5,6,7,8,9,A,B,C,D,E,F,a,b,c,d,e,f
		{
			c2 := SubStr(aStr,3,1)
			if c1 in 0,1,2,3,4,5,6,7,8,9,A,B,C,D,E,F,a,b,c,d,e,f
			{
				vOut = vk%c1%%c2%
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
ConvNarrow(aStr) {
	sDirect =
	vOut =
	StringLen _len,aStr
	loop,%_len%
	{
		StringMid, c, aStr, A_Index, 1
		code := Asc(c)
		if code between 65280 and 65376
		{
			code &= 255
			code += 32
			c2 := chr(code)
			vOut := vOut . c2
		}
		else if(code = 65509)		; backslash
		{
			c2 = \
			vOut := vOut . c2
		}
		else if code in 8220,8221	; 二重引用符
		{
			c2 = "
			vOut := vOut . c2
		}
		else if code in 8217		; 一重引用符
		{
			c2 ='
			vOut := vOut . c2
		}
		else if code in 8216		; 一重引用符
		{
			c2 =``
			vOut := vOut . c2
		}
		else if code in 12288		;全角スペース
		{
			vOut := vOut . Chr(32)
		}
		else
		{
			vOut := vOut . c
		}
	}
	return vOut
}


;----------------------------------------------------------------------
;	引用文字
;----------------------------------------------------------------------
QuotedStr(aStr) {
	vOut =
	StringLeft, _cl, aStr, 1
	StringRight, _cr, aStr, 1
	StringLen _len, aStr
	if _len >= 3
	{
		if Asc(_cl) in 34,39	; 二重引用符／一重引用符
		{
			if _cr = %_cl%
			{
				vOut := SubStr(aStr, 2, _len - 2)
				vOut := ParseEscSeq(vOut)
			}
		}
	}
	return vOut
}


;----------------------------------------------------------------------
;	引用符内文字のエスケープ処理
;----------------------------------------------------------------------
ParseEscSeq(aQuo) {
	StringLen _len, aQuo
	vOut =
	c1 =
	uc := 0
	loop,%_len%
	{
		StringMid, c, aQuo, A_Index, 1
		c1 := c1 . c
		_code1 := Asc(c1)
		_code := Asc(c)
		if _code1 = 92	; backslash
		{
			_len := StrLen(c1)
			if _len = 2
			{
				if c = n				;
				{
					vOut := vOut . Chr(10)
					c1 =
				} else if c = r			;
				{
					vOut := vOut . Chr(14)
					c1 =
				} else if c = t			;
				{
					vOut := vOut . Chr(9)
					c1 =
				} else if _code = 92	; backslash
				{
					vOut := vOut . chr(92)
					c1 =
				} else if _code = 39	; single quotation
				{
					vOut := vOut . chr(39)
					c1 =
				} else if _code = 34	; double quotation
				{
					vOut := vOut . chr(34)
					c1 =
				} else if c <> u
				{
					vOut := vOut . c
					c1 =
					uc := 0
				} else {
					uc := 0
				}
			} else if _len in 3,4,5,6
			{
				if c not in 0,1,2,3,4,5,6,7,8,9,A,B,C,D,E,F
				{
					vOut := vOut . SubStr(c1,2)
					c1 =
					uc := 0
				} else if _code in 48,49,50,51,52,53,54,55,56,57
				{
					uc := uc*16 + _code - Asc("0")
				} else  if _code in 65,66,67,68,69,70
				{
					uc := uc*16 + _code - Asc("A") + 10
				} else {
					uc := uc*16 + _code - Asc("a") + 10
				}
			} 

			if _len = 6
			{
				vOut := vOut . Chr(uc)
				c1 =
				uc := 0
			}
		} else {
			vOut := vOut . c1
			c1 =
		}
	}
	return vOut
}

;----------------------------------------------------------------------
; 通常のキーdown時にSendする引数の文字列を設定する
; 引数　：aStr：対応するキー入力
; 戻り値：Sendの引数
;----------------------------------------------------------------------
TSDownStr(aStr) {
	if aStr =
		return
	vOut = 
	StringLen _len,aStr
	loop,%_len%
	{
		if vOut =
			vOut = {Blind}
		StringMid, _ch, aStr, A_Index, 1
		if Asc(_ch) > 255
		{
			_c2 := Kanji2KeySymbol(_ch)
		} else {
			_c2 := Char2KeySymbol(_ch)
		}
		if _c2 <>
		{
			if Asc(_c2) <= 255
			{
				if A_Index = %_len%
				{
					vOut = %vOut%{%_c2% Down}
				} else {
					vOut = %vOut%{%_c2% Down}{%_c2% up}
				}
			} else {
				vOut = %vOut%{%_ch%}
			}
		}
	}
	if vOut = {Blind}
		vOut =
	return vOut
}
;----------------------------------------------------------------------
; 通常のキーUp時にSendする引数の文字列を設定する
; 引数　：aStr：対応するキー入力
; 戻り値：Sendの引数
;----------------------------------------------------------------------
TSUpStr(aStr) {
	if aStr =
		return
	
	vOut = 
	StringRight, _ch, aStr, 1
	if Asc(_ch) > 255
	{
		_c2 := Kanji2KeySymbol(_ch)
	} else {
		_c2 := Char2KeySymbol(_ch)
	}
	if Asc(_c2) <= 255
	{
		vOut = {Blind}{%_c2% up}
	}
	return vOut
}

;----------------------------------------------------------------------
;	半角文字のうち制御コードをAutoHotKeyのシンボルに変換
;----------------------------------------------------------------------
Char2KeySymbol(vCh) {
	if vCh = 
		return
	_code := Asc(vCh)
	if _code > 32
		return vCh
	if _code = 32
		return "Space"
	if _code = 9
		return "Tab"
	if _code in 10,14
		return "Enter"
	return
}
;----------------------------------------------------------------------
;	漢字シンボルをAutoHotKeyのシンボルに変更
;----------------------------------------------------------------------
Kanji2KeySymbol(vCh)
{
	if vCh =
		return
	_ch := SubStr(vCh,1,1)
	if _ch = 無
		vSymbol = 
	else if _ch = 後
		vSymbol = Backspace
	else if _ch = 逃
		vSymbol = Esc
	else if _ch = 入
		vSymbol = Enter
	else if _ch = 空
		vSymbol = Space
	else if _ch = 消
		vSymbol = Delete
	else if _ch = 挿
		vSymbol = Insert
	else if _ch = 上
		vSymbol = Up
	else if _ch = 左
		vSymbol = Esc
	else if _ch = 右
		vSymbol = Right
	else if _ch = 下
		vSymbol = Down
	else if _ch = 家
		vSymbol = Home
	else if _ch = 終
		vSymbol = End
	else if _ch = 前
		vSymbol = PgUp
	else if _ch = 次
		vSymbol = PgDn
	else
		vSymbol := _ch
	return vSymbol
}

;----------------------------------------------------------------------
; 通常のキーダウン時にSendする引数の文字列を設定する
; 引数　：aStr：対応するキー入力
; 戻り値：Sendの引数
;----------------------------------------------------------------------
ModifierDownStr(aStr) {
	vOut = 
	if StrLen(aStr) = 1
	{
		_symbol := Kanji2KeySymbol(aStr)
		if _symbol <>
			vOut = {Blind}{%_symbol% down}
	}
	return vOut
}
;----------------------------------------------------------------------
; 通常のキーダウン時にSendする引数の文字列を設定する
; 引数　：aStr：対応するキー入力
; 戻り値：Sendの引数
;----------------------------------------------------------------------
ModifierUpStr(aStr) {
	vOut = 
	if StrLen(aStr) = 1
	{
		_symbol := Kanji2KeySymbol(aStr)
		if _symbol <>
			vOut = {Blind}{%_symbol% up}
	}
	return vOut
}
;----------------------------------------------------------------------
; レイアウト名からモード名を取得
; 引数　：_LayoutName：レイアウト名
; 戻り値：モード名
;----------------------------------------------------------------------
Layout2Mode(_LayoutName) 
{
	if _LayoutName = 英数シフト無し
		return "ANN"
	else if _LayoutName = 英数左親指シフト
		return "ALN"
	else if _LayoutName = 英数右親指シフト
		return "ARN"
	else if _LayoutName = 英数小指シフト
		return "ANK"
	else if _LayoutName = 英数小指左親指シフト
		return "ALK"
	else if _LayoutName = 英数小指右親指シフト
		return "ARK"
	else if _LayoutName = ローマ字シフト無し
		return "RNN"
	else if _LayoutName = ローマ字左親指シフト
		return "RLN"
	else if _LayoutName = ローマ字右親指シフト
		return "RRN"
	else if _LayoutName = ローマ字小指シフト
		return "RNK"
	else if _LayoutName = ローマ字小指左親指シフト
		return "RRK"
	else if _LayoutName = ローマ字小指右親指シフト
		return "RLK"
	else
		return ""
	return ""
}
