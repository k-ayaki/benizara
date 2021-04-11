;-----------------------------------------------------------------------
;	名称：Settings7.ahk
;	機能：紅皿のパラメータ設定
;	ver.0.1.4.4 .... 2021/3/28
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
		g_LayoutFile := ".\NICOLA配列.bnz"
		IniWrite,%g_LayoutFile%,%g_IniFile%,FilePath,LayoutFile
		g_Continue := 1
		IniWrite,%g_Continue%,%g_IniFile%,Key,Continue
		g_Threshold := 100
		IniWrite,%g_Threshold%,%g_IniFile%,Key,Threshold
		g_ThresholdSS := 150
		IniWrite,%g_ThresholdSS%,%g_IniFile%,Key,ThresholdSS
		g_ZeroDelay := 1
		IniWrite,%g_ZeroDelay%,%g_IniFile%,Key,ZeroDelay
		g_OverlapOM := 35
		IniWrite,%g_OverlapOM%,%g_IniFile%,Key,OverlapOM
		g_OverlapMO := 70
		IniWrite,%g_OverlapMO%,%g_IniFile%,Key,OverlapMO
		g_OverlapSS := 35
		IniWrite,%g_OverlapSS%,%g_IniFile%,Key,OverlapSS
		g_OyaKey := "無変換－変換"
		IniWrite,%g_OyaKey%,%g_IniFile%,Key,OyaKey
		g_KeySingle := "無効"
		IniWrite,%g_KeySingle%,%g_IniFile%,Key,KeySingle
		g_KeyRepeat := 0
		IniWrite,%g_KeyRepeat%,%g_IniFile%,Key,KeyRepeat
		g_KeyPause := "Pause"
		IniWrite,%g_KeyPause%,%g_IniFile%,Key,KeyPause
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
	IniRead,g_ThresholdSS,%g_IniFile%,Key,ThresholdSS
	if(g_ThresholdSS < 10)
		g_ThresholdSS := 10
	if(g_ThresholdSS > 400)
		g_ThresholdSS := 400
	IniRead,g_OverlapMO,%g_IniFile%,Key,OverlapMO
	if(g_OverlapMO < 10)
		g_OverlapMO := 10
	if(g_OverlapMO > 90)
		g_OverlapMO := 90
	IniRead,g_OverlapOM,%g_IniFile%,Key,OverlapOM
	if(g_OverlapOM < 10)
		g_OverlapOM := 10
	if(g_OverlapOM > 90)
		g_OverlapOM := 90
	IniRead,g_OverlapSS,%g_IniFile%,Key,OverlapSS
	if(g_OverlapSS < 10)
		g_OverlapSS := 10
	if(g_OverlapSS > 90)
		g_OverlapSS := 90
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
		g_KeyRepeat := 0
	IniRead,g_KeyPause,%g_IniFile%,Key,KeyPause
	if g_KeyPause not in Pause,ScrollLock,無効
		g_KeyPause := "Pause"
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
	_ThresholdSS := g_ThresholdSS
	_LayoutFile := g_LayoutFile
	_OverlapMO := g_OverlapMO
	_OverlapOM := g_OverlapOM
	_Overlap := g_Overlap
	_OverlapSS := g_OverlapSS
	_OyaKey := g_OyaKey
	_KeySingle := g_KeySingle
	_KeyRepeat := g_KeyRepeat
