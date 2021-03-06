﻿;-----------------------------------------------------------------------
;	名称：Settings7.ahk
;	機能：紅皿のパラメータ設定
;	ver.0.1.4.4 .... 2021/3/14
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
	keyAttributeHash := MakeKeyAttributeHash()
	keyState := MakeKeyState()
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
	_allTheLayout := g_allTheLayout
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
	Gui, Add, Text,X30 Y40, 配列定義ファイル：
	Gui, Add, Edit,vvFilePath ggDefFile X150 Y40 W380 H20 ReadOnly, %_LayoutFile%
	Gui, Add, Button,ggFileSelect X550 Y40 W32 H21,…

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
	Gui,Add,GroupBox,X20 Y90 W670 H270,キー配列
	_col := 1
	_ypos := 105
	_cnt := 13
	loop,%_cnt%
	{
		_row := A_Index
		Gosub,G2KeyRectChar
	}
	_col := 2
	_ypos := _ypos + 48
	_cnt := 12
	loop,%_cnt%
	{
		_row := A_Index
		Gosub,G2KeyRectChar
	}
	_col := 3
	_ypos := _ypos + 48
	_cnt := 12
	loop,%_cnt%
	{
		_row := A_Index
		Gosub,G2KeyRectChar
	}
	_col := 4
	_ypos := _ypos + 48
	_cnt := 11
	loop,%_cnt%
	{
		_row := A_Index
		Gosub,G2KeyRectChar
	}
	_ypos := _ypos + 48
	_col := 5
	_row := 1
	Gosub,G2KeyRectChar5
	_col := 5
	_row := 2
	Gosub,G2KeyRectChar5
	_col := 5
	_row := 3
	Gosub,G2KeyRectChar5
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
	_col2 := _colcnv[_col]
	_row2 := _rowcnv[_row]
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
	_col2 := _colcnv[_col]
	_row2 := _rowcnv[_row]
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
	Gui, Add, Text,X%_xpos0% Y%_ypos0% +Center BackgroundTrans,■
	if(_row == 1 && keyAttributeHash["A01"] == "L")
	{
		Gui, Font,s42 cFFFF00,Yu Gothic UI
	}
	else 
	if(_row == 2 && keyAttributeHash["A02"] == "L")
	{
		Gui, Font,s42 cFFFF00,Yu Gothic UI
	}
	else
	if(_row == 2 && keyAttributeHash["A02"] == "R")
	{
		Gui, Font,s42 c00FFFF,Yu Gothic UI
	}
	else
	if(_row == 3 && keyAttributeHash["A03"] == "R")
	{
		Gui, Font,s42 c00FFFF,Yu Gothic UI
	}
	else
	{
		Gui, Font,s42 cFFFFFF,Yu Gothic UI
	}
	_ypos0 := _ypos - 8
	_xpos0 := _xpos - 1
	_col2 := _colcnv[_col]
	_row2 := _rowcnv[_row]
	Gui, Add, Text,vvkeyFC%_col2%%_row2% X%_xpos0% Y%_ypos0% +Center BackgroundTrans,■
	return

;-----------------------------------------------------------------------
; 機能：キーダウン表示
;-----------------------------------------------------------------------
G2KeyBorder:
	Gui, Font,s45 c000000,Yu Gothic UI
	_ypos0 := _ypos - 12
	_xpos0 := _xpos - 3
	_col2 := _colcnv[_col]
	_row2 := _rowcnv[_row]
	
	Gui, Add, Text,vvkeyDN%_col2%%_row2% X%_xpos0% Y%_ypos0% +Center BackgroundTrans,　
	;_row2 := _rowcnv[A_Index]
	;vkeyDN%_col2%%_row2% := "　"
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
	if((g_Romaji="A" && LFA!=0x77)
	|| (g_Romaji="R" && LFR!=0x77)) {
		Gosub,ReadKeyboardState
	}
	return

