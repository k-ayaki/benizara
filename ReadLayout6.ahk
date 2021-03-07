;-----------------------------------------------------------------------
;	名称：ReadLayout6.ahk
;	機能：紅皿のキーレイアウトファイルの読み込み
;	ver.0.1.4.0 .... 2019/8/18
;-----------------------------------------------------------------------
ReadLayout:
	kup := Object()
	kdn := Object()
	mup := Object()
	mdn := Object()
	romahash := MakeRomaHash()
	SymbolHash := MakeSymbolHash()
	

	Gosub, InitLayout2
	vLayoutFile := g_LayoutFile
	if(vLayoutFile = "")
		return

	_error := ""
	Gosub, ReadLayoutFile
	if(_error <> "")
	{
		Msgbox,%_error%

		LFA := 0
		LFN := 0
	}
	Gosub, SetLayoutProperty
	return

#include Path.ahk

; 各テーブルを読み込んだか否かの判定変数の初期化とデフォルトテーブル
;
InitLayout2:
	LFANN := 0
	LFALN := 0
	LFARN := 0

	LFANK := 0
	LFALK := 0
	LFARK := 0

	LFRNN := 0
	LFRLN := 0
	LFRRN := 0

	LFRNK := 0
	LFRLK := 0
	LFRRK := 0
	loop,4
	{
		LFANN%A_Index% := ""
		LFALN%A_Index% := ""
		LFARN%A_Index% := ""

		LFANK%A_Index% := ""
		LFALK%A_Index% := ""
		LFARK%A_Index% := ""

		LFRNN%A_Index% := ""
		LFRLN%A_Index% := ""
		LFRRN%A_Index% := ""

		LFRNK%A_Index% := ""
		LFRLK%A_Index% := ""
		LFRRK%A_Index% := ""
	}
	; デフォルトテーブル
	LFADN1 := "１,２,３,４,５,６,７,８,９,０,ー,＾,￥"
	LFADN2 := "ｑ,ｗ,ｅ,ｒ,ｔ,ｙ,ｕ,ｉ,ｏ,ｐ,＠,［"
	LFADN3 := "ａ,ｓ,ｄ,ｆ,ｇ,ｈ,ｋ,ｌ,ｌ,；,：,］"
	LFADN4 := "ｚ,ｘ,ｃ,ｖ,ｂ,ｎ,ｍ,，,．,／,￥"

	LFADK1 := "！,”,＃,＄,％,＆,’, （,）,無,＝,～,｜"
	LFADK2 := "Ｑ,Ｗ,Ｅ,Ｒ,Ｔ,Ｙ,Ｕ,Ｉ,Ｏ,Ｐ,‘,｛"
	LFADK3 := "Ａ,Ｓ,Ｄ,Ｆ,Ｇ,Ｈ,Ｊ,Ｋ,Ｌ,＋,＊,｝"
	LFADK4 := "Ｚ,Ｘ,Ｃ,Ｖ,Ｂ,Ｎ,Ｍ,＜,＞,？,＿"
	; NULLテーブル
	LFNUL1 := "　,　,　,　,　,　,　,　,　,　,　,　,　"
	LFNUL2 := "　,　,　,　,　,　,　,　,　,　,　,　"
	LFNUL3 := "　,　,　,　,　,　,　,　,　,　,　,　"
	LFNUL4 := "　,　,　,　,　,　,　,　,　,　,　"
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
	Gosub,InitLayout2
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
;	各モードのレイアウトを処理
;----------------------------------------------------------------------
Mode2Key:
	LF%_mode% := 1
	_col := "1"
	;StringSplit org,LF%_mode%%_col%,`,
	org := StrSplit(LF%_mode%%_col%,",")
	if(org.MaxIndex() <> 13)
	{
		_cnt := org.MaxIndex()
		_error := _LayoutName . "の１段目にエラーがあります。要素数が" . _cnt . "です。"
		return
	}
	Gosub, TrimSpace
	Gosub, SetKeyTable
	if(_mode = "ANN")
		Gosub, SetAlphabet
	
	_col := "2"
	;StringSplit org,LF%_mode%%_col%,`,
	org := StrSplit(LF%_mode%%_col%,",")
	if(org.MaxIndex() <> 12)
	{
		_cnt := org.MaxIndex()
		_error := _LayoutName . "の２段目にエラーがあります。要素数が" . _cnt . "です。"
		return
	}
	Gosub, TrimSpace
	Gosub, SetKeyTable
	if(_mode = "ANN")
		Gosub, SetAlphabet
	
	_col := "3"
	;StringSplit org,LF%_mode%%_col%,`,
	org := StrSplit(LF%_mode%%_col%,",")
	if(org.MaxIndex() <> 12)
	{
		_cnt := org.MaxIndex()
		_error := _LayoutName . "の３段目にエラーがあります。要素数が" . _cnt . "です。"
		return
	}
	Gosub, TrimSpace
	Gosub, SetKeyTable
	if(_mode = "ANN")
		Gosub, SetAlphabet

	_col := "4"
	;StringSplit org,LF%_mode%%_col%,`,
	org := StrSplit(LF%_mode%%_col%,",")
	if(org.MaxIndex() <> 11)
	{
		_cnt := org.MaxIndex()
		_error := _LayoutName . "の４段目にエラーがあります。要素数が" . _cnt . "です。"
		return
	}
	Gosub, TrimSpace
	Gosub, SetKeyTable
	if(_mode = "ANN")
		Gosub, SetAlphabet
	return

