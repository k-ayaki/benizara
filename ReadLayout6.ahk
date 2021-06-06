;-----------------------------------------------------------------------
;	名称：ReadLayout6.ahk
;	機能：紅皿のキーレイアウトファイルの読み込み
;	ver.0.1.4.6 .... 2021/5/2
;-----------------------------------------------------------------------
ReadLayout:

	_colhash := Object()
	_colhash[1] := "E"
	_colhash[2] := "D"
	_colhash[3] := "C"
	_colhash[4] := "B"
	_colhash[5] := "A"

	_colkeyshash := Object()
	_colkeyshash["E"] := 13
	_colkeyshash["D"] := 12
	_colkeyshash["C"] := 12
	_colkeyshash["B"] := 11
	_colkeyshash["A"] := 4
	
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
	
	layoutAry := "E01,E02,E03,E04,E05,E06,E07,E08,E09,E10,E11,E12,E13,E14"
	layoutAry := layoutAry . ",D01,D02,D03,D04,D05,D06,D07,D08,D09,D10,D11,D12"
	layoutAry := layoutAry . ",C01,C02,C03,C04,C05,C06,C07,C08,C09,C10,C11,C12"
	layoutAry := layoutAry . ",B01,B02,B03,B04,B05,B06,B07,B08,B09,B10,B11"
	layoutArys := StrSplit(layoutAry,",")
	
	Gosub, InitLayout2
	vLayoutFile := g_LayoutFile
	if(vLayoutFile == "")
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
	kst := Object()	; キーの状態
	ksc := Object()	; 最大同時打鍵個数
	kup := Object()	; keyup したときの Send形式
	kdn := Object()	; keydown したときの Send形式
	mup := Object()	; キーボードそのものを keyup したときの Send形式
	mdn := Object()	; キーボードそのものを keydown したときの Send形式

	DakuonSurfaceHash := MakeDakuonSurfaceHash()	; 濁音
	HandakuonSurfaceHash := MakeHanDakuonSurfaceHash()	; 半濁音
	YouonSurfaceHash := MakeYouonSurfaceHash()	; 拗音
	CorrectSurfaceHash := MakeCorrectSurfaceHash()	; 修正

	g_Oya2Layout := Object()

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
	code2SimulPos := MakeCode2SimulPos()
	code2ContPos := MakeCode2ContPos()
	name2vkey := MakeName2vkeyHash()
	ScanCodeHash := MakeScanCodeHash()
	Chr2vkeyHash := MakeChr2vkeyHash()
	ctrlKeyHash := MakeCtrlKeyHash()
	modifierHash := MakeModifierHash()

	keyAttribute3 := MakeKeyAttribute3Hash()
	keyState := MakeKeyState()
	keyNameHash := MakeKeyNameHash()
	kLabel := MakeKeyLabelHash()
	g_SimulMode := Object()

	g_layoutName := ""
	g_layoutVersion := ""
	g_layoutURL := ""

	LF := Object()
	LF["ANN"] := ""
	LF["ALN"] := ""
	LF["ARN"] := ""
	LF["A1N"] := ""
	LF["A2N"] := ""
	LF["A3N"] := ""
	LF["A4N"] := ""

	LF["ANK"] := ""
	LF["ALK"] := ""
	LF["ARK"] := ""
	LF["A1K"] := ""
	LF["A2K"] := ""
	LF["A3K"] := ""
	LF["A4K"] := ""

	LF["RNN"] := ""
	LF["RLN"] := ""
	LF["RRN"] := ""
	LF["R1N"] := ""
	LF["R2N"] := ""
	LF["R3N"] := ""
	LF["R4N"] := ""

	LF["RNK"] := ""
	LF["RLK"] := ""
	LF["RRK"] := ""
	LF["R1K"] := ""
	LF["R2K"] := ""
	LF["R3K"] := ""
	LF["R4K"] := ""
	loop,4
	{
		LF["ANN" . _colhash[A_Index]] := ""
		LF["ALN" . _colhash[A_Index]] := ""
		LF["ARN" . _colhash[A_Index]] := ""
		LF["A1N" . _colhash[A_Index]] := ""
		LF["A2N" . _colhash[A_Index]] := ""
		LF["A3N" . _colhash[A_Index]] := ""
		LF["A4N" . _colhash[A_Index]] := ""

		LF["ANK" . _colhash[A_Index]] := ""
		LF["ALK" . _colhash[A_Index]] := ""
		LF["ARK" . _colhash[A_Index]] := ""
		LF["A1K" . _colhash[A_Index]] := ""
		LF["A2K" . _colhash[A_Index]] := ""
		LF["A3K" . _colhash[A_Index]] := ""
		LF["A4K" . _colhash[A_Index]] := ""

		LF["RNN" . _colhash[A_Index]] := ""
		LF["RLN" . _colhash[A_Index]] := ""
		LF["RRN" . _colhash[A_Index]] := ""
		LF["R1N" . _colhash[A_Index]] := ""
		LF["R2N" . _colhash[A_Index]] := ""
		LF["R3N" . _colhash[A_Index]] := ""
		LF["R4N" . _colhash[A_Index]] := ""

		LF["RNK" . _colhash[A_Index]] := ""
		LF["RLK" . _colhash[A_Index]] := ""
		LF["RRK" . _colhash[A_Index]] := ""
		LF["R1K" . _colhash[A_Index]] := ""
		LF["R2K" . _colhash[A_Index]] := ""
		LF["R3K" . _colhash[A_Index]] := ""
		LF["R4K" . _colhash[A_Index]] := ""
	}
	; デフォルトテーブル
	LF["ADNE"] := "１,２,３,４,５,６,７,８,９,０,－,＾,￥,後"
	LF["ADND"] := "ｑ,ｗ,ｅ,ｒ,ｔ,ｙ,ｕ,ｉ,ｏ,ｐ,＠,［"
	LF["ADNC"] := "ａ,ｓ,ｄ,ｆ,ｇ,ｈ,ｊ,ｋ,ｌ,；,：,］"
	LF["ADNB"] := "ｚ,ｘ,ｃ,ｖ,ｂ,ｎ,ｍ,，,．,／,￥"
	SetkLabel("ANN","ADN")

	LF["ADKE"] := "！,”,＃,＄,％,＆,’, （,）,無,＝,～,｜,後"
	LF["ADKD"] := "Ｑ,Ｗ,Ｅ,Ｒ,Ｔ,Ｙ,Ｕ,Ｉ,Ｏ,Ｐ,‘,｛"
	LF["ADKC"] := "Ａ,Ｓ,Ｄ,Ｆ,Ｇ,Ｈ,Ｊ,Ｋ,Ｌ,＋,＊,｝"
	LF["ADKB"] := "Ｚ,Ｘ,Ｃ,Ｖ,Ｂ,Ｎ,Ｍ,＜,＞,？,＿"
	SetkLabel("ANK","ADK")
	
	; NULLテーブル
	LF["NULE"] := "　,　,　,　,　,　,　,　,　,　,　,　,　,　"
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
	loop, % CountObject(org)
	{
		kLabel[_modeDst . _col . _rowhash[A_Index]] := org[A_Index]
	}
	_col := "D"
	org := StrSplit(LF[_modeSrc . "D"],",")

	loop, % CountObject(org)
	{
		kLabel[_modeDst . _col . _rowhash[A_Index]] := org[A_Index]
	}
	_col := "C"
	org := StrSplit(LF[_modeSrc . "C"],",")
	loop, % CountObject(org)
	{
		kLabel[_modeDst . _col . _rowhash[A_Index]] := org[A_Index]
	}
	_col := "B"
	org := StrSplit(LF[_modeSrc . "B"],",")

	loop, % CountObject(org)
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
	if(Path_FileExists(vLayoutFile) == 0)
	{
		_error := "ファイルが存在しません " . vLayoutFile
		return
	}
	Gosub,InitLayout2
	g_mode := ""
	g_modeName := ""
	g_Section := ""
	_spos := ""
	_mline := 0
	_mline2 := 0
	_error := ""
	_lineCtr := 0
	g_layoutName := ""
	g_layoutVersion := ""
	g_layoutURL := ""
	_fileObj := fileOpen(vLayoutFile,"r")
	if(isObject(_fileObj)==false) {
		_error := "ファイルが開けません " . vLayoutFile
		return
	}
	Loop
	{
		_lineCtr := _lineCtr + 1
		if(_fileObj.AtEOF) {
			break
		}
		_line := _fileObj.ReadLine()
		; コメント部分の除去
	    cpos := InStr(_line,";")
    	if(cpos == 1)
    	{
			_line2 := ""
		} else {
	    	_line2 := Trim(_line)
		    cpos := InStr(_line2,chr(10))
		    if(cpos > 0) {
		    	_line2 := substr(_line2,1,cpos-1)
		    }
		    cpos := InStr(_line2,chr(13))
		    if(cpos > 0) {
		    	_line2 := substr(_line2,1,cpos-1)
		    }
	    }
	    if(_line2 != "")
		{
			if(SubStr(_line2,1,1)=="[" && SubStr(_line2,StrLen(_line2),1)=="]") {
				g_Section := _line2
			}
			if((SubStr(_line2,1,1)=="<" || SubStr(_line2,1,1)=="{")
			&& (SubStr(_line2,StrLen(_line2),1)==">" || SubStr(_line2,StrLen(_line2),1)=="}")) {
				g_Section := _line2
			}
			if(layout2Hash[_line2] != "") {
				g_mode := layout2Hash[_line2]
				_spos := ""
				if(g_mode != "")
				{
					g_modeSave := g_mode
					g_modeName := _line2
					_mline := 1
					_mline2 := 0
					LF[g_mode . _colhash[1]] := ""
					LF[g_mode . _colhash[2]] := ""
					LF[g_mode . _colhash[3]] := ""
					LF[g_mode . _colhash[4]] := ""
					LF[g_mode . _colhash[5]] := "換,空,変,日"
				}
				continue
			}
			if(g_mode != "") 
			{
				if(1<=_mline && _mline <= 4)
				{
					LF[g_mode . _colhash[_mline]] := _line2
					if(_mline == 4) {
						GoSub, Mode2Key		; 親指シフトレイアウトの処理
						if(_error <> "")
						{
							_error := vLayoutFile . ":" . g_modeName . ":" . _error

							g_Section := ""
							g_mode := ""
							g_modeName := ""
							_spos := ""
							_mline2 := 0
							_mline := 0
							_fileObj.Close()
							return
						}
					}
					_spos := ""
					_mline2 := 0
					_mline := _mline + 1
				}
				else if(_mline == 5) {
					if(ParseSimulPos(_line2) != "") {
						_spos := ParseSimulPos(_line2)		; 同時打鍵パターンがあるか
						_cpos := ParseContPos(_line2)	; 連続打鍵パターンがあるか
						_simulMode := _line2
						if(_spos != "")
						{
							_mline2 := 1
							LF[g_mode . _spos . _colhash[1]] := ""
							LF[g_mode . _spos . _colhash[2]] := ""
							LF[g_mode . _spos . _colhash[3]] := ""
							LF[g_mode . _spos . _colhash[4]] := ""
						}
						continue
					}
					if(_spos != "") {
						if(1<=_mline2 && _mline2 <= 4)
						{
							LF[g_mode . _spos . _colhash[_mline2]] := _line2
							if(_mline2 == 4) {
								GoSub, Mode3Key		; 同時打鍵レイアウトの処理
								if(_error <> "")
								{
									_error := vLayoutFile . ":" . g_modeName . ":" . _error

									g_Section := ""
									g_mode := ""
									_spos := ""
									_mline2 := 0
									_fileObj.Close()
									return
								}
								_spos := ""
							}
							_mline2 := _mline2 + 1
						}
						continue
					}
					continue
				}
			}

			if(g_Section == "[配列]")
			{
				cpos2 := Instr(_line2,"=")
				org := StrSplit(_line2,"=")
				if(CountObject(org) == 2)
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
					else
					if(org[1]=="URL")
					{
						g_layoutURL := org[2]
					}
				}
				continue
			}
			else
			if(g_Section == "[機能キー]")
			{
				cpos2 := Instr(_line2,",")
				org := StrSplit(_line2,",")
				if(CountObject(org) == 2)
				{
					_layoutPos := fkeyPosHash[org[1]]
					_code := fkeyCodeHash[org[2]]
					if(_layoutPos != "" && _code != "") {
						keyNameHash[_layoutPos] := _code
						kLabel[_layoutPos] := CodeNameHash[_code]
						if(org[2] == "Space&Shift") {
							keyAttribute3["AN" . _layoutPos] := "S"	; Space
							keyAttribute3["AK" . _layoutPos] := "S"	; Space
							keyAttribute3["RN" . _layoutPos] := "S"	; Space
							keyAttribute3["RK" . _layoutPos] := "S"	; Space
						}
					}
				}
			}
		}
	}
	_fileObj.Close()
	Return