;-----------------------------------------------------------------------
; 機能：キー配列表示の切り替え
;-----------------------------------------------------------------------
G2RefreshLayout5:
	Critical
	Gui, Submit, NoHide
	GuiControl,-Redraw,vkeyDNA01
	GuiControl,-Redraw,vkeyDNA02
	GuiControl,-Redraw,vkeyDNA03
	if((g_Romaji="A" && LFA!=0x77)
	|| (g_Romaji="R" && LFR!=0x77)) {
		Gui,Font,S42 cFFFFFF,Yu Gothic UI
		GuiControl,Font,vkeyFCA01
		Gui,Font,S42 cFFFFFF,Yu Gothic UI
		GuiControl,Font,vkeyFCA02
		Gui,Font,S42 cFFFFFF,Yu Gothic UI
		GuiControl,Font,vkeyFCA03
		Gui, Font,s9 c000000,Meiryo UI
		GuiControl,,vkeyFAA01,　　　
		GuiControl,,vkeyFAA02,　　　
		GuiControl,,vkeyFAA03,　　　
		GuiControl,,vkeyFBA01,無変換
		GuiControl,,vkeyFBA02, 空白 
		GuiControl,,vkeyFBA03, 変換 
	}
	else
	if(keyAttributeHash["A01"] == "L" && keyAttributeHash["A03"] == "R")
	{
		Gui,Font,S42 cFFFF00,Yu Gothic UI
		GuiControl,Font,vkeyFCA01
		Gui,Font,S42 cFFFFFF,Yu Gothic UI
		GuiControl,Font,vkeyFCA02
		Gui,Font,S42 c00FFFF,Yu Gothic UI
		GuiControl,Font,vkeyFCA03
		Gui, Font,s9 c000000,Meiryo UI
		GuiControl,,vkeyFAA01,左親指
		GuiControl,,vkeyFAA02,　　　
		GuiControl,,vkeyFAA03,右親指
		if(s_KeySingle = "有効")
		{
			GuiControl,,vkeyFBA01,無変換
			GuiControl,,vkeyFBA02, 空白 
			GuiControl,,vkeyFBA03, 変換 
		}
		else
		{
			GuiControl,,vkeyFBA01,　　　
			GuiControl,,vkeyFBA02, 空白 
			GuiControl,,vkeyFBA03,　　　
		}
	}
	else if(keyAttributeHash["A01"] == "L" && keyAttributeHash["A02"] == "R")
	{
		Gui,Font,S42 cFFFF00,Yu Gothic UI
		GuiControl,Font,vkeyFCA01 
		Gui,Font,S42 c00FFFF,Yu Gothic UI
		GuiControl,Font,vkeyFCA02
		Gui,Font,S42 cFFFFFF,Yu Gothic UI
		GuiControl,Font,vkeyFCA03
		GuiControl,,vkeyFAA01,左親指
		GuiControl,,vkeyFAA02,右親指
		GuiControl,,vkeyFAA03,　　　
		if(s_KeySingle = "有効")
		{
			GuiControl,,vkeyFBA01,無変換
			GuiControl,,vkeyFBA02, 空白 
			GuiControl,,vkeyFBA03, 変換 
		}
		else
		{
			GuiControl,,vkeyFBA01,　　　
			GuiControl,,vkeyFBA02, 空白 
			GuiControl,,vkeyFBA03, 変換 
		}
	}
	else	; 空白－変換
	{
		Gui,Font,S42 cFFFFFF,Yu Gothic UI
		GuiControl,Font,vkeyFCA01
		Gui,Font,S42 cFFFF00,Yu Gothic UI
		GuiControl,Font,vkeyFCA02
		Gui,Font,S42 c00FFFF,Yu Gothic UI
		GuiControl,Font,vkeyFCA03
		GuiControl,,vkeyFAA01,　　　
		GuiControl,,vkeyFAA02,左親指
		GuiControl,,vkeyFAA03,右親指
		if(s_KeySingle = "有効")
		{
			GuiControl,,vkeyFBA01,無変換
			GuiControl,,vkeyFBA02, 空白 
			GuiControl,,vkeyFBA03, 変換 
		}
		else
		{
			GuiControl,,vkeyFBA01,無変換
			GuiControl,,vkeyFBA02, 空白 
			GuiControl,,vkeyFBA03,　　　
		}
	}
	vkeyDNA01 := "　"
	GuiControl,2:,vkeyDNA01,　
	vkeyDNA02 := "　"
	GuiControl,2:,vkeyDNA02,　
	vkeyDNA03 := "　"
	GuiControl,2:,vkeyDNA03,　
	GuiControl,+Redraw,vkeyDNA01
	GuiControl,+Redraw,vkeyDNA02
	GuiControl,+Redraw,vkeyDNA03
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
		_col2 := _colcnv[A_Index]
		org := StrSplit(LF["NUL" . _col2],",")
		loop,% org.MaxIndex()
		{
			_row2 := _rowcnv[A_Index]
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
		_col2 := _colcnv[A_Index]
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
			_row2 := _rowcnv[A_Index]
			GuiControl,,vkeyRK%_col2%%_row2%,%_ch%
		}
	}
	loop,4
	{
		_col2 := _colcnv[A_Index]
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
			_row2 := _rowcnv[A_Index]
			GuiControl,,vkeyRN%_col2%%_row2%,%_ch%
		}
	}
	loop,4
	{
		_col2 := _colcnv[A_Index]
		if(LF[g_Romaji . "LN" . _col2] != "")
		{
			org := StrSplit(LF[g_Romaji . "LN" . _col2],",")
		}
		else
		{
			org := StrSplit(LF["NUL" . _col2],",")
		}
		loop,% org.MaxIndex()
		{
			_ch := org[A_Index]
			_row2 := _rowcnv[A_Index]
			GuiControl,,vkeyRL%_col2%%_row2%,%_ch%
		}
	}
	loop,4
	{
		_col2 := _colcnv[A_Index]
		if(LF[g_Romaji . "RN" . _col2] != "")
		{
			org := StrSplit(LF[g_Romaji . "RN" . _col2],",")
		}
		else
		{
			org := StrSplit(LF["NUL" . _col2],",")
		}
		loop,% org.MaxIndex()
		{
			_ch := org[A_Index]
			_row2 := _rowcnv[A_Index]
			GuiControl,,vkeyRR%_col2%%_row2%,%_ch%
		}
	}
	loop,4
	{
		_col2 := _colcnv[A_Index]
		org := StrSplit(LF["NUL" . _col2],",")
		loop,% org.MaxIndex()
		{
			_row2 := _rowcnv[A_Index]
			GuiControl,+Redraw,vkeyDN%_col2%%_row2%
			GuiControl,+Redraw,vkeyRK%_col2%%_row2%
			GuiControl,+Redraw,vkeyRN%_col2%%_row2%
			GuiControl,+Redraw,vkeyRL%_col2%%_row2%
			GuiControl,+Redraw,vkeyRR%_col2%%_row2%
		}
	}
	Critical,off
	return