;----------------------------------------------------------------------
;	レイアウトファイルの設定
;----------------------------------------------------------------------

SetLayoutProperty:
	vAllTheLayout := ""
	LFA := 0
	if(LFANN=1) {
		LFA := LFA | 1
	}
	if(LFALN=1) {
		LFA := LFA | 2
	}
	if(LFARN=1) {
		LFA := LFA | 4
	}
	if(LFANK=1) {
		LFA := LFA | 0x10
	}
	if(LFALK=1) {
		LFA := LFA | 0x20
	}
	if(LFARK=1) {
		LFA := LFA | 0x40
	}
	if(LFA=0x77) {
		vAllTheLayout := "英数シフト無し|英数左親指シフト|英数右親指シフト|英数小指シフト|英数小指左親指シフト|英数小指右親指シフト|"
	} else if(LFA!=0x00) {
		msgbox,英数モードの６面ののうち、定義されていないモードがあります。
	}
	LFR := 0
	if(LFRNN=1) {
		LFR := LFR | 1
	}
	if(LFRRN=1) {
		LFR := LFR | 2
	}
	if(LFRLN=1) {
		LFR := LFR | 4
	}
	if(LFRNK=1) {
		LFR := LFR | 0x10
	}
	if(LFRLK=1) {
		LFR := LFR | 0x20
	}
	if(LFRRK=1) {
		LFR := LFR | 0x40
	}
	if(LFR=0x77) {
		vAllTheLayout := vAllTheLayout . "ローマ字シフト無し||ローマ字左親指シフト|ローマ字右親指シフト|ローマ字小指シフト|ローマ字小指左親指シフト|ローマ字小指右親指シフト"
	} else if(LFR!=0x00) {
		msgbox,ローマ字モードの６面のうち、定義されていないモードがあります
	}
	return

;----------------------------------------------------------------------
;	行内のスペースを除去
;----------------------------------------------------------------------
TrimSpace:
	loop, %org0%
	{
		_tmp := org[A_Index]
		StringReplace, _tmp, _tmp, %A_Space%,, All
		org[A_Index] = _tmp
	}
	return