;----------------------------------------------------------------------
;	文字同時打鍵の指定を解釈
;----------------------------------------------------------------------
ParseSimulPos(_line)
{
	global code2SimulPos

	_spos := ""
	if(strlen(_line) >= 3)
	{
		_spos := code2SimulPos[substr(_line,1,3)]
	}
	if(strlen(_line) >= 6)
	{
		_spos := _spos . code2SimulPos[substr(_line,4,3)]
	}
	return _spos
}
;----------------------------------------------------------------------
;	文字同時打鍵の指定を解釈
;----------------------------------------------------------------------
ParseContPos(_line)
{
	global code2ContPos

	_cpos := ""
	if(strlen(_line) >= 3)
	{
		_cpos := code2ContPos[substr(_line,1,3)]
	}
	if(strlen(_line) >= 6)
	{
		_cpos := _cpos . code2ContPos[substr(_line,4,3)]
	}
	return _cpos
}
;----------------------------------------------------------------------
;	各モードのレイアウトを処理
;----------------------------------------------------------------------
Mode2Key:
	_error := ""
	LF[g_mode] := g_modeName
	_col := "E"
	org := SplitColumn(LF[g_mode . "E"])
	if(CountObject(org) < 13 || CountObject(org) > 14)
	{
		_error := g_Section . "のE段目にエラーがあります。要素数が" . CountObject(org) . "です。"
		return
	}
	if(CountObject(org) == 13) {
		org[14] := "後"
	}
	Gosub, SetKeyTable
	if(_error <> "") 
		return
	if(g_mode == "ANN")
		Gosub, SetAlphabet
	
	_col := "D"
	org := SplitColumn(LF[g_mode . "D"])
	if(CountObject(org) <> 12)
	{
		_error := g_Section . "のD段目にエラーがあります。要素数が" . CountObject(org) . "です。"
		return
	}
	Gosub, SetKeyTable
	if(_error <> "")
		return
	if(g_mode == "ANN")
		Gosub, SetAlphabet
	
	_col := "C"
	org := SplitColumn(LF[g_mode . "C"])
	if(CountObject(org) <> 12)
	{
		_error := g_Section . "のC段目にエラーがあります。要素数が" . CountObject(org) . "です。"
		return
	}
	Gosub, SetKeyTable
	if(_error <> "")
		return
	if(g_mode == "ANN")
		Gosub, SetAlphabet

	_col := "B"
	org := SplitColumn(LF[g_mode . "B"])
	if(CountObject(org) <> 11)
	{
		_error := g_Section . "のB段目にエラーがあります。要素数が" . CountObject(org) . "です。"
		return
	}
	Gosub, SetKeyTable
	if(_error <> "")
		return
	if(g_mode == "ANN")
		Gosub, SetAlphabet
	_col := "A"
	;org := SplitColumn("換,空,変,日")
	org := SplitColumn(LF[g_mode . "A"])	
	Gosub, SetKeyTable
	if(_error <> "")
		return
	if(g_mode == "ANN")
		Gosub, SetAlphabet
	return

