;-----------------------------------------------------------------------
;	名称：Settings7.ahk
;	機能：紅皿のパラメータ設定
;	ver.0.1.4.7 .... 2021/6/15
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
		g_ThresholdSS := 250
		IniWrite,%g_ThresholdSS%,%g_IniFile%,Key,ThresholdSS
		g_ZeroDelay := 1
		IniWrite,%g_ZeroDelay%,%g_IniFile%,Key,ZeroDelay
		g_OverlapOM := 35
		IniWrite,%g_OverlapOM%,%g_IniFile%,Key,OverlapOM
		g_OverlapMO := 70
		IniWrite,%g_OverlapMO%,%g_IniFile%,Key,OverlapMO
		g_OverlapSS := 100
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
	IniRead,g_KeySingle,%g_IniFile%,Key,KeySingle
	if g_KeySingle not in 有効,無効
		g_KeySingle := "無効"
	IniRead,g_KeyRepeat,%g_IniFile%,Key,KeyRepeat
	if g_KeyRepeat not in 1,0
		g_KeyRepeat := 0
	IniRead,g_KeyPause,%g_IniFile%,Key,KeyPause
	if g_KeyPause not in Pause,ScrollLock,無効
		g_KeyPause := "Pause"
	gosub, RemapOya
	return
	
;-----------------------------------------------------------------------
; 機能：設定ダイアログの表示
;-----------------------------------------------------------------------
Settings:
	IfWinExist,紅皿設定
	{
		;msgbox, 既に紅皿設定ダイアログは開いています。
		WinActivate,紅皿設定
		return
	}
	vLayoutFile := g_LayoutFile
	g_CurrSimulMode := "…"
