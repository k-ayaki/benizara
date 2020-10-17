﻿;-----------------------------------------------------------------------
;	名称：Settings7.ahk
;	機能：紅皿のパラメータ設定
;	ver.0.1.4.3 .... 2020/10/5
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
	Gui, Font,s10 c000000
	;Gui, Add, Text,X30 Y52,親指シフトキー：
	;if(_OyaKey = "無変換－変換")
	;	Gui, Add, DropDownList,ggOya vvOyaKey X133 Y52 W125,無変換－変換||無変換－空白|空白－変換|
	;else if(_OyaKey = "無変換－空白")
	;	Gui, Add, DropDownList,ggOya vvOyaKey X133 Y52 W125,無変換－変換|無変換－空白||空白－変換|
	;else
	;	Gui, Add, DropDownList,ggOya vvOyaKey X133 Y52 W125,無変換－変換|無変換－空白|空白－変換||
	
	;GuiControl,,vOyaKey,%_OyaKey%
	Gui, Add, Checkbox,ggContinue vvContinue X292 Y52,連続シフト
	GuiControl,,vContinue,%_Continue%

	Gui, Add, Checkbox,ggZeroDelay vvZeroDelay X392 Y52,零遅延モード
	GuiControl,,vZeroDelay,%_ZeroDelay%
	
	Gui, Font,s10 c000000
	;Gui, Add, Text,X57 Y92,単独打鍵：
	;if(_KeySingle = "無効")
	;	Gui, Add, DropDownList,ggKeySingle vvKeySingle X137 Y92 W95,無効||有効|
	;else
	;	Gui, Add, DropDownList,ggKeySingle vvKeySingle X137 Y92 W95,無効|有効||
	
	;GuiControl,Disable,vKeySingle

	Gui, Add, Checkbox,ggKeyRepeat vvKeyRepeat X292 Y92,キーリピート
	GuiControl,,_KeyRepeat,%_KeyRepeat%
	
	Gui, Font,s10 c000000
	Gui, Add, Text,X30 Y132 c000000,文字と親指シフトの同時打鍵の割合：
	Gui, Add, Edit,vvOverlapNum X263 Y130 W50 ReadOnly, %_Overlap%
	Gui, Add, Text,X320 Y132 c000000,[`%]
	
	Gui, Add, Slider, X49 Y172 ggOlSlider w400 vvOlSlider Range20-80 line10 TickInterval10
	GuiControl,,vOlSlider,%_Overlap%
	
	Gui, Add, Text,X30 Y212 c000000,文字と親指シフトの同時打鍵の判定時間：
	Gui, Add, Edit,vvThresholdNum X263 Y210 W50 ReadOnly, %_Threshold%
	Gui, Add, Text,X320 Y212 c000000,[mSEC]
	
	Gui, Add, Slider, X49 Y252 ggThSlider w400 vvThSlider Range10-400 line10 TickInterval10
	GuiControl,,vThSlider,%_Threshold%

	Gui, Tab, 3
	if(DllCall("Shell32\IsUserAnAdmin") = 1)
	{
		Gui, Add, Text,X30 Y52,管理者権限で動作しています。
	}
	else
	{
		Gui, Add, Text,X30 Y52,通常権限で動作しています。
		Gui, Add, Button,ggButtonAdmin X30 Y102 W140 H22,管理者権限に切替
	}
	
	Gui, Tab, 4
	Gui, Font,s10 c000000,ＭＳ ゴシック
	Gui, Add, Text,X30  Y52,名称：benizara / 紅皿
	Gui, Add, Text,X30  Y92,機能：Yet another NICOLA Emulaton Software
	Gui, Add, Text,X30 Y104,　　　キーボード配列エミュレーションソフト
	Gui, Add, Text,X30 Y132,バージョン：%g_Ver% / %g_Date%
	Gui, Add, Text,X30 Y172,作者：Ken'ichiro Ayaki
	Gui, Show, W720 H440, 紅皿設定

	SetTimer,G2PollingLayout,100
	GuiControl,Focus,vEdit
	return


;-----------------------------------------------------------------------
; 機能：キーレイアウトの表示
;-----------------------------------------------------------------------
G2DrawKeyFrame:
	Gui,Add,GroupBox,X20 Y90 W670 H270,キー配列
	_col := 1
	_ypos := 110
	_cnt := 13
	loop,%_cnt%
	{
		_row := A_Index
		_xpos := 32*(_col-1) + 48*(_row - 1) + 40
		_ch := " "
		Gosub, G2KeyRectangle
		_xpos0 := _xpos + 10
		_ypos0 := _ypos + 10
		Gui, Font,s11 c000000,Meiryo UI
		Gui, Add, Text,vvkeyRK%_col%%_row% X%_xpos0% Y%_ypos0% W16 +Center c000000 BackgroundTrans,%_ch%
		_xpos0 := _xpos + 30
		_ypos0 := _ypos + 10
		Gui, Font,s11 c000000,Meiryo UI
		Gui, Add, Text,vvkeyRR%_col%%_row% X%_xpos0% Y%_ypos0% W16 +Center c000000 BackgroundTrans,%_ch%
		_xpos0 := _xpos + 10
		_ypos0 := _ypos + 30
		Gui, Font,s11 c000000,Meiryo UI
		Gui, Add, Text,vvkeyRL%_col%%_row% X%_xpos0% Y%_ypos0% W16 +Center c000000 BackgroundTrans,%_ch%
		_xpos0 := _xpos + 30
		_ypos0 := _ypos + 30
		Gui, Font,s11 c000000,Meiryo UI
		Gui, Add, Text,vvkeyRN%_col%%_row% X%_xpos0% Y%_ypos0% W16 +Center c000000 BackgroundTrans,%_ch%
		Gosub, G2KeyBorder
	}

	_col := 2
	_ypos := _ypos + 48
	_cnt := 12
	loop,%_cnt%
	{
		_row := A_Index
		_xpos := 32*(_col-1) + 48*(_row - 1) + 40
		_ch := " "
		Gosub, G2KeyRectangle
		_xpos0 := _xpos + 10
		_ypos0 := _ypos + 10
		Gui, Font,s11 c000000,Meiryo UI
		Gui, Add, Text,vvkeyRK%_col%%_row% X%_xpos0% Y%_ypos0% W16 +Center c000000 BackgroundTrans,%_ch%		
		_xpos0 := _xpos + 30
		_ypos0 := _ypos + 10
		Gui, Font,s11 c000000,Meiryo UI
		Gui, Add, Text,vvkeyRR%_col%%_row% X%_xpos0% Y%_ypos0% W16 +Center c000000 BackgroundTrans,%_ch%
		_xpos0 := _xpos + 10
		_ypos0 := _ypos + 30
		Gui, Font,s11 c000000,Meiryo UI
		Gui, Add, Text,vvkeyRL%_col%%_row% X%_xpos0% Y%_ypos0% W16 +Center c000000 BackgroundTrans,%_ch%
		_xpos0 := _xpos + 30
		_ypos0 := _ypos + 30
		Gui, Font,s11 c000000,Meiryo UI
		Gui, Add, Text,vvkeyRN%_col%%_row% X%_xpos0% Y%_ypos0% W16 +Center c000000 BackgroundTrans,%_ch%
		Gosub, G2KeyBorder
	}
	_col := 3
	_ypos := _ypos + 48
	_cnt := 12
	loop,%_cnt%
	{
		_row := A_Index
		_xpos := 32*(_col-1) + 48*(_row - 1) + 40
		_ch := " "
		Gosub, G2KeyRectangle
		_xpos0 := _xpos + 10
		_ypos0 := _ypos + 10
		Gui, Font,s11 c000000,Meiryo UI
		Gui, Add, Text,vvkeyRK%_col%%_row% X%_xpos0% Y%_ypos0% W16 +Center c000000 BackgroundTrans,%_ch%
		_xpos0 := _xpos + 30
		_ypos0 := _ypos + 10
		Gui, Font,s11 c000000,Meiryo UI
		Gui, Add, Text,vvkeyRR%_col%%_row% X%_xpos0% Y%_ypos0% W16 +Center c000000 BackgroundTrans,%_ch%
		_xpos0 := _xpos + 10
		_ypos0 := _ypos + 30
		Gui, Font,s11 c000000,Meiryo UI
		Gui, Add, Text,vvkeyRL%_col%%_row% X%_xpos0% Y%_ypos0% W16 +Center c000000 BackgroundTrans,%_ch%
 		_xpos0 := _xpos + 30
		_ypos0 := _ypos + 30
		Gui, Font,s11 c000000,Meiryo UI
		Gui, Add, Text,vvkeyRN%_col%%_row% X%_xpos0% Y%_ypos0% W16 +Center c000000 BackgroundTrans,%_ch%
		Gosub, G2KeyBorder
	}
	_col := 4
	_ypos := _ypos + 48
	_cnt := 11
	loop,%_cnt%
	{
		_row := A_Index
		_xpos := 32*(_col-1) + 48*(_row - 1) + 40
		_ch := " "
		Gosub, G2KeyRectangle
		_xpos0 := _xpos + 10
		_ypos0 := _ypos + 10
		Gui, Font,s11 c000000,Meiryo UI
		Gui, Add, Text,vvkeyRK%_col%%_row% X%_xpos0% Y%_ypos0% W16 +Center c000000 BackgroundTrans,%_ch%
		_xpos0 := _xpos + 30
		_ypos0 := _ypos + 10
		Gui, Font,s11 c000000,Meiryo UI
		Gui, Add, Text,vvkeyRR%_col%%_row% X%_xpos0% Y%_ypos0% W16 +Center c000000 BackgroundTrans,%_ch%
		_xpos0 := _xpos + 10
		_ypos0 := _ypos + 30
		Gui, Font,s11 c000000,Meiryo UI
		Gui, Add, Text,vvkeyRL%_col%%_row% X%_xpos0% Y%_ypos0% W16 +Center c000000 BackgroundTrans,%_ch%
		_xpos0 := _xpos + 30
		_ypos0 := _ypos + 30
		Gui, Font,s11 c000000,Meiryo UI
		Gui, Add, Text,vvkeyRN%_col%%_row% X%_xpos0% Y%_ypos0% W16 +Center c000000 BackgroundTrans,%_ch%
		Gosub, G2KeyBorder
	}
	_col := 5
	_ypos := _ypos + 48
	_row := 1
	_xpos := 32*(_col-1) + 48*(_row + 2 - 1) + 40
	Gosub, G2KeyRectangle5
	_xpos0 := _xpos + 6
	_ypos0 := _ypos + 10
	Gui, Font,s9 c000000,Meiryo UI
	Gui, Add, Text,vvkeyFA%_col%%_row% X%_xpos0% Y%_ypos0% W42 +Center c000000 BackgroundTrans,左親指
	_xpos0 := _xpos + 6
	_ypos0 := _ypos + 30
	Gui, Font,s9 c000000,Meiryo UI
	Gui, Add, Text,vvkeyFB%_col%%_row% X%_xpos0% Y%_ypos0% W42 +Center c000000 BackgroundTrans,　　　
	Gosub, G2KeyBorder

	_row := 2
	_xpos := 32*(_col-1) + 48*(_row + 2 - 1) + 40
	Gosub, G2KeyRectangle5
	_xpos0 := _xpos + 6
	_ypos0 := _ypos + 10
	Gui, Font,s9 c000000,Meiryo UI
	Gui, Add, Text,vvkeyFA%_col%%_row% X%_xpos0% Y%_ypos0% W42 +Center c000000 BackgroundTrans,　　　
	_xpos0 := _xpos + 6
	_ypos0 := _ypos + 30
	Gui, Font,s9 c000000,Meiryo UI
	Gui, Add, Text,vvkeyFB%_col%%_row% X%_xpos0% Y%_ypos0% W42 +Center c000000 BackgroundTrans,　　　
	Gosub, G2KeyBorder

	_row := 3
	_xpos := 32*(_col-1) + 48*(_row + 2 - 1) + 40
	Gosub, G2KeyRectangle5
	_xpos0 := _xpos + 6
	_ypos0 := _ypos + 10
	Gui, Font,s9 c000000,Meiryo UI
	Gui, Add, Text,vvkeyFA%_col%%_row% X%_xpos0% Y%_ypos0% W42 +Center c000000 BackgroundTrans,右親指
	_xpos0 := _xpos + 6
	_ypos0 := _ypos + 30
	Gui, Font,s9 c000000,Meiryo UI
	Gui, Add, Text,vvkeyFB%_col%%_row% X%_xpos0% Y%_ypos0% W42 +Center c000000 BackgroundTrans,　  
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
	Gui, Add, Text,X%_xpos0% X%_xpos0% Y%_ypos0% +Center BackgroundTrans,■
	if(_row == 1 && kOyaL=="sc07B")
	{
		Gui, Font,s42 cFFFF00,Yu Gothic UI
	}
	else 
	if(_row == 2 && kOyaL=="Space")
	{
		Gui, Font,s42 cFFFF00,Yu Gothic UI
	}
	else
	if(_row == 2 && kOyaR=="Space")
	{
		Gui, Font,s42 c00FFFF,Yu Gothic UI
	}
	else
	if(_row == 3 && kOyaR=="sc079")
	{
		Gui, Font,s42 c00FFFF,Yu Gothic UI
	}
	else
	{
		Gui, Font,s42 cFFFFFF,Yu Gothic UI
	}
	_ypos0 := _ypos - 8
	_xpos0 := _xpos - 1
	Gui, Add, Text,vvkeyFC%_col%%_row% X%_xpos0% Y%_ypos0% +Center BackgroundTrans,■
	return

;-----------------------------------------------------------------------
; 機能：キーダウン表示
;-----------------------------------------------------------------------
G2KeyBorder:
	Gui, Font,s45 c000000,Yu Gothic UI
	_ypos0 := _ypos - 12
	_xpos0 := _xpos - 3
	Gui, Add, Text,vvkeyDN%_col%%_row% X%_xpos0% X%_xpos0% Y%_ypos0% +Center BackgroundTrans,　
	vkeyDN%_col%%A_Index% := "　"
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
	if(s_Romaji != g_Romaji) 
	{
		s_Romaji := g_Romaji
		Gosub,G2RefreshLayout
	}
	if(s_kOyaL != kOyaL || s_kOyaR != kOyaR || s_KeySingle != g_KeySingle)
	{
		s_kOyaL := kOyaL 
		s_kOyaR := kOyaR
		s_KeySingle := g_KeySingle
		Gosub,G2RefreshLayout5
	}
	return

;-----------------------------------------------------------------------
; 機能：キー配列表示の切り替え
;-----------------------------------------------------------------------
G2RefreshLayout5:
	Gui, Submit, NoHide
	if(s_kOyaL = "sc07B" && s_kOyaR = "sc079")
	{
		Gui,Font,S42 cFFFF00,Yu Gothic UI
		GuiControl,Font,vkeyFC51
		Gui,Font,S42 cFFFFFF,Yu Gothic UI
		GuiControl,Font,vkeyFC52
		Gui,Font,S42 c00FFFF,Yu Gothic UI
		GuiControl,Font,vkeyFC53
		Gui, Font,s9 c000000,Meiryo UI
		GuiControl,,vkeyFA51,左親指
		GuiControl,,vkeyFA52,　　　
		GuiControl,,vkeyFA53,右親指
		if(s_KeySingle = "有効")
		{
			GuiControl,,vkeyFB51,無変換
			GuiControl,,vkeyFB52, 空白 
			GuiControl,,vkeyFB53, 変換 
		}
		else
		{
			GuiControl,,vkeyFB51,　　　
			GuiControl,,vkeyFB52, 空白 
			GuiControl,,vkeyFB53,　　　
		}
	}
	else if(s_kOyaL = "sc07B" && s_kOyaR = "Space")
	{
		Gui,Font,S42 cFFFF00,Yu Gothic UI
		GuiControl,Font,vkeyFC51
		Gui,Font,S42 c00FFFF,Yu Gothic UI
		GuiControl,Font,vkeyFC52
		Gui,Font,S42 cFFFFFF,Yu Gothic UI
		GuiControl,Font,vkeyFC53
		GuiControl,,vkeyFA51,左親指
		GuiControl,,vkeyFA52,右親指
		GuiControl,,vkeyFA53,　　　
		if(s_KeySingle = "有効")
		{
			GuiControl,,vkeyFB51,無変換
			GuiControl,,vkeyFB52, 空白 
			GuiControl,,vkeyFB53, 変換 
		}
		else
		{
			GuiControl,,vkeyFB51,　　　
			GuiControl,,vkeyFB52, 空白 
			GuiControl,,vkeyFB53, 変換 
		}
	}
	else	; 空白－変換
	{
		Gui,Font,S42 cFFFFFF,Yu Gothic UI
		GuiControl,Font,vkeyFC51
		Gui,Font,S42 cFFFF00,Yu Gothic UI
		GuiControl,Font,vkeyFC52
		Gui,Font,S42 c00FFFF,Yu Gothic UI
		GuiControl,Font,vkeyFC53
		GuiControl,,vkeyFA51,　　　
		GuiControl,,vkeyFA52,左親指
		GuiControl,,vkeyFA53,右親指
		if(s_KeySingle = "有効")
		{
			GuiControl,,vkeyFB51,無変換
			GuiControl,,vkeyFB52, 空白 
			GuiControl,,vkeyFB53, 変換 
		}
		else
		{
			GuiControl,,vkeyFB51,無変換
			GuiControl,,vkeyFB52, 空白 
			GuiControl,,vkeyFB53,　　　
		}
	}
	return

;-----------------------------------------------------------------------
; 機能：キー配列表示の切り替え
;-----------------------------------------------------------------------
G2RefreshLayout:
	Gui, Submit, NoHide
	loop,4
	{
		_col := A_Index
		StringSplit org,LFNUL%_col%,`,
		loop,%org0%
		{
			GuiControl,-Redraw,vkeyDN%_col%%A_Index%
			GuiControl,,vkeyDN%_col%%A_Index%,　
			GuiControl,-Redraw,vkeyRK%_col%%A_Index%
			GuiControl,-Redraw,vkeyRN%_col%%A_Index%
			GuiControl,-Redraw,vkeyRL%_col%%A_Index%
			GuiControl,-Redraw,vkeyRR%_col%%A_Index%
		}
	}
	loop,4
	{
		_col := A_Index
		if(LF%g_Romaji%NK%_col% != "")
		{
			StringSplit org,LF%g_Romaji%NK%_col%,`,
		}
		else
		{
			StringSplit org,LFADK%_col%,`,
		}
		loop,%org0%
		{
			_ch := org%A_Index%
			GuiControl,,vkeyRK%_col%%A_Index%,%_ch%
		}
	}
	loop,4
	{
		_col := A_Index
		if(LF%g_Romaji%NN%_col% != "")
		{
			StringSplit org,LF%g_Romaji%NN%_col%,`,
		}
		else
		{
			StringSplit org,LFADN%_col%,`,
		}
		loop,%org0%
		{
			_ch := org%A_Index%
			GuiControl,,vkeyRN%_col%%A_Index%,%_ch%
		}
	}
	loop,4
	{
		_col := A_Index
		if(LF%g_Romaji%LN%_col% != "")
		{
			StringSplit org,LF%g_Romaji%LN%_col%,`,
		}
		else
		{
			StringSplit org,LFNUL%_col%,`,
		}
		loop,%org0%
		{
			_ch := org%A_Index%
			GuiControl,,vkeyRL%_col%%A_Index%,%_ch%
		}
	}
	loop,4
	{
		_col := A_Index
		if(LF%g_Romaji%RN%_col% != "")
		{
			StringSplit org,LF%g_Romaji%RN%_col%,`,
		}
		else
		{
			StringSplit org,LFNUL%_col%,`,
		}
		loop,%org0%
		{
			_ch := org%A_Index%
			GuiControl,,vkeyRR%_col%%A_Index%,%_ch%
		}
	}
	loop,4
	{
		_col := A_Index
		StringSplit org,LFNUL%_col%,`,
		loop,%org0%
		{
			GuiControl,+Redraw,vkeyDN%_col%%A_Index%
			GuiControl,+Redraw,vkeyRK%_col%%A_Index%
			GuiControl,+Redraw,vkeyRN%_col%%A_Index%
			GuiControl,+Redraw,vkeyRL%_col%%A_Index%
			GuiControl,+Redraw,vkeyRR%_col%%A_Index%
		}
	}
	return

;-----------------------------------------------------------------------
; 機能：タブ変更
;-----------------------------------------------------------------------
gTabChange:
	Gui, Submit, NoHide
	g_TabName := vTabName
	GuiControl,Focus,vEdit
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
		kOyaR := "sc079"
		kOyaL := "sc07B"
	}
	else if(vOyaKey = "無変換－空白")
	{
		kOyaR := "Space"
		kOyaL := "sc07B"
	}
	else	; 空白－変換
	{
		kOyaL := "Space"
		kOyaR := "sc079"
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
	Gui,Destroy
	return

;-----------------------------------------------------------------------
; 機能：キャンセルボタンの押下
;-----------------------------------------------------------------------
gButtonCancel:
GuiClose:
	Gosub, Init
	Gui,Destroy
	return
