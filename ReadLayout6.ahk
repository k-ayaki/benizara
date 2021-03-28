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

	_colhash := Object()
	_colhash[1] := "E"
	_colhash[2] := "D"
	_colhash[3] := "C"
	_colhash[4] := "B"
	_colhash[5] := "A"
	
	_rowhash := Object()
	_rowhash[0] := "00"
	_rowhash[1] := "01"
	_rowhash[2] := "02"
	_rowhash[3] := "03"
	_rowhash[4] := "04"
	_rowhash[5] := "05"
	_rowhash[6] := "06"
	_rowhash[7] := "07"
	_rowhash[8] := "08"
	_rowhash[9] := "09"
	_rowhash[10]:= "10"
	_rowhash[11]:= "11"
	_rowhash[12]:= "12"
	_rowhash[13]:= "13"
	_rowhash[14]:= "14"
	_rowhash[15]:= "15"
	
	layoutAry := "E01,E02,E03,E04,E05,E06,E07,E08,E09,E10,E11,E12,E13"
	layoutAry := layoutAry . ",D01,D02,D03,D04,D05,D06,D07,D08,D09,D10,D11,D12"
	layoutAry := layoutAry . ",C01,C02,C03,C04,C05,C06,C07,C08,C09,C10,C11,C12"
	layoutAry := layoutAry . ",B01,B02,B03,B04,B05,B06,B07,B08,B09,B10,B11"
	layoutArys := StrSplit(layoutAry,",")
	roma3hash := MakeRoma3Hash()
	layout2Hash := MakeLayout2Hash()
	z2hHash := MakeZ2hHash()
	vkeyHash := MakeVkeyHash()
	layoutPosHash := MakeLayoutPosHash()
	fkeyPosHash := MakefkeyPosHash()
	fkeyCodeHash := MakefkeyCodeHash()
	CodeNameHash := MakeCodeNameHash()
	kanaHash := MakeKanaHash()
	GuiLayoutHash := MakeGuiLayoutHash()
	code2Pos := MakeCode2Pos()
	lpos2Mode := MakeLpos2ModeHash()
	name2vkey := MakeName2vkeyHash()

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
	keyAttribute2 := MakeKeyAttribute2Hash()
	keyState := MakeKeyState()
	keyNameHash := MakeKeyNameHash()
	kLabel := MakeKeyLabelHash()
	g_layoutName := ""
	g_layoutVersion := ""
	LF := Object()
	LF["ANN"] := 0
	LF["ALN"] := 0
	LF["ARN"] := 0
	LF["A1N"] := 0
	LF["A2N"] := 0
	LF["A3N"] := 0
	LF["A4N"] := 0

	LF["ANK"] := 0
	LF["ALK"] := 0
	LF["ARK"] := 0
	LF["A1K"] := 0
	LF["A2K"] := 0
	LF["A3K"] := 0
	LF["A4K"] := 0

	LF["RNN"] := 0
	LF["RLN"] := 0
	LF["RRN"] := 0
	LF["R1N"] := 0
	LF["R2N"] := 0
	LF["R3N"] := 0
	LF["R4N"] := 0

	LF["RNK"] := 0
	LF["RLK"] := 0
	LF["RRK"] := 0
	LF["R1K"] := 0
	LF["R2K"] := 0
	LF["R3K"] := 0
	LF["R4K"] := 0
	loop,4
	{
		LF["ANN" . _colhash[A_Index]] := ""
		LF["ALN" . _colhash[A_Index]] := ""
		LF["ARN" . _colhash[A_Index]] := ""
		LF["A1N" . _colhash[A_Index]] := ""
		LF["A2N" . _colhash[A_Index]] := ""

		LF["ANK" . _colhash[A_Index]] := ""
		LF["ALK" . _colhash[A_Index]] := ""
		LF["ARK" . _colhash[A_Index]] := ""
		LF["A1K" . _colhash[A_Index]] := ""
		LF["A2K" . _colhash[A_Index]] := ""

		LF["RNN" . _colhash[A_Index]] := ""
		LF["RLN" . _colhash[A_Index]] := ""
		LF["RRN" . _colhash[A_Index]] := ""
		LF["R1N" . _colhash[A_Index]] := ""
		LF["R2N" . _colhash[A_Index]] := ""

		LF["RNK" . _colhash[A_Index]] := ""
		LF["RLK" . _colhash[A_Index]] := ""
		LF["RRK" . _colhash[A_Index]] := ""
		LF["R1K" . _colhash[A_Index]] := ""
		LF["R2K" . _colhash[A_Index]] := ""
	}
	; デフォルトテーブル
	LF["ADNE"] := "１,２,３,４,５,６,７,８,９,０,ー,＾,￥"
	LF["ADND"] := "ｑ,ｗ,ｅ,ｒ,ｔ,ｙ,ｕ,ｉ,ｏ,ｐ,＠,［"
	LF["ADNC"] := "ａ,ｓ,ｄ,ｆ,ｇ,ｈ,ｊ,ｋ,ｌ,；,：,］"
	LF["ADNB"] := "ｚ,ｘ,ｃ,ｖ,ｂ,ｎ,ｍ,，,．,／,￥"
	SetkLabel("ANN","ADN")

	LF["ADKE"] := "！,”,＃,＄,％,＆,’, （,）,無,＝,～,｜"
	LF["ADKD"] := "Ｑ,Ｗ,Ｅ,Ｒ,Ｔ,Ｙ,Ｕ,Ｉ,Ｏ,Ｐ,‘,｛"
	LF["ADKC"] := "Ａ,Ｓ,Ｄ,Ｆ,Ｇ,Ｈ,Ｊ,Ｋ,Ｌ,＋,＊,｝"
	LF["ADKB"] := "Ｚ,Ｘ,Ｃ,Ｖ,Ｂ,Ｎ,Ｍ,＜,＞,？,＿"
	SetkLabel("ANK","ADK")
	
	; NULLテーブル
	LF["NULE"] := "　,　,　,　,　,　,　,　,　,　,　,　,　"
	LF["NULD"] := "　,　,　,　,　,　,　,　,　,　,　,　"
	LF["NULC"] := "　,　,　,　,　,　,　,　,　,　,　,　"
	LF["NULB"] := "　,　,　,　,　,　,　,　,　,　,　"
	return