;----------------------------------------------------------------------
;	ローマ字・英数のときのキーダウン・キーアップの際に送信する内容を作成
;----------------------------------------------------------------------
SetKeyTable:
	kdn[_mode . "0"] := org.MaxIndex()
	kup[_mode . "0"] := org.MaxIndex()
	loop, % org.MaxIndex()
	{
		_qstr := QuotedStr(org[A_Index])
		if(_error <> "")
		{
			break
		}
		if(_qstr <> "")
		{
			kdn[_mode . _col . A_Index] := _qstr
			kup[_mode . _col . A_Index] := ""
			continue
		}
		ret := Kanji2KeySymbol(org[A_Index],_symbol)
		if(ret = 1)
		{
			kdn[_mode . _col . A_Index] := "{Blind}{" . _symbol . " down}"
			kup[_mode . _col . A_Index] := "{Blind}{" . _symbol . " up}"
			continue
		}
		_vk := ConvVkey(org[A_Index])
		if(_vk <> "")
		{
			kdn[_mode . _col . A_Index] := "{" . _vk . "}"
			kup[_mode . _col . A_Index] := ""
			continue
		}
		ret := ConvKana(org[A_Index], _nc)
		if(ret = 0)
		{
			GenSendStr(_nc,_dn,_up)
			kdn[_mode . _col . A_Index] := _dn
			kup[_mode . _col . A_Index] := _up
			continue
		}
		ret := ConvNarrow(org[A_Index], _nc)
		if(ret = 0)
		{
			if(substr(_mode,1,1)="A" && StrLen(aStr) >= 2)
			{
				_error := "英数モードのキーに２文字以上が設定されています"
			} else {
				GenSendStr(_nc,_dn,_up)
				kdn[_mode . _col . A_Index] := _dn
				kup[_mode . _col . A_Index] := _up
			}
		} else {
			kdn[_mode . _col . A_Index] := _nc
			kup[_mode . _col . A_Index] := ""
		}
	}
	return

