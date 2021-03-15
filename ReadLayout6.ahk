;-----------------------------------------------------------------------
;	名称：ReadLayout6.ahk
;	機能：紅皿のキーレイアウトファイルの読み込み
;	ver.0.1.4.4 .... 2021/3/10
;-----------------------------------------------------------------------
ReadLayout:
	kup := Object()
	kdn := Object()
	mup := Object()
	mdn := Object()

	_colcnv := Object()
	_colcnv[1] := "E"
	_colcnv[2] := "D"
	_colcnv[3] := "C"
	_colcnv[4] := "B"
	_colcnv[5] := "A"
	
	_rowcnv := Object()
	_rowcnv[1] := "01"
	_rowcnv[2] := "02"
	_rowcnv[3] := "03"
	_rowcnv[4] := "04"
	_rowcnv[5] := "05"
	_rowcnv[6] := "06"
	_rowcnv[7] := "07"
	_rowcnv[8] := "08"
	_rowcnv[9] := "09"
	_rowcnv[10]:= "10"
	_rowcnv[11]:= "11"
	_rowcnv[12]:= "12"
	_rowcnv[13]:= "13"
	
	romahash := MakeRomaHash()
	SymbolHash := MakeSymbolHash()
	layoutHash := MakeLayoutHash()
	kanjiSymbolHash := MakeKanjiSymbolHash()

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
	LF := Object()
	LF["ANN"] := 0
	LF["ALN"] := 0
	LF["ARN"] := 0

	LF["ANK"] := 0
	LF["ALK"] := 0
	LF["ARK"] := 0

	LF["RNN"] := 0
	LF["RLN"] := 0
	LF["RRN"] := 0

	LF["RNK"] := 0
	LF["RLK"] := 0
	LF["RRK"] := 0
	loop,4
	{
		LF["ANN" . _colcnv[A_Index]] := ""
		LF["ALN" . _colcnv[A_Index]] := ""
		LF["ARN" . _colcnv[A_Index]] := ""

		LF["ANK" . _colcnv[A_Index]] := ""
		LF["ALK" . _colcnv[A_Index]] := ""
		LF["ARK" . _colcnv[A_Index]] := ""

		LF["RNN" . _colcnv[A_Index]] := ""
		LF["RLN" . _colcnv[A_Index]] := ""
		LF["RRN" . _colcnv[A_Index]] := ""

		LF["RNK" . _colcnv[A_Index]] := ""
		LF["RLK" . _colcnv[A_Index]] := ""
		LF["RRK" . _colcnv[A_Index]] := ""
	}
	; デフォルトテーブル
	LF["ADNE"] := "１,２,３,４,５,６,７,８,９,０,ー,＾,￥"
	LF["ADND"] := "ｑ,ｗ,ｅ,ｒ,ｔ,ｙ,ｕ,ｉ,ｏ,ｐ,＠,［"
	LF["ADNC"] := "ａ,ｓ,ｄ,ｆ,ｇ,ｈ,ｋ,ｌ,ｌ,；,：,］"
	LF["ADNB"] := "ｚ,ｘ,ｃ,ｖ,ｂ,ｎ,ｍ,，,．,／,￥"

	LF["ADKE"] := "！,”,＃,＄,％,＆,’, （,）,無,＝,～,｜"
	LF["ADKD"] := "Ｑ,Ｗ,Ｅ,Ｒ,Ｔ,Ｙ,Ｕ,Ｉ,Ｏ,Ｐ,‘,｛"
	LF["ADKC"] := "Ａ,Ｓ,Ｄ,Ｆ,Ｇ,Ｈ,Ｊ,Ｋ,Ｌ,＋,＊,｝"
	LF["ADKB"] := "Ｚ,Ｘ,Ｃ,Ｖ,Ｂ,Ｎ,Ｍ,＜,＞,？,＿"
	; NULLテーブル
	LF["NULE"] := "　,　,　,　,　,　,　,　,　,　,　,　,　"
	LF["NULD"] := "　,　,　,　,　,　,　,　,　,　,　,　"
	LF["NULC"] := "　,　,　,　,　,　,　,　,　,　,　,　"
	LF["NULB"] := "　,　,　,　,　,　,　,　,　,　,　"
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
			if(cpos0 >= 1 && cpos1 > cpos0)
			{
				_LayoutName := SubStr(_line2, cpos0+1, cpos1-cpos0-1)
				_mode := layoutHash[_LayoutName]
				if(_mode <> "")
				{
					_mline := 0
				}
			}
			if(_mode <> "") 
			{
				if _mline between 1 and 4
				{
					LF[_mode . _colcnv[_mline]] := _line2
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
	LF[_mode] := 1
	_col := "E"
	org := StrSplit(LF[_mode . "E"],",")
	if(org.MaxIndex() <> 13)
	{
		_error := _LayoutName . "の１段目にエラーがあります。要素数が" . org.MaxIndex() . "です。"
		return
	}
	Gosub, TrimSpace
	Gosub, SetKeyTable
	if(_mode = "ANN")
		Gosub, SetAlphabet
	
	_col := "D"
	org := StrSplit(LF[_mode . "D"],",")
	if(org.MaxIndex() <> 12)
	{
		_error := _LayoutName . "の２段目にエラーがあります。要素数が" . org.MaxIndex() . "です。"
		return
	}
	Gosub, TrimSpace
	Gosub, SetKeyTable
	if(_mode = "ANN")
		Gosub, SetAlphabet
	
	_col := "C"
	org := StrSplit(LF[_mode . "C"],",")
	if(org.MaxIndex() <> 12)
	{
		_error := _LayoutName . "の３段目にエラーがあります。要素数が" . org.MaxIndex() . "です。"
		return
	}
	Gosub, TrimSpace
	Gosub, SetKeyTable
	if(_mode = "ANN")
		Gosub, SetAlphabet

	_col := "B"
	org := StrSplit(LF[_mode . "B"],",")
	if(org.MaxIndex() <> 11)
	{
		_error := _LayoutName . "の４段目にエラーがあります。要素数が" . org.MaxIndex() . "です。"
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
	if(LF["ANN"]=1) {
		LFA := LFA | 1
	}
	if(LF["ALN"]=1) {
		LFA := LFA | 2
	}
	if(LF["ARN"]=1) {
		LFA := LFA | 4
	}
	if(LF["ANK"]=1) {
		LFA := LFA | 0x10
	}
	if(LF["ALK"]=1) {
		LFA := LFA | 0x20
	}
	if(LF["ARK"]=1) {
		LFA := LFA | 0x40
	}
	if(LFA=0x77) {
		vAllTheLayout := "英数シフト無し|英数左親指シフト|英数右親指シフト|英数小指シフト|英数小指左親指シフト|英数小指右親指シフト|"
	} else if(LFA!=0x00) {
		msgbox,英数モードの６面ののうち、定義されていないモードがあります。
	}
	LFR := 0
	if(LF["RNN"]=1) {
		LFR := LFR | 1
	}
	if(LF["RRN"]=1) {
		LFR := LFR | 2
	}
	if(LF["RLN"]=1) {
		LFR := LFR | 4
	}
	if(LF["RNK"]=1) {
		LFR := LFR | 0x10
	}
	if(LF["RLK"]=1) {
		LFR := LFR | 0x20
	}
	if(LF["RRK"]=1) {
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
	loop, % org.MaxIndex()
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
		_row2 := _rowcnv[A_Index]
		_qstr := QuotedStr(org[A_Index])
		if(_error <> "")
		{
			break
		}
		if(_qstr <> "")
		{
			kdn[_mode . _col . _row2] := _qstr
			kup[_mode . _col . _row2] := ""
			continue
		}
		ret := Kanji2KeySymbol(org[A_Index],_symbol)
		if(ret = 1)
		{
			kdn[_mode . _col . _row2] := "{Blind}{" . _symbol . " down}"
			kup[_mode . _col . _row2] := "{Blind}{" . _symbol . " up}"
			continue
		}
		_vk := ConvVkey(org[A_Index])
		if(_vk <> "")
		{
			kdn[_mode . _col . _row2] := "{" . _vk . "}"
			kup[_mode . _col . _row2] := ""
			continue
		}
		ret := ConvKana(org[A_Index], _nc)
		if(ret = 0)
		{
			GenSendStr(_nc,_dn,_up)
			kdn[_mode . _col . _row2] := _dn
			kup[_mode . _col . _row2] := _up
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
				kdn[_mode . _col . _row2] := _dn
				kup[_mode . _col . _row2] := _up
			}
		} else {
			kdn[_mode . _col . _row2] := _nc
			kup[_mode . _col . _row2] := ""
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
		_row2 := _rowcnv[A_Index]
		mdn[_mode . _col . _row2] := kdn[_mode . _col . _row2]
		mup[_mode . _col . _row2] := kup[_mode . _col . _row2]
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
	global kanjiSymbolHash
	vSymbol := ""
	ret := 0
	if(_ch = "")
		return 0
	if(StrLen(_ch) <> 1)
		return 0

	vSymbol := kanjiSymbolHash[_ch]
	if(StrLen(vSymbol)>0) {
		ret := 1
	} else
	if(_ch = "無") {
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
;	漢字シンボルをAutohotkeyのコード名に変換
;----------------------------------------------------------------------
MakeKanjiSymbolHash()
{
	kanjiSymbolHash := Object()
	kanjiSymbolHash["後"] := "Backspace"
	kanjiSymbolHash["逃"] := "Esc"
	kanjiSymbolHash["入"] := "Enter"
	kanjiSymbolHash["空"] := "Space"
	kanjiSymbolHash["消"] := "Delete"
	kanjiSymbolHash["挿"] := "Insert"
	kanjiSymbolHash["上"] := "Up"
	kanjiSymbolHash["左"] := "Left"
	kanjiSymbolHash["右"] := "Right"
	kanjiSymbolHash["下"] := "Down"
	kanjiSymbolHash["家"] := "Home"
	kanjiSymbolHash["終"] := "End"
	kanjiSymbolHash["前"] := "PgUp"
	kanjiSymbolHash["次"] := "PgDn"
	kanjiSymbolHash["無"] := ""
	return kanjiSymbolHash
}

;----------------------------------------------------------------------
;	レイアウト名からモード名に変換
;----------------------------------------------------------------------
MakeLayoutHash() {
	LayoutHash := Object()
	LayoutHash["英数シフト無し"]           := "ANN"
	LayoutHash["英数左親指シフト"]         := "ALN"
	LayoutHash["英数右親指シフト"]         := "ARN"
	LayoutHash["英数小指シフト"]           := "ANK"
	LayoutHash["英数小指左親指シフト"]     := "ALK"
	LayoutHash["英数小指右親指シフト"]     := "ARK"
	LayoutHash["ローマ字シフト無し"]       := "RNN"
	LayoutHash["ローマ字左親指シフト"]     := "RLN"
	LayoutHash["ローマ字右親指シフト"]     := "RRN"
	LayoutHash["ローマ字小指シフト"]       := "RNK"
	LayoutHash["ローマ字小指左親指シフト"] := "RRK"
	LayoutHash["ローマ字小指右親指シフト"] := "RLK"
	return LayoutHash
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