_Settings:
	Gui,2:Default
	Gui, 2:New
	Gui, Font,s10 c000000
	Gui, Add, Button,ggButtonOk X530 Y405 W80 H22,ＯＫ
	Gui, Add, Button,ggButtonCancel X620 Y405 W80 H22,キャンセル
	Gui, Add, Tab3,ggTabChange vvTabName X10 Y10 W690 H390, 配列||親指シフト|文字同時打鍵|一時停止|管理者権限|紅皿について
	g_TabName := "配列"
	
	Gui, Tab, 1
	Gui, Add, Edit,X30 Y40 W280 H20 ReadOnly -Vscroll, %g_layoutName%　%g_layoutVersion%
	Gui, Add, Text,X320 Y40, 定義ファイル：
	Gui, Add, Edit,vvFilePath ggDefFile X400 Y40 W220 H20 ReadOnly, %_LayoutFile%
	Gui, Add, Button,ggFileSelect X630 Y40 W32 H21,…

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
	else if(ShiftMode["R"] = "プレフィックスシフト")
	{
		Gui, Add, Text,X30 Y70,プレフィックスシフトを用いた配列です
	}
	else if(ShiftMode["R"] = "文字同時打鍵")
	{
		Gui, Add, Text,X30 Y70,文字同時打鍵を用いた配列です
	}
	Gui, Font,s10 c000000,Meiryo UI
	Gosub,G2DrawKeyFrame
	Gui, Font,s9 c000000,Meiryo UI
	Gui, Add, Edit,vvEdit X60 Y370 W600 H20 -Vscroll,
	Gosub, G2RefreshLayout
	
	Gui, Tab, 2
	Gui, Font,s10 c000000,Meiryo UI
	Gui, Add, Edit,X20 Y40 W300 H40 ReadOnly -Vscroll,親指シフトキーの押し続けをシフトオンとします。
	Gui, Add, Checkbox,ggContinue vvContinue X+20 Y50,連続シフト
	GuiControl,,vContinue,%_Continue%

	Gui, Add, Edit,X20 Y90 W300 H40 ReadOnly -Vscroll,キー打鍵と共に遅延なく候補文字を表示します。	
	Gui, Add, Checkbox,ggZeroDelay vvZeroDelay X+20 Y100,零遅延モード
	GuiControl,,vZeroDelay,%_ZeroDelay%
	
	Gui, Add, Edit,X20 Y140 W300 H40 ReadOnly -Vscroll,親指シフトキーをキーリピートさせます。
	Gui, Add, Checkbox,ggKeyRepeat vvKeyRepeat X340 Y150,キーリピート
	GuiControl,,vKeyRepeat,%_KeyRepeat%
	
	Gui, Add, Edit,X20 Y190 W300 H60 ReadOnly -Vscroll,親指シフトキー⇒文字キーの順の打鍵の重なりが打鍵全体の何％のときに、同時打鍵であるかを決定します。
	Gui, Add, Text,X+20 Y190 W230 H20,親指キー⇒文字キーの重なりの割合：
	Gui, Add, Edit,vvOverlapNumOM X+3 Y188 W50 ReadOnly, %_OverlapOM%
	Gui, Add, Text,X+10 Y190 c000000,[`%]

	Gui, Add, Slider, X320 Y220 ggOlSliderOM w350 vvOlSliderOM Range10-90 line10 TickInterval10
	GuiControl,,vOlSliderOM,%_OverlapOM%

	Gui, Add, Edit,X20 Y260 W300 H60 ReadOnly -Vscroll,文字キー⇒親指シフトキーの順の打鍵の重なりが打鍵全体の何％のときに、同時打鍵であるかを決定します。
	Gui, Add, Text,X+20 Y260 W230 H20,文字キー⇒親指キーの重なりの割合：
	Gui, Add, Edit,vvOverlapNumMO X+3 Y258 W50 ReadOnly, %_OverlapMO%
	Gui, Add, Text,X+10 Y260 c000000,[`%]
	
	Gui, Add, Slider, X320 Y290 ggOlSliderMO w350 vvOlSliderMO Range10-90 line10 TickInterval10
	GuiControl,,vOlSliderMO,%_OverlapMO%
	
	Gui, Add, Edit,X20 Y330 W300 H60 ReadOnly -Vscroll,文字キーと親指シフトキーの打鍵の重なり期間やが何ミリ秒のときに同時打鍵であるかを決定します。
	Gui, Add, Text,X+20 Y330 W230 H20,文字キーと親指キーの重なりの判定時間：
	Gui, Add, Edit,vvThresholdNum X+3 Y328 W50 ReadOnly, %_Threshold%
	Gui, Add, Text,X+10 Y330 c000000,[mSEC]
	
	Gui, Add, Slider, X320 Y360 ggThSlider w350 vvThSlider Range10-400 line10 TickInterval10
	GuiControl,,vThSlider,%_Threshold%

	Gui, Tab, 3
	Gui, Add, Edit,X20 Y40 W300 H60 ReadOnly -Vscroll,キー打鍵と共に遅延なく候補文字を表示します。	
	Gui, Add, Checkbox,ggZeroDelaySS vvZeroDelaySS X+20 Y65,零遅延モード
	GuiControl,,vZeroDelaySS,%_ZeroDelay%
	
	Gui, Add, Edit,X20 Y110 W300 H60 ReadOnly -Vscroll,文字キー同志の打鍵の重なりが打鍵全体の何％のときに、同時打鍵であるかを決定します。
	Gui, Add, Text,X+20 Y110 W230 H20,文字キー同志の重なりの割合：
	Gui, Add, Edit,vvOverlapNumSS X+3 Y108 W50 ReadOnly, %_OverlapSS%
	Gui, Add, Text,X+10 Y110 c000000,[`%]

	Gui, Add, Slider, X320 Y140 ggOlSliderSS w350 vvOlSliderSS Range10-90 line10 TickInterval10
	GuiControl,,vOlSliderSS,%_OverlapSS%
	
	Gui, Add, Edit,X20 Y180 W300 H60 ReadOnly -Vscroll,文字キー同志の打鍵の重なり期間が何ミリ秒のときに同時打鍵であるかを決定します。
	Gui, Add, Text,X+20 Y180 W230 H20,文字キー同志の重なりの判定時間：
	Gui, Add, Edit,vvThresholdNumSS X+3 Y178 W50 ReadOnly, %_ThresholdSS%
	Gui, Add, Text,X+10 Y180 c000000,[mSEC]
	
	Gui, Add, Slider, X320 Y210 ggThSliderSS w350 vvThSliderSS Range10-400 line10 TickInterval10
	GuiControl,,vThSliderSS,%_ThresholdSS%
	
	Gui, Tab, 4
	Gui, Font,s10 c000000,Meiryo UI
	Gui, Add, Edit,X20 Y40 W640 H60 ReadOnly -Vscroll,紅皿を一時停止させるキーを決定します。
	Gui, Add, Text,X30 Y130,一時停止キー：
	if(g_KeyPause = "Pause")
		Gui, Add, DropDownList,ggSetPause vvKeyPause X140 Y130 W125,Pause||ScrollLock|無効|
	else if(g_KeyPause = "ScrollLock")
		Gui, Add, DropDownList,ggSetPause vvKeyPause X140 Y130 W125,Pause|ScrollLock||無効|
	else
		Gui, Add, DropDownList,ggSetPause vvKeyPause X140 Y130 W125,Pause|ScrollLock|無効||

	Gui, Tab, 5
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
	Gui, Tab, 6
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
	_ch := GuiLayoutHash[g_Romaji]
	Gui,Add,GroupBox,vvkeyLayoutName X20 Y90 W670 H270,%_ch%
	_col := 1
	_ypos := 105
	loop,13
	{
		_row := A_Index
		Gosub,DrawKeyE2B
	}
	_col := 2
	_ypos := _ypos + 48
	loop,12
	{
		_row := A_Index
		Gosub,DrawKeyE2B
	}
	_col := 3
	_ypos := _ypos + 48
	loop,12
	{
		_row := A_Index
		Gosub,DrawKeyE2B
	}
	_col := 4
	_ypos := _ypos + 48
	loop,11
	{
		_row := A_Index
		Gosub,DrawKeyE2B
	}
	_col := 5
	_ypos := _ypos + 48
	loop, 4
	{
		_row := A_Index
		Gosub,DrawKeyA
	}
	Gosub,DrawKeyUsage
	critical,off
	return

;-----------------------------------------------------------------------
; 機能：E～B段の各キーの矩形と入力文字の表示
;-----------------------------------------------------------------------
DrawKeyE2B:
	_xpos := 32*(_col-1) + 48*(_row - 1) + 40
	_ch := " "
	Gosub, DrawKeyRectE2B
	_xpos0 := _xpos + 4
	_ypos0 := _ypos + 10
	_col2 := _colhash[_col]
	_row2 := _rowhash[_row]
	Gui, Font,s10 c000000,Meiryo UI
	Gui, Add, Text,vvkeyRL%_col2%%_row2% X%_xpos0% Y%_ypos0% W24 +Center c000000 BackgroundTrans,%_ch%
	_xpos0 := _xpos + 24
	_ypos0 := _ypos + 10
	Gui, Font,s10 c000000,Meiryo UI
	Gui, Add, Text,vvkeyRR%_col2%%_row2% X%_xpos0% Y%_ypos0% W24 +Center c000000 BackgroundTrans,%_ch%
	_xpos0 := _xpos + 4
	_ypos0 := _ypos + 30
	Gui, Font,s10 c000000,Meiryo UI
	Gui, Add, Text,vvkeyRK%_col2%%_row2% X%_xpos0% Y%_ypos0% W24 +Center c000000 BackgroundTrans,%_ch%
	_xpos0 := _xpos + 24
	_ypos0 := _ypos + 30
	Gui, Font,s10 c000000,Meiryo UI
	Gui, Add, Text,vvkeyRN%_col2%%_row2% X%_xpos0% Y%_ypos0% W24 +Center c000000 BackgroundTrans,%_ch%
	Gosub, DrawKeyBorder
	return
;-----------------------------------------------------------------------
; 機能：A段の各キーの矩形と入力文字の表示
;-----------------------------------------------------------------------
DrawKeyA:
	_xpos := 32*(_col-1) + 48*(_row + 2 - 1) + 40
	Gosub, DrawKeyRectA
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
	Gosub, DrawKeyBorder
	return

;-----------------------------------------------------------------------
; 機能：キー凡例
;-----------------------------------------------------------------------
DrawKeyUsage:
	_xpos := 40
	_row := 0
	Gosub, DrawKeyRectA
	_xpos0 := _xpos + 4
	_ypos0 := _ypos + 10
	Gui, Font,s7 c000000,Meiryo UI
	_ch := "左親"
	Gui, Add, Text,vvkeyRLA00 X%_xpos0% Y%_ypos0% W24 +Center c000000 BackgroundTrans,%_ch%
	_xpos0 := _xpos + 24
	_ypos0 := _ypos + 10
	Gui, Font,s7 c000000,Meiryo UI
	_ch := "右親"
	Gui, Add, Text,vvkeyRRA00 X%_xpos0% Y%_ypos0% W24 +Center c000000 BackgroundTrans,%_ch%
	_xpos0 := _xpos + 4
	_ypos0 := _ypos + 30
	Gui, Font,s7 c000000,Meiryo UI
	_ch := "小指"
	Gui, Add, Text,vvkeyRKA00 X%_xpos0% Y%_ypos0% W24 +Center c000000 BackgroundTrans,%_ch%
	_xpos0 := _xpos + 24
	_ypos0 := _ypos + 30
	Gui, Font,s8 c000000,Meiryo UI
	_ch := "無"
	Gui, Add, Text,vvkeyRNA00 X%_xpos0% Y%_ypos0% W24 +Center c000000 BackgroundTrans,%_ch%
	Gosub, DrawKeyBorder
	return

;-----------------------------------------------------------------------
; 機能：各キーの矩形表示
;-----------------------------------------------------------------------
DrawKeyRectE2B:
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
DrawKeyRectA:
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
DrawKeyBorder:
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
			_ch := GuiLayoutHash[g_Romaji]
			GuiControl,,vkeyLayoutName,%_ch%
			Gosub,G2RefreshLayout
		}
		s_KeySingle := g_KeySingle
		Gosub,RefreshLayoutA
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
RefreshLayoutA:
	_layoutPos := "A01"
	Gosub,RefreshLayoutA1
	_layoutPos := "A02"
	Gosub,RefreshLayoutA1
	_layoutPos := "A03"
	Gosub,RefreshLayoutA1
	_layoutPos := "A04"
	Gosub,RefreshLayoutA1
	_layoutPos := "A00"
	Gosub,RefreshLayoutUsage
	return

;-----------------------------------------------------------------------
; 機能：Ａ列のキー表示の更新
;-----------------------------------------------------------------------
RefreshLayoutA1:
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
	_label := kLabel[_layoutPos]
	GuiControl,,vkeyFB%_layoutPos%,%_label%
	vkeyDN%_layoutPos% := "　"
	GuiControl,2:,vkeyDN%_layoutPos%,　
	GuiControl,+Redraw,vkeyDN%_layoutPos%
	Critical,off
	return
;-----------------------------------------------------------------------
; 機能：凡例表示の更新
;-----------------------------------------------------------------------
RefreshLayoutUsage:
	Critical
	Gui, Submit, NoHide
	if(ShiftMode["R"] == "親指シフト") {
		GuiControl,,vkeyRLA00,左親
		GuiControl,,vkeyRRA00,右親
	}
	else
	if(ShiftMode["R"] == "プレフィックスシフト") {
		GuiControl,,vkeyRLA00,１
		GuiControl,,vkeyRRA00,２
	}
	else
	if(ShiftMode["R"] == "文字同時打鍵") {
		GuiControl,,vkeyRLA00,中指
		GuiControl,,vkeyRRA00,薬指
	}
	Critical,off
	return

;-----------------------------------------------------------------------
; 機能：キー配列表示の切り替え
;-----------------------------------------------------------------------
G2RefreshLayout:
	Critical
	Gui, Submit, NoHide
	for index, element in layoutArys
	{
		GuiControl,-Redraw,vkeyDN%element%
		GuiControl,,vkeyDN%element%,　
		GuiControl,-Redraw,vkeyRK%element%
		GuiControl,-Redraw,vkeyRN%element%
		GuiControl,-Redraw,vkeyRL%element%
		GuiControl,-Redraw,vkeyRR%element%
		
		_ch := kLabel[g_Romaji . "NK" . element]
		GuiControl,,vkeyRK%element%,%_ch%
		_ch := kLabel[g_Romaji . "NN" . element]
		GuiControl,,vkeyRN%element%,%_ch%	
		_ch := kLabel[g_Romaji . "LN" . element]
		if(_ch == "") {
			_ch := kLabel[g_Romaji . "1N" . element]
		}
		if(_ch == "") {
			_ch := kLabel[g_Romaji . "3N" . element]
		}
		GuiControl,,vkeyRL%element%,%_ch%
		_ch := kLabel[g_Romaji . "RN" . element]
		if(_ch == "") {
			_ch := kLabel[g_Romaji . "2N" . element]
		}
		if(_ch == "") {
			_ch := kLabel[g_Romaji . "4N" . element]
		}
		GuiControl,,vkeyRR%element%,%_ch%
		GuiControl,+Redraw,vkeyDN%element%
		GuiControl,+Redraw,vkeyRK%element%
		GuiControl,+Redraw,vkeyRN%element%
		GuiControl,+Redraw,vkeyRL%element%
		GuiControl,+Redraw,vkeyRR%element%
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
; 機能：親指シフト同時打鍵の判定時間のスライダー操作
;-----------------------------------------------------------------------
gThSlider:
	GuiControlGet, _Threshold , , vThSlider, 
	GuiControl,, vThresholdNum, %_Threshold%
	return

;-----------------------------------------------------------------------
; 機能：文字同時打鍵の判定時間のスライダー操作
;-----------------------------------------------------------------------
gThSliderSS:
	GuiControlGet, _ThresholdSS , , vThSliderSS, 
	GuiControl,, vThresholdNumSS, %_ThresholdSS%
	return
	

;-----------------------------------------------------------------------
; 機能：親指シフト同時打鍵の割合のスライダー操作
;-----------------------------------------------------------------------
gOlSliderMO:
	GuiControlGet, _OverlapMO , , vOlSliderMO, 
	GuiControl,, vOverlapNumMO, %_OverlapMO%
	return

;-----------------------------------------------------------------------
; 機能：親指シフト同時打鍵の割合のスライダー操作
;-----------------------------------------------------------------------
gOlSliderOM:
	GuiControlGet, _OverlapOM , , vOlSliderOM, 
	GuiControl,, vOverlapNumOM, %_OverlapOM%
	return

;-----------------------------------------------------------------------
; 機能：文字同時打鍵の割合のスライダー操作
;-----------------------------------------------------------------------
gOlSliderSS:
	GuiControlGet, _OverlapSS , , vOlSliderSS, 
	GuiControl,, vOverlapNumSS, %_OverlapSS%
	return
	
;-----------------------------------------------------------------------
; 機能：連続シフトチェックボックスの操作
;-----------------------------------------------------------------------
gContinue:
	Gui, Submit, NoHide
	_Continue := %A_GuiControl%
	if(_Continue = 1)
	{
		_Threshold := 50
		_OverlapOM := 35
		_OverlapMO := 70
	}
	else
	{
		_Threshold := 150
		_OverlapOM := 50
		_OverlapMO := 50
	}
	GuiControl,,vThSlider,%_Threshold%
	GuiControl,,vThresholdNum,%_Threshold%

	GuiControl,, vOverlapNumOM, %_OverlapOM%
	GuiControl,,vOlSliderOM,%_OverlapOM%

	GuiControl,, vOverlapNumMO, %_OverlapMO%
	GuiControl,,vOlSliderMO,%_OverlapMO%
	Return

;-----------------------------------------------------------------------
; 機能：零遅延モードチェックボックスの操作
;-----------------------------------------------------------------------
gZeroDelay:
	Gui, Submit, NoHide
	_ZeroDelay := %A_GuiControl%
	Return

gZeroDelaySS:
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
		if(ShiftMode["R"] == "親指シフト" || ShiftMode["A"] == "親指シフト") {
			keyAttribute2["RA01"] := "L"
			keyAttribute2["RA02"] := "X"
			keyAttribute2["RA03"] := "R"
			keyAttribute2["AA01"] := "L"
			keyAttribute2["AA02"] := "X"
			keyAttribute2["AA03"] := "R"
			g_Oya2Layout["L"] := "A01"
			g_Oya2Layout["R"] := "A03"
		}
	}
	else if(vOyaKey = "無変換－空白")
	{
		if(ShiftMode["R"] == "親指シフト" || ShiftMode["A"] == "親指シフト") {
			keyAttribute2["RA01"] := "L"
			keyAttribute2["RA02"] := "R"
			keyAttribute2["RA03"] := "X"
			keyAttribute2["AA01"] := "L"
			keyAttribute2["AA02"] := "R"
			keyAttribute2["AA03"] := "X"
			g_Oya2Layout["L"] := "A01"
			g_Oya2Layout["R"] := "A02"
		}
	}
	else	; 空白－変換
	{
		if(ShiftMode["R"] == "親指シフト" || ShiftMode["A"] == "親指シフト") {
			keyAttribute2["RA01"] := "X"
			keyAttribute2["RA02"] := "L"
			keyAttribute2["RA03"] := "R"
			keyAttribute2["AA01"] := "X"
			keyAttribute2["AA02"] := "L"
			keyAttribute2["AA03"] := "R"
			g_Oya2Layout["L"] := "A02"
			g_Oya2Layout["R"] := "A03"
		}
	}
	Gosub,RefreshLayoutA
	Return

gKeySingle:
	Gui, Submit, NoHide
	_KeySingle := vKeySingle
	g_KeySingle := vKeySingle
	if(g_KeySingle = "有効")
	{
		_KeyRepeat := 1
	}
	Gosub,RefreshLayoutA
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
			vLayoutFile := g_LayoutFile
			GoSub, ReadLayoutFile
		}
		Gosub, SetLayoutProperty
		_LayoutFile := vLayoutFile
	}
	Gui,Destroy
	Goto,_Settings

;-----------------------------------------------------------------------
; 機能：一時停止ボタンの選択メニュー
;-----------------------------------------------------------------------

gSetPause:
	Gui, Submit, NoHide
	_KeyPause := vKeyPause
	return

;-----------------------------------------------------------------------
; 機能：管理者権限設定ボタン
;-----------------------------------------------------------------------
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
	g_ThresholdSS := _ThresholdSS
	g_LayoutFile := _LayoutFile
	g_OverlapOM := _OverlapOM
	g_OverlapMO := _OverlapMO
	g_OverlapSS := _OverlapSS
	g_OyaKey := _OyaKey
	g_KeySingle := _KeySingle
	g_KeyRepeat := _KeyRepeat
	g_KeyPause := _KeyPause

	g_IniFile := ".\benizara.ini"
	IniWrite,%g_LayoutFile%,%g_IniFile%,FilePath,LayoutFile
	IniWrite,%g_Continue%,%g_IniFile%,Key,Continue
	IniWrite,%g_Threshold%,%g_IniFile%,Key,Threshold
	IniWrite,%g_ThresholdSS%,%g_IniFile%,Key,ThresholdSS
	IniWrite,%g_ZeroDelay%,%g_IniFile%,Key,ZeroDelay
	IniWrite,%g_OverlapMO%,%g_IniFile%,Key,OverlapMO
	IniWrite,%g_OverlapOM%,%g_IniFile%,Key,OverlapOM
	IniWrite,%g_OverlapSS%,%g_IniFile%,Key,OverlapSS
	IniWrite,%g_OyaKey%,%g_IniFile%,Key,OyaKey
	IniWrite,%g_KeySingle%,%g_IniFile%,Key,KeySingle
	IniWrite,%g_KeyRepeat%,%g_IniFile%,Key,KeyRepeat
	IniWrite,%g_KeyPause%,%g_IniFile%,Key,KeyPause
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