ReadKeyboardState:
	Critical
	VarSetCapacity(stKtbl, cbSize:=512, 0)
	NumPut(cbSize, stKtbl,  0, "UChar")   ;	
	stCurr := DllCall("GetKeyboardState", "UPtr", &stKtbl)
	if(stCurr==0) 
	{
		return
	}
	_vkey := 0x31
	_keyname := "E01"
	Gosub,SetKeyGui2
	_vkey := 0x32
	_keyname := "E02"
	Gosub,SetKeyGui2
	_vkey := 0x33
	_keyname := "E03"
	Gosub,SetKeyGui2
	_vkey := 0x34
	_keyname := "E04"  
	Gosub,SetKeyGui2
	_vkey := 0x35
	_keyname := "E05"
	Gosub,SetKeyGui2
	_vkey := 0x36
	_keyname := "E06"
	Gosub,SetKeyGui2
	_vkey := 0x37
	_keyname := "E07"
	Gosub,SetKeyGui2
	_vkey := 0x38
	_keyname := "E08"
	Gosub,SetKeyGui2
	_vkey := 0x39
	_keyname := "E09"
	Gosub,SetKeyGui2
	_vkey := 0x30
	_keyname := "E10"
	Gosub,SetKeyGui2
	_vkey := 0xBD			;-
	_keyname := "E11"
	Gosub,SetKeyGui2
	_vkey := 0xDE			;^
	_keyname := "E12"
	Gosub,SetKeyGui2
	_vkey := 0xDC			;\
	_keyname := "E13"
	Gosub,SetKeyGui2

	_vkey := 0x51			;q
	_keyname := "D01"
	Gosub,SetKeyGui2
	_vkey := 0x57			;w
	_keyname := "D02"
	Gosub,SetKeyGui2
	_vkey := 0x45			;e
	_keyname := "D03"
	Gosub,SetKeyGui2
	_vkey := 0x52			;r
	_keyname := "D04"
	Gosub,SetKeyGui2
	_vkey := 0x54			;t
	_keyname := "D05"
	Gosub,SetKeyGui2
	_vkey := 0x59			;y
	_keyname := "D06"
	Gosub,SetKeyGui2
	_vkey := 0x55			;u
	_keyname := "D07"
	Gosub,SetKeyGui2
	_vkey := 0x49			;i
	_keyname := "D08"
	Gosub,SetKeyGui2
	_vkey := 0x4F			;o
	_keyname := "D09"
	Gosub,SetKeyGui2
	_vkey := 0x50			;p
	_keyname := "D10"
	Gosub,SetKeyGui2
	_vkey := 0xC0			;@
	_keyname := "D11"
	Gosub,SetKeyGui2
	_vkey := 0xDB			;[
	_keyname := "D12"
	Gosub,SetKeyGui2
	
	_vkey := 0x41			;a
	_keyname := "C01"
	Gosub,SetKeyGui2
	_vkey := 0x53			;s
	_keyname := "C02"
	Gosub,SetKeyGui2
	_vkey := 0x44			;d
	_keyname := "C03"
	Gosub,SetKeyGui2
	_vkey := 0x46			;f
	_keyname := "C04"
	Gosub,SetKeyGui2
	_vkey := 0x47			;g
	_keyname := "C05"
	Gosub,SetKeyGui2
	_vkey := 0x48			;h
	_keyname := "C06"
	Gosub,SetKeyGui2
	_vkey := 0x4A			;j
	_keyname := "C07"
	Gosub,SetKeyGui2
	_vkey := 0x4B			;k
	_keyname := "C08"
	Gosub,SetKeyGui2
	_vkey := 0x4C			;l
	_keyname := "C09"
	Gosub,SetKeyGui2
	_vkey := 0xBB			;;
	_keyname := "C10"
	Gosub,SetKeyGui2
	_vkey := 0xBA			;:
	_keyname := "C11"
	Gosub,SetKeyGui2
	_vkey := 0xDD			;]
	_keyname := "C12"
	Gosub,SetKeyGui2

	_vkey := 0x5A			;z
	_keyname := "B01"
	Gosub,SetKeyGui2
	_vkey := 0x58			;x
	_keyname := "B02"
	Gosub,SetKeyGui2
	_vkey := 0x43			;c
	_keyname := "B03"
	Gosub,SetKeyGui2
	_vkey := 0x56			;v
	_keyname := "B04"
	Gosub,SetKeyGui2
	_vkey := 0x42			;b
	_keyname := "B05"
	Gosub,SetKeyGui2
	_vkey := 0x4E			;n
	_keyname := "B06"
	Gosub,SetKeyGui2
	_vkey := 0x4D			;m
	_keyname := "B07"
	Gosub,SetKeyGui2
	_vkey := 0xBC			;,
	_keyname := "B08"
	Gosub,SetKeyGui2
	_vkey := 0xBE			;.
	_keyname := "B09"
	Gosub,SetKeyGui2
	_vkey := 0xBF			;/
	_keyname := "B10"
	Gosub,SetKeyGui2
	_vkey := 0xE2			;\
	_keyname := "B11"
	Gosub,SetKeyGui2
	
	_vkey := 0x1D			;無変換
	_keyname := "A01"
	Gosub,SetKeyGui2
	_vkey := 0x20			;スペース
	_keyname := "A02"
	Gosub,SetKeyGui2
	_vkey := 0x1C			;変換
	_keyname := "A03"
	Gosub,SetKeyGui2
	critical,off
	return