;----------------------------------------------------------------------
;	カラム行をカンマで分割して配列に設定
;----------------------------------------------------------------------
SplitColumn(lColumn) {
	obj := Object()
	idx := 0

	while(lColumn <> "") {
		idx := idx + 1
		StringLeft, _cl, lColumn, 1
		if(_cl == "'" || _cl == """") {
			cpos := 2
			cpos := Instr(lColumn, _cl, false, cpos)
			if(cpos!=0) {	; 対応する引用符があった
				cpos := Instr(lColumn, ",", false, cpos + 1)
				if(cpos!=0) {	; 次のカンマがあった
					obj[idx] := SubStr(lColumn,1,cpos-1)
					lColumn := SubStr(lColumn,cpos+1)
				} else {
					obj[idx] := lColumn
					lColumn := ""
				}
			} else {
				obj[idx] := lColumn
				lColumn := ""
			}
		} else {
			cpos := Instr(lColumn, ",")
			if(cpos!=0) {	; 次のカンマがあった
				obj[idx] := SubStr(lColumn,1,cpos-1)
				lColumn := SubStr(lColumn,cpos+1)
			} else {
				obj[idx] := lColumn
				lColumn := ""
			}
		}
	}
	return obj
}

;----------------------------------------------------------------------
;	文字の同時打鍵のレイアウトを処理
;----------------------------------------------------------------------
Mode3Key:
	_error := ""
	_idx := CountObject(g_SimulMode)
	g_SimulMode[_idx + 1] := g_mode . _simulMode		; 同時打鍵テーブル

	_col := "E"
	org := SplitColumn(LF[g_mode . _spos . "E"])
	if(CountObject(org) < 13 || CountObject(org) > 14)
	{
		_error := g_Section . "のE段目にエラーがあります。要素数が" . CountObject(org) . "です。"
		return
	}
	if(CountObject(org) == 13) {
		org[14] := "後"
	}
	if(_cpos != _spos) {
		_lpos2 := substr(_spos,1,3)
		if(strlen(_spos)>=6) {
			_lpos2 := substr(_spos,4,3)
		}
	}
	_lpos := Object()
	_lpos[1] := substr(_spos,1,3)
	if(strlen(_spos)>=6) {
		_lpos[2] := substr(_spos,4,3)
		Gosub, SetSimulKeyTable3
	} else {
		Gosub, SetSimulKeyTable
	}
	if(_cpos != _spos) {
		_lpos := Object()
		_lpos[1] := substr(_cpos,1,3)
		if(strlen(_cpos)>=6) {
			_lpos[2] := substr(_cpos,4,3)
			Gosub, SetSimulKeyTable3
		} else {
			Gosub, SetSimulKeyTable
		}
	}
	if(_error <> "")
		return
	
	_col := "D"
	org := SplitColumn(LF[g_mode . _spos . "D"])
	if(CountObject(org) <> 12)
	{
		_error := g_Section . "のD段目にエラーがあります。要素数が" . CountObject(org) . "です。"
		return
	}
	_lpos := Object()
	_lpos[1] := substr(_spos,1,3)
	if(strlen(_spos)>=6) {
		_lpos[2] := substr(_spos,4,3)
		Gosub, SetSimulKeyTable3
	} else {
		Gosub, SetSimulKeyTable
	}
	if(_cpos != _spos) {
		_lpos := Object()
		_lpos[1] := substr(_cpos,1,3)
		if(strlen(_cpos)>=6) {
			_lpos[2] := substr(_cpos,4,3)
			Gosub, SetSimulKeyTable3
		} else {
			Gosub, SetSimulKeyTable
		}
	}
	if(_error <> "")
		return
	
	_col := "C"
	org := SplitColumn(LF[g_mode . _spos . "C"])
	if(CountObject(org) <> 12)
	{
		_error := g_Section . "のC段目にエラーがあります。要素数が" . CountObject(org) . "です。"
		return
	}
	_lpos := Object()
	_lpos[1] := substr(_spos,1,3)
	if(strlen(_spos)>=6) {
		_lpos[2] := substr(_spos,4,3)
		Gosub, SetSimulKeyTable3
	} else {
		Gosub, SetSimulKeyTable
	}
	if(_cpos != _spos) {
		_lpos := Object()
		_lpos[1] := substr(_cpos,1,3)
		if(strlen(_cpos)>=6) {
			_lpos[2] := substr(_cpos,4,3)
			Gosub, SetSimulKeyTable3
		} else {
			Gosub, SetSimulKeyTable
		}
	}	
	if(_error <> "")
		return

	_col := "B"
	org := SplitColumn(LF[g_mode . _spos . "B"])
	if(CountObject(org) <> 11)
	{
		_error := g_Section . "のB段目にエラーがあります。要素数が" . CountObject(org) . "です。"
		return
	}
	_lpos := Object()
	_lpos[1] := substr(_spos,1,3)
	if(strlen(_spos)>=6) {
		_lpos[2] := substr(_spos,4,3)
		Gosub, SetSimulKeyTable3
	} else {
		Gosub, SetSimulKeyTable
	}
	if(_cpos != _spos) {
		_lpos := Object()
		_lpos[1] := substr(_cpos,1,3)
		if(strlen(_cpos)>=6) {
			_lpos[2] := substr(_cpos,4,3)
			Gosub, SetSimulKeyTable3
		} else {
			Gosub, SetSimulKeyTable
		}
	}
	if(_error <> "")
		return
	return

;----------------------------------------------------------------------
;	レイアウトファイルの設定
;----------------------------------------------------------------------
SetLayoutProperty:
	ShiftMode := Object()
	ShiftMode["A"] := ""
	if(LF["ANN"]!="" && LF["ALN"]!="" && LF["ARN"]!="")
	{
		ShiftMode["A"] := "親指シフト"
		RemapOyaKey("A")
		
		if(LF["ANK"]!="" && LF["ALK"] == "") {
			CopyColumns("ANK", "ALK")
			g_mode := "ALK"
			Gosub, SetE2AKeyTables
		}
		if(LF["ANK"]!="" && LF["ARK"] == "") {
			CopyColumns("ANK", "ARK")
			g_mode := "ARK"
			Gosub, SetE2AKeyTables
		}
	} else 
	if(LF["ANN"]!="" && LF["A1N"]!="") 
	{
		ShiftMode["A"] := "プレフィックスシフト"
	}
	else
	if(LF["ANN"]!="" && listSimulMode("A")!="")
	{
		ShiftMode["A"] := "文字同時打鍵"
	}
	else
	if(LF["ANN"]!="" && LF["ANK"]!="")
	{
		ShiftMode["A"] := "小指シフト"
	}
	
	ShiftMode["R"] := ""
	if(LF["RNN"]!="" && LF["RRN"]!="" && LF["RLN"]!="")
	{
		ShiftMode["R"] := "親指シフト"
		RemapOyaKey("R")

		if(LF["RNK"]!="" && LF["RLK"] == "") {
			CopyColumns("RNK", "RLK")
			g_mode := "RLK"
			Gosub, SetE2AKeyTables
		}
		if(LF["RNK"]!="" && LF["RRK"] == "") {
			CopyColumns("RNK","RRK")
			g_mode := "RRK"
			Gosub, SetE2AKeyTables
		}
	} else
	if(LF["RNN"]!="" && LF["R1N"]!="")
	{
		ShiftMode["R"] := "プレフィックスシフト"
	}
	else
	if(LF["RNN"]!="" && listSimulMode("R")!="")
	{
		ShiftMode["R"] := "文字同時打鍵"
	}
	else
	if(LF["RNN"]!="" LF["RNK"]!="")
	{
		ShiftMode["R"] := "小指シフト"
	}
	return

;----------------------------------------------------------------------
;	E段からA段までカラム列からキー配列表を設定
;----------------------------------------------------------------------
SetE2AKeyTables:
	_col := "E"
	org := StrSplit(LF[g_mode . "E"],",")
	Gosub, SetKeyTable
	if(_error <> "")
		return
	_col := "D"
	org := StrSplit(LF[g_mode . "D"],",")
	Gosub, SetKeyTable
	if(_error <> "")
		return
	_col := "C"
	org := StrSplit(LF[g_mode . "C"],",")
	Gosub, SetKeyTable
	if(_error <> "")
		return
	_col := "B"
	org := StrSplit(LF[g_mode . "B"],",")
	Gosub, SetKeyTable
	if(_error <> "") 
		return
	_col := "A"
	;org := StrSplit("換,空,変,日",",")
	org := StrSplit(LF[g_mode . "A"],",")
	Gosub, SetKeyTable
	if(_error <> "") 
		return
	return

;----------------------------------------------------------------------
;	親指キー設定をキー属性配列に反映させる
;----------------------------------------------------------------------
RemapOyaKey(_Romaji) {
	global keyAttribute3, g_Oya2Layout, g_OyaKey, g_KeySingle

	if(g_OyaKey == "無変換－空白") {
		keyAttribute3[_Romaji . "NA01"] := "L"
		keyAttribute3[_Romaji . "NA02"] := "R"
		keyAttribute3[_Romaji . "NA03"] := "X"
		keyAttribute3[_Romaji . "KA01"] := "L"
		keyAttribute3[_Romaji . "KA02"] := "R"
		keyAttribute3[_Romaji . "KA03"] := "X"		
		g_Oya2Layout["L"] := "A01"
		g_Oya2Layout["R"] := "A02"
	}
	else if(g_OyaKey == "空白－変換") {
		keyAttribute3[_Romaji . "NA01"] := "X"
		keyAttribute3[_Romaji . "NA02"] := "L"
		keyAttribute3[_Romaji . "NA03"] := "R"
		keyAttribute3[_Romaji . "KA01"] := "X"
		keyAttribute3[_Romaji . "KA02"] := "L"
		keyAttribute3[_Romaji . "KA03"] := "R"
		g_Oya2Layout["L"] := "A02"
		g_Oya2Layout["R"] := "A03"
	} else {
		keyAttribute3[_Romaji . "NA01"] := "L"
		keyAttribute3[_Romaji . "NA02"] := "X"
		keyAttribute3[_Romaji . "NA03"] := "R"
		keyAttribute3[_Romaji . "KA01"] := "L"
		keyAttribute3[_Romaji . "KA02"] := "X"
		keyAttribute3[_Romaji . "KA03"] := "R"

		g_Oya2Layout["L"] := "A01"
		g_Oya2Layout["R"] := "A03"
	}
	if(_Romaji == "R") {
		; ローマ字モードにて親指シフトモード、かつキー単独打鍵が無効ならば、
		; 英数モードでも変換キーと無変換キーを無効化
		if(g_KeySingle == "無効") {
			if(g_OyaKey == "無変換－空白") {
				keyAttribute3["ANA01"] := "L"
				keyAttribute3["ANA02"] := "R"
				keyAttribute3["ANA03"] := "X"
				keyAttribute3["AKA01"] := "L"
				keyAttribute3["AKA02"] := "R"
				keyAttribute3["AKA03"] := "X"
			}
			else if(g_OyaKey == "空白－変換") {
				keyAttribute3["ANA01"] := "X"
				keyAttribute3["ANA02"] := "L"
				keyAttribute3["ANA03"] := "R"
				keyAttribute3["AKA01"] := "X"
				keyAttribute3["AKA02"] := "L"
				keyAttribute3["AKA03"] := "R"
			} else {
				keyAttribute3["ANA01"] := "L"
				keyAttribute3["ANA02"] := "X"
				keyAttribute3["ANA03"] := "R"
				keyAttribute3["AKA01"] := "L"
				keyAttribute3["AKA02"] := "X"
				keyAttribute3["AKA03"] := "R"
			}
		} else {
			keyAttribute3["ANA01"] := "X"
			keyAttribute3["ANA02"] := "X"
			keyAttribute3["ANA03"] := "X"
			keyAttribute3["AKA01"] := "X"
			keyAttribute3["AKA02"] := "X"
			keyAttribute3["AKA03"] := "X"
		}
	}
	return
}

;----------------------------------------------------------------------
;	ローマ字・英数のときのキーダウン・キーアップの際に送信する内容を作成
;----------------------------------------------------------------------
SetKeyTable:
	kdn[g_mode . "0"] := CountObject(org)
	kup[g_mode . "0"] := CountObject(org)
	loop, % CountObject(org)
	{
		_row2 := _rowhash[A_Index]
		_lpos2 := _col . _row2
		if(ksc[g_mode . _lpos2] < 1) {
			ksc[g_mode . _lpos2] := 1	; 最大同時打鍵数を１に初期化
		}

		; 月配列などのプレフィックスシフトキー
		if(org[A_Index] == " 1" || org[A_Index] == " 2" || org[A_Index] == " 3" || org[A_Index] == " 4")
		{
			kdn[g_mode . _lpos2] := ""
			kup[g_mode . _lpos2] := ""

			kLabel[g_mode . _lpos2] := SubStr(org[A_Index],2,1)

			g_mode2 := substr(g_mode,1,1) . substr(g_mode,3,1)
			keyAttribute3[g_mode2 . _lpos2] := SubStr(org[A_Index],2,1)
			continue
		}
		; 無の指定ならば，元のキーそのもののスキャンコードとする
		if(org[A_Index] == "無") {
			kLabel[g_mode . _lpos2] := org[A_Index]
			kst[g_mode . _lpos2] := "S"	; scan code
			kdn[g_mode . _lpos2] := "{" . ScanCodeHash[_lpos2] . " down}"
			kup[g_mode . _lpos2] := "{" . ScanCodeHash[_lpos2] . " up}"
			continue
		}
		GenSendStr3(org[A_Index], _down, _up, _status)
		if(_error <> "") {
			_error := _lpos2 . ":" . _error
			break
		}
		kst[g_mode . _lpos2] := _status
		if( _down <> "")
		{
			if(SubStr(g_mode,1,1)=="R")
			{
				kLabel[g_mode . _lpos2] := Romaji2Kana(org[A_Index])
			}
			else
			{
				kLabel[g_mode . _lpos2] := org[A_Index]
			}
			kdn[g_mode . _lpos2] := _down
			kup[g_mode . _lpos2] := _up
		} else {
			kLabel[g_mode . _lpos2] := org[A_Index]
			kdn[g_mode . _lpos2] := ""
			kup[g_mode . _lpos2] := ""
		}
		continue
	}
	return

;----------------------------------------------------------------------
;	ローマ字＋文字同時打鍵のときのキーダウン・キーアップの際に送信する内容を作成
;----------------------------------------------------------------------
SetSimulKeyTable:
	loop, % CountObject(org)
	{
		_row2 := _rowhash[A_Index]
		_lpos[0] := _col . _row2

		if(ksc[g_mode . _lpos[0]] < 2) {
			ksc[g_mode . _lpos[0]] := 2	; 最大同時打鍵数を設定
		}
		; 送信形式に変換・・・なお、文字同時打鍵は小指シフトしない
		GenSendStr3(org[A_Index], _down, _up, _status)
		if(_error <> "") {
			_error := _lpos[0] . ":" . _error
			break
		}
		kst[g_mode . _lpos[0]] := kst[g_mode . _lpos[0]] . _status
		kst[g_mode . _lpos[1]] := kst[g_mode . _lpos[1]] . _status
		kst[g_mode . _simulMode . _lpos[0]] := _status
		kst[g_mode . _lpos[1] . _lpos[0]] := _status
		kst[g_mode . _lpos[0] . _lpos[1]] := _status
		if( _down <> "")
		{
			if(SubStr(g_mode,1,1)=="R") {
				kLabel[g_mode . _simulMode . _lpos[0]] := Romaji2Kana(org[A_Index])
				kLabel[g_mode . _lpos[1] . _lpos[0]] := Romaji2Kana(org[A_Index])
				kLabel[g_mode . _lpos[0] . _lpos[1]] := Romaji2Kana(org[A_Index])
			} else {
				kLabel[g_mode . _simulMode . _lpos[0]] := org[A_Index]			
				kLabel[g_mode . _lpos[1] . _lpos[0]] := org[A_Index]
				kLabel[g_mode . _lpos[0] . _lpos[1]] := org[A_Index]
			}
			kdn[g_mode . _lpos[1] . _lpos[0]] := _down
			kdn[g_mode . _lpos[0] . _lpos[1]] := _down

			kup[g_mode . _lpos[1] . _lpos[0]] := _up
			kup[g_mode . _lpos[0] . _lpos[1]] := _up
		} else {
			kLabel[g_mode . _simulMode . _lpos[0]] := org[A_Index]
			kst[g_mode . _simulMode . _lpos[0]] := ""

			kLabel[g_mode . _lpos[1] . _lpos[0]] := org[A_Index]
			kLabel[g_mode . _lpos[0] . _lpos[1]] := org[A_Index]
			kst[g_mode . _lpos[1] . _lpos[0]] := ""	
			kst[g_mode . _lpos[0] . _lpos[1]] := ""	
		}
		continue
	}
	return

;----------------------------------------------------------------------
;	ローマ字＋文字同時打鍵のときのキーダウン・キーアップの際に送信する内容を作成
;----------------------------------------------------------------------
SetSimulKeyTable3:
	loop, % CountObject(org)
	{
		_row2 := _rowhash[A_Index]
		_lpos[0] := _col . _row2
		if(ksc[g_mode . _lpos[0]]<3) {
			ksc[g_mode . _lpos[0]] := 3	; 最大同時打鍵数を設定
		}
		; 送信形式に変換・・・なお、文字同時打鍵は小指シフトしない
		GenSendStr3(org[A_Index], _down, _up, _status)
		if(_error <> "") {
			_error := _lpos[0] . ":" . _error
			break
		}
		kst[g_mode . _lpos[0]] := kst[g_mode . _lpos[0]] . _status
		kst[g_mode . _lpos[1]] := kst[g_mode . _lpos[1]] . _status
		kst[g_mode . _lpos[2]] := kst[g_mode . _lpos[2]] . _status
		
		kst[g_mode . _simulMode . _lpos[0]] := _status	; 普通の文字"M" 修飾キーm
		kst[g_mode . _lpos[1] . _lpos[2] . _lpos[0]] := _status
		kst[g_mode . _lpos[0] . _lpos[2] . _lpos[1]] := _status
		kst[g_mode . _lpos[0] . _lpos[1] . _lpos[2]] := _status
		kst[g_mode . _lpos[1] . _lpos[0] . _lpos[2]] := _status
		kst[g_mode . _lpos[2] . _lpos[0] . _lpos[1]] := _status
		kst[g_mode . _lpos[2] . _lpos[1] . _lpos[0]] := _status
		if( _down <> "")
		{
			if(SubStr(g_mode,1,1)=="R") {
				kLabel[g_mode . _simulMode . _lpos[0]] := Romaji2Kana(org[A_Index])
				kLabel[g_mode . _lpos[1] . _lpos[2] . _lpos[0]] := Romaji2Kana(org[A_Index])
				kLabel[g_mode . _lpos[0] . _lpos[2] . _lpos[1]] := Romaji2Kana(org[A_Index])
				kLabel[g_mode . _lpos[0] . _lpos[1] . _lpos[2]] := Romaji2Kana(org[A_Index])
				kLabel[g_mode . _lpos[1] . _lpos[0] . _lpos[2]] := Romaji2Kana(org[A_Index])
				kLabel[g_mode . _lpos[2] . _lpos[0] . _lpos[1]] := Romaji2Kana(org[A_Index])
				kLabel[g_mode . _lpos[2] . _lpos[1] . _lpos[0]] := Romaji2Kana(org[A_Index])
			} else {
				kLabel[g_mode . _simulMode . _lpos[0]] := _aStr0
				kLabel[g_mode . _lpos[1] . _lpos[2] . _lpos[0]] := org[A_Index]
				kLabel[g_mode . _lpos[0] . _lpos[2] . _lpos[1]] := org[A_Index]
				kLabel[g_mode . _lpos[0] . _lpos[1] . _lpos[2]] := org[A_Index]
				kLabel[g_mode . _lpos[1] . _lpos[0] . _lpos[2]] := org[A_Index]
				kLabel[g_mode . _lpos[2] . _lpos[0] . _lpos[1]] := org[A_Index]
				kLabel[g_mode . _lpos[2] . _lpos[1] . _lpos[0]] := org[A_Index]
			}
			kdn[g_mode . _lpos[1] . _lpos[2] . _lpos[0]] := _down
			kdn[g_mode . _lpos[0] . _lpos[2] . _lpos[1]] := _down
			kdn[g_mode . _lpos[0] . _lpos[1] . _lpos[2]] := _down
			kdn[g_mode . _lpos[1] . _lpos[0] . _lpos[2]] := _down
			kdn[g_mode . _lpos[2] . _lpos[0] . _lpos[1]] := _down
			kdn[g_mode . _lpos[2] . _lpos[1] . _lpos[0]] := _down

			kup[g_mode . _lpos[1] . _lpos[2] . _lpos[0]] := _up
			kup[g_mode . _lpos[0] . _lpos[2] . _lpos[1]] := _up
			kup[g_mode . _lpos[0] . _lpos[1] . _lpos[2]] := _up
			kup[g_mode . _lpos[1] . _lpos[0] . _lpos[2]] := _up
			kup[g_mode . _lpos[2] . _lpos[0] . _lpos[1]] := _up
			kup[g_mode . _lpos[2] . _lpos[1] . _lpos[0]] := _up
		} else {
			kLabel[g_mode . _simulMode . _lpos[0]] := org[A_Index]
			kst[g_mode . _simulMode . _lpos[0]] := ""

			kLabel[g_mode . _lpos[1] . _lpos[2] . _lpos[0]] := org[A_Index]
			kLabel[g_mode . _lpos[0] . _lpos[2] . _lpos[1]] := org[A_Index]
			kLabel[g_mode . _lpos[0] . _lpos[1] . _lpos[2]] := org[A_Index]
			kLabel[g_mode . _lpos[1] . _lpos[0] . _lpos[2]] := org[A_Index]
			kLabel[g_mode . _lpos[2] . _lpos[0] . _lpos[1]] := org[A_Index]
			kLabel[g_mode . _lpos[2] . _lpos[1] . _lpos[0]] := org[A_Index]

			kst[g_mode . _lpos[1] . _lpos[2] . _lpos[0]] := ""
			kst[g_mode . _lpos[0] . _lpos[2] . _lpos[1]] := ""
			kst[g_mode . _lpos[0] . _lpos[1] . _lpos[2]] := ""
			kst[g_mode . _lpos[1] . _lpos[0] . _lpos[2]] := ""
			kst[g_mode . _lpos[2] . _lpos[0] . _lpos[1]] := ""
			kst[g_mode . _lpos[2] . _lpos[1] . _lpos[0]] := ""
		}
		continue
	}
	return


;----------------------------------------------------------------------
;	修飾キー＋文字キーの出力の際に送信する内容を作成
;----------------------------------------------------------------------
SetAlphabet:
	mdn[g_mode . "0"] := CountObject(org)
	mup[g_mode . "0"] := mdn[g_mode . "0"] 
	loop, % CountObject(org)
	{
		_row2 := _rowhash[A_Index]
		mdn[g_mode . _col . _row2] := kdn[g_mode . _col . _row2]
		mup[g_mode . _col . _row2] := kup[g_mode . _col . _row2]
	}
	return
	
;----------------------------------------------------------------------
;	カラム配列の複写
;----------------------------------------------------------------------
CopyColumns(_mdsrc, _mddst)
{
	global LF, _rowhash

	if(LF[_mdsrc] == "") 
	{
		return
	}
	LF[_mddst] := LF[_mdsrc]
	LF[_mddst . "E"] := LF[_mdsrc . "E"]
	LF[_mddst . "D"] := LF[_mdsrc . "D"]
	LF[_mddst . "C"] := LF[_mdsrc . "C"]
	LF[_mddst . "B"] := LF[_mdsrc . "B"]
	LF[_mddst . "A"] := LF[_mdsrc . "A"]
	return
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
GenSendStr3(aStr,BYREF _dn,BYREF _up, BYREF _status)
{
	global z2hHash, Chr2vkeyHash, modifierHash, roma3Hash, ctrlKeyHash
	global _error
	
	_error := ""
	_status := ""
	_len := strlen(aStr)	; 全角
	if(_len == 0)
	{
		return ""
	}
	; 入力文字列をAutohotkeyのSend形式に変換
	_dn := ""
	_up := ""
	_quotation := ""
	_qstr := ""
	_vkey := ""
	_vcnt := 0
	_c2 := ""
	_idx := 1
	while(_idx <= _len)
	{
		_a1 := substr(aStr,_idx,1)
		_a2 := substr(aStr,_idx,2)
		
		if(_c2 != "") {
			_dn := _dn .  "{" . _c2 . " up}"
			_c2 := ""
		}
		
		if(_a1 == "v" || _a1 == "V") {	; 仮想キーコードのマーク
			_c2 := "vk"
			_vcnt := 1
			_idx := _idx + 1
		} else if(_vcnt == 1 || _vcnt == 2) {
			if(instr("0123456789ABCDEFabcdef",_a1) == 0) {
				_error := "仮想キーコードの記載が誤っています"
			}
			_c2 := _c2 . _a1
			_vcnt := _vcnt + 1
			if(_vcnt >= 3) {
				_dn := _dn . "{" . _c2 . " down}"
				_vcnt := 0
				_status := _status . "v"		; 仮想キーコード
			}
			_idx := _idx + 1
		} else if(_a1 == "'" || _a1 == """") {	; 引用符のマーク
			if(_quotation == "") {
				_quotation := _a1
			} else {
				_quotation := ""
				_status := _status . "Q"		; 引用があった
			}
			_idx := _idx + 1
		} else if(_quotation != "") {
			_dn := _dn . "{" . _a1 . "}"
			_idx := _idx + 1
		} else if(modifierHash[_a1] != "") {
			if(_idx != _len) {
				_dn := _dn .  modifierHash[_a1]
			}
			_status := _status . "m"			; 修飾キーがあった
			_idx := _idx + 1
		} else {
			if(ctrlKeyHash[_a1] != "") {
				_status := _status . "c"		; 制御キーがあった
			}
			if(roma3Hash[_a2] != "") {
				_c1 := roma3Hash[_a2]
				_idx := _idx + strlen(_a2)
			} else
			if(roma3Hash[_a1] != "") {
				_c1 := roma3Hash[_a1]
				_idx := _idx + 1
			} else {
				_c1 := _a1
				_idx := _idx + 1
			}
			loop,Parse, _c1
			{
				if(_c2 != "") {
					_dn := _dn .  "{" . _c2 . " up}"
					_c2 := ""
				}
				_c2 := z2hHash[A_LoopField]
				if(_c2 != "")
				{
					_dn := _dn .  "{" . _c2 . " down}"
				}
			}
		}
	}
	if(_c2 != "") {
		_up := _up .  "{" . _c2 . " up}"
		_c2 := ""
	}
	if(_quotation != "") {
		_error := "引用符が閉じられていません"
	}
	return _dn
}

