;-----------------------------------------------------------------------
;	名称：Settings7.ahk
;	機能：紅皿のパラメータ設定
;	ver.0.1.4.4 .... 2021/3/20
;-----------------------------------------------------------------------

	Gosub,Init
	g_LayoutFile := ".\NICOLA配列.bnz"
	Gosub,ReadLayout
	Gosub, Settings
	Gosub, InitLayout2
	return

#include ReadLayout6.ahk
#include Path.ahk

;-----------------------------------------------------------------------
; Iniファイルの読み込み
;-----------------------------------------------------------------------
Init:
	g_IniFile := ".\benizara.ini"
	if(Path_FileExists(g_IniFile) = 0)
	{
		g_LayoutFile := ""
		IniWrite,%g_LayoutFile%,%g_IniFile%,FilePath,LayoutFile
		g_Continue := 1
		IniWrite,%g_Continue%,%g_IniFile%,Key,Continue
		g_Threshold := 100
		IniWrite,%g_Threshold%,%g_IniFile%,Key,Threshold
		g_ZeroDelay := 1
		IniWrite,%g_ZeroDelay%,%g_IniFile%,Key,ZeroDelay
		g_Overlap := 50
		IniWrite,%g_Overlap%,%g_IniFile%,Key,Overlap
		g_OyaKey := "無変換－変換"
		IniWrite,%g_OyaKey%,%g_IniFile%,Key,OyaKey
		g_KeySingle := "無効"
		IniWrite,%g_KeySingle%,%g_IniFile%,Key,KeySingle
		g_KeyRepeat := 1
		IniWrite,%g_KeyRepeat%,%g_IniFile%,Key,KeyRepeat
	}
	IniRead,g_LayoutFile,%g_IniFile%,FilePath,LayoutFile
	IniRead,g_Continue,%g_IniFile%,Key,Continue
	if(g_Continue>1) 
		g_Continue := 1
	if(g_Continue<0)
		g_Continue := 0
	IniRead,g_ZeroDelay,%g_IniFile%,Key,ZeroDelay
	if(g_ZeroDelay>1) 
		g_ZeroDelay := 1
	if(g_ZeroDelay<0)
		g_ZeroDelay := 0
	IniRead,g_Threshold,%g_IniFile%,Key,Threshold
	if(g_Threshold < 10)
		g_Threshold := 10
	if(g_Threshold > 400)
		g_Threshold := 400
	IniRead,g_Overlap,%g_IniFile%,Key,Overlap
	if(g_Overlap < 20)
		g_Overlap := 20
	if(g_Overlap > 80)
		g_Overlap := 80
	IniRead,g_OyaKey,%g_IniFile%,Key,OyaKey
	if g_OyaKey not in 無変換－変換,無変換－空白,空白－変換
		g_OyaKey := "無変換－変換"
	vOyaKey := g_OyaKey
	gosub, RemapOya
	IniRead,g_KeySingle,%g_IniFile%,Key,KeySingle
	if g_KeySingle not in 有効,無効
		g_KeySingle := "無効"
	IniRead,g_KeyRepeat,%g_IniFile%,Key,KeyRepeat
	if g_KeyRepeat not in 1,0
		g_KeyRepeat := 1
	return
	
;-----------------------------------------------------------------------
; 機能：設定ダイアログの表示
;-----------------------------------------------------------------------
Settings:
	IfWinExist,紅皿設定
	{
		msgbox, 既に紅皿設定ダイアログは開いています。
		return
	}	
	_Continue := g_Continue
	_ZeroDelay := g_ZeroDelay
	_Threshold := g_Threshold
	_LayoutFile := g_LayoutFile
	_Overlap := g_Overlap
	_OyaKey := g_OyaKey
	_KeySingle := g_KeySingle
	_KeyRepeat := g_KeyRepeat