_Settings:
	Gui,2:Default
	Gui, 2:New
	Gui, Font,s10 c000000
	Gui, Add, Button,ggButtonOk X530 Y405 W80 H22,ＯＫ
	Gui, Add, Button,ggButtonCancel X620 Y405 W80 H22,キャンセル
	Gui, Add, Tab3,ggTabChange vvTabName X10 Y10 W740 H390, 配列||親指シフト|文字同時打鍵|一時停止|管理者権限|紅皿について
	g_TabName := "配列"
	
	Gui, Tab, 1
	Gui, Font, underline
	Gui, Add, Text,X30 Y40 cBlue ggLayoutURL,%g_layoutName%　%g_layoutVersion%
	;Gui, Add, Edit,X30 Y40 W280 H20 cBlue ReadOnly -Vscroll ggLayoutURL, %g_layoutName%　%g_layoutVersion%
	;Gui, Add, Text,X30 Y222 cBlue ggURLdownload,ダウンロードページ

	Gui, Font,Norm
	Gui, Add, Text,X320 Y40, 定義ファイル：
	Gui, Add, Edit,vvFilePath ggDefFile X400 Y40 W220 H20 ReadOnly, %vLayoutFile%
	Gui, Add, Button,ggFileSelect X630 Y40 W32 H21,…

	if(ShiftMode["R"] = "親指シフト" || ShiftMode["R"] = "文字同時打鍵")
	{
		Gui, Add, Text,X30 Y70,親指シフトキー：
		if(ShiftMode["R"] = "文字同時打鍵") {
			Gui, Add, DropDownList,ggOya vvOyaKey X133 Y70 W125,…||
		} else if(g_OyaKey = "無変換－変換")
			Gui, Add, DropDownList,ggOya vvOyaKey X133 Y70 W125,無変換－変換||無変換－空白|空白－変換|
		else if(g_OyaKey = "無変換－空白")
			Gui, Add, DropDownList,ggOya vvOyaKey X133 Y70 W125,無変換－変換|無変換－空白||空白－変換|
		else
			Gui, Add, DropDownList,ggOya vvOyaKey X133 Y70 W125,無変換－変換|無変換－空白|空白－変換||
	
		Gui, Add, Text,X290 Y70,単独打鍵：
		if(ShiftMode["R"] = "文字同時打鍵") {
			Gui, Add, DropDownList,ggKeySingle vvKeySingle X360 Y70 W95,…||
		}
		else if(g_KeySingle = "無効")
			Gui, Add, DropDownList,ggKeySingle vvKeySingle X360 Y70 W95,無効||有効|
		else
			Gui, Add, DropDownList,ggKeySingle vvKeySingle X360 Y70 W95,無効|有効||

		Gui, Add, Text,X490 Y70,同時打鍵の表示：
		_ddlist := "…"
		if(v == g_CurrSimulMode) {
			_ddlist := _ddlist . "||"
		} else {
			_ddlist := _ddlist . "|"
		}
		enum := g_SimulMode._NewEnum()
		while enum[k,v]
		{
			if(substr(v,1,1) == g_Romaji) {
				if(v == g_CurrSimulMode) {
					_ddlist := _ddlist . v . "||"
				} else {
					_ddlist := _ddlist . v . "|"
				}
			}
		}
		Gui, Add, DropDownList,ggCurrSimulMode vvCurrSimulMode X600 Y70 W95,%_ddlist%
	}
	else if(ShiftMode["R"] = "プレフィックスシフト")
	{
		Gui, Add, Text,X30 Y70,プレフィックスシフトを用いた配列です
	}
	Gui, Font,s10 c000000,Meiryo UI
	Gosub,G2DrawKeyFrame
	Gui, Font,s9 c000000,Meiryo UI
	Gui, Add, Edit,vvEdit X60 Y370 W650 H20 -Vscroll,
	Gosub, G2RefreshLayout
	
	Gui, Tab, 2
	Gui, Font,s10 c000000,Meiryo UI
	Gui, Add, Edit,X20 Y40 W300 H40 ReadOnly -Vscroll,親指シフトキーの押し続けをシフトオンとします。
	Gui, Add, Checkbox,ggContinue vvContinue X+20 Y50,連続シフト
	GuiControl,,vContinue,%g_Continue%

	Gui, Add, Edit,X20 Y90 W300 H40 ReadOnly -Vscroll,キー打鍵と共に遅延なく候補文字を表示します。	
	Gui, Add, Checkbox,ggZeroDelay vvZeroDelay X+20 Y100,零遅延モード
	GuiControl,,vZeroDelay,%g_ZeroDelay%
	
	Gui, Add, Edit,X20 Y140 W300 H40 ReadOnly -Vscroll,親指シフトキーをキーリピートさせます。
	Gui, Add, Checkbox,ggKeyRepeat vvKeyRepeat X340 Y150,キーリピート
	GuiControl,,vKeyRepeat,%g_KeyRepeat%
	
	Gui, Add, Edit,X20 Y190 W300 H60 ReadOnly -Vscroll,親指シフトキー⇒文字キーの順の打鍵の重なりが打鍵全体の何％のときに、同時打鍵であるかを決定します。
	Gui, Add, Text,X+20 Y190 W230 H20,親指キー⇒文字キーの重なりの割合：
	Gui, Add, Edit,vvOverlapNumOM X+3 Y188 W50 ReadOnly, %g_OverlapOM%
	Gui, Add, Text,X+10 Y190 c000000,[`%]

	Gui, Add, Slider, X320 Y220 ggOlSliderOM w400 vvOlSliderOM Range10-90 line10 TickInterval10
	GuiControl,,vOlSliderOM,%g_OverlapOM%

	Gui, Add, Edit,X20 Y260 W300 H60 ReadOnly -Vscroll,文字キー⇒親指シフトキーの順の打鍵の重なりが打鍵全体の何％のときに、同時打鍵であるかを決定します。
	Gui, Add, Text,X+20 Y260 W230 H20,文字キー⇒親指キーの重なりの割合：
	Gui, Add, Edit,vvOverlapNumMO X+3 Y258 W50 ReadOnly, %g_OverlapMO%
	Gui, Add, Text,X+10 Y260 c000000,[`%]
	
	Gui, Add, Slider, X320 Y290 ggOlSliderMO w400 vvOlSliderMO Range10-90 line10 TickInterval10
	GuiControl,,vOlSliderMO,%g_OverlapMO%
	
	Gui, Add, Edit,X20 Y330 W300 H60 ReadOnly -Vscroll,文字キーと親指シフトキーの打鍵の重なり期間やが何ミリ秒のときに同時打鍵であるかを決定します。
	Gui, Add, Text,X+20 Y330 W230 H20,文字キーと親指キーの重なりの判定時間：
	Gui, Add, Edit,vvThresholdNum X+3 Y328 W50 ReadOnly, %g_Threshold%
	Gui, Add, Text,X+10 Y330 c000000,[mSEC]
	
	Gui, Add, Slider, X320 Y360 ggThSlider w400 vvThSlider Range10-400 line10 TickInterval10
	GuiControl,,vThSlider,%g_Threshold%

	Gui, Tab, 3
	Gui, Add, Edit,X20 Y40 W300 H60 ReadOnly -Vscroll,キー打鍵と共に遅延なく候補文字を表示します。	
	Gui, Add, Checkbox,ggZeroDelaySS vvZeroDelaySS X+20 Y65,零遅延モード
	GuiControl,,vZeroDelaySS,%g_ZeroDelay%
	
	Gui, Add, Edit,X20 Y110 W300 H60 ReadOnly -Vscroll,文字キー同志の打鍵の重なりが打鍵全体の何％のときに、同時打鍵であるかを決定します。
	Gui, Add, Text,X+20 Y110 W230 H20,文字キー同志の重なりの割合：
	Gui, Add, Edit,vvOverlapNumSS X+3 Y108 W50 ReadOnly, %g_OverlapSS%
	Gui, Add, Text,X+10 Y110 c000000,[`%]

	Gui, Add, Slider, X320 Y140 ggOlSliderSS w400 vvOlSliderSS Range10-90 line10 TickInterval10
	GuiControl,,vOlSliderSS,%g_OverlapSS%
	
	Gui, Add, Edit,X20 Y180 W300 H60 ReadOnly -Vscroll,文字キー同志の打鍵の重なり期間が何ミリ秒のときに同時打鍵であるかを決定します。
	Gui, Add, Text,X+20 Y180 W230 H20,文字キー同志の重なりの判定時間：
	Gui, Add, Edit,vvThresholdNumSS X+3 Y178 W50 ReadOnly, %g_ThresholdSS%
	Gui, Add, Text,X+10 Y180 c000000,[mSEC]
	
	Gui, Add, Slider, X320 Y210 ggThSliderSS w400 vvThSliderSS Range10-400 line10 TickInterval10
	GuiControl,,vThSliderSS,%g_ThresholdSS%
	
	Gui, Tab, 4
	Gui, Font,s10 c000000,Meiryo UI
	Gui, Add, Edit,X20 Y40 W690 H60 ReadOnly -Vscroll,紅皿を一時停止させるキーを決定します。
	Gui, Add, Text,X30 Y130,一時停止キー：
	if(g_KeyPause = "Pause")
		Gui, Add, DropDownList,ggSetPause vvKeyPause X140 Y130 W125,Pause||ScrollLock|無効|
	else if(g_KeyPause = "ScrollLock")
		Gui, Add, DropDownList,ggSetPause vvKeyPause X140 Y130 W125,Pause|ScrollLock||無効|
	else
		Gui, Add, DropDownList,ggSetPause vvKeyPause X140 Y130 W125,Pause|ScrollLock|無効||

	Gui, Tab, 5
	Gui, Font,s10 c000000,Meiryo UI
	Gui, Add, Edit,X20 Y40 W690 H60 ReadOnly -Vscroll,管理者権限で動作しているアプリケーションに対して親指シフト入力するか否かを決定します。
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
	Gui, Show, W770 H440, 紅皿設定

	s_Romaji := ""
	s_KeySingle := ""
	SetTimer,G2PollingLayout,50
	GuiControl,Focus,vEdit
	return

;-----------------------------------------------------------------------
; 機能：紅皿のダウンロードURLを開く
;-----------------------------------------------------------------------
gLayoutURL:
	Run, %g_layoutURL%
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
	_ch := GuiLayoutHash[g_Romaji] . ":" . ShiftMode[g_Romaji]
	Gui,Add,GroupBox,vvkeyLayoutName X20 Y90 W720 H270,%_ch%
	_col := 1
	_ypos := 105
	loop,14
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
	
	if(g_CurrSimulMode == "…" || g_Romaji == "A") {
		_ch := "小指"
	} else {
		_ch := "同打"
	}
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
	if(keyAttribute3[g_Romaji . "N" . _col2 . _row2] == "L")
	{
		Gui, Font,s42 cFFFF00,Yu Gothic UI
	}
	else
	if(keyAttribute3[g_Romaji . "K" . _col2 . _row2] == "R")
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
			_ch := GuiLayoutHash[g_Romaji] . ":" . ShiftMode[g_Romaji]
			GuiControl,,vkeyLayoutName,%_ch%
			Gosub,G2RefreshLayout
			
			Gosub,RefreshSimulKeyMenu
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
; 機能：同時打鍵キーメニューの更新：英数ローマ字モードに応じて
;-----------------------------------------------------------------------
RefreshSimulKeyMenu:
	_ddlist := "|…"
	if(v == g_CurrSimulMode) {
		_ddlist := _ddlist . "||"
	} else {
		_ddlist := _ddlist . "|"
	}
	enum := g_SimulMode._NewEnum()
	while enum[k,v]
	{
		if(substr(v,1,1) == g_Romaji) {
			if(v == g_CurrSimulMode) {
				_ddlist := _ddlist . v . "||"
			} else {
				_ddlist := _ddlist . v . "|"
			}
		}
	}
	GuiControl,,vCurrSimulMode,%_ddlist%
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
	Gui, Submit, NoHide
	GuiControl,-Redraw,vkeyDN%_layoutPos%
	if(keyAttribute3[g_Romaji . "N" . _layoutPos] == "L")
	{
		Gui,Font,S42 cFFFF00,Yu Gothic UI
		GuiControl,Font,vkeyFC%_layoutPos%
		GuiControl,,vkeyFA%_layoutPos%,左親指
	}
	else
	if(keyAttribute3[g_Romaji . "N" . _layoutPos] == "R")
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
	return
;-----------------------------------------------------------------------
; 機能：凡例表示の更新
;-----------------------------------------------------------------------
RefreshLayoutUsage:
	Gui, Submit, NoHide
	if(ShiftMode["R"] == "親指シフト" || ShiftMode["R"] == "文字同時打鍵") {
		GuiControl,,vkeyRLA00,左親
		GuiControl,,vkeyRRA00,右親
	}
	else
	if(ShiftMode["R"] == "プレフィックスシフト") {
		GuiControl,,vkeyRLA00,１
		GuiControl,,vkeyRRA00,２
	}
	return

;-----------------------------------------------------------------------
; 機能：キー配列表示の切り替え
;-----------------------------------------------------------------------
G2RefreshLayout:
	Gui, Submit, NoHide
	for index, element in layoutArys
	{
		GuiControl,-Redraw,vkeyDN%element%
		GuiControl,,vkeyDN%element%,　
		GuiControl,-Redraw,vkeyRK%element%
		GuiControl,-Redraw,vkeyRN%element%
		GuiControl,-Redraw,vkeyRL%element%
		GuiControl,-Redraw,vkeyRR%element%
		
		if(g_CurrSimulMode == "…") {
			_st := kst[g_Romaji . "NK" . element]
			Gosub, SetFontColor
			GuiControl,Font,vkeyRK%element%
			_ch := kLabel[g_Romaji . "NK" . element]
			GuiControl,,vkeyRK%element%,%_ch%
		} else {
			_st := kst[g_CurrSimulMode . element]
			Gosub, SetFontColor
			GuiControl,Font,vkeyRK%element%
			_ch := kLabel[g_CurrSimulMode . element]
			GuiControl,,vkeyRK%element%,%_ch%
		}

		_st := kst[g_Romaji . "NN" . element]
		Gosub, SetFontColor
		GuiControl,Font,vkeyRN%element%
		_ch := kLabel[g_Romaji . "NN" . element]
		GuiControl,,vkeyRN%element%,%_ch%
		

		_ch := kLabel[g_Romaji . "LN" . element]
		_st := kst[g_Romaji . "LN" . element]
		if(_ch == "") {
			_ch := kLabel[g_Romaji . "1N" . element]
			_st := kst[g_Romaji . "1N" . element]
		}
		Gosub, SetFontColor
		GuiControl,Font,vkeyRL%element%
		GuiControl,,vkeyRL%element%,%_ch%

		_ch := kLabel[g_Romaji . "RN" . element]
		_st := kst[g_Romaji . "RN" . element]
		if(_ch == "") {
			_ch := kLabel[g_Romaji . "2N" . element]
			_st := kst[g_Romaji . "2N" . element]
		}
		Gosub, SetFontColor
		GuiControl,Font,vkeyRR%element%
		GuiControl,,vkeyRR%element%,%_ch%

		GuiControl,+Redraw,vkeyDN%element%
		GuiControl,+Redraw,vkeyRK%element%
		GuiControl,+Redraw,vkeyRN%element%
		GuiControl,+Redraw,vkeyRL%element%
		GuiControl,+Redraw,vkeyRR%element%
	}
	return


;-----------------------------------------------------------------------
; 機能：フォント色の設定
;-----------------------------------------------------------------------
SetFontColor:
	if(_st=="e") {			; 
		Gui, Font,s10 cC00000 Norm,Meiryo UI
	} else if(_st=="Q") {	; 引用符
		Gui, Font,s10 c0000FF Norm,Meiryo UI
	} else if(_st=="V") {	; 仮想キーコード
		Gui, Font,s10 c008000 Norm,Meiryo UI
	} else {
		Gui, Font,s10 c000000 Norm,Meiryo UI
	}
	return

;-----------------------------------------------------------------------
; 機能：キーのオンオフ表示の更新
;-----------------------------------------------------------------------
ReadKeyboardState:
	;VarSetCapacity(stKtbl, cbSize:=512, 0)
	;NumPut(cbSize, stKtbl,  0, "UChar")   ;	
	;stCurr := DllCall("GetKeyboardState", "UPtr", &stKtbl)
	;if(stCurr==0) 
	;{
	;	return
	;}
	loop, 14
	{
		_layoutPos := "E" . _rowhash[A_Index]
		_vkey := vkeyStrHash[_layoutPos]
		Gosub,SetKeyGui2
	}
	loop, 12
	{
		_layoutPos := "D" . _rowhash[A_Index]
		_vkey := vkeyStrHash[_layoutPos]
		Gosub,SetKeyGui2
	}
	loop, 12
	{
		_layoutPos := "C" . _rowhash[A_Index]
		_vkey := vkeyStrHash[_layoutPos]
		Gosub,SetKeyGui2
	}
	loop, 11
	{
		_layoutPos := "B" . _rowhash[A_Index]
		_vkey := vkeyStrHash[_layoutPos]
		Gosub,SetKeyGui2
	}
	loop, 4
	{
		_layoutPos := "A" . _rowhash[A_Index]
		_vkey := vkeyHash[_layoutPos]
		Gosub,SetKeyGui2
	}
	return

SetKeyGui2:
	;_keyState := DllCall("GetAsyncKeyState", "UInt", _vkey)
	_keyState := GetKeyState(_vkey,"P")
	GuiControlGet,_val,,vkeyDN%_layoutPos%
	if( _keyState!= 0 && _val != "□")
	{
		GuiControl,2:,vkeyDN%_layoutPos%,□
	}
	else
	if( _keyState == 0	&&  _val != "　")
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
	GuiControlGet, g_Threshold , , vThSlider, 
	GuiControl,, vThresholdNum, %g_Threshold%
	return

;-----------------------------------------------------------------------
; 機能：文字同時打鍵の判定時間のスライダー操作
;-----------------------------------------------------------------------
gThSliderSS:
	GuiControlGet, g_ThresholdSS , , vThSliderSS, 
	GuiControl,, vThresholdNumSS, %g_ThresholdSS%
	return
	

;-----------------------------------------------------------------------
; 機能：親指シフト同時打鍵の割合のスライダー操作
;-----------------------------------------------------------------------
gOlSliderMO:
	GuiControlGet, g_OverlapMO , , vOlSliderMO, 
	GuiControl,, vOverlapNumMO, %g_OverlapMO%
	return

;-----------------------------------------------------------------------
; 機能：親指シフト同時打鍵の割合のスライダー操作
;-----------------------------------------------------------------------
gOlSliderOM:
	GuiControlGet, g_OverlapOM , , vOlSliderOM, 
	GuiControl,, vOverlapNumOM, %g_OverlapOM%
	return

;-----------------------------------------------------------------------
; 機能：文字同時打鍵の割合のスライダー操作
;-----------------------------------------------------------------------
gOlSliderSS:
	GuiControlGet, g_OverlapSS , , vOlSliderSS, 
	GuiControl,, vOverlapNumSS, %g_OverlapSS%
	return
	
;-----------------------------------------------------------------------
; 機能：連続シフトチェックボックスの操作
;-----------------------------------------------------------------------
gContinue:
	Gui, Submit, NoHide
	g_Continue := %A_GuiControl%
	if(g_Continue = 1)
	{
		g_Threshold := 100
		g_OverlapOM := 35
		g_OverlapMO := 70
	}
	else
	{
		g_Threshold := 150
		g_OverlapOM := 35
		g_OverlapMO := 70
	}
	GuiControl,,vThSlider,%g_Threshold%
	GuiControl,,vThresholdNum,%g_Threshold%

	GuiControl,, vOverlapNumOM, %g_OverlapOM%
	GuiControl,,vOlSliderOM,%g_OverlapOM%

	GuiControl,, vOverlapNumMO, %g_OverlapMO%
	GuiControl,,vOlSliderMO,%g_OverlapMO%
	Return

;-----------------------------------------------------------------------
; 機能：零遅延モードチェックボックスの操作
;-----------------------------------------------------------------------
gZeroDelay:
	Gui, Submit, NoHide
	g_ZeroDelay := %A_GuiControl%
	Return


;-----------------------------------------------------------------------
; 機能：零遅延モードチェックボックスの操作
;-----------------------------------------------------------------------
gZeroDelaySS:
	Gui, Submit, NoHide
	g_ZeroDelay := %A_GuiControl%
	Return

;-----------------------------------------------------------------------
; 機能：その他、無効化したＧＵＩ要素の操作・・・ダミー
; ver.0.1.3.7 ... gSpace/gSpaceUp を追加
;-----------------------------------------------------------------------
gOya:
	Gui, Submit, NoHide
	if(vOyaKey != "…") {
		g_OyaKey := vOyaKey
		Gosub,RemapOya
		Gosub,RefreshLayoutA
	}
	Return

;-----------------------------------------------------------------------
; 機能：単独打鍵の設定
;-----------------------------------------------------------------------
gKeySingle:
	Gui, Submit, NoHide
	if(vKeySingle != "…") {
		g_KeySingle := vKeySingle
		if(g_KeySingle = "有効")	; キーリピートON（事後的にOFF可)
		{
			g_KeyRepeat := 1
		}
		Gosub,RemapOya
		Gosub,RefreshLayoutA
	}
	return

;-----------------------------------------------------------------------
; 機能：同時打鍵キーの指定
;-----------------------------------------------------------------------
gCurrSimulMode:
	Gui, Submit, NoHide
	g_CurrSimulMode := vCurrSimulMode
	Gui,Destroy
	Goto,_Settings

;-----------------------------------------------------------------------
; 機能：親指シフトモードの変数設定
;-----------------------------------------------------------------------
RemapOya:
	if(ShiftMode["A"] == "親指シフト") {
		RemapOyaKey("A")
	}
	if(ShiftMode["R"] == "親指シフト") {
		RemapOyaKey("R")
	}
	return

;-----------------------------------------------------------------------
; 機能：キーリピートの設定
;-----------------------------------------------------------------------
gKeyRepeat:
	Gui, Submit, NoHide
	g_KeyRepeat := vKeyRepeat
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

		SetTimer,Interrupt10,off
		SetHook("off")
		SetHookHenkan("off")
		SetHookSpace("off")
		
		Gosub, InitLayout2
		GoSub, ReadLayoutFile
		if(_error=="")
		{
			Traytip,キーボード配列エミュレーションソフト「紅皿」,benizara %g_Ver% `n%g_layoutName%　%g_layoutVersion%
		} else
		{
			msgbox, %_error%
			
			; 元ファイルを再読み込みする
			Gosub, InitLayout2
			vLayoutFile := g_LayoutFile
			GoSub, ReadLayoutFile
			GuiControl,, vFilePath, %vLayoutFile%
		}
		Gosub, SetLayoutProperty
		g_LayoutFile := vLayoutFile
		
		_currentTick := Pf_Count()	;A_TickCount
		g_MojiTick[0] := _currentTick
		g_OyaTick["R"] := _currentTick
		g_OyaTick["L"] := _currentTick
		SetTimer,Interrupt10,on
		vIntKeyUp := 0
		vIntKeyDn := 0
	}
	Gui,Destroy
	g_CurrSimulMode := "…"
	Goto,_Settings

;-----------------------------------------------------------------------
; 機能：一時停止ボタンの選択メニュー
;-----------------------------------------------------------------------

gSetPause:
	Gui, Submit, NoHide
	g_KeyPause := vKeyPause
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
	SetTimer,G2PollingLayout,off
	Gui,Destroy
	return