;----------------------------------------------------------------------
;	オブジェクトの要素数を数える
;----------------------------------------------------------------------
CountObject(_obj)
{
	_cnt := 0
	enum := _obj._NewEnum()
	While enum[k, v]
	{
		_cnt := _cnt + 1
	}
	return _cnt
}
;----------------------------------------------------------------------
;	オブジェクトの要素を削除
;----------------------------------------------------------------------
RemoveObject(_obj)
{
	if(isObject(_obj)) {
		loop
		{
			_cnt := 0
			enum := _obj._NewEnum()
			While enum[k, v]
			{
				_obj.Remove(k,k)
				_cnt := _cnt + 1
			}
			if(_cnt == 0)
				break
		}
	}
}
;----------------------------------------------------------------------
;	オブジェクトの要素リストを返す
;----------------------------------------------------------------------
listSimulMode(_Romaji)
{
	global g_SimulMode
	
	_ddlist := ""
	enum := g_SimulMode._NewEnum()
	While enum[k, v]
	{
		if(substr(v,1,1)==_Romaji) {
			_ddlist := ddlist . v . "|"
		}
	}
	return _ddlist
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
	Hash["[英数３プリフィックスシフト]"]         := "A3N"	; for 月配列
	Hash["[英数４プリフィックスシフト]"]         := "A4N"	; for 月配列
	Hash["[英数小指１プリフィックスシフト]"]     := "A1K"	; for 月配列
	Hash["[英数小指２プリフィックスシフト]"]     := "A2K"	; for 月配列	
	Hash["[英数小指３プリフィックスシフト]"]     := "A3K"	; for 月配列
	Hash["[英数小指４プリフィックスシフト]"]     := "A4K"	; for 月配列	
	Hash["[ローマ字１プリフィックスシフト]"]     := "R1N"	; for 月配列
	Hash["[ローマ字２プリフィックスシフト]"]     := "R2N"	; for 月配列
	Hash["[ローマ字３プリフィックスシフト]"]     := "R3N"	; for 月配列
	Hash["[ローマ字４プリフィックスシフト]"]     := "R4N"	; for 月配列
	Hash["[ローマ字小指１プリフィックスシフト]"] := "R1K"	; for 月配列
	Hash["[ローマ字小指２プリフィックスシフト]"] := "R2K"	; for 月配列	
	Hash["[ローマ字小指３プリフィックスシフト]"] := "R3K"	; for 月配列
	Hash["[ローマ字小指４プリフィックスシフト]"] := "R4K"	; for 月配列	
	; やまぶき互換
	Hash["[1英数シフト無し]"]     := "A1N"	; for 月配列
	Hash["[2英数シフト無し]"]     := "A2N"	; for 月配列
	Hash["[3英数シフト無し]"]     := "A3N"	; for 月配列
	Hash["[4英数シフト無し]"]     := "A4N"	; for 月配列
	Hash["[1英数小指シフト]"]     := "A1K"	; for 月配列
	Hash["[2英数小指シフト]"]     := "A2K"	; for 月配列
	Hash["[3英数小指シフト]"]     := "A3K"	; for 月配列
	Hash["[4英数小指シフト]"]     := "A4K"	; for 月配列
	Hash["[1ローマ字シフト無し]"] := "R1N"	; for 月配列
	Hash["[2ローマ字シフト無し]"] := "R2N"	; for 月配列
	Hash["[3ローマ字シフト無し]"] := "R3N"	; for 月配列
	Hash["[4ローマ字シフト無し]"] := "R4N"	; for 月配列
	Hash["[1ローマ字小指シフト]"] := "R1K"	; for 月配列
	Hash["[2ローマ字小指シフト]"] := "R2K"	; for 月配列
	Hash["[3ローマ字小指シフト]"] := "R3K"	; for 月配列
	Hash["[4ローマ字小指シフト]"] := "R4K"	; for 月配列
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
	hash["後"] := "BS"	;"Backspace"
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
	hash["表"] := "tab"
	hash["日"] := "vkF2sc070"
	hash["英"] := "vkF0sc03A"
	hash["変"] := "vk1Csc079"
	hash["換"] := "vk1Dsc07B"
	hash["無"] := ""
	hash["濁"] := ""
	hash["半"] := ""
	hash["拗"] := ""
	hash["修"] := ""
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

	hash["うぃ"]   := "ｗｉ"
	hash["うぇ"]   := "ｗｅ"

	hash["ふぁ"] := "ｆａ"
	hash["ふぃ"] := "ｆｉ"
	hash["ふぇ"] := "ｆｅ"
	hash["ふぉ"] := "ｆｏ"

	hash["くぁ"] := "ｑａ"
	hash["くぃ"] := "ｑｉ"
	hash["くぇ"] := "ｑｅ"
	hash["くぉ"] := "ｑｏ"

	hash["きゃ"] := "ｋｙａ"
	hash["きぃ"] := "ｋｙｉ"
	hash["きゅ"] := "ｋｙｕ"
	hash["きぇ"] := "ｋｙｅ"
	hash["きょ"] := "ｋｙｏ"

	hash["ぎゃ"] := "ｇｙａ"
	hash["ぎぃ"] := "ｇｙｉ"
	hash["ぎゅ"] := "ｇｙｕ"
	hash["ぎぇ"] := "ｇｙｅ"
	hash["ぎょ"] := "ｇｙｏ"

	hash["しゃ"] := "ｓｙａ"
	hash["しぃ"] := "ｓｙｉ"
	hash["しゅ"] := "ｓｙｕ"
	hash["しぇ"] := "ｓｙｅ"
	hash["しょ"] := "ｓｙｏ"

	hash["しゃ"] := "ｓｈａ"
	hash["しゅ"] := "ｓｈｕ"
	hash["しぇ"] := "ｓｈｅ"
	hash["しょ"] := "ｓｈｏ"
	
	hash["じゃ"] := "ｚｙａ"
	hash["じぃ"] := "ｚｙｉ"
	hash["じゅ"] := "ｚｙｕ"
	hash["じぇ"] := "ｚｙｅ"
	hash["じょ"] := "ｚｙｏ"

	hash["てゃ"] := "ｔｈａ"
	hash["てぃ"] := "ｔｈｉ"
	hash["てゅ"] := "ｔｈｕ"
	hash["てぇ"] := "ｔｈｅ"
	hash["てょ"] := "ｔｈｏ"

	hash["ちゃ"] := "ｔｙａ"
	hash["ちぃ"] := "ｔｙｉ"
	hash["ちゅ"] := "ｔｙｕ"
	hash["ちぇ"] := "ｔｙｅ"
	hash["ちょ"] := "ｔｙｏ"

	hash["ぢゃ"] := "ｄｙａ"
	hash["ぢぃ"] := "ｄｙｉ"
	hash["ぢゅ"] := "ｄｙｕ"
	hash["ぢぇ"] := "ｄｙｅ"
	hash["ぢょ"] := "ｄｙｏ"

	hash["にゃ"] := "ｎｙａ"
	hash["にぃ"] := "ｎｙｉ"
	hash["にゅ"] := "ｎｙｕ"
	hash["にぇ"] := "ｎｙｅ"
	hash["にょ"] := "ｎｙｏ"

	hash["でゃ"] := "ｄｈａ"
	hash["でぃ"] := "ｄｈｉ"
	hash["でゅ"] := "ｄｈｕ"
	hash["でぇ"] := "ｄｈｅ"
	hash["でょ"] := "ｄｈｏ"

	hash["びゃ"] := "ｂｙａ"
	hash["びぃ"] := "ｂｙｉ"
	hash["びゅ"] := "ｂｙｕ"
	hash["びぇ"] := "ｂｙｅ"
	hash["びょ"] := "ｂｙｏ"

	hash["ひゃ"] := "ｈｙａ"
	hash["ひぃ"] := "ｈｙｉ"
	hash["ひゅ"] := "ｈｙｕ"
	hash["ひぇ"] := "ｈｙｅ"
	hash["ひょ"] := "ｈｙｏ"

	hash["ぴゃ"] := "ｐｙａ"
	hash["ぴぃ"] := "ｐｙｉ"
	hash["ぴゅ"] := "ｐｙｕ"
	hash["ぴぇ"] := "ｐｙｅ"
	hash["ぴょ"] := "ｐｙｏ"

	hash["みゃ"] := "ｍｙａ"
	hash["みぃ"] := "ｍｙｉ"
	hash["みゅ"] := "ｍｙｕ"
	hash["みぇ"] := "ｍｙｅ"
	hash["みょ"] := "ｍｙｏ"

	hash["りゃ"] := "ｒｙａ"
	hash["りぃ"] := "ｒｙｉ"
	hash["りゅ"] := "ｒｙｕ"
	hash["りぇ"] := "ｒｙｅ"
	hash["りょ"] := "ｒｙｏ"
	
	hash["とぁ"] := "ｔｗａ"
	hash["とぃ"] := "ｔｗｉ"
	hash["とぅ"] := "ｔｗｕ"
	hash["とぇ"] := "ｔｗｅ"
	hash["とぉ"] := "ｔｗｏ"

	hash["どぁ"] := "ｄｗａ"
	hash["どぃ"] := "ｄｗｉ"
	hash["どぅ"] := "ｄｗｕ"
	hash["どぇ"] := "ｄｗｅ"
	hash["どぉ"] := "ｄｗｏ"

	hash["ァ"] := "ｌａ"
	hash["ア"] := "ａ"
	hash["ィ"] := "ｌｉ"
	hash["イ"] := "ｉ"
	hash["ゥ"] := "ｌｕ"
	hash["ウ"] := "ｕ"
	hash["ェ"] := "ｌｅ"
	hash["エ"] := "ｅ"
	hash["ォ"] := "ｌｏ"
	hash["オ"] := "ｏ"
	hash["カ"] := "ｋａ"
	hash["ガ"] := "ｇａ"
	hash["キ"] := "ｋｉ"
	hash["ギ"] := "ｇｉ"
	hash["ク"] := "ｋｕ"
	hash["グ"] := "ｇｕ"
	hash["ケ"] := "ｋｅ"
	hash["ゲ"] := "ｇｅ"
	hash["コ"] := "ｋｏ"
	hash["ゴ"] := "ｇｏ"
	hash["サ"] := "ｓａ"
	hash["ザ"] := "ｚａ"
	hash["シ"] := "ｓｉ"
	hash["ジ"] := "ｚｉ"
	hash["ス"] := "ｓｕ"
	hash["ズ"] := "ｚｕ"
	hash["セ"] := "ｓｅ"
	hash["ゼ"] := "ｚｅ"
	hash["ソ"] := "ｓｏ"
	hash["ゾ"] := "ｚｏ"
	hash["タ"] := "ｔａ"
	hash["ダ"] := "ｄａ"
	hash["チ"] := "ｔｉ"
	hash["ヂ"] := "ｄｉ"
	hash["ッ"] := "ｌｔｕ"
	hash["ツ"] := "ｔｕ"
	hash["ヅ"] := "ｄｕ"
	hash["テ"] := "ｔｅ"
	hash["デ"] := "ｄｅ"
	hash["ト"] := "ｔｏ"
	hash["ド"] := "ｄｏ"
	hash["ナ"] := "ｎａ"
	hash["ニ"] := "ｎｉ"
	hash["ヌ"] := "ｎｕ"
	hash["ネ"] := "ｎｅ"
	hash["ノ"] := "ｎｏ"
	hash["ハ"] := "ｈａ"
	hash["バ"] := "ｂａ"
	hash["パ"] := "ｐａ"
	hash["ヒ"] := "ｈｉ"
	hash["ビ"] := "ｂｉ"
	hash["ピ"] := "ｐｉ"
	hash["フ"] := "ｆｕ"
	hash["ブ"] := "ｂｕ"
	hash["プ"] := "ｐｕ"
	hash["ヘ"] := "ｈｅ"
	hash["ベ"] := "ｂｅ"
	hash["ペ"] := "ｐｅ"
	hash["ホ"] := "ｈｏ"
	hash["ボ"] := "ｂｏ"
	hash["ポ"] := "ｐｏ"
	hash["マ"] := "ｍａ"
	hash["ミ"] := "ｍｉ"
	hash["ム"] := "ｍｕ"
	hash["メ"] := "ｍｅ"
	hash["モ"] := "ｍｏ"
	hash["ャ"] := "ｌｙａ"
	hash["ヤ"] := "ｙａ"
	hash["ュ"] := "ｌｙｕ"
	hash["ユ"] := "ｙｕ"
	hash["ョ"] := "ｌｙｏ"
	hash["ヨ"] := "ｙｏ"
	hash["ラ"] := "ｒａ"
	hash["リ"] := "ｒｉ"
	hash["ル"] := "ｒｕ"
	hash["レ"] := "ｒｅ"
	hash["ロ"] := "ｒｏ"
	hash["ヮ"] := "ｌｗａ"
	hash["ワ"] := "ｗａ"
	hash["ヰ"] := "ｗｙｉ"
	hash["ヱ"] := "ｗｙｅ"
	hash["ヲ"] := "ｗｏ"
	hash["ン"] := "ｎｎ"
	hash["ヴ"] := "ｖｕ"
	hash["ヵ"] := "ｌｋａ"
	hash["ヶ"] := "ｌｋｅ"

	hash["ウィ"] := "ｗｉ"
	hash["ウェ"] := "ｗｅ"

	hash["ファ"] := "ｆａ"
	hash["フィ"] := "ｆｉ"
	hash["フェ"] := "ｆｅ"
	hash["フォ"] := "ｆｏ"

	hash["クァ"] := "ｑａ"
	hash["クィ"] := "ｑｉ"
	hash["クェ"] := "ｑｅ"
	hash["クォ"] := "ｑｏ"

	hash["キャ"] := "ｋｙａ"
	hash["キィ"] := "ｋｙｉ"
	hash["キュ"] := "ｋｙｕ"
	hash["キェ"] := "ｋｙｅ"
	hash["キョ"] := "ｋｙｏ"

	hash["ギャ"] := "ｇｙａ"
	hash["ギィ"] := "ｇｙｉ"
	hash["ギュ"] := "ｇｙｕ"
	hash["ギェ"] := "ｇｙｅ"
	hash["ギョ"] := "ｇｙｏ"

	hash["シャ"] := "ｓｙａ"
	hash["シィ"] := "ｓｙｉ"
	hash["シュ"] := "ｓｙｕ"
	hash["シェ"] := "ｓｙｅ"
	hash["ショ"] := "ｓｙｏ"

	hash["ジャ"] := "ｚｙａ"
	hash["ジィ"] := "ｚｙｉ"
	hash["ジュ"] := "ｚｙｕ"
	hash["ジェ"] := "ｚｙｅ"
	hash["ジョ"] := "ｚｙｏ"

	hash["テャ"] := "ｔｈａ"
	hash["ティ"] := "ｔｈｉ"
	hash["テュ"] := "ｔｈｕ"
	hash["テェ"] := "ｔｈｅ"
	hash["テョ"] := "ｔｈｏ"

	hash["チャ"] := "ｔｙａ"
	hash["チィ"] := "ｔｙｉ"
	hash["チュ"] := "ｔｙｕ"
	hash["チェ"] := "ｔｙｅ"
	hash["チョ"] := "ｔｙｏ"

	hash["ヂャ"] := "ｄｙａ"
	hash["ヂィ"] := "ｄｙｉ"
	hash["ヂュ"] := "ｄｙｕ"
	hash["ヂェ"] := "ｄｙｅ"
	hash["ヂョ"] := "ｄｙｏ"

	hash["ニャ"] := "ｎｙａ"
	hash["ニィ"] := "ｎｙｉ"
	hash["ニュ"] := "ｎｙｕ"
	hash["ニェ"] := "ｎｙｅ"
	hash["ニョ"] := "ｎｙｏ"

	hash["デャ"] := "ｄｈａ"
	hash["ディ"] := "ｄｈｉ"
	hash["デュ"] := "ｄｈｕ"
	hash["デェ"] := "ｄｈｅ"
	hash["デョ"] := "ｄｈｏ"

	hash["ビャ"] := "ｂｙａ"
	hash["ビィ"] := "ｂｙｉ"
	hash["ビュ"] := "ｂｙｕ"
	hash["ビェ"] := "ｂｙｅ"
	hash["ビョ"] := "ｂｙｏ"

	hash["ヒャ"] := "ｈｙａ"
	hash["ヒィ"] := "ｈｙｉ"
	hash["ヒュ"] := "ｈｙｕ"
	hash["ヒェ"] := "ｈｙｅ"
	hash["ヒョ"] := "ｈｙｏ"

	hash["ピャ"] := "ｐｙａ"
	hash["ピィ"] := "ｐｙｉ"
	hash["ピュ"] := "ｐｙｕ"
	hash["ピェ"] := "ｐｙｅ"
	hash["ピョ"] := "ｐｙｏ"

	hash["ミャ"] := "ｍｙａ"
	hash["ミィ"] := "ｍｙｉ"
	hash["ミュ"] := "ｍｙｕ"
	hash["ミェ"] := "ｍｙｅ"
	hash["ミョ"] := "ｍｙｏ"

	hash["リャ"] := "ｒｙａ"
	hash["リィ"] := "ｒｙｉ"
	hash["リュ"] := "ｒｙｕ"
	hash["リェ"] := "ｒｙｅ"
	hash["リョ"] := "ｒｙｏ"
	
	hash["トァ"] := "ｔｗａ"
	hash["トィ"] := "ｔｗｉ"
	hash["トゥ"] := "ｔｗｕ"
	hash["トェ"] := "ｔｗｅ"
	hash["トォ"] := "ｔｗｏ"

	hash["ドァ"] := "ｄｗａ"
	hash["ドィ"] := "ｄｗｉ"
	hash["ドゥ"] := "ｄｗｕ"
	hash["ドェ"] := "ｄｗｅ"
	hash["ドォ"] := "ｄｗｏ"
	return hash
}

