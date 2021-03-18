;-----------------------------------------------------------------------
;	名称：ReadLayout6.ahk
;	機能：紅皿のキーレイアウトファイルの読み込み
;	ver.0.1.4.4 .... 2021/3/10
;-----------------------------------------------------------------------
ReadLayout:
	ksf := Object()	; 表層形
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
	_rowcnv[0] := "00"
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
	_rowcnv[14]:= "14"
	_rowcnv[15]:= "15"
	
	roma3hash := MakeRoma3Hash()
	layoutHash := MakeLayoutHash()
	z2hHash := MakeZ2hHash()
	
	Gosub, InitLayout2
	vLayoutFile := g_LayoutFile
	if(vLayoutFile = "")
		return

	_error := ""
	Gosub, ReadLayoutFile
	if(_error <> "")
	{
		Msgbox,%_error%

		LFA := ""
		LFN := ""
	}
	Gosub, SetLayoutProperty
	return

#include Path.ahk

; 各テーブルを読み込んだか否かの判定変数の初期化とデフォルトテーブル
;
InitLayout2:
	keyAttribute := MakeKeyAttributeHash()
	keyState := MakeKeyState()
	LF := Object()
	LF["ANN"] := 0
	LF["ALN"] := 0
	LF["ARN"] := 0
	LF["A1N"] := 0
	LF["A2N"] := 0

	LF["ANK"] := 0
	LF["ALK"] := 0
	LF["ARK"] := 0
	LF["A1K"] := 0
	LF["A2K"] := 0

	LF["RNN"] := 0
	LF["RLN"] := 0
	LF["RRN"] := 0
	LF["R1N"] := 0
	LF["R2N"] := 0

	LF["RNK"] := 0
	LF["RLK"] := 0
	LF["RRK"] := 0
	LF["R1K"] := 0
	LF["R2K"] := 0
	loop,4
	{
		LF["ANN" . _colcnv[A_Index]] := ""
		LF["ALN" . _colcnv[A_Index]] := ""
		LF["ARN" . _colcnv[A_Index]] := ""
		LF["A1N" . _colcnv[A_Index]] := ""
		LF["A2N" . _colcnv[A_Index]] := ""

		LF["ANK" . _colcnv[A_Index]] := ""
		LF["ALK" . _colcnv[A_Index]] := ""
		LF["ARK" . _colcnv[A_Index]] := ""
		LF["A1K" . _colcnv[A_Index]] := ""
		LF["A2K" . _colcnv[A_Index]] := ""

		LF["RNN" . _colcnv[A_Index]] := ""
		LF["RLN" . _colcnv[A_Index]] := ""
		LF["RRN" . _colcnv[A_Index]] := ""
		LF["R1N" . _colcnv[A_Index]] := ""
		LF["R2N" . _colcnv[A_Index]] := ""

		LF["RNK" . _colcnv[A_Index]] := ""
		LF["RLK" . _colcnv[A_Index]] := ""
		LF["RRK" . _colcnv[A_Index]] := ""
		LF["R1K" . _colcnv[A_Index]] := ""
		LF["R2K" . _colcnv[A_Index]] := ""
	}
	; デフォルトテーブル
	LF["ADNE"] := "１,２,３,４,５,６,７,８,９,０,ー,＾,￥"
	LF["ADND"] := "ｑ,ｗ,ｅ,ｒ,ｔ,ｙ,ｕ,ｉ,ｏ,ｐ,＠,［"
	LF["ADNC"] := "ａ,ｓ,ｄ,ｆ,ｇ,ｈ,ｊ,ｋ,ｌ,；,：,］"
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
	;Gosub, TrimSpace
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
	;Gosub, TrimSpace
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
	;Gosub, TrimSpace
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
	;Gosub, TrimSpace
	Gosub, SetKeyTable
	if(_mode = "ANN")
		Gosub, SetAlphabet
	return