_Settings:
	Gui,2:Default
	Gui, 2:New
	Gui, Font,s10 c000000
	Gui, Add, Button,ggButtonOk X530 Y405 W80 H22,ＯＫ
	Gui, Add, Button,ggButtonCancel X620 Y405 W80 H22,キャンセル
	Gui, Add, Tab3,ggTabChange vvTabName X10 Y10 W690 H390, 配列||親指シフト|管理者権限|紅皿について
	g_TabName := "配列"
	
	Gui, Tab, 1
	Gui, Add, Edit,X30 Y40 W250 H20 ReadOnly -Vscroll, %g_layoutName%　%g_layoutVersion%
	Gui, Add, Text,X300 Y40, 定義ファイル：
	Gui, Add, Edit,vvFilePath ggDefFile X370 Y40 W220 H20 ReadOnly, %_LayoutFile%
	Gui, Add, Button,ggFileSelect X600 Y40 W32 H21,…

	if(ShiftMode["R"] = "親指シフト")
	{
		Gui, Add, Text,X30 Y70,親指シフトキー：
		if(_OyaKey = "無変換－変換")
			Gui, Add, DropDownList,ggOya vvOyaKey X133 Y70 W125,無変換－変換||無変換－空白|空白－変換|
		else if(_OyaKey = "無変換－空白")
			Gui, Add, DropDownList,ggOya vvOyaKey X133 Y70 W125,無変換－変換|無変換－空白||空白－変換|
		else
			Gui, Add, DropDownList,ggOya vvOyaKey X133 Y70 W125,無変換－変換|無変換－空白|空白－変換||
	
		Gui, Add, Text,X290 Y70,単独打鍵：
		if(_KeySingle = "無効")
			Gui, Add, DropDownList,ggKeySingle vvKeySingle X360 Y70 W95,無効||有効|
		else
			Gui, Add, DropDownList,ggKeySingle vvKeySingle X360 Y70 W95,無効|有効||
	}

	Gui, Font,s10 c000000,Meiryo UI
	Gosub,G2DrawKeyFrame
	Gui, Font,s9 c000000,Meiryo UI
	Gui, Add, Edit,vvEdit X60 Y370 W600 H20 -Vscroll,
	Gosub, G2RefreshLayout
	
	Gui, Tab, 2
	Gui, Font,s10 c000000,Meiryo UI
	Gui, Add, Edit,X20 Y40 W300 H60 ReadOnly -Vscroll,親指シフトキーを押し続けながら文字キーを押したときを親指シフトとするか否かを設定します。更に同時打鍵の判定時間を推奨値に設定します。
	Gui, Add, Checkbox,ggContinue vvContinue X+20 Y65,連続シフト
	GuiControl,,vContinue,%_Continue%

	Gui, Add, Edit,X20 Y110 W300 H60 ReadOnly -Vscroll,キー打鍵が確定する前に候補文字を表示する設定です。候補文字とは異なる打鍵であった場合、バックスペースで消去して、正しい文字で修正します。
	Gui, Add, Checkbox,ggZeroDelay vvZeroDelay X+20 Y135,零遅延モード
	GuiControl,,vZeroDelay,%_ZeroDelay%
	
	Gui, Add, Edit,X20 Y180 W300 H60 ReadOnly -Vscroll,親指シフトキーの単独打鍵を受け付けた際に、無変換や変換をキーリピートさせるか否かを設定します。
	Gui, Add, Checkbox,ggKeyRepeat vvKeyRepeat X340 Y205,キーリピート
	GuiControl,,vKeyRepeat,%_KeyRepeat%
	
	Gui, Add, Edit,X20 Y250 W300 H60 ReadOnly -Vscroll,親指Aー文字Mー親指Bの順の打鍵の際に、親指Aから文字Mまで打鍵間隔が全体の何％のときに、親指Aのシフトであるかを決定します。
	Gui, Add, Text,X+20 Y250 W230 H20,文字と親指シフトの同時打鍵の割合：
	Gui, Add, Edit,vvOverlapNum X+3 Y248 W50 ReadOnly, %_Overlap%
	Gui, Add, Text,X+10 Y250 c000000,[`%]
	
	Gui, Add, Slider, X320 Y280 ggOlSlider w350 vvOlSlider Range20-80 line10 TickInterval10
	GuiControl,,vOlSlider,%_Overlap%
	
	Gui, Add, Edit,X20 Y320 W300 H60 ReadOnly -Vscroll,親指ー文字の打鍵間隔や文字ー親指の打鍵間隔が何ミリ秒のときに親指シフトであるかを決定します。
	Gui, Add, Text,X+20 Y320 W230 H20,文字と親指シフトの同時打鍵の判定時間：
	Gui, Add, Edit,vvThresholdNum X+3 Y318 W50 ReadOnly, %_Threshold%
	Gui, Add, Text,X+10 Y320 c000000,[mSEC]
	
	Gui, Add, Slider, X320 Y350 ggThSlider w350 vvThSlider Range10-400 line10 TickInterval10
	GuiControl,,vThSlider,%_Threshold%

	Gui, Tab, 3
	Gui, Font,s10 c000000,Meiryo UI
	Gui, Add, Edit,X20 Y40 W640 H60 ReadOnly -Vscroll,管理者権限で動作しているアプリケーションに対して親指シフト入力するか否かを決定します。
	if(DllCall("Shell32\IsUserAnAdmin") = 1)
	{
		Gui, Add, Text,X30 Y+30,紅皿は管理者権限で動作しています。
	}
	else
	{
		Gui, Add, Text,X30 Y+30,紅皿は通常権限で動作しています。
		Gui, Add, Button,ggButtonAdmin X30 Y+30 W140 H22,管理者権限に切替
	}
	Gui, Tab, 4
	Gui, Font,s10 c000000,Meiryo UI
	Gui, Add, Text,X30  Y52,名称：benizara / 紅皿
	Gui, Add, Text,X30  Y92,機能：Yet another NICOLA Emulaton Software
	Gui, Add, Text,X30 Y114,　　　キーボード配列エミュレーションソフト
	Gui, Add, Text,X30 Y142,バージョン：%g_Ver% / %g_Date%
	Gui, Add, Text,X30 Y182,作者：Ken'ichiro Ayaki
	Gui, Font, underline
	Gui, Add, Text,X30 Y222 cBlue ggURLdownload,ダウンロードページ
	Gui, Add, Text,X30 Y262 cBlue ggURLsupport,サポートページ
	Gui, Show, W720 H440, 紅皿設定

	s_Romaji := ""
	s_KeySingle := ""
	SetTimer,G2PollingLayout,50
	GuiControl,Focus,vEdit
	return

;-----------------------------------------------------------------------
; 機能：紅皿のダウンロードURLを開く
;-----------------------------------------------------------------------
gURLdownload:
	Run, https://osdn.net/projects/benizara/releases/
	return

;-----------------------------------------------------------------------
; 機能：紅皿のサポートURLを開く
;-----------------------------------------------------------------------
gURLsupport:
	Run, https://benizara.hatenablog.com/
	return

;-----------------------------------------------------------------------
; 機能：キーレイアウトの表示
;-----------------------------------------------------------------------
G2DrawKeyFrame:
	Critical
	Gui,Add,GroupBox,X20 Y90 W670 H270,キー配列
	_col := 1
	_ypos := 105
	loop,13
	{
		_row := A_Index
		Gosub,G2KeyRectChar
	}
	_col := 2
	_ypos := _ypos + 48
	loop,12
	{
		_row := A_Index
		Gosub,G2KeyRectChar
	}
	_col := 3
	_ypos := _ypos + 48
	loop,12
	{
		_row := A_Index
		Gosub,G2KeyRectChar
	}
	_col := 4
	_ypos := _ypos + 48
	loop,11
	{
		_row := A_Index
		Gosub,G2KeyRectChar
	}
	_col := 5
	_ypos := _ypos + 48
	loop, 4
	{
		_row := A_Index
		Gosub,G2KeyRectChar5
	}
	critical,off
	return

;-----------------------------------------------------------------------
; 機能：E～B段の各キーの矩形と入力文字の表示
;-----------------------------------------------------------------------
G2KeyRectChar:
	_xpos := 32*(_col-1) + 48*(_row - 1) + 40
	_ch := " "
	Gosub, G2KeyRectangle
	_xpos0 := _xpos + 10
	_ypos0 := _ypos + 10
	_col2 := _colhash[_col]
	_row2 := _rowhash[_row]
	Gui, Font,s11 c000000,Meiryo UI
	Gui, Add, Text,vvkeyRK%_col2%%_row2% X%_xpos0% Y%_ypos0% W16 +Center c000000 BackgroundTrans,%_ch%
	_xpos0 := _xpos + 30
	_ypos0 := _ypos + 10
	Gui, Font,s11 c000000,Meiryo UI
	Gui, Add, Text,vvkeyRR%_col2%%_row2% X%_xpos0% Y%_ypos0% W16 +Center c000000 BackgroundTrans,%_ch%
	_xpos0 := _xpos + 10
	_ypos0 := _ypos + 30
	Gui, Font,s11 c000000,Meiryo UI
	Gui, Add, Text,vvkeyRL%_col2%%_row2% X%_xpos0% Y%_ypos0% W16 +Center c000000 BackgroundTrans,%_ch%
	_xpos0 := _xpos + 30
	_ypos0 := _ypos + 30
	Gui, Font,s11 c000000,Meiryo UI
	Gui, Add, Text,vvkeyRN%_col2%%_row2% X%_xpos0% Y%_ypos0% W16 +Center c000000 BackgroundTrans,%_ch%
	Gosub, G2KeyBorder
	return
;-----------------------------------------------------------------------
; 機能：A段の各キーの矩形と入力文字の表示
;-----------------------------------------------------------------------
G2KeyRectChar5:
	_xpos := 32*(_col-1) + 48*(_row + 2 - 1) + 40
	Gosub, G2KeyRectangle5
	_xpos0 := _xpos + 6
	_ypos0 := _ypos + 10
	_col2 := _colhash[_col]
	_row2 := _rowhash[_row]
	Gui, Font,s9 c000000,Meiryo UI
	Gui, Add, Text,vvkeyFA%_col2%%_row2% X%_xpos0% Y%_ypos0% W42 +Center c000000 BackgroundTrans,　　
	_xpos0 := _xpos + 6
	_ypos0 := _ypos + 30
	Gui, Font,s9 c000000,Meiryo UI
	Gui, Add, Text,vvkeyFB%_col2%%_row2% X%_xpos0% Y%_ypos0% W42 +Center c000000 BackgroundTrans,　  
	Gosub, G2KeyBorder
	return

;-----------------------------------------------------------------------
; 機能：各キーの矩形表示
;-----------------------------------------------------------------------
G2KeyRectangle:
	Gui, Font,s45 c000000,Yu Gothic UI
	_ypos0 := _ypos - 12
	_xpos0 := _xpos - 3
	Gui, Add, Text,X%_xpos0% X%_xpos0% Y%_ypos0% +Center BackgroundTrans,■
	if(_row = 1)
	{
		Gui, Font,s42 cFFC3E1,Yu Gothic UI
	}
	else if _row in 2,3
	{
		Gui, Font,s42 cFFFFC3,Yu Gothic UI
	}
	else if _row in 4,5
	{
		Gui, Font,s42 cC3FFC3,Yu Gothic UI
	}
	else if _row in 6,7
	{
		Gui, Font,s42 cC3FFFF,Yu Gothic UI
	}
	else if _row in 8,9
	{
		Gui, Font,s42 cE1C3FF,Yu Gothic UI
	}
	else
	{
		Gui, Font,s42 cC0C0C0,Yu Gothic UI
	}
	_ypos0 := _ypos - 8
	_xpos0 := _xpos - 1
	Gui, Add, Text,X%_xpos0% Y%_ypos0% +Center BackgroundTrans,■
	return

;-----------------------------------------------------------------------
; 機能：各キーの矩形表示・・・５列目
;-----------------------------------------------------------------------
G2KeyRectangle5:
	Gui, Font,s45 c000000,Yu Gothic UI
	_ypos0 := _ypos - 12
	_xpos0 := _xpos - 3
	_col2 := _colhash[_col]
	_row2 := _rowhash[_row]
	Gui, Add, Text,X%_xpos0% Y%_ypos0% +Center BackgroundTrans,■
	if(keyAttribute2[g_Romaji . _col2 . _row2] == "L")
	{
		Gui, Font,s42 cFFFF00,Yu Gothic UI
	}
	else
	if(keyAttribute2[g_Romaji . _col2 . _row2] == "R")
	{
		Gui, Font,s42 c00FFFF,Yu Gothic UI
	}
	else
	{
		Gui, Font,s42 cFFFFFF,Yu Gothic UI
	}
	_ypos0 := _ypos - 8
	_xpos0 := _xpos - 1
	_col2 := _colhash[_col]
	_row2 := _rowhash[_row]
	Gui, Add, Text,vvkeyFC%_col2%%_row2% X%_xpos0% Y%_ypos0% +Center BackgroundTrans,■
	return

;-----------------------------------------------------------------------
; 機能：キーダウン表示
;-----------------------------------------------------------------------
G2KeyBorder:
	Gui, Font,s45 c000000,Yu Gothic UI
	_ypos0 := _ypos - 12
	_xpos0 := _xpos - 3
	_col2 := _colhash[_col]
	_row2 := _rowhash[_row]
	
	Gui, Add, Text,vvkeyDN%_col2%%_row2% X%_xpos0% Y%_ypos0% +Center BackgroundTrans,　
	return

;-----------------------------------------------------------------------
; 機能：キー配列変更に係る変数の監視
;-----------------------------------------------------------------------
G2PollingLayout:
	Gui,2:Default
	Gui, Submit, NoHide
	if(g_TabName != "配列")
	{
		return
	}
	if(s_KeySingle != g_KeySingle || s_Romaji != g_Romaji)
	{
		if(s_Romaji != g_Romaji) 
		{
			s_Romaji := g_Romaji
			Gosub,G2RefreshLayout
		}
		s_KeySingle := g_KeySingle
		Gosub,G2RefreshLayout5
	}
	if(ShiftMode[g_Romaji] == "" ) {
		Gosub,ReadKeyboardState
	} else {
		_layoutPos := "A04"
		Gosub,SetKeyGui2A
		_layoutPos := "A03"
		Gosub,SetKeyGui2A
		_layoutPos := "A02"
		Gosub,SetKeyGui2A
		_layoutPos := "A01"
		Gosub,SetKeyGui2A
	}
	return

;-----------------------------------------------------------------------
; 機能：キー配列表示の切り替え
;-----------------------------------------------------------------------
G2RefreshLayout5:
	_layoutPos := "A01"
	Gosub,G2RefreshLayout51
	_layoutPos := "A02"
	Gosub,G2RefreshLayout51
	_layoutPos := "A03"
	Gosub,G2RefreshLayout51
	_layoutPos := "A04"
	Gosub,G2RefreshLayout51
	return

;-----------------------------------------------------------------------
; 機能：Ａ列のキー表示の更新
;-----------------------------------------------------------------------
G2RefreshLayout51:
	Critical
	Gui, Submit, NoHide
	GuiControl,-Redraw,vkeyDN%_layoutPos%
	if(keyAttribute2[g_Romaji . _layoutPos] == "L")
	{
		Gui,Font,S42 cFFFF00,Yu Gothic UI
		GuiControl,Font,vkeyFC%_layoutPos%
		GuiControl,,vkeyFA%_layoutPos%,左親指
	}
	else
	if(keyAttribute2[g_Romaji . _layoutPos] == "R")
	{
		Gui,Font,S42 c00FFFF,Yu Gothic UI
		GuiControl,Font,vkeyFC%_layoutPos%
		GuiControl,,vkeyFA%_layoutPos%,右親指
	}
	else
	{
		Gui,Font,S42 cFFFFFF,Yu Gothic UI
		GuiControl,Font,vkeyFC%_layoutPos%

		Gui,Font,s9 c000000,Meiryo UI
		GuiControl,,vkeyFA%_layoutPos%,　　　
	}
	if(s_KeySingle = "有効" || (codeLabel%_layoutPos% != "無変換" || codeLabel%_layoutPos% != " 変換 ")) {
		_label := codeLabelHash[_layoutPos]
		GuiControl,,vkeyFB%_layoutPos%,%_label%
	} else {
		GuiControl,,vkeyFB%_layoutPos%,　　　
	}
	vkeyDN%_layoutPos% := "　"
	GuiControl,2:,vkeyDN%_layoutPos%,　
	GuiControl,+Redraw,vkeyDN%_layoutPos%
	Critical,off
	return

;-----------------------------------------------------------------------
; 機能：キー配列表示の切り替え
;-----------------------------------------------------------------------
G2RefreshLayout:
	Critical
	Gui, Submit, NoHide
	loop,4
	{
		_col2 := _colhash[A_Index]
		org := StrSplit(LF["NUL" . _col2],",")
		loop,% org.MaxIndex()
		{
			_row2 := _rowhash[A_Index]
			GuiControl,-Redraw,vkeyDN%_col2%%_row2%
			GuiControl,,vkeyDN%_col2%%_row2%,　
			GuiControl,-Redraw,vkeyRK%_col2%%_row2%
			GuiControl,-Redraw,vkeyRN%_col2%%_row2%
			GuiControl,-Redraw,vkeyRL%_col2%%_row2%
			GuiControl,-Redraw,vkeyRR%_col2%%_row2%
		}
	}
	loop,4
	{
		_col2 := _colhash[A_Index]
		if(LF[g_Romaji . "NK" . _col2] != "")
		{
			org := StrSplit(LF[g_Romaji . "NK" . _col2],",")
		}
		else
		{
			org := StrSplit(LF["ADK" . _col2],",")
		}
		loop,% org.MaxIndex()
		{
			_ch := org[A_Index]
			_row2 := _rowhash[A_Index]
			GuiControl,,vkeyRK%_col2%%_row2%,%_ch%
		}
	}
	loop,4
	{
		_col2 := _colhash[A_Index]
		if(LF[g_Romaji . "NN" . _col2] != "")
		{
			org := StrSplit(LF[g_Romaji . "NN" . _col2],",")
		}
		else
		{
			org := StrSplit(LF["ADN" . _col2],",")
		}
		loop,% org.MaxIndex()
		{
			_ch := org[A_Index]
			_row2 := _rowhash[A_Index]
			GuiControl,,vkeyRN%_col2%%_row2%,%_ch%
		}
	}
	loop,4
	{
		_col2 := _colhash[A_Index]
		if(LF[g_Romaji . "LN" . _col2] != "")
		{
			org := StrSplit(LF[g_Romaji . "LN" . _col2],",")
		}
		else 
		if(LF[g_Romaji . "1N" . _col2] != "")
		{
			org := StrSplit(LF[g_Romaji . "1N" . _col2],",")
		}
		else
		{
			org := StrSplit(LF["NUL" . _col2],",")
		}
		loop,% org.MaxIndex()
		{
			_ch := org[A_Index]
			_row2 := _rowhash[A_Index]
			GuiControl,,vkeyRL%_col2%%_row2%,%_ch%
		}
	}
	loop,4
	{
		_col2 := _colhash[A_Index]
		if(LF[g_Romaji . "RN" . _col2] != "")
		{
			org := StrSplit(LF[g_Romaji . "RN" . _col2],",")
		}
		else
		if(LF[g_Romaji . "2N" . _col2] != "")
		{
			org := StrSplit(LF[g_Romaji . "2N" . _col2],",")
		}
		else
		{
			org := StrSplit(LF["NUL" . _col2],",")
		}
		loop,% org.MaxIndex()
		{
			_ch := org[A_Index]
			_row2 := _rowhash[A_Index]
			GuiControl,,vkeyRR%_col2%%_row2%,%_ch%
		}
	}
	loop,4
	{
		_col2 := _colhash[A_Index]
		org := StrSplit(LF["NUL" . _col2],",")
		loop,% org.MaxIndex()
		{
			_row2 := _rowhash[A_Index]
			GuiControl,+Redraw,vkeyDN%_col2%%_row2%
			GuiControl,+Redraw,vkeyRK%_col2%%_row2%
			GuiControl,+Redraw,vkeyRN%_col2%%_row2%
			GuiControl,+Redraw,vkeyRL%_col2%%_row2%
			GuiControl,+Redraw,vkeyRR%_col2%%_row2%
		}
	}
	Critical,off
	return

;-----------------------------------------------------------------------
; 機能：キーのオンオフ表示の更新
;-----------------------------------------------------------------------
ReadKeyboardState:
	Critical
	VarSetCapacity(stKtbl, cbSize:=512, 0)
	NumPut(cbSize, stKtbl,  0, "UChar")   ;	
	stCurr := DllCall("GetKeyboardState", "UPtr", &stKtbl)
	if(stCurr==0) 
	{
		return
	}
	loop, 13
	{
		_layoutPos := "E" . _rowhash[A_Index]
		_vkey := vkeyHash[_layoutPos]
		Gosub,SetKeyGui2
	}
	loop, 12
	{
		_layoutPos := "D" . _rowhash[A_Index]
		_vkey := vkeyHash[_layoutPos]
		Gosub,SetKeyGui2
	}
	loop, 12
	{
		_layoutPos := "C" . _rowhash[A_Index]
		_vkey := vkeyHash[_layoutPos]
		Gosub,SetKeyGui2
	}
	loop, 11
	{
		_layoutPos := "B" . _rowhash[A_Index]
		_vkey := vkeyHash[_layoutPos]
		Gosub,SetKeyGui2
	}
	loop, 4
	{
		_layoutPos := "A" . _rowhash[A_Index]
		_vkey := vkeyHash[_layoutPos]
		Gosub,SetKeyGui2
	}
	critical,off
	return

SetKeyGui2:
	GuiControlGet,_val,,vkeyDN%_layoutPos%
	if( (NumGet(stKtbl,_vkey,"UChar") & 0x80)!= 0
	&&   _val != "□")
	{
		GuiControl,2:,vkeyDN%_layoutPos%,□
	}
	else
	if( (NumGet(stKtbl,_vkey,"UChar") & 0x80)== 0
	&&  _val != "　")
	{
		GuiControl,2:,vkeyDN%_layoutPos%,　
	}
	return

SetKeyGui2A:
	GuiControlGet,_val,,vkeyDN%_layoutPos%
	if( keyState[_layoutPos]!= 0 && _val != "□")
	{
		GuiControl,2:,vkeyDN%_layoutPos%,□
	}
	else
	if( keyState[_layoutPos]== 0 && _val != "　")
	{
		GuiControl,2:,vkeyDN%_layoutPos%,　
	}
	return

;-----------------------------------------------------------------------
; 機能：タブ変更
;-----------------------------------------------------------------------
gTabChange:
	Gui, Submit, NoHide
	g_TabName := vTabName
	GuiControl,Focus,vEdit
	if(g_TabName == "配列")
	{
		SetTimer,G2PollingLayout,on
	}
	else
	{
		SetTimer,G2PollingLayout,off
	}
	return
	
;-----------------------------------------------------------------------
; 機能：同時打鍵の判定時間のスライダー操作
;-----------------------------------------------------------------------
gThSlider:
	GuiControlGet, _Threshold , , vThSlider, 
	;msgbox, _Threshold is %_Threshold% vThSlider is %vThSlider%
	GuiControl,, vThresholdNum, %_Threshold%
	return
	
;-----------------------------------------------------------------------
; 機能：同時打鍵の割合のスライダー操作
;-----------------------------------------------------------------------
gOlSlider:
	GuiControlGet, _Overlap , , vOlSlider, 
	GuiControl,, vOverlapNum, %_Overlap%
	return

;-----------------------------------------------------------------------
; 機能：連続シフトチェックボックスの操作
;-----------------------------------------------------------------------
gContinue:
	Gui, Submit, NoHide
	_Continue := %A_GuiControl%
	if(_Continue = 1)
		_Threshold := 50
	else
		_Threshold := 150
	GuiControl,,vThSlider,%_Threshold%
	GuiControl,,vThresholdNum,%_Threshold%
	Return

;-----------------------------------------------------------------------
; 機能：零遅延モードチェックボックスの操作
;-----------------------------------------------------------------------
gZeroDelay:
	Gui, Submit, NoHide
	_ZeroDelay := %A_GuiControl%
	Return

;-----------------------------------------------------------------------
; 機能：その他、無効化したＧＵＩ要素の操作・・・ダミー
; ver.0.1.3.7 ... gSpace/gSpaceUp を追加
;-----------------------------------------------------------------------
gOya:
	Gui, Submit, NoHide
RemapOya:
	_OyaKey := vOyaKey
	if(vOyaKey = "無変換－変換")
	{
		if(ShiftMode["R"] == "親指シフト") {
			keyAttribute2["RA01"] := "L"
			keyAttribute2["RA02"] := "X"
			keyAttribute2["RA03"] := "R"
		} else
		if(ShiftMode["A"] == "親指シフト") {
			keyAttribute2["AA01"] := "L"
			keyAttribute2["AA02"] := "X"
			keyAttribute2["AA03"] := "R"
		}
	}
	else if(vOyaKey = "無変換－空白")
	{
		if(ShiftMode["R"] == "親指シフト") {
			keyAttribute2["RA01"] := "L"
			keyAttribute2["RA02"] := "R"
			keyAttribute2["RA03"] := "X"
		} else
		if(ShiftMode["A"] == "親指シフト") {
			keyAttribute2["AA01"] := "L"
			keyAttribute2["AA02"] := "R"
			keyAttribute2["AA03"] := "X"
		}
	}
	else	; 空白－変換
	{
		if(ShiftMode["R"] == "親指シフト") {
			keyAttribute2["RA01"] := "X"
			keyAttribute2["RA02"] := "L"
			keyAttribute2["RA03"] := "R"
		} else
		if(ShiftMode["A"] == "親指シフト") {
			keyAttribute2["AA01"] := "X"
			keyAttribute2["AA02"] := "L"
			keyAttribute2["AA03"] := "R"
		}
	}
	Return

gKeySingle:
	Gui, Submit, NoHide
	_KeySingle := vKeySingle
	g_KeySingle := vKeySingle
	if(g_KeySingle = "有効")
	{
		_KeyRepeat := 1
	}
	return

gKeyRepeat:
	Gui, Submit, NoHide
	_KeyRepeat := vKeyRepeat
	return
	
gDefFile:
	Gui, Submit, NoHide
	;MsgBox % %A_GuiControl%
	Return

;-----------------------------------------------------------------------
; 機能：ファイル選択ボタンの押下
;-----------------------------------------------------------------------
gFileSelect:
	SetTimer,G2PollingLayout,off
	SetWorkingDir, %A_ScriptDir%
	FileSelectFile, vLayoutFileAbs,0,%A_ScriptDir%,,Layout File (*.bnz; *.yab)
	
	if(vLayoutFileAbs<>"")
	{
		vLayoutFile := Path_RelativePathTo(A_WorkingDir, 0x10, vLayoutFileAbs, 0x20)
		if(vLayoutFile = "")
		{
			vLayoutFile := vLayoutFileAbs
		}
		GuiControl,, vFilePath, %vLayoutFile%

		Gosub, InitLayout2
		GoSub, ReadLayoutFile
		if(_error <> "")
		{
			msgbox, %_error%
			
			; 元ファイルを再読み込みする
			Gosub, InitLayout2
			_LayoutFile := g_LayoutFile
			GoSub, ReadLayoutFile
		}
		Gosub, SetLayoutProperty
		_LayoutFile := vLayoutFile
	}
	Gui,Destroy
	Goto,_Settings


gButtonAdmin:
	{ 
		try ; leads to having the script re-launching itself as administrator 
		{ 
			if A_IsCompiled 
				Run *RunAs "%A_ScriptFullPath%" /restart 
			else
				Run *RunAs "%A_AhkPath%" /restart "%A_ScriptFullPath%" 
		} 
		ExitApp 
	}
	return

;-----------------------------------------------------------------------
; 機能：OKボタンの押下
;-----------------------------------------------------------------------

gButtonOk:
	g_Continue := _Continue
	g_ZeroDelay := _ZeroDelay
	g_Threshold := _Threshold
	g_LayoutFile := _LayoutFile
	g_Overlap := _Overlap
	g_OyaKey := _OyaKey
	g_KeySingle := _KeySingle
	g_KeyRepeat := _KeyRepeat

	g_IniFile := ".\benizara.ini"
	IniWrite,%g_LayoutFile%,%g_IniFile%,FilePath,LayoutFile
	IniWrite,%g_Continue%,%g_IniFile%,Key,Continue
	IniWrite,%g_Threshold%,%g_IniFile%,Key,Threshold
	IniWrite,%g_ZeroDelay%,%g_IniFile%,Key,ZeroDelay
	IniWrite,%g_Overlap%,%g_IniFile%,Key,Overlap
	IniWrite,%g_OyaKey%,%g_IniFile%,Key,OyaKey
	IniWrite,%g_KeySingle%,%g_IniFile%,Key,KeySingle
	IniWrite,%g_KeyRepeat%,%g_IniFile%,Key,KeyRepeat
	SetTimer,G2PollingLayout,off
	Gui,Destroy
	return

;-----------------------------------------------------------------------
; 機能：キャンセルボタンの押下
;-----------------------------------------------------------------------
gButtonCancel:
GuiClose:
	Gosub, Init
	SetTimer,G2PollingLayout,off
	Gui,Destroy
	return