;----------------------------------------------------------------------
; 濁音表層ハッシュを生成
;----------------------------------------------------------------------
MakeDakuonSurfaceHash()
{
	hash := Object()
	hash["う"] := "ゔ"
	hash["ぅ"] := "ゔ"
	hash["か"] := "が"
	hash["き"] := "ぎ"
	hash["く"] := "ぐ"
	hash["け"] := "げ"
	hash["こ"] := "ご"

	hash["さ"] := "ざ"
	hash["し"] := "じ"
	hash["す"] := "ず"
	hash["せ"] := "ぜ"
	hash["そ"] := "ぞ"

	hash["た"] := "だ"
	hash["ち"] := "ぢ"
	hash["つ"] := "づ"
	hash["っ"] := "づ"
	hash["て"] := "で"
	hash["と"] := "ど"

	hash["は"] := "ば"
	hash["ひ"] := "び"
	hash["ふ"] := "ぶ"
	hash["へ"] := "べ"
	hash["ほ"] := "ぼ"

	hash["ぱ"] := "ば"
	hash["ぴ"] := "び"
	hash["ぷ"] := "ぶ"
	hash["ぺ"] := "べ"
	hash["ぽ"] := "ぼ"

	hash["ゔ"] := "う"
	hash["が"] := "か"
	hash["ぎ"] := "き"
	hash["ぐ"] := "く"
	hash["げ"] := "け"
	hash["ご"] := "こ"

	hash["ざ"] := "さ"
	hash["じ"] := "し"
	hash["ず"] := "す"
	hash["ぜ"] := "せ"
	hash["ぞ"] := "そ"

	hash["だ"] := "た"
	hash["ぢ"] := "ち"
	hash["づ"] := "つ"
	hash["で"] := "て"
	hash["ど"] := "と"

	hash["ば"] := "は"
	hash["び"] := "ひ"
	hash["ぶ"] := "ふ"
	hash["べ"] := "へ"
	hash["ぼ"] := "ほ"
	return hash
}