SetKeyGui2:
	GuiControlGet,_val,,vkeyDN%_keyname%
	if( (NumGet(stKtbl,_vkey,"UChar") & 0x80)!= 0
	&&   _val != "□")
	{
		GuiControl,2:,vkeyDN%_keyname%,□
	}
	else
	if( (NumGet(stKtbl,_vkey,"UChar") & 0x80)== 0
	&&  _val != "　")
	{
		GuiControl,2:,vkeyDN%_keyname%,　
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
		keyAttributeHash["A01"] := "L"
		keyAttributeHash["A02"] := "X"
		keyAttributeHash["A03"] := "R"
	}
	else if(vOyaKey = "無変換－空白")
	{
		keyAttributeHash["A01"] := "L"
		keyAttributeHash["A02"] := "R"
		keyAttributeHash["A03"] := "X"
	}
	else	; 空白－変換
	{
		keyAttributeHash["A01"] := "X"
		keyAttributeHash["A02"] := "L"
		keyAttributeHash["A03"] := "R"
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
		_allTheLayout := vAllTheLayout
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
	g_allTheLayout := _allTheLayout
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


;----------------------------------------------------------------------
;	キー名から処理関数に変換
;	M:文字キー
;	X:修飾キー
;	L:左親指キー
;	R:右親指キー
;----------------------------------------------------------------------
MakeKeyAttributeHash() {
	keyAttributeHash := Object()
	keyAttributeHash["E00"] := "X"	; 半角/全角
	keyAttributeHash["E01"] := "M"
	keyAttributeHash["E02"] := "M"
	keyAttributeHash["E03"] := "M"
	keyAttributeHash["E04"] := "M"
	keyAttributeHash["E05"] := "M"
	keyAttributeHash["E06"] := "M"
	keyAttributeHash["E07"] := "M"
	keyAttributeHash["E08"] := "M"
	keyAttributeHash["E09"] := "M"
	keyAttributeHash["E10"] := "M"
	keyAttributeHash["E11"] := "M"
	keyAttributeHash["E12"] := "M"
	keyAttributeHash["E13"] := "M"
	keyAttributeHash["E14"] := "X"	; Backspace
	keyAttributeHash["D00"] := "X"	; Tab
	keyAttributeHash["D01"] := "M"
	keyAttributeHash["D02"] := "M"
	keyAttributeHash["D03"] := "M"
	keyAttributeHash["D04"] := "M"
	keyAttributeHash["D05"] := "M"
	keyAttributeHash["D06"] := "M"
	keyAttributeHash["D07"] := "M"
	keyAttributeHash["D08"] := "M"
	keyAttributeHash["D09"] := "M"
	keyAttributeHash["D10"] := "M"
	keyAttributeHash["D11"] := "M"
	keyAttributeHash["D12"] := "M"
	keyAttributeHash["C01"] := "M"
	keyAttributeHash["C02"] := "M"
	keyAttributeHash["C03"] := "M"
	keyAttributeHash["C04"] := "M"
	keyAttributeHash["C05"] := "M"
	keyAttributeHash["C06"] := "M"
	keyAttributeHash["C07"] := "M"
	keyAttributeHash["C08"] := "M"
	keyAttributeHash["C09"] := "M"
	keyAttributeHash["C10"] := "M"
	keyAttributeHash["C11"] := "M"
	keyAttributeHash["C12"] := "M"
	keyAttributeHash["C13"] := "X"	; Enter
	keyAttributeHash["B01"] := "M"
	keyAttributeHash["B02"] := "M"
	keyAttributeHash["B03"] := "M"
	keyAttributeHash["B04"] := "M"
	keyAttributeHash["B05"] := "M"
	keyAttributeHash["B06"] := "M"
	keyAttributeHash["B07"] := "M"
	keyAttributeHash["B08"] := "M"
	keyAttributeHash["B09"] := "M"
	keyAttributeHash["B10"] := "M"
	keyAttributeHash["B11"] := "M"
	keyAttributeHash["A00"] := "X"	; LCtrl
	keyAttributeHash["A01"] := "L"
	keyAttributeHash["A02"] := "X"	; Space
	keyAttributeHash["A03"] := "R"
	keyAttributeHash["A04"] := "X"	; カタカナひらがな
	keyAttributeHash["A05"] := "X"	; Rctrl
	return keyAttributeHash
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