;----------------------------------------------------------------------
;	修飾キー＋文字キーの出力の際に送信する内容を作成
;----------------------------------------------------------------------
SetAlphabet:
	mdn[_mode . "0"] := org.MaxIndex()
	mup[_mode . "0"] := org.MaxIndex()
	loop, % org.MaxIndex()
	{
		mdn[_mode . _col . A_Index] := kdn[_mode . _col . A_Index]
		mup[_mode . _col . A_Index] := kup[_mode . _col . A_Index]
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
	vSymbol := ""
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
; 全角平仮名をローマ字に変換
; 引数　：aStr：変換前の文字列
; 戻り値：エラーコード 0:正常
;----------------------------------------------------------------------
ConvKana(aStr,BYREF nStr) {
	global romahash
	nStr := ""
	rVal := 0
	StringLen _len,aStr
	if(_len == 1) 
	{
		_code := Asc(aStr)
		nStr := romahash[_code]
		StringLen _len2,nStr
		if(_len2 == 0) 
		{
			rVal := 1
		}
	}
	else
	{
		rVal := 1
	}
	return rVal
}

;----------------------------------------------------------------------
; 全角文字列が半角に変換可能ならば変換
; 引数　：aStr：変換前の文字列
; 戻り値：エラーコード 0:正常
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
	global SymbolHash
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
		_code := Asc(_ch)
		_c2 := SymbolHash[_code]
		if(_c2 <> "")
		{
			if(A_Index = _len)
			{
				_dn := _dn .  "{" . _c2 . " Down}"
				_up := "{Blind}{" . _c2 . " up}"
			} else {
				_dn := _dn .  "{" . _c2 . " Down}{" . _c2 . " up}"
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
;----------------------------------------------------------------------
;	半角文字のうち制御コードをAutoHotKeyのシンボルに変換
;----------------------------------------------------------------------
MakeSymbolHash() {
	Symbolhash := Object()
	Symbolhash[0x08] := "Backspace"
	Symbolhash[0x09] := "Tab"
	Symbolhash[0x0A] := "Enter"
	Symbolhash[0x0D] := "Enter"
	Symbolhash[0x1B] := "Esc"
	Symbolhash[0x20] := "Space"
	Symbolhash[0x21] := "!"
	Symbolhash[0x22] := """"
	Symbolhash[0x23] := "#"
	Symbolhash[0x24] := "$"
	Symbolhash[0x25] := "%"
	Symbolhash[0x26] := "&"
	Symbolhash[0x27] := "'"
	Symbolhash[0x28] := "("
	Symbolhash[0x29] := ")"
	Symbolhash[0x2A] := "*"
	Symbolhash[0x2B] := "+"
	Symbolhash[0x2C] := ","
	Symbolhash[0x2D] := "-"
	Symbolhash[0x2E] := "."
	Symbolhash[0x2F] := "/"
	Symbolhash[0x30] := "0"
	Symbolhash[0x31] := "1"
	Symbolhash[0x32] := "2"
	Symbolhash[0x33] := "3"
	Symbolhash[0x34] := "4"
	Symbolhash[0x35] := "5"
	Symbolhash[0x36] := "6"
	Symbolhash[0x37] := "7"
	Symbolhash[0x38] := "8"
	Symbolhash[0x39] := "9"
	Symbolhash[0x3A] := ":"
	Symbolhash[0x3B] := ";"
	Symbolhash[0x3C] := "<"
	Symbolhash[0x3D] := "="
	Symbolhash[0x3E] := ">"
	Symbolhash[0x3F] := "?"
	Symbolhash[0x40] := "@"
	Symbolhash[0x41] := "A"
	Symbolhash[0x42] := "B"
	Symbolhash[0x43] := "C"
	Symbolhash[0x44] := "D"
	Symbolhash[0x45] := "E"
	Symbolhash[0x46] := "F"
	Symbolhash[0x47] := "G"
	Symbolhash[0x48] := "H"
	Symbolhash[0x49] := "I"
	Symbolhash[0x4A] := "J"
	Symbolhash[0x4B] := "K"
	Symbolhash[0x4C] := "L"
	Symbolhash[0x4D] := "M"
	Symbolhash[0x4E] := "N"
	Symbolhash[0x4F] := "O"
	Symbolhash[0x50] := "P"
	Symbolhash[0x51] := "Q"
	Symbolhash[0x52] := "R"
	Symbolhash[0x53] := "S"
	Symbolhash[0x54] := "T"
	Symbolhash[0x55] := "U"
	Symbolhash[0x56] := "V"
	Symbolhash[0x57] := "W"
	Symbolhash[0x58] := "X"
	Symbolhash[0x59] := "Y"
	Symbolhash[0x5A] := "Z"
	Symbolhash[0x5B] := "["
	Symbolhash[0x5C] := "\"
	Symbolhash[0x5D] := "]"
	Symbolhash[0x5E] := "^"
	Symbolhash[0x5F] := "_"
	Symbolhash[0x60] := "`"
	Symbolhash[0x61] := "a"
	Symbolhash[0x62] := "b"
	Symbolhash[0x63] := "c"
	Symbolhash[0x64] := "d"
	Symbolhash[0x65] := "e"
	Symbolhash[0x66] := "f"
	Symbolhash[0x67] := "g"
	Symbolhash[0x68] := "h"
	Symbolhash[0x69] := "i"
	Symbolhash[0x6A] := "j"
	Symbolhash[0x6B] := "k"
	Symbolhash[0x6C] := "l"
	Symbolhash[0x6D] := "m"
	Symbolhash[0x6E] := "n"
	Symbolhash[0x6F] := "o"
	Symbolhash[0x70] := "p"
	Symbolhash[0x71] := "q"
	Symbolhash[0x72] := "r"
	Symbolhash[0x73] := "s"
	Symbolhash[0x74] := "t"
	Symbolhash[0x75] := "u"
	Symbolhash[0x76] := "v"
	Symbolhash[0x77] := "w"
	Symbolhash[0x78] := "x"
	Symbolhash[0x79] := "y"
	Symbolhash[0x7A] := "z"
	Symbolhash[0x7B] := "{"
	Symbolhash[0x7C] := "|"
	Symbolhash[0x7D] := "}"
	Symbolhash[0x7E] := "~"
	Symbolhash[0x7F] := "Del"
	return SymbolHash
}

;----------------------------------------------------------------------
; ローマ字変換用ハッシュを生成
; 戻り値：モード名
;----------------------------------------------------------------------
MakeRomaHash()
{
	hash := Object()
	hash[0x3041] := "la"	;ぁ
	hash[0x3042] := "a"		;あ
	hash[0x3043] := "xi"	;ぃ
	hash[0x3044] := "i"		;い
	hash[0x3045] := "lu"	;ぅ
	hash[0x3046] := "u"		;う
	hash[0x3047] := "le"	;ぇ
	hash[0x3048] := "e"		;え
	hash[0x3049] := "lo"	;ぉ
	hash[0x304A] := "o"		;お
	hash[0x304B] := "ka"	;か
	hash[0x304C] := "ga"	;が
	hash[0x304D] := "ki"	;き
	hash[0x304E] := "gi"	;ぎ
	hash[0x304F] := "ku"	;く
	hash[0x3050] := "gu"	;ぐ
	hash[0x3051] := "ke"	;け
	hash[0x3052] := "ge"	;げ
	hash[0x3053] := "ko"	;こ
	hash[0x3054] := "go"	;ご
	hash[0x3055] := "sa"	;さ
	hash[0x3056] := "za"	;ざ
	hash[0x3057] := "si"	;し
	hash[0x3058] := "zi"	;じ
	hash[0x3059] := "su"	;す
	hash[0x305A] := "zu"	;ず
	hash[0x305B] := "se"	;せ
	hash[0x305C] := "ze"	;ぜ
	hash[0x305D] := "so"	;そ
	hash[0x305E] := "zo"	;ぞ
	hash[0x305F] := "ta"	;た
	hash[0x3060] := "da"	;だ
	hash[0x3061] := "ti"	;ち
	hash[0x3062] := "di"	;ぢ
	hash[0x3063] := "ltu"	;っ
	hash[0x3064] := "tu"	;つ
	hash[0x3065] := "du"	;づ
	hash[0x3066] := "te"	;て
	hash[0x3067] := "de"	;で
	hash[0x3068] := "to"	;と
	hash[0x3069] := "do"	;ど
	hash[0x306A] := "na"	;な
	hash[0x306B] := "ni"	;に
	hash[0x306C] := "nu"	;ぬ
	hash[0x306D] := "ne"	;ね
	hash[0x306E] := "no"	;の
	hash[0x306F] := "ha"	;は
	hash[0x3070] := "ba"	;ば
	hash[0x3071] := "pa"	;ぱ
	hash[0x3072] := "hi"	;ひ
	hash[0x3073] := "bi"	;び
	hash[0x3074] := "pi"	;ぴ
	hash[0x3075] := "fu"	;ふ
	hash[0x3076] := "bu"	;ぶ
	hash[0x3077] := "pu"	;ぷ
	hash[0x3078] := "he"	;へ
	hash[0x3079] := "be"	;べ
	hash[0x307A] := "pe"	;ぺ
	hash[0x307B] := "ho"	;ほ
	hash[0x307C] := "bo"	;ぼ
	hash[0x307D] := "po"	;ぽ
	hash[0x307E] := "ma"	;ま
	hash[0x307F] := "mi"	;み
	hash[0x3080] := "mu"	;む
	hash[0x3081] := "me"	;め
	hash[0x3082] := "mo"	;も
	hash[0x3083] := "lya"	;ゃ
	hash[0x3084] := "ya"	;や
	hash[0x3085] := "lyu"	;ゅ
	hash[0x3086] := "yu"	;ゆ
	hash[0x3087] := "lyo"	;ょ
	hash[0x3088] := "yo"	;よ
	hash[0x3089] := "ra"	;ら
	hash[0x308A] := "ri"	;り
	hash[0x308B] := "ru"	;る
	hash[0x308C] := "re"	;れ
	hash[0x308D] := "ro"	;ろ
	hash[0x308E] := "lwa"	;ゎ
	hash[0x308F] := "wa"	;わ
	hash[0x3090] := "wi"	;ゐ
	hash[0x3091] := "we"	;ゑ
	hash[0x3092] := "wo"	;を
	hash[0x3093] := "nn"	;ん
	hash[0x3094] := "vu"	;ゔ
	hash[0x3095] := "lka"	;ゕ
	hash[0x3096] := "lke"	;ゖ
	return hash
}