;----------------------------------------------------------------------
; 半濁音表層ハッシュ
;----------------------------------------------------------------------
MakeHanDakuonSurfaceHash()
{
	hash := Object()
	hash["は"] := "ぱ"
	hash["ひ"] := "ぴ"
	hash["ふ"] := "ぷ"
	hash["へ"] := "ぺ"
	hash["ほ"] := "ぽ"

	hash["ば"] := "ぱ"
	hash["び"] := "ぴ"
	hash["ぶ"] := "ぷ"
	hash["べ"] := "ぺ"
	hash["ぼ"] := "ぽ"

	hash["ぱ"] := "は"
	hash["ぴ"] := "ひ"
	hash["ぷ"] := "ふ"
	hash["ぺ"] := "へ"
	hash["ぽ"] := "ほ"
	return hash
}
;----------------------------------------------------------------------
; 拗音表層ハッシュ
;----------------------------------------------------------------------
MakeYouonSurfaceHash()
{
	hash := Object()
	hash["あ"] := "ぁ"
	hash["い"] := "ぃ"
	hash["う"] := "ぅ"
	hash["ゔ"] := "ぅ"
	hash["え"] := "ぇ"
	hash["お"] := "ぉ"
	hash["か"] := "ゕ"
	hash["が"] := "ゕ"
	hash["け"] := "ゖ"
	hash["げ"] := "ゖ"
	hash["つ"] := "っ"
	hash["づ"] := "っ"

	hash["や"] := "ゃ"
	hash["ゆ"] := "ゅ"
	hash["よ"] := "ょ"
	hash["わ"] := "ゎ"
	
	hash["ぁ"] := "あ"
	hash["ぃ"] := "い"
	hash["ぅ"] := "う"
	hash["ぇ"] := "え"
	hash["ぉ"] := "お"
	hash["ゕ"] := "か"
	hash["ゕ"] := "が"
	hash["ゖ"] := "け"
	hash["ゖ"] := "げ"
	hash["っ"] := "つ"

	hash["ゃ"] := "や"
	hash["ゅ"] := "ゆ"
	hash["ょ"] := "よ"
	hash["ゎ"] := "わ"
	return hash
}
;----------------------------------------------------------------------
; 修正表層ハッシュを生成
;----------------------------------------------------------------------
MakeCorrectSurfaceHash()
{
	hash := Object()
	hash["あ"] := "ぁ"
	hash["ぁ"] := "あ"

	hash["い"] := "ぃ"
	hash["ぃ"] := "い"

	hash["う"] := "ゔ"
	hash["ゔ"] := "ぅ"
	hash["ぅ"] := "う"

	hash["ぇ"] := "え"
	hash["え"] := "ぇ"
	hash["ぉ"] := "お"
	hash["お"] := "ぉ"

	hash["か"] := "が"
	hash["が"] := "ゕ"
	hash["ゕ"] := "か"
	
	hash["き"] := "ぎ"
	hash["ぎ"] := "き"

	hash["く"] := "ぐ"
	hash["ぐ"] := "く"

	hash["け"] := "げ"
	hash["げ"] := "ゖ"
	hash["ゖ"] := "け"

	hash["こ"] := "ご"
	hash["ご"] := "こ"

	hash["さ"] := "ざ"
	hash["ざ"] := "さ"

	hash["し"] := "じ"
	hash["じ"] := "し"

	hash["す"] := "ず"
	hash["ず"] := "す"

	hash["せ"] := "ぜ"
	hash["ぜ"] := "せ"

	hash["そ"] := "ぞ"
	hash["ぞ"] := "そ"

	hash["た"] := "だ"
	hash["だ"] := "た"
	hash["ち"] := "ぢ"
	hash["ぢ"] := "ち"
	hash["つ"] := "づ"
	hash["づ"] := "っ"
	hash["っ"] := "つ"
	hash["て"] := "で"
	hash["で"] := "て"
	hash["と"] := "ど"
	hash["ど"] := "と"

	hash["は"] := "ぱ"
	hash["ぱ"] := "ば"
	hash["ば"] := "は"
	
	hash["ひ"] := "ぴ"
	hash["ぴ"] := "び"
	hash["び"] := "ひ"

	hash["ふ"] := "ぷ"
	hash["ぷ"] := "ぶ"
	hash["ぶ"] := "ふ"

	hash["へ"] := "ぺ"
	hash["ぺ"] := "べ"
	hash["べ"] := "へ"

	hash["ほ"] := "ぽ"
	hash["ぽ"] := "ぼ"
	hash["ぼ"] := "ほ"

	hash["や"] := "ゃ"
	hash["ゃ"] := "や"

	hash["ゆ"] := "ゅ"
	hash["ゅ"] := "ゆ"

	hash["よ"] := "ょ"
	hash["ょ"] := "よ"

	hash["ゎ"] := "わ"
	hash["わ"] := "ゎ"
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
	hash["ｗｙｉ"] := "ゐ"
	hash["ｗｅ"]   := "うぇ"
	hash["ｗｙｅ"] := "ゑ"
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
	hash["ｆｕ"] := "ふ"
	hash["ｆｅ"] := "ふぇ"
	hash["ｆｏ"] := "ふぉ"

	hash["ｑａ"] := "くぁ"
	hash["ｑｉ"] := "くぃ"
	hash["ｑｕ"] := "く"
	hash["ｑｅ"] := "くぇ"
	hash["ｑｏ"] := "くぉ"

	hash["ｃａ"] := "か"
	hash["ｃｉ"] := "し"
	hash["ｃｕ"] := "く"
	hash["ｃｅ"] := "せ"
	hash["ｃｏ"] := "こ"
	
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

	hash["ｊｙａ"] := "じゃ"
	hash["ｊｙｉ"] := "じぃ"
	hash["ｊｙｕ"] := "じゅ"
	hash["ｊｙｅ"] := "じぇ"
	hash["ｊｙｏ"] := "じょ"

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

	hash["ｄｙａ"] := "ぢゃ"
	hash["ｄｙｉ"] := "ぢぃ"
	hash["ｄｙｕ"] := "ぢゅ"
	hash["ｄｙｅ"] := "ぢぇ"
	hash["ｄｙｏ"] := "ぢょ"

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
	
	hash["ｔｗａ"] := "とぁ"
	hash["ｔｗｉ"] := "とぃ"
	hash["ｔｗｕ"] := "とぅ"
	hash["ｔｗｅ"] := "とぇ"
	hash["ｔｗｏ"] := "とぉ"

	hash["ｄｗａ"] := "どぁ"
	hash["ｄｗｉ"] := "どぃ"
	hash["ｄｗｕ"] := "どぅ"
	hash["ｄｗｅ"] := "どぇ"
	hash["ｄｗｏ"] := "どぉ"
	return hash
}