;----------------------------------------------------------------------
;	レイアウトファイルの設定
;----------------------------------------------------------------------

SetLayoutProperty:
	ShiftMode := Object()
	ShiftMode["A"] := ""
	if(LF["ANN"]==1 && LF["ALN"]==1 && LF["ARN"]==1 && LF["ANK"]==1 && LF["ALK"]==1 && LF["ARK"]==1)
	{
		ShiftMode["A"] := "親指シフト"
	} else 
	if(LF["ANN"]==1 && (LF["A1N"]==1 || LF["A2N"]==1) && (LF["ANK"]==1 || LF["A1K"]==1 && LF["A2K"]==1)) 
	{
		ShiftMode["A"] := "プレフィックスシフト"
	}
	else
	if(LF["ANN"]==1 && LF["ALN"]==0 && LF["ARN"]==0 && LF["ANK"]==1 && LF["ALK"]==0 && LF["ARK"]==0)
	{
		ShiftMode["A"] := "小指シフト"
	}
	ShiftMode["R"] := ""
	if(LF["RNN"]==1 && LF["RRN"]==1 && LF["RLN"]==1 && LF["RNK"]==1 && LF["RLK"]==1 && LF["RRK"]==1)
	{
		ShiftMode["R"] := "親指シフト"
	} else
	if(LF["RNN"]==1 && (LF["R1N"]==1 || LF["R2N"]==1) && LF["RNK"]==1 && (LF["R1K"]==1 || LF["R2K"]==1))
	{
		ShiftMode["R"] := "プレフィックスシフト"
	}
	else
	if(LF["RNN"]==1 && LF["RRN"]==0 && LF["RLN"]==0 && LF["RNK"]==1 && LF["RLK"]==0 && LF["RRK"]==0)
	{
		ShiftMode["R"] := "小指シフト"
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
		ksf[_mode . _col . _row2] := org[A_Index]

		; 月配列などのプレフィックスシフトキー
		if(org[A_Index] == " 1" || org[A_Index] == " 2")
		{
			kdn[_mode . _col . _row2] := ""
			kup[_mode . _col . _row2] := ""
			if(_mode = "RNN" || _mode = "ANN")
			{
				keyAttribute[_col . _row2] := SubStr(org[A_Index],2,1)
			}
			continue
		}

		; 引用符つき文字列を登録・・・2020年10月以降のWindows10ではダメになった
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
		; vkeyならば vkeyとして登録
		_vk := ConvVkey(org[A_Index])
		if(_vk <> "")
		{
			kdn[_mode . _col . _row2] := "{" . _vk . "}"
			kup[_mode . _col . _row2] := ""
			continue
		}
		; かな文字はローマ字に変換
		_aStr := kana2Romaji(org[A_Index])
		
		; 送信形式に変換
		GenSendStr2(_aStr, _up, _down)
		if( _up <> "")
		{
			kdn[_mode . _col . _row2] := _up
			kup[_mode . _col . _row2] := _down
		}
		continue
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
; かなをローマ字に変換する
; 引数　：aStr：対応するキー入力
; 戻り値：ローマ字に変換した後
;----------------------------------------------------------------------
Kana2Romaji(aStr)
{
	global roma3Hash
	_len := strlen(aStr)	; 全角
	if(_len = 0)
	{
		return ""
	}
	; かな文字をローマ字に展開
	_aStr2 := ""
	loop,Parse, aStr
	{
		_c2 := roma3Hash[A_LoopField]
		if(_c2 <> "")
		{
			_aStr2 := _aStr2 . _c2
		}
		else
		{
			_aStr2 := _aStr2 . A_LoopField
		}
	}
	return _aStr2
}
;----------------------------------------------------------------------
; 通常のキーdown時にSendする引数の文字列を設定する
; 引数　：aStr：対応するキー入力
; 戻り値：Sendの引数
;----------------------------------------------------------------------
GenSendStr2(aStr,BYREF _dn,BYREF _up)
{
	global z2hHash
	_len := strlen(aStr)	; 全角
	if(_len = 0)
	{
		return ""
	}
	; 入力文字列をAutohotkeyのSend形式に変換
	_dn := "{Blind}"
	_up := ""
	loop,Parse, aStr
	{
		_c2 := z2hHash[A_LoopField]
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
;	レイアウト名からモード名に変換
;----------------------------------------------------------------------
MakeLayoutHash() {
	Hash := Object()
	Hash["英数シフト無し"]           := "ANN"
	Hash["英数左親指シフト"]         := "ALN"
	Hash["英数右親指シフト"]         := "ARN"
	Hash["英数小指シフト"]           := "ANK"
	Hash["英数小指左親指シフト"]     := "ALK"
	Hash["英数小指右親指シフト"]     := "ARK"
	Hash["ローマ字シフト無し"]       := "RNN"
	Hash["ローマ字左親指シフト"]     := "RLN"
	Hash["ローマ字右親指シフト"]     := "RRN"
	Hash["ローマ字小指シフト"]       := "RNK"
	Hash["ローマ字小指左親指シフト"] := "RRK"
	Hash["ローマ字小指右親指シフト"] := "RLK"

	Hash["英数１プリフィックスシフト"]         := "A1N"	; for 月配列
	Hash["英数２プリフィックスシフト"]         := "A2N"	; for 月配列
	Hash["英数小指１プリフィックスシフト"]     := "A1K"	; for 月配列
	Hash["英数小指２プリフィックスシフト"]     := "A2K"	; for 月配列	
	Hash["ローマ字１プリフィックスシフト"]     := "R1N"	; for 月配列
	Hash["ローマ字２プリフィックスシフト"]     := "R2N"	; for 月配列
	Hash["ローマ字小指１プリフィックスシフト"] := "R1K"	; for 月配列
	Hash["ローマ字小指２プリフィックスシフト"] := "R2K"	; for 月配列	
	return Hash
}


;----------------------------------------------------------------------
;	全角を半角に変換
;----------------------------------------------------------------------
MakeZ2hHash() {
	hash := Object()
	hash["後"] := "Backspace"
	hash["逃"] := "Esc"
	hash["入"] := "Enter"
	hash["空"] := "Space"
	hash["消"] := "Delete"
	hash["挿"] := "Insert"
	hash["上"] := "Up"
	hash["左"] := "Left"
	hash["右"] := "Right"
	hash["下"] := "Down"
	hash["家"] := "Home"
	hash["終"] := "End"
	hash["前"] := "PgUp"
	hash["次"] := "PgDn"
	hash["無"] := ""
	hash[chr(65509)] := "\"
	hash[chr(8220)]  := """"
	hash[chr(8221)]  := """"	; 二重引用符
	hash[chr(8217)]  := "'"		; 一重引用符
	hash[chr(8216)]  := "``"
	hash[chr(12288)] := " "		;全角スペース
	hash["　"] := "Space"
	hash["！"] := "!"
	hash["”"] := """"
	hash["“"] := """"
	hash["＃"] := "#"
	hash["＄"] := "$"
	hash["％"] := "%"
	hash["＆"] := "&"
	hash["’"] := "'"
	hash["′"] := "'"
	hash["（"] := "("
	hash["）"] := ")"
	hash["＊"] := "*"
	hash["＋"] := "+"
	hash["，"] := ","
	hash["－"] := "-"
	hash["．"] := "."
	hash["／"] := "/"
	hash["０"] := "0"
	hash["１"] := "1"
	hash["２"] := "2"
	hash["３"] := "3"
	hash["４"] := "4"
	hash["５"] := "5"
	hash["６"] := "6"
	hash["７"] := "7"
	hash["８"] := "8"
	hash["９"] := "9"
	hash["："] := ":"
	hash["；"] := ";"
	hash["＜"] := "<"
	hash["＝"] := "="
	hash["＞"] := ">"
	hash["？"] := "?"
	hash["＠"] := "@"
	hash["Ａ"] := "A"
	hash["Ｂ"] := "B"
	hash["Ｃ"] := "C"
	hash["Ｄ"] := "D"
	hash["Ｅ"] := "E"
	hash["Ｆ"] := "F"
	hash["Ｇ"] := "G"
	hash["Ｈ"] := "H"
	hash["Ｉ"] := "I"
	hash["Ｊ"] := "J"
	hash["Ｋ"] := "K"
	hash["Ｌ"] := "L"
	hash["Ｍ"] := "M"
	hash["Ｎ"] := "N"
	hash["Ｏ"] := "O"
	hash["Ｐ"] := "P"
	hash["Ｑ"] := "Q"
	hash["Ｒ"] := "R"
	hash["Ｓ"] := "S"
	hash["Ｔ"] := "T"
	hash["Ｕ"] := "U"
	hash["Ｖ"] := "V"
	hash["Ｗ"] := "W"
	hash["Ｘ"] := "X"
	hash["Ｙ"] := "Y"
	hash["Ｚ"] := "Z"
	hash["［"] := "["
	hash["￥"] := "\"
	hash["］"] := "]"
	hash["＾"] := "^"
	hash["＿"] := "_"
	hash["｀"] := "`"
	hash["ａ"] := "a"
	hash["ｂ"] := "b"
	hash["ｃ"] := "c"
	hash["ｄ"] := "d"
	hash["ｅ"] := "e"
	hash["ｆ"] := "f"
	hash["ｇ"] := "g"
	hash["ｈ"] := "h"
	hash["ｉ"] := "i"
	hash["ｊ"] := "j"
	hash["ｋ"] := "k"
	hash["ｌ"] := "l"
	hash["ｍ"] := "m"
	hash["ｎ"] := "n"
	hash["ｏ"] := "o"
	hash["ｐ"] := "p"
	hash["ｑ"] := "q"
	hash["ｒ"] := "r"
	hash["ｓ"] := "s"
	hash["ｔ"] := "t"
	hash["ｕ"] := "u"
	hash["ｖ"] := "v"
	hash["ｗ"] := "w"
	hash["ｘ"] := "x"
	hash["ｙ"] := "y"
	hash["ｚ"] := "z"
	hash["｛"] := "{"
	hash["｜"] := "|"
	hash["｝"] := "}"
	hash["～"] := "~"
	return hash
}

;----------------------------------------------------------------------
; ローマ字変換用ハッシュを生成
; 戻り値：モード名
;----------------------------------------------------------------------
MakeRoma3Hash()
{
	hash := Object()
	hash["ぁ"] := "ｌａ"
	hash["あ"] := "ａ"
	hash["ぃ"] := "ｌｉ"
	hash["い"] := "ｉ"
	hash["ぅ"] := "ｌｕ"
	hash["う"] := "ｕ"
	hash["ぇ"] := "ｌｅ"
	hash["え"] := "ｅ"
	hash["ぉ"] := "ｌｏ"
	hash["お"] := "ｏ"
	hash["か"] := "ｋａ"
	hash["が"] := "ｇａ"
	hash["き"] := "ｋｉ"
	hash["ぎ"] := "ｇｉ"
	hash["く"] := "ｋｕ"
	hash["ぐ"] := "ｇｕ"
	hash["け"] := "ｋｅ"
	hash["げ"] := "ｇｅ"
	hash["こ"] := "ｋｏ"
	hash["ご"] := "ｇｏ"
	hash["さ"] := "ｓａ"
	hash["ざ"] := "ｚａ"
	hash["し"] := "ｓｉ"
	hash["じ"] := "ｚｉ"
	hash["す"] := "ｓｕ"
	hash["ず"] := "ｚｕ"
	hash["せ"] := "ｓｅ"
	hash["ぜ"] := "ｚｅ"
	hash["そ"] := "ｓｏ"
	hash["ぞ"] := "ｚｏ"
	hash["た"] := "ｔａ"
	hash["だ"] := "ｄａ"
	hash["ち"] := "ｔｉ"
	hash["ぢ"] := "ｄｉ"
	hash["っ"] := "ｌｔｕ"
	hash["つ"] := "ｔｕ"
	hash["づ"] := "ｄｕ"
	hash["て"] := "ｔｅ"
	hash["で"] := "ｄｅ"
	hash["と"] := "ｔｏ"
	hash["ど"] := "ｄｏ"
	hash["な"] := "ｎａ"
	hash["に"] := "ｎｉ"
	hash["ぬ"] := "ｎｕ"
	hash["ね"] := "ｎｅ"
	hash["の"] := "ｎｏ"
	hash["は"] := "ｈａ"
	hash["ば"] := "ｂａ"
	hash["ぱ"] := "ｐａ"
	hash["ひ"] := "ｈｉ"
	hash["び"] := "ｂｉ"
	hash["ぴ"] := "ｐｉ"
	hash["ふ"] := "ｆｕ"
	hash["ぶ"] := "ｂｕ"
	hash["ぷ"] := "ｐｕ"
	hash["へ"] := "ｈｅ"
	hash["べ"] := "ｂｅ"
	hash["ぺ"] := "ｐｅ"
	hash["ほ"] := "ｈｏ"
	hash["ぼ"] := "ｂｏ"
	hash["ぽ"] := "ｐｏ"
	hash["ま"] := "ｍａ"
	hash["み"] := "ｍｉ"
	hash["む"] := "ｍｕ"
	hash["め"] := "ｍｅ"
	hash["も"] := "ｍｏ"
	hash["ゃ"] := "ｌｙａ"
	hash["や"] := "ｙａ"
	hash["ゅ"] := "ｌｙｕ"
	hash["ゆ"] := "ｙｕ"
	hash["ょ"] := "ｌｙｏ"
	hash["よ"] := "ｙｏ"
	hash["ら"] := "ｒａ"
	hash["り"] := "ｒｉ"
	hash["る"] := "ｒｕ"
	hash["れ"] := "ｒｅ"
	hash["ろ"] := "ｒｏ"
	hash["ゎ"] := "ｌｗａ"
	hash["わ"] := "ｗａ"
	hash["ゐ"] := "ｗｉ"
	hash["ゑ"] := "ｗｅ"
	hash["を"] := "ｗｏ"
	hash["ん"] := "ｎｎ"
	hash["ゔ"] := "ｖｕ"
	hash["ゕ"] := "ｌｋａ"
	hash["ゖ"] := "ｌｋｅ"
	return hash
}



;----------------------------------------------------------------------
;	キー名から処理関数に変換
;	M:文字キー
;	X:修飾キー
;	L:左親指キー
;	R:右親指キー
;----------------------------------------------------------------------
MakeKeyAttributeHash() {
	keyAttribute := Object()
	keyAttribute["E00"] := "X"	; 半角/全角
	keyAttribute["E01"] := "M"
	keyAttribute["E02"] := "M"
	keyAttribute["E03"] := "M"
	keyAttribute["E04"] := "M"
	keyAttribute["E05"] := "M"
	keyAttribute["E06"] := "M"
	keyAttribute["E07"] := "M"
	keyAttribute["E08"] := "M"
	keyAttribute["E09"] := "M"
	keyAttribute["E10"] := "M"
	keyAttribute["E11"] := "M"
	keyAttribute["E12"] := "M"
	keyAttribute["E13"] := "M"
	keyAttribute["E14"] := "X"	; Backspace
	keyAttribute["D00"] := "X"	; Tab
	keyAttribute["D01"] := "M"
	keyAttribute["D02"] := "M"
	keyAttribute["D03"] := "M"
	keyAttribute["D04"] := "M"
	keyAttribute["D05"] := "M"
	keyAttribute["D06"] := "M"
	keyAttribute["D07"] := "M"
	keyAttribute["D08"] := "M"
	keyAttribute["D09"] := "M"
	keyAttribute["D10"] := "M"
	keyAttribute["D11"] := "M"
	keyAttribute["D12"] := "M"
	keyAttribute["C01"] := "M"
	keyAttribute["C02"] := "M"
	keyAttribute["C03"] := "M"
	keyAttribute["C04"] := "M"
	keyAttribute["C05"] := "M"
	keyAttribute["C06"] := "M"
	keyAttribute["C07"] := "M"
	keyAttribute["C08"] := "M"
	keyAttribute["C09"] := "M"
	keyAttribute["C10"] := "M"
	keyAttribute["C11"] := "M"
	keyAttribute["C12"] := "M"
	keyAttribute["C13"] := "X"	; Enter
	keyAttribute["B01"] := "M"
	keyAttribute["B02"] := "M"
	keyAttribute["B03"] := "M"
	keyAttribute["B04"] := "M"
	keyAttribute["B05"] := "M"
	keyAttribute["B06"] := "M"
	keyAttribute["B07"] := "M"
	keyAttribute["B08"] := "M"
	keyAttribute["B09"] := "M"
	keyAttribute["B10"] := "M"
	keyAttribute["B11"] := "M"
	keyAttribute["A00"] := "X"	; LCtrl
	keyAttribute["A01"] := "L"
	keyAttribute["A02"] := "X"	; Space
	keyAttribute["A03"] := "R"
	keyAttribute["A04"] := "X"	; カタカナひらがな
	keyAttribute["A05"] := "X"	; Rctrl
	return keyAttribute
}

MakeKeyState() {
	keyState := Object()
	keyState["E00"] := 0	; 半角/全角
	keyState["E01"] := 0
	keyState["E02"] := 0
	keyState["E03"] := 0
	keyState["E04"] := 0
	keyState["E05"] := 0
	keyState["E06"] := 0
	keyState["E07"] := 0
	keyState["E08"] := 0
	keyState["E09"] := 0
	keyState["E10"] := 0
	keyState["E11"] := 0
	keyState["E12"] := 0
	keyState["E13"] := 0
	keyState["E14"] := 0	; Backspace
	keyState["D00"] := 0	; Tab
	keyState["D01"] := 0
	keyState["D02"] := 0
	keyState["D03"] := 0
	keyState["D04"] := 0
	keyState["D05"] := 0
	keyState["D06"] := 0
	keyState["D07"] := 0
	keyState["D08"] := 0
	keyState["D09"] := 0
	keyState["D10"] := 0
	keyState["D11"] := 0
	keyState["D12"] := 0
	keyState["C01"] := 0
	keyState["C02"] := 0
	keyState["C03"] := 0
	keyState["C04"] := 0
	keyState["C05"] := 0
	keyState["C06"] := 0
	keyState["C07"] := 0
	keyState["C08"] := 0
	keyState["C09"] := 0
	keyState["C10"] := 0
	keyState["C11"] := 0
	keyState["C12"] := 0
	keyState["C13"] := 0	; Enter
	keyState["B01"] := 0
	keyState["B02"] := 0
	keyState["B03"] := 0
	keyState["B04"] := 0
	keyState["B05"] := 0
	keyState["B06"] := 0
	keyState["B07"] := 0
	keyState["B08"] := 0
	keyState["B09"] := 0
	keyState["B10"] := 0
	keyState["B11"] := 0
	keyState["A00"] := 0	;LCtrl
	keyState["A01"] := 0
	keyState["A02"] := 0	; Space
	keyState["A03"] := 0
	keyState["A04"] := 0	; カタカナひらがな
	keyState["A05"] := 0	; RCtrl
	return keyState
}
