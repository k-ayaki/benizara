;-----------------------------------------------------------------------
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
	s_kOyaL := "" 
	s_kOyaR := ""
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
; 機能：１～４行目の各キーの矩形と入力文字の表示
;-----------------------------------------------------------------------
G2KeyRectChar:
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
	return
;-----------------------------------------------------------------------
; 機能：１～４行目の各キーの矩形と入力文字の表示
;-----------------------------------------------------------------------
G2KeyRectChar5:
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
	Gui, Add, Text,vvkeyDN%_col%%_row% X%_xpos0% Y%_ypos0% +Center BackgroundTrans,　
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
	if(s_kOyaL != kOyaL || s_kOyaR != kOyaR || s_KeySingle != g_KeySingle || s_Romaji != g_Romaji)
	{
		if(s_Romaji != g_Romaji) 
		{
			s_Romaji := g_Romaji
			Gosub,G2RefreshLayout
		}
		s_kOyaL := kOyaL 
		s_kOyaR := kOyaR
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
	Gui, Submit, NoHide
	GuiControl,-Redraw,vkeyDN51
	GuiControl,-Redraw,vkeyDN52
	GuiControl,-Redraw,vkeyDN53
	if((g_Romaji="A" && LFA!=0x77)
	|| (g_Romaji="R" && LFR!=0x77)) {
		Gui,Font,S42 cFFFFFF,Yu Gothic UI
		GuiControl,Font,vkeyFC51
		Gui,Font,S42 cFFFFFF,Yu Gothic UI
		GuiControl,Font,vkeyFC52
		Gui,Font,S42 cFFFFFF,Yu Gothic UI
		GuiControl,Font,vkeyFC53
		Gui, Font,s9 c000000,Meiryo UI
		GuiControl,,vkeyFA51,　　　
		GuiControl,,vkeyFA52,　　　
		GuiControl,,vkeyFA53,　　　
		GuiControl,,vkeyFB51,無変換
		GuiControl,,vkeyFB52, 空白 
		GuiControl,,vkeyFB53, 変換 
	}
	else
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
	vkeyDN51 := "　"
	GuiControl,2:,vkeyDN51,　
	vkeyDN52 := "　"
	GuiControl,2:,vkeyDN52,　
	vkeyDN53 := "　"
	GuiControl,2:,vkeyDN53,　
	GuiControl,+Redraw,vkeyDN51
	GuiControl,+Redraw,vkeyDN52
	GuiControl,+Redraw,vkeyDN53
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
	_keyname := "11"
	Gosub,SetKeyGui2
	_vkey := 0x32
	_keyname := "12"
	Gosub,SetKeyGui2
	_vkey := 0x33
	_keyname := "13"
	Gosub,SetKeyGui2
	_vkey := 0x34
	_keyname := "14"  
	Gosub,SetKeyGui2
	_vkey := 0x35
	_keyname := "15"
	Gosub,SetKeyGui2
	_vkey := 0x36
	_keyname := "16"
	Gosub,SetKeyGui2
	_vkey := 0x37
	_keyname := "17"
	Gosub,SetKeyGui2
	_vkey := 0x38
	_keyname := "18"
	Gosub,SetKeyGui2
	_vkey := 0x39
	_keyname := "19"
	Gosub,SetKeyGui2
	_vkey := 0x30
	_keyname := "110"
	Gosub,SetKeyGui2
	_vkey := 0xBD			;-
	_keyname := "111"
	Gosub,SetKeyGui2
	_vkey := 0xDE			;^
	_keyname := "112"
	Gosub,SetKeyGui2
	_vkey := 0xDC			;\
	_keyname := "113"
	Gosub,SetKeyGui2

	_vkey := 0x51			;q
	_keyname := "21"
	Gosub,SetKeyGui2
	_vkey := 0x57			;w
	_keyname := "22"
	Gosub,SetKeyGui2
	_vkey := 0x45			;e
	_keyname := "23"
	Gosub,SetKeyGui2
	_vkey := 0x52			;r
	_keyname := "24"
	Gosub,SetKeyGui2
	_vkey := 0x54			;t
	_keyname := "25"
	Gosub,SetKeyGui2
	_vkey := 0x59			;y
	_keyname := "26"
	Gosub,SetKeyGui2
	_vkey := 0x55			;u
	_keyname := "27"
	Gosub,SetKeyGui2
	_vkey := 0x49			;i
	_keyname := "28"
	Gosub,SetKeyGui2
	_vkey := 0x4F			;o
	_keyname := "29"
	Gosub,SetKeyGui2
	_vkey := 0x50			;p
	_keyname := "210"
	Gosub,SetKeyGui2
	_vkey := 0xC0			;@
	_keyname := "211"
	Gosub,SetKeyGui2
	_vkey := 0xDB			;[
	_keyname := "212"
	Gosub,SetKeyGui2
	
	_vkey := 0x41			;a
	_keyname := "31"
	Gosub,SetKeyGui2
	_vkey := 0x53			;s
	_keyname := "32"
	Gosub,SetKeyGui2
	_vkey := 0x44			;d
	_keyname := "33"
	Gosub,SetKeyGui2
	_vkey := 0x46			;f
	_keyname := "34"
	Gosub,SetKeyGui2
	_vkey := 0x47			;g
	_keyname := "35"
	Gosub,SetKeyGui2
	_vkey := 0x48			;h
	_keyname := "36"
	Gosub,SetKeyGui2
	_vkey := 0x4A			;j
	_keyname := "37"
	Gosub,SetKeyGui2
	_vkey := 0x4B			;k
	_keyname := "38"
	Gosub,SetKeyGui2
	_vkey := 0x4C			;l
	_keyname := "39"
	Gosub,SetKeyGui2
	_vkey := 0xBB			;;
	_keyname := "310"
	Gosub,SetKeyGui2
	_vkey := 0xBA			;:
	_keyname := "311"
	Gosub,SetKeyGui2
	_vkey := 0xDD			;]
	_keyname := "312"
	Gosub,SetKeyGui2

	_vkey := 0x5A			;z
	_keyname := "41"
	Gosub,SetKeyGui2
	_vkey := 0x58			;x
	_keyname := "42"
	Gosub,SetKeyGui2
	_vkey := 0x43			;c
	_keyname := "43"
	Gosub,SetKeyGui2
	_vkey := 0x56			;v
	_keyname := "44"
	Gosub,SetKeyGui2
	_vkey := 0x42			;b
	_keyname := "45"
	Gosub,SetKeyGui2
	_vkey := 0x4E			;n
	_keyname := "46"
	Gosub,SetKeyGui2
	_vkey := 0x4D			;m
	_keyname := "47"
	Gosub,SetKeyGui2
	_vkey := 0xBC			;,
	_keyname := "48"
	Gosub,SetKeyGui2
	_vkey := 0xBE			;.
	_keyname := "49"
	Gosub,SetKeyGui2
	_vkey := 0xBF			;/
	_keyname := "410"
	Gosub,SetKeyGui2
	_vkey := 0xE2			;\
	_keyname := "411"
	Gosub,SetKeyGui2
	
	_vkey := 0x1D			;無変換
	_keyname := "51"
	Gosub,SetKeyGui2
	_vkey := 0x20			;スペース
	_keyname := "52"
	Gosub,SetKeyGui2
	_vkey := 0x1C			;変換
	_keyname := "53"
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
		_Threshold := 100
	else
		_Threshold := 200
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
	SetTimer,G2PollingLayout,off
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