;----------------------------------------------------------------------
;	キー名から処理関数に変換
;	連想配列：ローマ字／英数、小指シフト、配列位置
;
;	M:文字キー
;	X:修飾キー
;	S:同時打鍵キー
;	L:左親指キー
;	R:右親指キー
;----------------------------------------------------------------------
MakeKeyAttribute3Hash() {
	keyAttribute3 := Object()
	keyAttribute3["ANE00"] := "X"	; 半角/全角
	keyAttribute3["AKE00"] := "X"	; 半角/全角
	keyAttribute3["RNE00"] := "X"	; 半角/全角
	keyAttribute3["RKE00"] := "X"	; 半角/全角
	keyAttribute3["ANE01"] := "M"
	keyAttribute3["AKE01"] := "M"
	keyAttribute3["RNE01"] := "M"
	keyAttribute3["RKE01"] := "M"
	keyAttribute3["ANE02"] := "M"
	keyAttribute3["AKE02"] := "M"
	keyAttribute3["RNE02"] := "M"
	keyAttribute3["RKE02"] := "M"
	keyAttribute3["ANE03"] := "M"
	keyAttribute3["AKE03"] := "M"
	keyAttribute3["RNE03"] := "M"
	keyAttribute3["RKE03"] := "M"
	keyAttribute3["ANE04"] := "M"
	keyAttribute3["AKE04"] := "M"
	keyAttribute3["RNE04"] := "M"
	keyAttribute3["RKE04"] := "M"
	keyAttribute3["ANE05"] := "M"
	keyAttribute3["AKE05"] := "M"
	keyAttribute3["RNE05"] := "M"
	keyAttribute3["RKE05"] := "M"
	keyAttribute3["ANE06"] := "M"
	keyAttribute3["AKE06"] := "M"
	keyAttribute3["RNE06"] := "M"
	keyAttribute3["RKE06"] := "M"
	keyAttribute3["ANE07"] := "M"
	keyAttribute3["AKE07"] := "M"
	keyAttribute3["RNE07"] := "M"
	keyAttribute3["RKE07"] := "M"
	keyAttribute3["ANE08"] := "M"
	keyAttribute3["AKE08"] := "M"
	keyAttribute3["RNE08"] := "M"
	keyAttribute3["RKE08"] := "M"
	keyAttribute3["ANE09"] := "M"
	keyAttribute3["AKE09"] := "M"
	keyAttribute3["RNE09"] := "M"
	keyAttribute3["RKE09"] := "M"
	keyAttribute3["ANE10"] := "M"
	keyAttribute3["AKE10"] := "M"
	keyAttribute3["RNE10"] := "M"
	keyAttribute3["RKE10"] := "M"
	keyAttribute3["ANE11"] := "M"
	keyAttribute3["AKE11"] := "M"
	keyAttribute3["RNE11"] := "M"
	keyAttribute3["RKE11"] := "M"
	keyAttribute3["ANE12"] := "M"
	keyAttribute3["AKE12"] := "M"
	keyAttribute3["RNE12"] := "M"
	keyAttribute3["RKE12"] := "M"
	keyAttribute3["ANE13"] := "M"
	keyAttribute3["AKE13"] := "M"
	keyAttribute3["RNE13"] := "M"
	keyAttribute3["RKE13"] := "M"
	keyAttribute3["ANE14"] := "M"	; Backspace
	keyAttribute3["AKE14"] := "M"	; Backspace
	keyAttribute3["RNE14"] := "M"	; Backspace
	keyAttribute3["RKE14"] := "M"	; Backspace
	keyAttribute3["AND00"] := "X"	; Tab
	keyAttribute3["AKD00"] := "X"	; Tab
	keyAttribute3["RND00"] := "X"	; Tab
	keyAttribute3["RKD00"] := "X"	; Tab
	keyAttribute3["AND01"] := "M"
	keyAttribute3["AKD01"] := "M"
	keyAttribute3["RND01"] := "M"
	keyAttribute3["RKD01"] := "M"
	keyAttribute3["AND02"] := "M"
	keyAttribute3["AKD02"] := "M"
	keyAttribute3["RND02"] := "M"
	keyAttribute3["RKD02"] := "M"
	keyAttribute3["AND03"] := "M"
	keyAttribute3["AKD03"] := "M"
	keyAttribute3["RND03"] := "M"
	keyAttribute3["RKD03"] := "M"
	keyAttribute3["AND04"] := "M"
	keyAttribute3["AKD04"] := "M"
	keyAttribute3["RND04"] := "M"
	keyAttribute3["RKD04"] := "M"
	keyAttribute3["AND05"] := "M"
	keyAttribute3["AKD05"] := "M"
	keyAttribute3["RND05"] := "M"
	keyAttribute3["RKD05"] := "M"
	keyAttribute3["AND06"] := "M"
	keyAttribute3["AKD06"] := "M"
	keyAttribute3["RND06"] := "M"
	keyAttribute3["RKD06"] := "M"
	keyAttribute3["AND07"] := "M"
	keyAttribute3["AKD07"] := "M"
	keyAttribute3["RND07"] := "M"
	keyAttribute3["RKD07"] := "M"
	keyAttribute3["AND08"] := "M"
	keyAttribute3["AKD08"] := "M"
	keyAttribute3["RND08"] := "M"
	keyAttribute3["RKD08"] := "M"
	keyAttribute3["AND09"] := "M"
	keyAttribute3["AKD09"] := "M"
	keyAttribute3["RND09"] := "M"
	keyAttribute3["RKD09"] := "M"
	keyAttribute3["AND10"] := "M"
	keyAttribute3["AKD10"] := "M"
	keyAttribute3["RND10"] := "M"
	keyAttribute3["RKD10"] := "M"
	keyAttribute3["AND11"] := "M"
	keyAttribute3["AKD11"] := "M"
	keyAttribute3["RND11"] := "M"
	keyAttribute3["RKD11"] := "M"
	keyAttribute3["AND12"] := "M"
	keyAttribute3["AKD12"] := "M"
	keyAttribute3["RND12"] := "M"
	keyAttribute3["RKD12"] := "M"
	keyAttribute3["ANC01"] := "M"
	keyAttribute3["AKC01"] := "M"
	keyAttribute3["RNC01"] := "M"
	keyAttribute3["RKC01"] := "M"
	keyAttribute3["ANC02"] := "M"
	keyAttribute3["AKC02"] := "M"
	keyAttribute3["RNC02"] := "M"
	keyAttribute3["RKC02"] := "M"
	keyAttribute3["ANC03"] := "M"
	keyAttribute3["AKC03"] := "M"
	keyAttribute3["RNC03"] := "M"
	keyAttribute3["RKC03"] := "M"
	keyAttribute3["ANC04"] := "M"
	keyAttribute3["AKC04"] := "M"
	keyAttribute3["RNC04"] := "M"
	keyAttribute3["RKC04"] := "M"
	keyAttribute3["ANC05"] := "M"
	keyAttribute3["AKC05"] := "M"
	keyAttribute3["RNC05"] := "M"
	keyAttribute3["RKC05"] := "M"
	keyAttribute3["ANC06"] := "M"
	keyAttribute3["AKC06"] := "M"
	keyAttribute3["RNC06"] := "M"
	keyAttribute3["RKC06"] := "M"
	keyAttribute3["ANC07"] := "M"
	keyAttribute3["AKC07"] := "M"
	keyAttribute3["RNC07"] := "M"
	keyAttribute3["RKC07"] := "M"
	keyAttribute3["ANC08"] := "M"
	keyAttribute3["AKC08"] := "M"
	keyAttribute3["RNC08"] := "M"
	keyAttribute3["RKC08"] := "M"
	keyAttribute3["ANC09"] := "M"
	keyAttribute3["AKC09"] := "M"
	keyAttribute3["RNC09"] := "M"
	keyAttribute3["RKC09"] := "M"
	keyAttribute3["ANC10"] := "M"
	keyAttribute3["AKC10"] := "M"
	keyAttribute3["RNC10"] := "M"
	keyAttribute3["RKC10"] := "M"
	keyAttribute3["ANC11"] := "M"
	keyAttribute3["AKC11"] := "M"
	keyAttribute3["RNC11"] := "M"
	keyAttribute3["RKC11"] := "M"
	keyAttribute3["ANC12"] := "M"
	keyAttribute3["AKC12"] := "M"
	keyAttribute3["RNC12"] := "M"
	keyAttribute3["RKC12"] := "M"
	keyAttribute3["ANC13"] := "X"	; Enter
	keyAttribute3["AKC13"] := "X"	; Enter
	keyAttribute3["RNC13"] := "X"	; Enter
	keyAttribute3["RKC13"] := "X"	; Enter
	keyAttribute3["ANB01"] := "M"
	keyAttribute3["AKB01"] := "M"
	keyAttribute3["RNB01"] := "M"
	keyAttribute3["RKB01"] := "M"
	keyAttribute3["ANB02"] := "M"
	keyAttribute3["AKB02"] := "M"
	keyAttribute3["RNB02"] := "M"
	keyAttribute3["RKB02"] := "M"
	keyAttribute3["ANB03"] := "M"
	keyAttribute3["AKB03"] := "M"
	keyAttribute3["RNB03"] := "M"
	keyAttribute3["RKB03"] := "M"
	keyAttribute3["ANB04"] := "M"
	keyAttribute3["AKB04"] := "M"
	keyAttribute3["RNB04"] := "M"
	keyAttribute3["RKB04"] := "M"
	keyAttribute3["ANB05"] := "M"
	keyAttribute3["AKB05"] := "M"
	keyAttribute3["RNB05"] := "M"
	keyAttribute3["RKB05"] := "M"
	keyAttribute3["ANB06"] := "M"
	keyAttribute3["AKB06"] := "M"
	keyAttribute3["RNB06"] := "M"
	keyAttribute3["RKB06"] := "M"
	keyAttribute3["ANB07"] := "M"
	keyAttribute3["AKB07"] := "M"
	keyAttribute3["RNB07"] := "M"
	keyAttribute3["RKB07"] := "M"
	keyAttribute3["ANB08"] := "M"
	keyAttribute3["AKB08"] := "M"
	keyAttribute3["RNB08"] := "M"
	keyAttribute3["RKB08"] := "M"
	keyAttribute3["ANB09"] := "M"
	keyAttribute3["AKB09"] := "M"
	keyAttribute3["RNB09"] := "M"
	keyAttribute3["RKB09"] := "M"
	keyAttribute3["ANB10"] := "M"
	keyAttribute3["AKB10"] := "M"
	keyAttribute3["RNB10"] := "M"
	keyAttribute3["RKB10"] := "M"
	keyAttribute3["ANB11"] := "M"
	keyAttribute3["AKB11"] := "M"
	keyAttribute3["RNB11"] := "M"
	keyAttribute3["RKB11"] := "M"
	keyAttribute3["ANA00"] := "X"	; LCtrl
	keyAttribute3["AKA00"] := "X"	; LCtrl
	keyAttribute3["RNA00"] := "X"	; LCtrl
	keyAttribute3["RKA00"] := "X"	; LCtrl
	keyAttribute3["ANA01"] := "X"
	keyAttribute3["AKA01"] := "X"
	keyAttribute3["RNA01"] := "X"
	keyAttribute3["RKA01"] := "X"
	keyAttribute3["ANA02"] := "X"	; Space
	keyAttribute3["AKA02"] := "X"	; Space
	keyAttribute3["RNA02"] := "X"	; Space
	keyAttribute3["RKA02"] := "X"	; Space
	keyAttribute3["ANA03"] := "X"
	keyAttribute3["AKA03"] := "X"
	keyAttribute3["RNA03"] := "X"
	keyAttribute3["RKA03"] := "X"
	keyAttribute3["ANA04"] := "X"	; カタカナひらがな
	keyAttribute3["AKA04"] := "X"	; カタカナひらがな
	keyAttribute3["RNA04"] := "X"	; カタカナひらがな
	keyAttribute3["RKA04"] := "X"	; カタカナひらがな
	keyAttribute3["ANA05"] := "X"	; Rctrl
	keyAttribute3["AKA05"] := "X"	; Rctrl
	keyAttribute3["RNA05"] := "X"	; Rctrl
	keyAttribute3["RKA05"] := "X"	; Rctrl
	return keyAttribute3
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
MakeCode2SimulPos()
{
	hash := Object()
	hash["<1>"] := "E01"		;1	キーオン（出力されたら解除）
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

	hash["{1}"] := "E01"		;1  キーが押されている
	hash["{2}"] := "E02"		;2
	hash["{3}"] := "E03"		;3
	hash["{4}"] := "E04"		;4
	hash["{5}"] := "E05"		;5
	hash["{6}"] := "E06"		;6
	hash["{7}"] := "E07"		;7
	hash["{8}"] := "E08"		;8
	hash["{9}"] := "E09"		;9
	hash["{0}"] := "E10"		;0
	hash["{-}"] := "E11"		;-
	hash["{^}"] := "E12"		;^
	hash["{\}"] := "E13"		;\

	hash["{q}"] := "D01"		;q
	hash["{w}"] := "D02"		;w
	hash["{e}"] := "D03"		;e
	hash["{r}"] := "D04"		;r
	hash["{t}"] := "D05"		;t
	hash["{y}"] := "D06"		;y
	hash["{u}"] := "D07"		;u
	hash["{i}"] := "D08"		;i
	hash["{o}"] := "D09"		;o
	hash["{p}"] := "D10"		;p
	hash["{@}"] := "D11"		;@
	hash["{[}"] := "D12"		;[

	hash["{a}"] := "C01"		;a
	hash["{s}"] := "C02"		;s
	hash["{d}"] := "C03"		;d
	hash["{f}"] := "C04"		;f
	hash["{g}"] := "C05"		;g
	hash["{h}"] := "C06"		;h
	hash["{j}"] := "C07"		;j
	hash["{k}"] := "C08"		;k
	hash["{l}"] := "C09"		;l
	hash["{;}"] := "C10"		;;
	hash["{:}"] := "C11"		;:
	hash["{]}"] := "C12"		;]

	hash["{z}"] := "B01"		;z
	hash["{x}"] := "B02"		;x
	hash["{c}"] := "B03"		;c
	hash["{v}"] := "B04"		;v
	hash["{b}"] := "B05"		;b
	hash["{n}"] := "B06"		;n
	hash["{m}"] := "B07"		;m
	hash["{,}"] := "B08"		;,
	hash["{.}"] := "B09"		;.
	hash["{/}"] := "B10"		;/
	hash["{\}"] := "B11"		;\
	return hash
}

;----------------------------------------------------------------------
;	キー名を連続シフトの配列位置に変換
;----------------------------------------------------------------------
MakeCode2ContPos()
{
	hash := Object()
	hash["<1>"] := "E01"		;1	キーオン（出力されたら解除）
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

	hash["{1}"] := "501"		;1  キーが押されている
	hash["{2}"] := "502"		;2
	hash["{3}"] := "503"		;3
	hash["{4}"] := "504"		;4
	hash["{5}"] := "505"		;5
	hash["{6}"] := "506"		;6
	hash["{7}"] := "507"		;7
	hash["{8}"] := "508"		;8
	hash["{9}"] := "509"		;9
	hash["{0}"] := "510"		;0
	hash["{-}"] := "511"		;-
	hash["{^}"] := "512"		;^
	hash["{\}"] := "513"		;\

	hash["{q}"] := "401"		;q
	hash["{w}"] := "402"		;w
	hash["{e}"] := "403"		;e
	hash["{r}"] := "404"		;r
	hash["{t}"] := "405"		;t
	hash["{y}"] := "406"		;y
	hash["{u}"] := "407"		;u
	hash["{i}"] := "408"		;i
	hash["{o}"] := "409"		;o
	hash["{p}"] := "410"		;p
	hash["{@}"] := "411"		;@
	hash["{[}"] := "412"		;[

	hash["{a}"] := "301"		;a
	hash["{s}"] := "302"		;s
	hash["{d}"] := "303"		;d
	hash["{f}"] := "304"		;f
	hash["{g}"] := "305"		;g
	hash["{h}"] := "306"		;h
	hash["{j}"] := "307"		;j
	hash["{k}"] := "308"		;k
	hash["{l}"] := "309"		;l
	hash["{;}"] := "310"		;;
	hash["{:}"] := "311"		;:
	hash["{]}"] := "312"		;]

	hash["{z}"] := "201"		;z
	hash["{x}"] := "202"		;x
	hash["{c}"] := "203"		;c
	hash["{v}"] := "204"		;v
	hash["{b}"] := "205"		;b
	hash["{n}"] := "206"		;n
	hash["{m}"] := "207"		;m
	hash["{,}"] := "208"		;,
	hash["{.}"] := "209"		;.
	hash["{/}"] := "210"		;/
	hash["{\}"] := "211"		;\
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
	hash["E14"] := "Backspace"	;\b

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
	hash["A02"] := "sc039"	;スペース
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
	hash["*sc00E"]    := "E14"	; \b

	hash["*sc00F"]    := "D00"	;tab
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
	hash["*sc01C"]    := "C13"	;Enter
	
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
	hash["*sc039"]    := "A02"
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
	hash["*sc00E up"] := "E14"	; \b

	hash["*sc00F up"] := "D00"	;tab
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
	hash["*sc01C up"] := "C13"	;Enter

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
	hash["*sc039 up"] := "A02"
	hash["*sc079 up"] := "A03"
	hash["*sc070 up"] := "A04"
	hash["RCtrl up"]  := "A05"
	return hash
}
;----------------------------------------------------------------------
;	レイアウト位置からスキャンコードの変換
;----------------------------------------------------------------------
MakeScanCodeHash()
{
	hash := Object()
	hash["E00"] := "sc029"	;半角／全角
	hash["E01"] := "sc002"	;1
	hash["E02"] := "sc003"
	hash["E03"] := "sc004"
	hash["E04"] := "sc005"
	hash["E05"] := "sc006"
	hash["E06"] := "sc007"
	hash["E07"] := "sc008"
	hash["E08"] := "sc009"
	hash["E09"] := "sc00A"
	hash["E10"] := "sc00B"
	hash["E11"] := "sc00C"
	hash["E12"] := "sc00D"
	hash["E13"] := "sc07D"
	hash["E14"] := "sc00E"	; \b

	hash["D00"] := "sc00F"	;tab
	hash["D01"] := "sc010"
	hash["D02"] := "sc011"
	hash["D03"] := "sc012"
	hash["D04"] := "sc013"
	hash["D05"] := "sc014"
	hash["D06"] := "sc015"
	hash["D07"] := "sc016"
	hash["D08"] := "sc017"
	hash["D09"] := "sc018"
	hash["D10"] := "sc019"
	hash["D11"] := "sc01A"
	hash["D12"] := "sc01B"
	
	hash["C01"] := "sc01E"
	hash["C02"] := "sc01F"
	hash["C03"] := "sc020"
	hash["C04"] := "sc021"
	hash["C05"] := "sc022"
	hash["C06"] := "sc023"
	hash["C07"] := "sc024"
	hash["C08"] := "sc025"
	hash["C09"] := "sc026"
	hash["C10"] := "sc027"
	hash["C11"] := "sc028"
	hash["C12"] := "sc02B"
	hash["C13"] := "sc01C"	;Enter
	
	hash["B01"] := "sc02C"
	hash["B02"] := "sc02D"
	hash["B03"] := "sc02E"
	hash["B04"] := "sc02F"
	hash["B05"] := "sc030"
	hash["B06"] := "sc031"
	hash["B07"] := "sc032"
	hash["B08"] := "sc033"
	hash["B09"] := "sc034"
	hash["B10"] := "sc035"
	hash["B11"] := "sc073"

	hash["A00"] := "sc01D"
	hash["A01"] := "sc07B"
	hash["A02"] := "sc039"
	hash["A03"] := "sc079"
	hash["A04"] := "sc070"	;カタカナ/ひらがな
	hash["A05"] := "sc11D"
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
	hash["sc00E"]     := "E14"

	hash["Tab"]       := "D00"
	hash["sc00F"]     := "D00"
	hash["Enter"]     := "C13"
	hash["sc01C"]     := "C13"

	hash["左Ctrl"] := "A00"
	hash["無変換"] := "A01"	;無変換
	hash["Space"]  := "A02"	;スペース
	hash["sc039"]  := "A02"	;スペース
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
	hash["Backspace"] := "sc00E"

	hash["Tab"]       := "sc00F"
	hash["Enter"]     := "sc039"

	hash["左Ctrl"]    := "LCtrl"
	hash["無変換"]    := "sc07B"	;無変換
	hash["Space"]     := "sc039"	;スペース
	hash["変換"]      := "sc079"	;変換
	hash["カタカナ/ひらがな"] := "sc070"	;カタカナ/ひらがな
	hash["右Ctrl"]    := "RCtrl"
	hash["Space&Shift"] := "sc039"	;スペース＆シフト
	return hash
}

;----------------------------------------------------------------------
;	機能キー名とコードの変換
;----------------------------------------------------------------------
MakeCodeNameHash()
{
	hash := Object()
	hash["sc029"]     := "半/全 "	;半角／全角
	hash["sc00E"]     := "Backsp"

	hash["sc00F"]     := " Tab  "
	hash["sc039"]     := "Enter "

	hash["LCtrl"]     := "左Ctrl"
	hash["sc07B"]     := "無変換"	;無変換
	hash["Space"]     := " 空白 "	;スペース
	hash["sc039"]     := " 空白 "	;スペース
	hash["sc079"]     := " 変換 "	;変換
	hash["sc070"]     := "カ/ひ"	;カタカナ/ひらがな
	hash["RCtrl"]     := "右Ctrl"
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

;----------------------------------------------------------------------
;	文字名からvkeyへの変換
;http://kts.sakaiweb.com/virtualkeycodes.html
;----------------------------------------------------------------------
MakeChr2vkeyHash()
{
	hash := Object()
	hash["全"] := "vkF3"	;半角／全角 VK_OEM_AUTO
	hash["１"] := "vk31"
	hash["２"] := "vk32"
	hash["３"] := "vk33"
	hash["４"] := "vk34"
	hash["５"] := "vk35"
	hash["６"] := "vk36"
	hash["７"] := "vk37"
	hash["８"] := "vk38"
	hash["９"] := "vk39"
	hash["０"] := "vk30"
	hash["－"] := "vkBD"	;-= VK_OEM_MINUS
	hash["＾"] := "vkDE"	;^~ VK_OEM_7
	hash["￥"] := "vkDC"	;\| VK_OEM_5
	hash["後"] := "vk08"	;VK_BACK

	hash["表"] := "vk09"	;VK_TAB
	hash["ｑ"] := "vk51"	;q
	hash["ｗ"] := "vk57"	;w
	hash["ｅ"] := "vk45"	;e
	hash["ｒ"] := "vk52"	;r
	hash["ｔ"] := "vk54"	;t
	hash["ｙ"] := "vk59"	;y
	hash["ｕ"] := "vk55"	;u
	hash["ｉ"] := "vk49"	;i
	hash["ｏ"] := "vk4F"	;o
	hash["ｐ"] := "vk50"	;p
	hash["＠"] := "vkC0"	;@ VK_OEM_3
	hash["［"] := "vkDB"	;[ VK_OEM_4
	
	hash["ａ"] := "vk41"	;a
	hash["ｓ"] := "vk53"	;s
	hash["ｄ"] := "vk44"	;d
	hash["ｆ"] := "vk46"	;f
	hash["ｇ"] := "vk47"	;g
	hash["ｈ"] := "vk48"	;h
	hash["ｊ"] := "vk4A"	;j
	hash["ｋ"] := "vk4B"	;k
	hash["ｌ"] := "vk4C"	;l
	hash["；"] := "vkBB"	;; VK_OEM_PLUS
	hash["："] := "vkBA"	;: VK_OEM_1
	hash["］"] := "vkDD"	;] VK_OEM_6
	hash["入"] := "vk0D"	;  VK_ENTER

	hash["ｚ"] := "vk5A"	;z
	hash["ｘ"] := "vk58"	;x
	hash["ｃ"] := "vk43"	;c
	hash["ｖ"] := "vk56"	;v
	hash["ｂ"] := "vk42"	;b
	hash["ｎ"] := "vk4E"	;n
	hash["ｍ"] := "vk4D"	;m
	hash["，"] := "vkBC"	;,< VK_OEM_COMMA
	hash["．"] := "vkBE"	;.> VK_OEM_PERIOD
	hash["／"] := "vkBF"	;/? VK_OEM_2
	hash["￥"] := "vkE2"	;\
	
	hash["空"] := "vk20"	;スペース
	hash["日"] := "vkF2"	;カタカナ/ひらがな VK_OEM_COPY

	hash["！"] := "vk31"
	hash["”"] := "vk32"
	hash["＃"] := "vk33"
	hash["＄"] := "vk34"
	hash["％"] := "vk35"
	hash["＆"] := "vk36"
	hash["’"] := "vk37"
	hash["（"] := "vk38"
	hash["）"] := "vk39"
	hash["＝"] := "vkBD"	;-= VK_OEM_MINUS
	hash["～"] := "vkDE"	;^~ VK_OEM_7
	hash["｜"] := "vkDC"	;\| VK_OEM_5
	hash["後"] := "vk08"	;VK_BACK

	hash["Ｑ"] := "vk51"	;q
	hash["Ｗ"] := "vk57"	;w
	hash["Ｅ"] := "vk45"	;e
	hash["Ｒ"] := "vk52"	;r
	hash["Ｔ"] := "vk54"	;t
	hash["Ｙ"] := "vk59"	;y
	hash["Ｕ"] := "vk55"	;u
	hash["Ｉ"] := "vk49"	;i
	hash["Ｏ"] := "vk4F"	;o
	hash["Ｐ"] := "vk50"	;p
	hash["‘"] := "vkC0"	;@ VK_OEM_3
	hash["｛"] := "vkDB"	;[ VK_OEM_4
	
	hash["Ａ"] := "vk41"	;a
	hash["Ｓ"] := "vk53"	;s
	hash["Ｄ"] := "vk44"	;d
	hash["Ｆ"] := "vk46"	;f
	hash["Ｇ"] := "vk47"	;g
	hash["Ｈ"] := "vk48"	;h
	hash["Ｊ"] := "vk4A"	;j
	hash["Ｋ"] := "vk4B"	;k
	hash["Ｌ"] := "vk4C"	;l
	hash["＋"] := "vkBB"	;; VK_OEM_PLUS
	hash["＊"] := "vkBA"	;: VK_OEM_1
	hash["｝"] := "vkDD"	;] VK_OEM_6

	hash["Ｚ"] := "vk5A"	;z
	hash["Ｘ"] := "vk58"	;x
	hash["Ｃ"] := "vk43"	;c
	hash["Ｖ"] := "vk56"	;v
	hash["Ｂ"] := "vk42"	;b
	hash["Ｎ"] := "vk4E"	;n
	hash["Ｍ"] := "vk4D"	;m
	hash["＜"] := "vkBC"	;,< VK_OEM_COMMA
	hash["＞"] := "vkBE"	;.> VK_OEM_PERIOD
	hash["？"] := "vkBF"	;/? VK_OEM_2
	hash["＿"] := "vkE2"	;\
	return hash
}

;----------------------------------------------------------------------
;	制御キー
;----------------------------------------------------------------------
MakeCtrlKeyHash() {
	hash := Object()
	hash["後"] := "BS"	;"Backspace"
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
	hash["表"] := "tab"
	hash["日"] := "vkF2sc070"
	hash["英"] := "vkF0sc03A"
	hash["変"] := "vk1Csc079"
	return hash
}

;----------------------------------------------------------------------
;	修飾キー
;----------------------------------------------------------------------
MakeModifierHash() {
	hash := Object()
	hash["c"] := "^"	;Ctrl
	hash["C"] := "^"	;Ctrl
	hash["a"] := "!"	;Alt
	hash["A"] := "!"	;Alt
	hash["s"] := "+"	;Shift
	hash["S"] := "+"	;Shift
	hash["w"] := "#"	;Win
	hash["W"] := "#"	;Win
	return hash
}