;----------------------------------------------------------------------
;	各モードのレイアウトを処理
;----------------------------------------------------------------------
SetkLabel(_modeDst, _modeSrc)
{
	global LF, kLabel, _rowhash

	_col := "E"
	org := StrSplit(LF[_modeSrc . "E"],",")
	loop, % org.MaxIndex()
	{
		kLabel[_modeDst . _col . _rowhash[A_Index]] := org[A_Index]
	}
	_col := "D"
	org := StrSplit(LF[_modeSrc . "D"],",")
	loop, % org.MaxIndex()
	{
		kLabel[_modeDst . _col . _rowhash[A_Index]] := org[A_Index]
	}
	_col := "C"
	org := StrSplit(LF[_modeSrc . "C"],",")
	loop, % org.MaxIndex()
	{
		kLabel[_modeDst . _col . _rowhash[A_Index]] := org[A_Index]
	}
	_col := "B"
	org := StrSplit(LF[_modeSrc . "B"],",")
	loop, % org.MaxIndex()
	{
		kLabel[_modeDst . _col . _rowhash[A_Index]] := org[A_Index]
	}
	return
}
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
	_Section := ""
	_lpos := ""
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
	    	_line2 := Trim(_line, OmitChars = " `t`n`r")
	    }
	    if(StrLen(_line2) > 0)
		{
			if(SubStr(_line2,1,1)=="[" && SubStr(_line2,StrLen(_line2),1)=="]") {
				_Section := _line2
			}
			if(SubStr(_line2,1,1)=="<" && SubStr(_line2,StrLen(_line2),1)==">") {
				_Section := _line2
			}
			if(layout2Hash[_line2] != "") {
				_mode := layout2Hash[_line2]
				_lpos := ""
				if(_mode <> "")
				{
					_mline := 1
				}
				continue
			}
			if(code2Pos[_line2] != "") {
				_lpos := code2Pos[_line2]
				_mode := ""
				if(_lpos <> "")
				{
					_mline := 1
				}
				continue
			}
			if(_mode <> "") 
			{
				if _mline between 1 and 4
				{
					LF[_mode . _colhash[_mline]] := _line2
				}
				_mline += 1
				if(_mline > 4)
				{
					GoSub, Mode2Key
					if(_error <> "")
					{
						_Section := ""
						_mode := ""
						_lpos := ""
						return
					}
					_Section := ""
					_mode := ""
					_lpos := ""
				}
				continue
			}
			if(_lpos <> "") {
				if _mline between 1 and 4
				{
					LF[_lpos . _colhash[_mline]] := _line2
				}
				_mline += 1
				if(_mline > 4)
				{
					GoSub, Mode3Key
					if(_error <> "")
					{
						_Section := ""
						_mode := ""
						_lpos := ""
						return
					}
					_Section := ""
					_mode := ""
					_lpos := ""
				}
				continue
			}

			if(_Section == "[配列]")
			{
				cpos2 := Instr(_line2,"=")
				org := StrSplit(_line2,"=")
				if(org.MaxIndex() == 2)
				{
					if(org[1]=="名称")
					{
						g_layoutName := org[2]
					}
					else
					if(org[1]=="バージョン")
					{
						g_layoutVersion := org[2]
					}
				}
				continue
			}
			else
			if(_Section == "[機能キー]")
			{
				cpos2 := Instr(_line2,",")
				org := StrSplit(_line2,",")
				if(org.MaxIndex() == 2)
				{
					_layoutPos := fkeyPosHash[org[1]]
					_code := fkeyCodeHash[org[2]]
					if(_layoutPos != "" && _code != "") {
						keyNameHash[_layoutPos] := _code
						kLabel[_layoutPos] := CodeNameHash[_code]
					}
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
		_error := _Section . "の１段目にエラーがあります。要素数が" . org.MaxIndex() . "です。"
		return
	}
	Gosub, SetKeyTable
	if(_mode = "ANN")
		Gosub, SetAlphabet
	
	_col := "D"
	org := StrSplit(LF[_mode . "D"],",")
	if(org.MaxIndex() <> 12)
	{
		_error := _Section . "の２段目にエラーがあります。要素数が" . org.MaxIndex() . "です。"
		return
	}
	Gosub, SetKeyTable
	if(_mode = "ANN")
		Gosub, SetAlphabet
	
	_col := "C"
	org := StrSplit(LF[_mode . "C"],",")
	if(org.MaxIndex() <> 12)
	{
		_error := _Section . "の３段目にエラーがあります。要素数が" . org.MaxIndex() . "です。"
		return
	}
	Gosub, SetKeyTable
	if(_mode = "ANN")
		Gosub, SetAlphabet

	_col := "B"
	org := StrSplit(LF[_mode . "B"],",")
	if(org.MaxIndex() <> 11)
	{
		_error := _Section . "の４段目にエラーがあります。要素数が" . org.MaxIndex() . "です。"
		return
	}
	Gosub, SetKeyTable
	if(_mode = "ANN")
		Gosub, SetAlphabet
	return

;----------------------------------------------------------------------
;	文字の同時打鍵のレイアウトを処理
;----------------------------------------------------------------------
Mode3Key:
	_mode2 := lpos2Mode[_lpos]
	if(_mode2!="") 
		LF[_mode2] := 1
	_col := "E"
	org := StrSplit(LF[_lpos . "E"],",")
	if(org.MaxIndex() <> 13)
	{
		_error := _Section . "の１段目にエラーがあります。要素数が" . org.MaxIndex() . "です。"
		return
	}
	Gosub, SetSimulKeyTable
	
	_col := "D"
	org := StrSplit(LF[_lpos . "D"],",")
	if(org.MaxIndex() <> 12)
	{
		_error := _Section . "の２段目にエラーがあります。要素数が" . org.MaxIndex() . "です。"
		return
	}
	Gosub, SetSimulKeyTable
	
	_col := "C"
	org := StrSplit(LF[_lpos . "C"],",")
	if(org.MaxIndex() <> 12)
	{
		_error := _Section . "の３段目にエラーがあります。要素数が" . org.MaxIndex() . "です。"
		return
	}
	Gosub, SetSimulKeyTable

	_col := "B"
	org := StrSplit(LF[_lpos . "B"],",")
	if(org.MaxIndex() <> 11)
	{
		_error := _Section . "の４段目にエラーがあります。要素数が" . org.MaxIndex() . "です。"
		return
	}
	Gosub, SetSimulKeyTable
	return

;----------------------------------------------------------------------
;	レイアウトファイルの設定
;----------------------------------------------------------------------

SetLayoutProperty:
	ShiftMode := Object()
	ShiftMode["A"] := ""
	if(LF["ANN"]==1 && LF["ALN"]==1 && LF["ARN"]==1 && LF["ANK"]==1)
	{
		ShiftMode["A"] := "親指シフト"
		keyAttribute2["AA01"] := "L"
		keyAttribute2["AA03"] := "R"
		
		if(LF["ALK"] == 0) {
			CopyKeyTable("ALK", "ANK")
			_mode := "ALK"
			_col := "E"
			org := StrSplit(LF[_mode . "E"],",")
			Gosub, SetKeyTable
			_col := "D"
			org := StrSplit(LF[_mode . "D"],",")
			Gosub, SetKeyTable
			_col := "C"
			org := StrSplit(LF[_mode . "C"],",")
			Gosub, SetKeyTable
			_col := "B"
			org := StrSplit(LF[_mode . "B"],",")
			Gosub, SetKeyTable
		}
		if(LF["ARK"] == 0) {
			CopyKeyTable("ARK", "ANK")
			_mode := "ARK"
			_col := "E"
			org := StrSplit(LF[_mode . "E"],",")
			Gosub, SetKeyTable
			_col := "D"
			org := StrSplit(LF[_mode . "D"],",")
			Gosub, SetKeyTable
			_col := "C"
			org := StrSplit(LF[_mode . "C"],",")
			Gosub, SetKeyTable
			_col := "B"
			org := StrSplit(LF[_mode . "B"],",")
			Gosub, SetKeyTable
		}
	} else 
	if(LF["ANN"]==1 && (LF["A1N"]==1 || LF["A2N"]==1) && LF["ANK"]==1 (LF["A1K"]==1 || LF["A2K"]==1)) 
	{
		ShiftMode["A"] := "プレフィックスシフト"
	}
	else
	if(LF["ANN"]==1 && (LF["A3N"]==1 || LF["A4N"]==1) && LF["ANK"]==1 (LF["A3K"]==1 || LF["A4K"]==1)) 
	{
		ShiftMode["A"] := "中指シフト"
	}
	else
	if(LF["ANN"]==1 && LF["ALN"]==0 && LF["ARN"]==0 && LF["ANK"]==1 && LF["ALK"]==0 && LF["ARK"]==0)
	{
		ShiftMode["A"] := "小指シフト"
	}
	ShiftMode["R"] := ""
	if(LF["RNN"]==1 && LF["RRN"]==1 && LF["RLN"]==1 && LF["RNK"]==1)
	{
		ShiftMode["R"] := "親指シフト"
		keyAttribute2["RA01"] := "L"
		keyAttribute2["RA03"] := "R"  
		
		if(LF["RLK"] == 0) {
			CopyKeyTable("RLK", "RNK")
			_mode := "ALK"
			_col := "E"
			org := StrSplit(LF[_mode . "E"],",")
			Gosub, SetKeyTable
			_col := "D"
			org := StrSplit(LF[_mode . "D"],",")
			Gosub, SetKeyTable
			_col := "C"
			org := StrSplit(LF[_mode . "C"],",")
			Gosub, SetKeyTable
			_col := "B"
			org := StrSplit(LF[_mode . "B"],",")
			Gosub, SetKeyTable
		}
		if(LF["RRK"] == 0) {
			CopyKeyTable("RRK", "RNK")
			_mode := "ARK"
			_col := "E"
			org := StrSplit(LF[_mode . "E"],",")
			Gosub, SetKeyTable
			_col := "D"
			org := StrSplit(LF[_mode . "D"],",")
			Gosub, SetKeyTable
			_col := "C"
			org := StrSplit(LF[_mode . "C"],",")
			Gosub, SetKeyTable
			_col := "B"
			org := StrSplit(LF[_mode . "B"],",")
			Gosub, SetKeyTable
		}
	} else
	if(LF["RNN"]==1 && (LF["R1N"]==1 || LF["R2N"]==1) && LF["RNK"]==1 && (LF["R1K"]==1 || LF["R2K"]==1))
	{
		ShiftMode["R"] := "プレフィックスシフト"
	}
	else
	if(LF["RNN"]==1 && (LF["R3N"]==1 || LF["R4N"]==1) && LF["RNK"]==1)
	{
		ShiftMode["R"] := "中指シフト"
	}
	else
	if(LF["RNN"]==1 && LF["RRN"]==0 && LF["RLN"]==0 && LF["RNK"]==1 && LF["RLK"]==0 && LF["RRK"]==0)
	{
		ShiftMode["R"] := "小指シフト"
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
		_row2 := _rowhash[A_Index]
		_lpos2 := _col . _row2

		; 月配列などのプレフィックスシフトキー
		if(org[A_Index] == " 1" || org[A_Index] == " 2")
		{
			kdn[_mode . _lpos2] := ""
			kup[_mode . _lpos2] := ""
			if(_mode = "RNN")
			{
				keyAttribute2["R" . _lpos2] := SubStr(org[A_Index],2,1)
				kLabel[_mode . _lpos2] := SubStr(org[A_Index],2,1)
			} else
			if(_mode = "ANN")
			{
				keyAttribute2["A" . _lpos2] := SubStr(org[A_Index],2,1)
				kLabel[_mode . _lpos2] := SubStr(org[A_Index],2,1)
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
			kdn[_mode . _lpos2] := _qstr
			kup[_mode . _lpos2] := ""
			continue
		}
		; vkeyならば vkeyとして登録
		_vk := ConvVkey(org[A_Index])
		if(_vk <> "")
		{
			kLabel[_mode . _lpos2] := _vk
			kdn[_mode . _lpos2] := "{" . _vk . "}"
			kup[_mode . _lpos2] := ""
			continue
		}
		; かな文字はローマ字に変換
		_aStr := kana2Romaji(org[A_Index])
		
		; 送信形式に変換
		GenSendStr2(_aStr, _down, _up)
		if( _down <> "")
		{
			if(SubStr(_mode,1,1)=="R")
			{
				kLabel[_mode . _lpos2] := Romaji2Kana(org[A_Index])
			}
			else
			{
				kLabel[_mode . _lpos2] := org[A_Index]
			}
			kdn[_mode . _lpos2] := _down
			kup[_mode . _lpos2] := _up
		}
		continue
	}
	return

;----------------------------------------------------------------------
;	ローマ字＋文字同時打鍵のときのキーダウン・キーアップの際に送信する内容を作成
;----------------------------------------------------------------------
SetSimulKeyTable:
	loop, % org.MaxIndex()
	{
		_row2 := _rowhash[A_Index]
		_lpos2 := _col . _row2

		; 引用符つき文字列を登録・・・2020年10月以降のWindows10ではダメになった
		_qstr := QuotedStr(org[A_Index])
		if(_error <> "")
		{
			break
		}
		if(_qstr <> "")
		{
			kdn[_lpos . _lpos2] := _qstr
			kup[_lpos . _lpos2] := ""
			kdn[_lpos2 . _lpos] := _qstr
			kup[_lpos2 . _lpos] := ""
			keyAttribute2["R" . _lpos2] := "S"
			keyAttribute2["R" . _lpos]  := "S"
			continue
		}
		; vkeyならば vkeyとして登録
		_vk := ConvVkey(org[A_Index])
		if(_vk <> "")
		{
			kLabel[_lpos . _lpos2] := _vk
			kLabel[_lpos2 . _lpos] := kLabel[_lpos . _lpos2]
			if(_mode2 != "") 
				KLabel[_mode2 . _lpos2] := _vk
			kdn[_lpos . _lpos2] := "{" . _vk . "}"
			kup[_lpos . _lpos2] := ""
			kdn[_lpos2 . _lpos] := "{" . _vk . "}"
			kup[_lpos2 . _lpos] := ""
			keyAttribute2["R" . _lpos2] := "S"
			keyAttribute2["R" . _lpos]  := "S"
			continue
		}
		; かな文字はローマ字に変換
		_aStr := kana2Romaji(org[A_Index])
		
		; 送信形式に変換
		GenSendStr2(_aStr, _down, _up)
		if( _down <> "")
		{
			kLabel[_lpos . _lpos2] := Romaji2Kana(org[A_Index])
			kLabel[_lpos2 . _lpos] := kLabel[_lpos . _lpos2]
			if(_mode2 != "") 
				KLabel[_mode2  . _lpos2] := Romaji2Kana(org[A_Index])
			kdn[_lpos . _lpos2] := _down
			kup[_lpos . _lpos2] := _up
			kdn[_lpos2 . _lpos] := _down
			kup[_lpos2 . _lpos] := _up
			keyAttribute2["R" . _lpos2] := "S"
			keyAttribute2["R" . _lpos]  := "S"
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
		_row2 := _rowhash[A_Index]
		mdn[_mode . _col . _row2] := kdn[_mode . _col . _row2]
		mup[_mode . _col . _row2] := kup[_mode . _col . _row2]
	}
	return
	
;----------------------------------------------------------------------
;	キーテーブルの複写
;----------------------------------------------------------------------
CopyKeyTable(_mddst, _mdsrc)
{
	global LF, _rowhash

	if(LF[_mdsrc] == 0) 
	{
		return
	}
	LF[_mddst] := 1
	LF[_mddst . "E"] := LF[_mdsrc . "E"]
	LF[_mddst . "D"] := LF[_mdsrc . "D"]
	LF[_mddst . "C"] := LF[_mdsrc . "C"]
	LF[_mddst . "B"] := LF[_mdsrc . "B"]
	LF[_mddst . "A"] := LF[_mdsrc . "A"]
	return
}
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
	global z2hHash

	vOut := ""
	_aQuo2 := ""
	loop,Parse, aQuo
	{
		_aQuo2 := _aQuo2 . z2hHash[A_LoopField]
	}
	_aQuo3 := ""
	loop,Parse, _aQuo2
	{
		vOut := vOut . "{ASC " . Asc(A_LoopField) . "}"
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
; ローマ字を仮名に変換する
; 引数　：aStr：対応するキー入力
; 戻り値：仮名に変換した後
;----------------------------------------------------------------------
Romaji2Kana(aStr)
{
	global kanaHash
	_c2 := kanaHash[aStr]
	if(_c2 <> "")
	{
		return _c2
	}
	return aStr
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
MakeLayout2Hash() {
	Hash := Object()
	Hash["[英数シフト無し]"]           := "ANN"
	Hash["[英数左親指シフト]"]         := "ALN"
	Hash["[英数右親指シフト]"]         := "ARN"
	Hash["[英数小指シフト]"]           := "ANK"
	Hash["[英数小指左親指シフト]"]     := "ALK"
	Hash["[英数小指右親指シフト]"]     := "ARK"
	Hash["[ローマ字シフト無し]"]       := "RNN"
	Hash["[ローマ字左親指シフト]"]     := "RLN"
	Hash["[ローマ字右親指シフト]"]     := "RRN"
	Hash["[ローマ字小指シフト]"]       := "RNK"
	Hash["[ローマ字小指左親指シフト]"] := "RRK"
	Hash["[ローマ字小指右親指シフト]"] := "RLK"

	Hash["[英数１プリフィックスシフト]"]         := "A1N"	; for 月配列
	Hash["[英数２プリフィックスシフト]"]         := "A2N"	; for 月配列
	Hash["[英数小指１プリフィックスシフト]"]     := "A1K"	; for 月配列
	Hash["[英数小指２プリフィックスシフト]"]     := "A2K"	; for 月配列	
	Hash["[ローマ字１プリフィックスシフト]"]     := "R1N"	; for 月配列
	Hash["[ローマ字２プリフィックスシフト]"]     := "R2N"	; for 月配列
	Hash["[ローマ字小指１プリフィックスシフト]"] := "R1K"	; for 月配列
	Hash["[ローマ字小指２プリフィックスシフト]"] := "R2K"	; for 月配列	
	; やまぶき互換
	Hash["[1英数シフト無し]"]     := "A1N"	; for 月配列
	Hash["[2英数シフト無し]"]     := "A2N"	; for 月配列
	Hash["[1英数小指シフト]"]     := "A1K"	; for 月配列
	Hash["[2英数小指シフト]"]     := "A2K"	; for 月配列	
	Hash["[1ローマ字シフト無し]"] := "R1N"	; for 月配列
	Hash["[2ローマ字シフト無し]"] := "R2N"	; for 月配列
	Hash["[1ローマ字小指シフト]"] := "R1K"	; for 月配列
	Hash["[2ローマ字小指シフト]"] := "R2K"	; for 月配列	

	return Hash
}

MakeGuiLayoutHash() {
	Hash := Object()
	Hash["A"] := "英数配列"
	Hash["R"] := "ローマ字配列"
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
	hash["ゐ"] := "ｗｙｉ"
	hash["ゑ"] := "ｗｙｅ"
	hash["を"] := "ｗｏ"
	hash["ん"] := "ｎｎ"
	hash["ゔ"] := "ｖｕ"
	hash["ヴ"] := "ｖｕ"
	hash["ゕ"] := "ｌｋａ"
	hash["ゖ"] := "ｌｋｅ"
	return hash
}

;----------------------------------------------------------------------
; かな変換用ハッシュを生成
; 戻り値：モード名
;----------------------------------------------------------------------
MakeKanaHash()
{
	hash := Object()
	hash["ｌａ"]   := "ぁ"
	hash["ｘａ"]   := "ぁ"
	hash["ａ"]     := "あ"
	hash["ｌｉ"]   := "ぃ"
	hash["ｘｉ"]   := "ぃ"
	hash["ｉ"]     := "い"
	hash["ｌｕ"]   := "ぅ"
	hash["ｘｕ"]   := "ぅ"
	hash["ｕ"]     := "う"
	hash["ｌｅ"]   := "ぇ"
	hash["ｘｅ"]   := "ぇ"
	hash["ｅ"]     := "え"
	hash["ｌｏ"]   := "ぉ"
	hash["ｘｏ"]   := "ぉ"
	hash["ｏ"]     := "お"
	hash["ｋａ"]   := "か"
	hash["ｇａ"]   := "が"
	hash["ｋｉ"]   := "き"
	hash["ｇｉ"]   := "ぎ"
	hash["ｋｕ"]   := "く"
	hash["ｇｕ"]   := "ぐ"
	hash["ｋｅ"]   := "け"
	hash["ｇｅ"]   := "げ"
	hash["ｋｏ"]   := "こ"
	hash["ｇｏ"]   := "ご"
	hash["ｓａ"]   := "さ"
	hash["ｚａ"]   := "ざ"
	hash["ｓｉ"]   := "し"
	hash["ｚｉ"]   := "じ"
	hash["ｓｕ"]   := "す"
	hash["ｚｕ"]   := "ず"
	hash["ｓｅ"]   := "せ"
	hash["ｚｅ"]   := "ぜ"
	hash["ｓｏ"]   := "そ"
	hash["ｚｏ"]   := "ぞ"
	hash["ｔａ"]   := "た"
	hash["ｄａ"]   := "だ"
	hash["ｔｉ"]   := "ち"
	hash["ｄｉ"]   := "ぢ"
	hash["ｌｔｕ"] := "っ"
	hash["ｘｔｕ"] := "っ"
	hash["ｔｕ"]   := "つ"
	hash["ｄｕ"]   := "づ"
	hash["ｔｅ"]   := "て"
	hash["ｄｅ"]   := "で"
	hash["ｔｏ"]   := "と"
	hash["ｄｏ"]   := "ど"
	hash["ｎａ"]   := "な"
	hash["ｎｉ"]   := "に"
	hash["ｎｕ"]   := "ぬ"
	hash["ｎｅ"]   := "ね"
	hash["ｎｏ"]   := "の"
	hash["ｈａ"]   := "は"
	hash["ｂａ"]   := "ば"
	hash["ｐａ"]   := "ぱ"
	hash["ｈｉ"]   := "ひ"
	hash["ｂｉ"]   := "び"
	hash["ｐｉ"]   := "ぴ"
	hash["ｆｕ"]   := "ふ"
	hash["ｂｕ"]   := "ぶ"
	hash["ｐｕ"]   := "ぷ"
	hash["ｈｅ"]   := "へ"
	hash["ｂｅ"]   := "べ"
	hash["ｐｅ"]   := "ぺ"
	hash["ｈｏ"]   := "ほ"
	hash["ｂｏ"]   := "ぼ"
	hash["ｐｏ"]   := "ぽ"
	hash["ｍａ"]   := "ま"
	hash["ｍｉ"]   := "み"
	hash["ｍｕ"]   := "む"
	hash["ｍｅ"]   := "め"
	hash["ｍｏ"]   := "も"
	hash["ｌｙａ"] := "ゃ"
	hash["ｘｙａ"] := "ゃ"
	hash["ｙａ"]   := "や"
	hash["ｌｙｕ"] := "ゅ"
	hash["ｘｙｕ"] := "ゅ"
	hash["ｙｕ"]   := "ゆ"
	hash["ｌｙｏ"] := "ょ"
	hash["ｘｙｏ"] := "ょ"
	hash["ｙｏ"]   := "よ"
	hash["ｒａ"]   := "ら"
	hash["ｒｉ"]   := "り"
	hash["ｒｕ"]   := "る"
	hash["ｒｅ"]   := "れ"
	hash["ｒｏ"]   := "ろ"
	hash["ｌｗａ"] := "ゎ"
	hash["ｘｗａ"] := "ゎ"
	hash["ｗａ"]   := "わ"
	hash["ｗｉ"]   := "うぃ"
	hash["ｗｅ"]   := "うぇ"
	hash["ｗｏ"]   := "を"
	hash["ｎｎ"]   := "ん"
	hash["ｖｕ"]   := "ゔ"
	hash["ｖｕ"]   := "ヴ"
	hash["ｌｋａ"] := "ゕ"
	hash["ｘｋｅ"] := "ゖ"
	hash["ｌｋａ"] := "ゕ"
	hash["ｘｋｅ"] := "ゖ"

	hash["ｆａ"] := "ふぁ"
	hash["ｆｉ"] := "ふぃ"
	hash["ｆｅ"] := "ふぇ"
	hash["ｆｅ"] := "ふぇ"
	hash["ｆｏ"] := "ふぉ"
	hash["ｗｙｉ"] := "ゐ"
	hash["ｗｙｅ"] := "ゑ"

	hash["ｋｙａ"] := "きゃ"
	hash["ｋｙｉ"] := "きぃ"
	hash["ｋｙｕ"] := "きゅ"
	hash["ｋｙｅ"] := "きぇ"
	hash["ｋｙｏ"] := "きょ"

	hash["ｇｙａ"] := "ぎゃ"
	hash["ｇｙｉ"] := "ぎぃ"
	hash["ｇｙｕ"] := "ぎゅ"
	hash["ｇｙｅ"] := "ぎぇ"
	hash["ｇｙｏ"] := "ぎょ"

	hash["ｓｙａ"] := "しゃ"
	hash["ｓｙｉ"] := "しぃ"
	hash["ｓｙｕ"] := "しゅ"
	hash["ｓｙｅ"] := "しぇ"
	hash["ｓｙｏ"] := "しょ"

	hash["ｓｈａ"] := "しゃ"
	hash["ｓｈｉ"] := "し"
	hash["ｓｈｕ"] := "しゅ"
	hash["ｓｈｅ"] := "しぇ"
	hash["ｓｈｏ"] := "しょ"
	
	hash["ｚｙａ"] := "じゃ"
	hash["ｚｙｉ"] := "じぃ"
	hash["ｚｙｕ"] := "じゅ"
	hash["ｚｙｅ"] := "じぇ"
	hash["ｚｙｏ"] := "じょ"

	hash["ｔｈａ"] := "てゃ"
	hash["ｔｈｉ"] := "てぃ"
	hash["ｔｈｕ"] := "てゅ"
	hash["ｔｈｅ"] := "てぇ"
	hash["ｔｈｏ"] := "てょ"

	hash["ｔｙａ"] := "ちゃ"
	hash["ｔｙｉ"] := "ちぃ"
	hash["ｔｙｕ"] := "ちゅ"
	hash["ｔｙｅ"] := "ちぇ"
	hash["ｔｙｏ"] := "ちょ"

	hash["ｎｙａ"] := "にゃ"
	hash["ｎｙｉ"] := "にぃ"
	hash["ｎｙｕ"] := "にゅ"
	hash["ｎｙｅ"] := "にぇ"
	hash["ｎｙｏ"] := "にょ"

	hash["ｄｈａ"] := "でゃ"
	hash["ｄｈｉ"] := "でぃ"
	hash["ｄｈｕ"] := "でゅ"
	hash["ｄｈｅ"] := "でぇ"
	hash["ｄｈｏ"] := "でょ"

	hash["ｂｙａ"] := "びゃ"
	hash["ｂｙｉ"] := "びぃ"
	hash["ｂｙｕ"] := "びゅ"
	hash["ｂｙｅ"] := "びぇ"
	hash["ｂｙｏ"] := "びょ"

	hash["ｈｙａ"] := "ひゃ"
	hash["ｈｙｉ"] := "ひぃ"
	hash["ｈｙｕ"] := "ひゅ"
	hash["ｈｙｅ"] := "ひぇ"
	hash["ｈｙｏ"] := "ひょ"

	hash["ｐｙａ"] := "ぴゃ"
	hash["ｐｙｉ"] := "ぴぃ"
	hash["ｐｙｕ"] := "ぴゅ"
	hash["ｐｙｅ"] := "ぴぇ"
	hash["ｐｙｏ"] := "ぴょ"

	hash["ｍｙａ"] := "みゃ"
	hash["ｍｙｉ"] := "みぃ"
	hash["ｍｙｕ"] := "みゅ"
	hash["ｍｙｅ"] := "みぇ"
	hash["ｍｙｏ"] := "みょ"

	hash["ｒｙａ"] := "りゃ"
	hash["ｒｙｉ"] := "りぃ"
	hash["ｒｙｕ"] := "りゅ"
	hash["ｒｙｅ"] := "りぇ"
	hash["ｒｙｏ"] := "りょ"

	return hash
}

;----------------------------------------------------------------------
;	キー名から処理関数に変換
;	M:文字キー
;	X:修飾キー
;	S:同時打鍵キー
;	L:左親指キー
;	R:右親指キー
;----------------------------------------------------------------------
MakeKeyAttribute2Hash() {
	keyAttribute2 := Object()
	keyAttribute2["AE00"] := "X"	; 半角/全角
	keyAttribute2["RE00"] := "X"	; 半角/全角
	keyAttribute2["AE01"] := "M"
	keyAttribute2["RE01"] := "M"
	keyAttribute2["AE02"] := "M"
	keyAttribute2["RE02"] := "M"
	keyAttribute2["AE03"] := "M"
	keyAttribute2["RE03"] := "M"
	keyAttribute2["AE04"] := "M"
	keyAttribute2["RE04"] := "M"
	keyAttribute2["AE05"] := "M"
	keyAttribute2["RE05"] := "M"
	keyAttribute2["AE06"] := "M"
	keyAttribute2["RE06"] := "M"
	keyAttribute2["AE07"] := "M"
	keyAttribute2["RE07"] := "M"
	keyAttribute2["AE08"] := "M"
	keyAttribute2["RE08"] := "M"
	keyAttribute2["AE09"] := "M"
	keyAttribute2["RE09"] := "M"
	keyAttribute2["AE10"] := "M"
	keyAttribute2["RE10"] := "M"
	keyAttribute2["AE11"] := "M"
	keyAttribute2["RE11"] := "M"
	keyAttribute2["AE12"] := "M"
	keyAttribute2["RE12"] := "M"
	keyAttribute2["AE13"] := "M"
	keyAttribute2["RE13"] := "M"
	keyAttribute2["AE14"] := "X"	; Backspace
	keyAttribute2["RE14"] := "X"	; Backspace
	keyAttribute2["AD00"] := "X"	; Tab
	keyAttribute2["RD00"] := "X"	; Tab
	keyAttribute2["AD01"] := "M"
	keyAttribute2["RD01"] := "M"
	keyAttribute2["AD02"] := "M"
	keyAttribute2["RD02"] := "M"
	keyAttribute2["AD03"] := "M"
	keyAttribute2["RD03"] := "M"
	keyAttribute2["AD04"] := "M"
	keyAttribute2["RD04"] := "M"
	keyAttribute2["AD05"] := "M"
	keyAttribute2["RD05"] := "M"
	keyAttribute2["AD06"] := "M"
	keyAttribute2["RD06"] := "M"
	keyAttribute2["AD07"] := "M"
	keyAttribute2["RD07"] := "M"
	keyAttribute2["AD08"] := "M"
	keyAttribute2["RD08"] := "M"
	keyAttribute2["AD09"] := "M"
	keyAttribute2["RD09"] := "M"
	keyAttribute2["AD10"] := "M"
	keyAttribute2["RD10"] := "M"
	keyAttribute2["AD11"] := "M"
	keyAttribute2["RD11"] := "M"
	keyAttribute2["AD12"] := "M"
	keyAttribute2["RD12"] := "M"
	keyAttribute2["AC01"] := "M"
	keyAttribute2["RC01"] := "M"
	keyAttribute2["AC02"] := "M"
	keyAttribute2["RC02"] := "M"
	keyAttribute2["AC03"] := "M"
	keyAttribute2["RC03"] := "M"
	keyAttribute2["AC04"] := "M"
	keyAttribute2["RC04"] := "M"
	keyAttribute2["AC05"] := "M"
	keyAttribute2["RC05"] := "M"
	keyAttribute2["AC06"] := "M"
	keyAttribute2["RC06"] := "M"
	keyAttribute2["AC07"] := "M"
	keyAttribute2["RC07"] := "M"
	keyAttribute2["AC08"] := "M"
	keyAttribute2["RC08"] := "M"
	keyAttribute2["AC09"] := "M"
	keyAttribute2["RC09"] := "M"
	keyAttribute2["AC10"] := "M"
	keyAttribute2["RC10"] := "M"
	keyAttribute2["AC11"] := "M"
	keyAttribute2["RC11"] := "M"
	keyAttribute2["AC12"] := "M"
	keyAttribute2["RC12"] := "M"
	keyAttribute2["AC13"] := "X"	; Enter
	keyAttribute2["RC13"] := "X"	; Enter
	keyAttribute2["AB01"] := "M"
	keyAttribute2["RB01"] := "M"
	keyAttribute2["AB02"] := "M"
	keyAttribute2["RB02"] := "M"
	keyAttribute2["AB03"] := "M"
	keyAttribute2["RB03"] := "M"
	keyAttribute2["AB04"] := "M"
	keyAttribute2["RB04"] := "M"
	keyAttribute2["AB05"] := "M"
	keyAttribute2["RB05"] := "M"
	keyAttribute2["AB06"] := "M"
	keyAttribute2["RB06"] := "M"
	keyAttribute2["AB07"] := "M"
	keyAttribute2["RB07"] := "M"
	keyAttribute2["AB08"] := "M"
	keyAttribute2["RB08"] := "M"
	keyAttribute2["AB09"] := "M"
	keyAttribute2["RB09"] := "M"
	keyAttribute2["AB10"] := "M"
	keyAttribute2["RB10"] := "M"
	keyAttribute2["AB11"] := "M"
	keyAttribute2["RB11"] := "M"
	keyAttribute2["AA00"] := "X"	; LCtrl
	keyAttribute2["RA00"] := "X"	; LCtrl
	keyAttribute2["AA01"] := "X"
	keyAttribute2["RA01"] := "X"
	keyAttribute2["AA02"] := "X"	; Space
	keyAttribute2["RA02"] := "X"	; Space
	keyAttribute2["AA03"] := "X"
	keyAttribute2["RA03"] := "X"
	keyAttribute2["AA04"] := "X"	; カタカナひらがな
	keyAttribute2["RA04"] := "X"	; カタカナひらがな
	keyAttribute2["AA05"] := "X"	; Rctrl
	keyAttribute2["RA05"] := "X"	; Rctrl
	return keyAttribute2
}

;----------------------------------------------------------------------
;	キー状態の連想配列
;----------------------------------------------------------------------
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

;----------------------------------------------------------------------
;	キー名をデフォルトのvkeyに変換
;----------------------------------------------------------------------
MakeVkeyHash()
{
	hash := Object()
	hash["E00"] := 0xF3		;半角／全角
	hash["E01"] := 0x31		;1
	hash["E02"] := 0x32		;2
	hash["E03"] := 0x33		;3
	hash["E04"] := 0x34		;4
	hash["E05"] := 0x35		;5
	hash["E06"] := 0x36		;6
	hash["E07"] := 0x37		;7
	hash["E08"] := 0x38		;8
	hash["E09"] := 0x39		;9
	hash["E10"] := 0x30		;0
	hash["E11"] := 0xBD		;-
	hash["E12"] := 0xDE		;^
	hash["E13"] := 0xDC		;\
	hash["E14"] := 0x08		;backspace

	hash["D00"] := 0x09		;tab
	hash["D01"] := 0x51		;q
	hash["D02"] := 0x57		;w
	hash["D03"] := 0x45		;e
	hash["D04"] := 0x52		;r
	hash["D05"] := 0x54		;t
	hash["D06"] := 0x59		;y
	hash["D07"] := 0x55		;u
	hash["D08"] := 0x49		;i
	hash["D09"] := 0x4F		;o
	hash["D10"] := 0x50		;p
	hash["D11"] := 0xC0		;@
	hash["D12"] := 0xDB		;[
	
	hash["C01"] := 0x41		;a
	hash["C02"] := 0x53		;s
	hash["C03"] := 0x44		;d
	hash["C04"] := 0x46		;f
	hash["C05"] := 0x47		;g
	hash["C06"] := 0x48		;h
	hash["C07"] := 0x4A		;j
	hash["C08"] := 0x4B		;k
	hash["C09"] := 0x4C		;l
	hash["C10"] := 0xBB		;;
	hash["C11"] := 0xBA		;:
	hash["C12"] := 0xDD		;]
	hash["C13"] := 0x0D		;enter

	hash["B01"] := 0x5A		;z
	hash["B02"] := 0x58		;x
	hash["B03"] := 0x43		;c
	hash["B04"] := 0x56		;v
	hash["B05"] := 0x42		;b
	hash["B06"] := 0x4E		;n
	hash["B07"] := 0x4D		;m
	hash["B08"] := 0xBC		;,
	hash["B09"] := 0xBE		;.
	hash["B10"] := 0xBF		;/
	hash["B11"] := 0xE2		;\
	
	hash["A00"] := 0xA2		;LCtrl
	hash["A01"] := 0x1D		;無変換
	hash["A02"] := 0x20		;スペース
	hash["A03"] := 0x1C		;変換
	hash["A04"] := 0xF2		;カタカナ/ひらがな
	hash["A05"] := 0xA3		;RCtrl
	return hash
}

;----------------------------------------------------------------------
;	キー名を配列位置に変換
;----------------------------------------------------------------------
MakeCode2Pos()
{
	hash := Object()
	hash["<1>"] := "E01"		;1
	hash["<2>"] := "E02"		;2
	hash["<3>"] := "E03"		;3
	hash["<4>"] := "E04"		;4
	hash["<5>"] := "E05"		;5
	hash["<6>"] := "E06"		;6
	hash["<7>"] := "E07"		;7
	hash["<8>"] := "E08"		;8
	hash["<9>"] := "E09"		;9
	hash["<0>"] := "E10"		;0
	hash["<->"] := "E11"		;-
	hash["<^>"] := "E12"		;^
	hash["<\>"] := "E13"		;\

	hash["<q>"] := "D01"		;q
	hash["<w>"] := "D02"		;w
	hash["<e>"] := "D03"		;e
	hash["<r>"] := "D04"		;r
	hash["<t>"] := "D05"		;t
	hash["<y>"] := "D06"		;y
	hash["<u>"] := "D07"		;u
	hash["<i>"] := "D08"		;i
	hash["<o>"] := "D09"		;o
	hash["<p>"] := "D10"		;p
	hash["<@>"] := "D11"		;@
	hash["<[>"] := "D12"		;[

	hash["<a>"] := "C01"		;a
	hash["<s>"] := "C02"		;s
	hash["<d>"] := "C03"		;d
	hash["<f>"] := "C04"		;f
	hash["<g>"] := "C05"		;g
	hash["<h>"] := "C06"		;h
	hash["<j>"] := "C07"		;j
	hash["<k>"] := "C08"		;k
	hash["<l>"] := "C09"		;l
	hash["<;>"] := "C10"		;;
	hash["<:>"] := "C11"		;:
	hash["<]>"] := "C12"		;]

	hash["<z>"] := "B01"		;z
	hash["<x>"] := "B02"		;x
	hash["<c>"] := "B03"		;c
	hash["<v>"] := "B04"		;v
	hash["<b>"] := "B05"		;b
	hash["<n>"] := "B06"		;n
	hash["<m>"] := "B07"		;m
	hash["<,>"] := "B08"		;,
	hash["<.>"] := "B09"		;.
	hash["</>"] := "B10"		;/
	hash["<\>"] := "B11"		;\
	return hash
}

;----------------------------------------------------------------------
;	キー名に変換
;----------------------------------------------------------------------
MakekeyNameHash()
{
	hash := Object()
	hash["E00"] := "sc029"		;半角／全角
	hash["E01"] := "1"
	hash["E02"] := "2"
	hash["E03"] := "3"
	hash["E04"] := "4"
	hash["E05"] := "5"
	hash["E06"] := "6"
	hash["E07"] := "7"
	hash["E08"] := "8"
	hash["E09"] := "9"
	hash["E10"] := "0"
	hash["E11"] := "-"
	hash["E12"] := "^"
	hash["E13"] := "\"
	hash["E14"] := "Backspace"

	hash["D00"] := "Tab"
	hash["D01"] := "q"
	hash["D02"] := "w"
	hash["D03"] := "e"
	hash["D04"] := "r"
	hash["D05"] := "t"
	hash["D06"] := "y"
	hash["D07"] := "u"
	hash["D08"] := "i"
	hash["D09"] := "o"
	hash["D10"] := "p"
	hash["D11"] := "@"
	hash["D12"] := "["
	
	hash["C01"] := "a"
	hash["C02"] := "s"
	hash["C03"] := "d"
	hash["C04"] := "f"
	hash["C05"] := "g"
	hash["C06"] := "h"
	hash["C07"] := "j"
	hash["C08"] := "k"
	hash["C09"] := "l"
	hash["C10"] := ";"
	hash["C11"] := ":"
	hash["C12"] := "]"
	hash["C13"] := "Enter"

	hash["B01"] := "z"
	hash["B02"] := "x"
	hash["B03"] := "c"
	hash["B04"] := "v"
	hash["B05"] := "b"
	hash["B06"] := "n"
	hash["B07"] := "m"
	hash["B08"] := ","
	hash["B09"] := "."
	hash["B10"] := "/"
	hash["B11"] := "\"
	
	hash["A00"] := "LCtrl"
	hash["A01"] := "sc07B"	;無変換
	hash["A02"] := "Space"	;スペース
	hash["A03"] := "sc079"	;変換
	hash["A04"] := "sc070"	;カタカナ/ひらがな
	hash["A05"] := "RCtrl"
	return hash
}

;----------------------------------------------------------------------
;	キーからラベル名に変換
;----------------------------------------------------------------------
MakeKeyLabelHash()
{
	hash := Object()
	hash["A01"] := "無変換"	;無変換
	hash["A02"] := " 空白 "	;スペース
	hash["A03"] := " 変換 "	;変換
	hash["A04"] := "カ/ひ "	;カタカナ/ひらがな
	return hash
}
;----------------------------------------------------------------------
;	キーダウン／キーアップ時のホットキーとレイアウト位置の変換
;----------------------------------------------------------------------
MakeLayoutPosHash()
{
	hash := Object()
	hash["*sc029"]    := "E00"	;半角／全角
	hash["*sc002"]    := "E01"	;1
	hash["*sc003"]    := "E02"
	hash["*sc004"]    := "E03"
	hash["*sc005"]    := "E04"
	hash["*sc006"]    := "E05"
	hash["*sc007"]    := "E06"
	hash["*sc008"]    := "E07"
	hash["*sc009"]    := "E08"
	hash["*sc00A"]    := "E09"
	hash["*sc00B"]    := "E10"
	hash["*sc00C"]    := "E11"
	hash["*sc00D"]    := "E12"
	hash["*sc07D"]    := "E13"
	hash["Backspace"] := "E14"	; \b

	hash["Tab"]       := "D00"	;tab
	hash["*sc010"]    := "D01"
	hash["*sc011"]    := "D02"
	hash["*sc012"]    := "D03"
	hash["*sc013"]    := "D04"
	hash["*sc014"]    := "D05"
	hash["*sc015"]    := "D06"
	hash["*sc016"]    := "D07"
	hash["*sc017"]    := "D08"
	hash["*sc018"]    := "D09"
	hash["*sc019"]    := "D10"
	hash["*sc01A"]    := "D11"
	hash["*sc01B"]    := "D12"
	
	hash["*sc01E"]    := "C01"
	hash["*sc01F"]    := "C02"
	hash["*sc020"]    := "C03"
	hash["*sc021"]    := "C04"
	hash["*sc022"]    := "C05"
	hash["*sc023"]    := "C06"
	hash["*sc024"]    := "C07"
	hash["*sc025"]    := "C08"
	hash["*sc026"]    := "C09"
	hash["*sc027"]    := "C10"
	hash["*sc028"]    := "C11"
	hash["*sc02B"]    := "C12"
	hash["Enter"]     := "C13"
	
	hash["*sc02C"]    := "B01"
	hash["*sc02D"]    := "B02"
	hash["*sc02E"]    := "B03"
	hash["*sc02F"]    := "B04"
	hash["*sc030"]    := "B05"
	hash["*sc031"]    := "B06"
	hash["*sc032"]    := "B07"
	hash["*sc033"]    := "B08"
	hash["*sc034"]    := "B09"
	hash["*sc035"]    := "B10"
	hash["*sc073"]    := "B11"

	hash["LCtrl"]     := "A00"
	hash["*sc07B"]    := "A01"
	hash["Space"]     := "A02"
	hash["*sc079"]    := "A03"
	hash["*sc070"]    := "A04"	;カタカナ/ひらがな
	hash["RCtrl"]     := "A05"

	hash["*sc029 up"] := "E00"	;半角／全角
	hash["*sc002 up"] := "E01"	;1
	hash["*sc003 up"] := "E02"
	hash["*sc004 up"] := "E03"
	hash["*sc005 up"] := "E04"
	hash["*sc006 up"] := "E05"
	hash["*sc007 up"] := "E06"
	hash["*sc008 up"] := "E07"
	hash["*sc009 up"] := "E08"
	hash["*sc00A up"] := "E09"
	hash["*sc00B up"] := "E10"
	hash["*sc00C up"] := "E11"
	hash["*sc00D up"] := "E12"
	hash["*sc07D up"] := "E13"
	hash["Backspace up"] := "E14"	; \b

	hash["Tab up"]    := "D00"	;tab
	hash["*sc010 up"] := "D01"
	hash["*sc011 up"] := "D02"
	hash["*sc012 up"] := "D03"
	hash["*sc013 up"] := "D04"
	hash["*sc014 up"] := "D05"
	hash["*sc015 up"] := "D06"
	hash["*sc016 up"] := "D07"
	hash["*sc017 up"] := "D08"
	hash["*sc018 up"] := "D09"
	hash["*sc019 up"] := "D10"
	hash["*sc01A up"] := "D11"
	hash["*sc01B up"] := "D12"
	
	hash["*sc01E up"] := "C01"
	hash["*sc01F up"] := "C02"
	hash["*sc020 up"] := "C03"
	hash["*sc021 up"] := "C04"
	hash["*sc022 up"] := "C05"
	hash["*sc023 up"] := "C06"
	hash["*sc024 up"] := "C07"
	hash["*sc025 up"] := "C08"
	hash["*sc026 up"] := "C09"
	hash["*sc027 up"] := "C10"
	hash["*sc028 up"] := "C11"
	hash["*sc02B up"] := "C12"
	hash["Enter up"]  := "C13"

	hash["*sc02C up"] := "B01"
	hash["*sc02D up"] := "B02"
	hash["*sc02E up"] := "B03"
	hash["*sc02F up"] := "B04"
	hash["*sc030 up"] := "B05"
	hash["*sc031 up"] := "B06"
	hash["*sc032 up"] := "B07"
	hash["*sc033 up"] := "B08"
	hash["*sc034 up"] := "B09"
	hash["*sc035 up"] := "B10"
	hash["*sc073 up"] := "B11"

	hash["LCtrl up"]  := "A00"
	hash["*sc07B up"] := "A01"
	hash["Space up"]  := "A02"
	hash["*sc079 up"] := "A03"
	hash["*sc070 up"] := "A04"
	hash["RCtrl up"]  := "A05"
	return hash
}
;----------------------------------------------------------------------
;	機能キー名とレイアウト位置の変換
;----------------------------------------------------------------------
MakefkeyPosHash()
{
	hash := Object()
	hash["半角/全角"] := "E00"		;半角／全角
	hash["Backspace"] := "E14"

	hash["Tab"]       := "D00"
	hash["Enter"]     := "C13"

	hash["左Ctrl"] := "A00"
	hash["無変換"] := "A01"	;無変換
	hash["Space"]  := "A02"	;スペース
	hash["変換"]   := "A03"	;変換
	hash["カタカナ/ひらがな"] := "A04"	;カタカナ/ひらがな
	hash["右Ctrl"] := "A05"
	return hash
}

;----------------------------------------------------------------------
;	機能キー名とコードの変換
;----------------------------------------------------------------------
MakefkeyCodeHash()
{
	hash := Object()
	hash["半角/全角"] := "sc029"	;半角／全角
	hash["Backspace"] := "Backspace"

	hash["Tab"]       := "Tab"
	hash["Enter"]     := "Enter"

	hash["左Ctrl"]    := "LCtrl"
	hash["無変換"]    := "sc07B"	;無変換
	hash["Space"]     := "Space"	;スペース
	hash["変換"]      := "sc079"	;変換
	hash["カタカナ/ひらがな"] := "sc070"	;カタカナ/ひらがな
	hash["右Ctrl"]    := "RCtrl"
	return hash
}

;----------------------------------------------------------------------
;	機能キー名とコードの変換
;----------------------------------------------------------------------
MakeCodeNameHash()
{
	hash := Object()
	hash["sc029"]     := "半/全 "	;半角／全角
	hash["Backspace"] := "Backsp"

	hash["Tab"]       := " Tab  "
	hash["Enter"]     := "Enter "

	hash["LCtrl"]     := "左Ctrl"
	hash["sc07B"]     := "無変換"	;無変換
	hash["Space"]     := " 空白 "	;スペース
	hash["sc079"]     := " 変換 "	;変換
	hash["sc070"]     := "カ/ひ"	;カタカナ/ひらがな
	hash["RCtrl"]     := "右Ctrl"
	return hash
}

;----------------------------------------------------------------------
;	新下駄配列などの同時打鍵モードのキーレイアウト名
;----------------------------------------------------------------------
MakeLpos2ModeHash()
{
	hash := Object()
	hash["C02"] := "R4N"	;第４指（薬指）
	hash["C03"] := "R3N"	;第３指（中指）
	hash["C08"] := "R3N"	;第３指（中指）
	hash["C09"] := "R4N"	;第４指（薬指）
	return hash
}


;----------------------------------------------------------------------
;	キー名とvkeyの変換
;----------------------------------------------------------------------
MakeName2vkeyHash()
{
	hash := Object()
	hash["Pause"]      := 0x13
	hash["ScrollLock"] := 0x91
	hash["Insert"]     := 0x2D
	
	hash["LShift"]     := 160
	hash["RShift"]     := 161
	hash["LCtrl"]      := 162
	hash["RCtrl"]      := 163
	hash["LAlt"]       := 164
	hash["RAlt"]       := 165
	hash["LWin"]       := 91
	hash["RWin"]       := 92
	hash["AppsKey"]    := 93
	return hash
}

