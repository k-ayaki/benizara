;-----------------------------------------------------------------------
;	名称：Settings7.ahk
;	機能：紅皿のパラメータ設定
;	ver.0.1.5.00 .... 2022/7/31
;-----------------------------------------------------------------------

	Gosub,Init
	g_LayoutFile := ".\NICOLA配列.bnz"
	Gosub,ReadLayout
	Gosub, Settings
	Gosub, InitLayout2
	return

#include ReadLayout6.ahk
#include Path.ahk
#include Objects.ahk
#Include, Gdip.ahk

StartGdi:
	; Start gdi+
	If !pToken := Gdip_Startup()
	{
		MsgBox, 48, gdiplus error!, Gdiplus failed to start. Please ensure you have gdiplus on your system
		ExitApp
	}
	return

CloseGdi:
	; gdi+ may now be shutdown
	Gdip_Shutdown(pToken)
	Return

;-----------------------------------------------------------------------
; Iniファイルの読み込み
;-----------------------------------------------------------------------
Init:
	SetWorkingDir, %g_DataDir%
	g_IniFile := g_DataDir . "\benizara.ini"
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
		g_OverlapOMO := 70
		IniWrite,%g_OverlapOMO%,%g_IniFile%,Key,OverlapOMO
		g_OverlapSS := 100
		IniWrite,%g_OverlapSS%,%g_IniFile%,Key,OverlapSS
		g_OyaKey := "無変換－変換"
		IniWrite,%g_OyaKey%,%g_IniFile%,Key,OyaKey
		g_KeySingle := "無効"
		IniWrite,%g_KeySingle%,%g_IniFile%,Key,KeySingle
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
	IniRead,g_OverlapOMO,%g_IniFile%,Key,OverlapOMO
	if(g_OverlapOMO < 10)
		g_OverlapOMO := 10
	if(g_OverlapOMO > 90)
		g_OverlapOMO := 90
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
	if(g_KeySingle == "有効") {
		g_KeyRepeat := 1
	} else {
		g_KeyRepeat := 0
	}
	IniRead,g_KeyPause,%g_IniFile%,Key,KeyPause
	if g_KeyPause not in Pause,ScrollLock,無効
		g_KeyPause := "Pause"
	RemapOya()
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
	g_isDialog := 1
	Gui,2:Default
	Gui, 2:New
	Gui, Font,s10 c000000
	Gui, Add, Button,ggButtonOk X530 Y405 W80 H22,ＯＫ
	Gui, Add, Button,ggButtonCancel X620 Y405 W80 H22,キャンセル
	Gui, Add, Tab3,ggTabChange vvTabName X10 Y10 W740 H390, 配列||親指シフト|文字同時打鍵|状態|紅皿について
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
		s_ddlist := RefreshSimulKeyMenu()
		Gui, Add, DropDownList,ggCurrSimulMode vvCurrSimulMode X600 Y70 W95,%s_ddlist%
	}
	else if(ShiftMode["R"] = "プレフィックスシフト")
	{
		Gui, Add, Text,X30 Y70,プレフィックスシフトを用いた配列です
	}
	Gui, Font,s10 c000000,Meiryo UI
	G2DrawKeyFrame(g_Romaji)
	Gui, Font,s9 c000000,Meiryo UI
	Gui, Add, Edit,vvEdit X60 Y370 W650 H20 -Vscroll,
	G2RefreshLayout()
	
	Gui, Tab, 2
	Gui, Font,s10 c000000,Meiryo UI
	Gui, Add, Edit,X20 Y40 W300 H20 ReadOnly -Vscroll,親指シフトキーの押し続けをシフトオンとします。
	Gui, Add, Checkbox,ggContinue vvContinue X+20 Y40,連続シフト
	GuiControl,,vContinue,%g_Continue%

	Gui, Add, Edit,X20 Y70 W300 H20 ReadOnly -Vscroll,キー打鍵と共に遅延なく候補文字を表示します。	
	Gui, Add, Checkbox,ggZeroDelay vvZeroDelay X+20 Y70,零遅延モード
	GuiControl,,vZeroDelay,%g_ZeroDelay%
	
	Gui, Add, Edit,X20 Y100 W300 H60 ReadOnly -Vscroll,親指シフトキー⇒文字キーの順の打鍵の重なりが打鍵全体の何％のときに、同時打鍵であるかを決定します。
	Gui, Add, Text,X+20 Y100 W230 H20,親指キー⇒文字キーの重なりの割合：
	Gui, Add, Edit,vvOverlapNumOM X+3 Y98 W50 ReadOnly, %g_OverlapOM%
	Gui, Add, Text,X+10 Y100 c000000,[`%]

	Gui, Add, Slider, X320 Y130 ggOlSliderOM w400 vvOlSliderOM Range10-90 line10 TickInterval10
	GuiControl,,vOlSliderOM,%g_OverlapOM%

	Gui, Add, Edit,X20 Y170 W300 H60 ReadOnly -Vscroll,文字キー⇒親指シフトキーの順の打鍵の重なりが打鍵全体の何％のときに、同時打鍵であるかを決定します。
	Gui, Add, Text,X+20 Y170 W230 H20,文字キー⇒親指キーの重なりの割合：
	Gui, Add, Edit,vvOverlapNumMO X+3 Y168 W50 ReadOnly, %g_OverlapMO%
	Gui, Add, Text,X+10 Y170 c000000,[`%]
	
	Gui, Add, Slider, X320 Y200 ggOlSliderMO w400 vvOlSliderMO Range10-90 line10 TickInterval10
	GuiControl,,vOlSliderMO,%g_OverlapMO%

	Gui, Add, Edit,X20 Y240 W300 H60 ReadOnly -Vscroll,文字キー⇒親指シフトキーオフ⇒文字キーオフの順の打鍵の重なりが打鍵全体の何％のときに、同時打鍵であるかを決定します。
	Gui, Add, Text,X+20 Y240 W230 H20,親指キーオフ時の重なりの割合：
	Gui, Add, Edit,vvOverlapNumOMO X+3 Y238 W50 ReadOnly, %g_OverlapOMO%
	Gui, Add, Text,X+10 Y240 c000000,[`%]
	
	Gui, Add, Slider, X320 Y270 ggOlSliderOMO w400 vvOlSliderOMO Range10-90 line10 TickInterval10
	GuiControl,,vOlSliderOMO,%g_OverlapOMO%

	Gui, Add, Edit,X20 Y310 W300 H60 ReadOnly -Vscroll,文字キーと親指シフトキーの打鍵の重なり期間やが何ミリ秒のときに同時打鍵であるかを決定します。
	Gui, Add, Text,X+20 Y310 W230 H20,文字キーと親指キーの重なりの判定時間：
	Gui, Add, Edit,vvThresholdNum X+3 Y308 W50 ReadOnly, %g_Threshold%
	Gui, Add, Text,X+10 Y310 c000000,[mSEC]
	
	Gui, Add, Slider, X320 Y340 ggThSlider w400 vvThSlider Range10-400 line10 TickInterval10
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
	Gui, Add, Edit,X20 Y40 W300 H20 ReadOnly -Vscroll,紅皿を一時停止させるキーを決定します。
	if(g_KeyPause == "Pause")
		Gui, Add, DropDownList,ggSetPause vvKeyPause X+20 Y40 W125,Pause||ScrollLock|無効|
	else if(g_KeyPause == "ScrollLock")
		Gui, Add, DropDownList,ggSetPause vvKeyPause X+20 Y40 W125,Pause|ScrollLock||無効|
	else
		Gui, Add, DropDownList,ggSetPause vvKeyPause X+20 Y40 W125,Pause|ScrollLock|無効||

	Gui, Add, Edit,X20 Y70 W300 H20 ReadOnly -Vscroll,一時停止状態であるか否かの表示です。
	Gui, Add, Checkbox,ggPauseStatus vvPauseStatus X+20 Y70,一時停止
	g_Pause := 0
	s_Pause := 0
	Gui, Add, Edit,X20 Y100 W300 H40 ReadOnly -Vscroll,管理者権限で動作しているアプリケーションに対して親指シフト入力するか否かを決定します。
	if(DllCall("Shell32\IsUserAnAdmin") = 1)
	{
		Gui, Add, Text,X+20 Y100,紅皿は管理者権限で動作しています。
	}
	else
	{
		Gui, Add, Text,X+20 Y100,紅皿は通常権限で動作しています。
		Gui, Add, Button,ggButtonAdmin X340 Y120 W140 H22,管理者権限に切替
	}

	Gui, Tab, 5
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
	SetTimer,G2PollingLayout,64
	SetTimer,G4PollingPause,128
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
G2DrawKeyFrame(a_Romaji)
{
	global
	Gui,2:Default
	_ch := GuiLayoutHash[a_Romaji] . ":" . ShiftMode[a_Romaji]
	Gui,Add,GroupBox,vvkeyLayoutName X20 Y90 W720 H270,%_ch%
	loop,14
	{
		DrawKeyE2B(1, A_Index)
	}
	loop,12
	{
		DrawKeyE2B(2, A_Index)
	}
	loop,12
	{
		DrawKeyE2B(3, A_Index)
	}
	loop,11
	{
		DrawKeyE2B(4, A_Index)
	}
	loop, 4
	{
		DrawKeyA(5, A_Index)
	}
	DrawKeyUsage(5)
	return
}

;-----------------------------------------------------------------------
; 機能：E～B段の各キーの矩形と入力文字の表示
;-----------------------------------------------------------------------
DrawKeyE2B(a_col,a_row)
{
	global
	_xpos0 := 32*(a_col-1) + 48*(a_row - 1) + 44
	_ypos0 := (a_col - 1)*48 + 115
	_col2 := g_colhash[a_col]
	_row2 := g_rowhash[a_row]
	Gui,2:Default
	Gui, Add, Picture, x%_xpos0% y%_ypos0% w44 h44 0xE vKeyRectangle%_col2%%_row2%
	RefreshKey(_col2 . _row2)
	return
}

;-----------------------------------------------------------------------
; 機能：A段の各キーの矩形と入力文字の表示
;-----------------------------------------------------------------------
DrawKeyA(a_col,a_row)
{
	global
	_xpos0 := 32*(a_col-1) + 48*(a_row + 2 - 1) + 44
	_ypos0 := (a_col - 1)*48 + 115
	_col2 := g_colhash[a_col]
	_row2 := g_rowhash[a_row]
	Gui,2:Default
	Gui, Add, Picture, x%_xpos0% y%_ypos0% w44 h44 0xE vKeyRectangle%_col2%%_row2%
	RefreshKey(_col2 . _row2)
}

;-----------------------------------------------------------------------
; 機能：キー凡例
;-----------------------------------------------------------------------
DrawKeyUsage(a_col)
{
	global
	_ypos0 := (a_col - 1)*48 + 115
	_xpos0 := 40
	Gui,2:Default
	Gui, Add, Picture, x%_xpos0% y%_ypos0% w44 h44 0xE vKeyRectangleA00
	RefreshKey("A00")
	return
}

;-----------------------------------------------------------------------
; 機能：キー表示
;-----------------------------------------------------------------------
Gdip_KeyRect(ByRef keyRectangle, Foreground, Background=0x00000000, TextLU="", TextRU="", TextLD="", TextRD="", pushed=0)
{
	GuiControlGet, Pos, Pos, keyRectangle
	GuiControlGet, hwnd, hwnd, keyRectangle
	pBrushFront := Gdip_BrushCreateSolid(Foreground)
	pBrushBack := Gdip_BrushCreateSolid(Background)
	pBitmap := Gdip_CreateBitmap(Posw, Posh)
	G := Gdip_GraphicsFromImage(pBitmap)
	Gdip_SetSmoothingMode(G, 4)
	
	Gdip_FillRectangle(G, pBrushBack, 0, 0, Posw, Posh)
	if(pushed == 0)
	{
		Gdip_FillRoundedRectangle(G, pBrushFront, 2, 3, (Posw-5), Posh-5, 3)
		Gdip_TextToGraphics(G, TextLU, "x6p y6p s25p left cff000000 r4", "Meiryo UI", Posw, Posh)
		Gdip_TextToGraphics(G, TextRU, "x50p y6p s25p left cff000000 r4", "Meiryo UI", Posw, Posh)
		if(strlen(TextLD)>6)
		{
			Gdip_TextToGraphics(G, TextLD, "x3p y50p s15p left cff000000 r4", "Meiryo UI", Posw, Posh)
		} else {
			Gdip_TextToGraphics(G, TextLD, "x6p y50p s25p left cff000000 r4", "Meiryo UI", Posw, Posh)
		}
		Gdip_TextToGraphics(G, TextRD, "x50p y50p s25p left cff000000 r4", "Meiryo UI", Posw, Posh)
	} else {
		Gdip_FillRoundedRectangle(G, pBrushFront, 3, 2, (Posw-5), Posh-5, 3)
		Gdip_TextToGraphics(G, TextLU, "x8p y4p s25p left cff000000 r4", "Meiryo UI", Posw, Posh)
		Gdip_TextToGraphics(G, TextRU, "x52p y4p s25p left cff000000 r4", "Meiryo UI", Posw, Posh)
		if(strlen(TextLD)>6)
		{
			Gdip_TextToGraphics(G, TextLD, "x5p y48p s15p left cff000000 r4", "Meiryo UI", Posw, Posh)
		} else {
			Gdip_TextToGraphics(G, TextLD, "x8p y48p s25p left cff000000 r4", "Meiryo UI", Posw, Posh)
		}
		Gdip_TextToGraphics(G, TextRD, "x52p y48p s25p left cff000000 r4", "Meiryo UI", Posw, Posh)
	}
	
	hBitmap := Gdip_CreateHBITMAPFromBitmap(pBitmap)
	SetImage(hwnd, hBitmap)
	Gdip_DeleteBrush(pBrushFront), Gdip_DeleteBrush(pBrushBack)
	Gdip_DeleteGraphics(G)
	Gdip_DisposeImage(pBitmap)
	DeleteObject(hBitmap)
	Return, 0
}

;-----------------------------------------------------------------------
; 機能：キー配列変更に係る変数の監視
;-----------------------------------------------------------------------
G2PollingLayout:
	Gui,2:Default
	Gui, Submit, NoHide
	if(g_isDialog==0)
	{
		SetTimer,G2PollingLayout,off
		return
	}
	if(g_TabName != "配列")
	{
		return
	}
	if(s_KeySingle != g_KeySingle || s_Romaji != g_Romaji)
	{
		if(s_Romaji != g_Romaji) 
		{
			s_Romaji := g_Romaji
			s_ch := GuiLayoutHash[g_Romaji] . ":" . ShiftMode[g_Romaji]
			GuiControl,,vkeyLayoutName,%s_ch%

			G2RefreshLayout()
			s_ddlist := "|" . RefreshSimulKeyMenu()	; リストを設定し直す
			GuiControl,,vCurrSimulMode,%s_ddlist%
		}
		s_KeySingle := g_KeySingle
		RefreshLayoutA()
	}
	ReadKeyboardState()
	return

;-----------------------------------------------------------------------
; 機能：同時打鍵キーメニューの更新：英数ローマ字モードに応じて（割込）
;-----------------------------------------------------------------------
RefreshSimulKeyMenu()
{
	global
	s_ddlist := "…"
	if(s_ddlist == g_CurrSimulMode) {
		s_ddlist .= "||"
	} else {
		s_ddlist .= "|"
	}
	enum := g_SimulMode._NewEnum()
	while enum[k,v]
	{
		if(substr(v,1,1) == g_Romaji) {
			if(v == g_CurrSimulMode) {
				s_ddlist .= v . "||"
			} else {
				s_ddlist .= v . "|"
			}
		}
	}
	return s_ddlist
}

;-----------------------------------------------------------------------
; 機能：キー配列表示の切り替え（割込）
;-----------------------------------------------------------------------
RefreshLayoutA()
{
	RefreshKey("A01")
	RefreshKey("A02")
	RefreshKey("A03")
	RefreshKey("A04")
	RefreshKey("A00")
	return
}

;-----------------------------------------------------------------------
; 機能：キー配列表示の切り替え（割込）
;-----------------------------------------------------------------------
G2RefreshLayout()
{
	global
	for index, element in layoutArys
	{
		RefreshKey(element)
	}
	return
}

;-----------------------------------------------------------------------
; 機能：キー配列表示の更新（キー押しか否か）
;-----------------------------------------------------------------------
RefreshKey(_pos, _keystatus=0)
{
	global

	g_keyState[_pos] := _keystatus 
	if(g_isDialog == 0)
	{
		return
	}
	if (_pos == "A00")
	{
		Gui, 2:Default
		Gui, 2: -DPIScale
		if(ShiftMode["R"] == "親指シフト" || ShiftMode["R"] == "文字同時打鍵") {
			if(g_CurrSimulMode == "…")
			{
				Gdip_KeyRect(KeyRectangle%_pos%, 0xffFFFFFF, 0xff000000, "左","右","小","無")
			} else {
				Gdip_KeyRect(KeyRectangle%_pos%, 0xffFFFFFF, 0xff000000, "左","右", substr(g_CurrSimulMode,4),"無")
			}
		}
		else
		if(ShiftMode["R"] == "プレフィックスシフト") {
			Gdip_KeyRect(KeyRectangle%_pos%, 0xffFFFFFF, 0xff000000, "１","２","小","無")
		}
		Gui, 2: +DPIScale
	} else
	if (substr(_pos,1,1) == "A")
	{
		Gui, 2:Default
		Gui, 2: -DPIScale
		if(keyAttribute3[g_Romaji . "N" . _pos] == "L")
		{
			Gdip_KeyRect(KeyRectangle%_pos%, 0xffFFFF00, 0xff000000, "左親指","",kLabel[_pos], "", _keystatus)
		}
		else
		if(keyAttribute3[g_Romaji . "N" . _pos] == "R")
		{
			Gdip_KeyRect(KeyRectangle%_pos%, 0xff00FFFF, 0xff000000, "右親指","",kLabel[_pos], "", _keystatus)
		}
		else
		{
			Gdip_KeyRect(KeyRectangle%_pos%, 0xffFFFFFF, 0xff000000, "","", kLabel[_pos], "", _keystatus)
		}
		Gui, 2: +DPIScale
	} else {
		if(g_sansPos != "") {
			_chrk := kLabel[g_Romaji . "NS" . _pos]
		} else
		if(g_CurrSimulMode == "…") {
			_chrk := kLabel[g_Romaji . "NK" . _pos]
		} else {
			_chrk := kLabel[g_CurrSimulMode . _pos]
		}
		_chrn := kLabel[g_Romaji . "NN" . _pos]
		
		_chrl := kLabel[g_Romaji . "LN" . _pos]
		if(_chrl == "") {
			_chrl := kLabel[g_Romaji . "1N" . _pos]
		}
		_chrr := kLabel[g_Romaji . "RN" . _pos]
		if(_chrr == "") {
			_chrr := kLabel[g_Romaji . "2N" . _pos]
		}
		Gui, 2:Default
		Gui, 2: -DPIScale
		Gdip_KeyRect(KeyRectangle%_pos%, "0xff" . g_pos2Colors[_pos], 0xff000000, _chrl,_chrr,_chrk,_chrn, _keystatus)
		GUI, 2: +DPIScale
	}
	return 0
}

;-----------------------------------------------------------------------
; 機能：キー配列表示の切り替え（割込）
;-----------------------------------------------------------------------
G4PollingPause:
	if(g_isDialog == 0)
	{
		SetTimer,G4PollingPause,off
		return
	}
	if (g_Pause != s_Pause)
	{
		s_Pause := g_Pause
		Gui,2:Default
		Gui, Submit, NoHide
		GuiControl,,vPauseStatus,%g_Pause%
		trayIconRefresh(g_Pause)
	}
	return

;-----------------------------------------------------------------------
; 機能：キーのオンオフ表示の更新
;-----------------------------------------------------------------------
ReadKeyboardState()
{
	global
	for index, element in layoutArys
	{
		if(element == "A04")
		{
			continue
		}
		;キーフックしていない場合にポーリングする
		if(keyHook[element] == "off")
		{
			s_vkey := vkeyStrHash[element]
			s_keyState := GetKeyState(s_vkey,"P")
			if(s_keyState != g_keyState[element])
			{
				RefreshKey(element, s_keyState)
			}
		}
	}
	return
}

;-----------------------------------------------------------------------
; 機能：タブ変更
;-----------------------------------------------------------------------
gTabChange:
	Gui,2:Default
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
	Gui,2:Default
	GuiControlGet, g_Threshold , , vThSlider, 
	GuiControl,, vThresholdNum, %g_Threshold%
	return

;-----------------------------------------------------------------------
; 機能：文字同時打鍵の判定時間のスライダー操作
;-----------------------------------------------------------------------
gThSliderSS:
	Gui,2:Default
	GuiControlGet, g_ThresholdSS , , vThSliderSS, 
	GuiControl,, vThresholdNumSS, %g_ThresholdSS%
	return
	

;-----------------------------------------------------------------------
; 機能：親指シフト同時打鍵の割合のスライダー操作
;-----------------------------------------------------------------------
gOlSliderMO:
	Gui,2:Default
	GuiControlGet, g_OverlapMO , , vOlSliderMO, 
	GuiControl,, vOverlapNumMO, %g_OverlapMO%
	return

;-----------------------------------------------------------------------
; 機能：親指シフト同時打鍵の割合のスライダー操作
;-----------------------------------------------------------------------
gOlSliderOM:
	Gui,2:Default
	GuiControlGet, g_OverlapOM , , vOlSliderOM, 
	GuiControl,, vOverlapNumOM, %g_OverlapOM%
	return

;-----------------------------------------------------------------------
; 機能：親指シフト同時打鍵の割合のスライダー操作
;-----------------------------------------------------------------------
gOlSliderOMO:
	Gui,2:Default
	GuiControlGet, g_OverlapOMO , , vOlSliderOMO, 
	GuiControl,, vOverlapNumOMO, %g_OverlapOMO%
	return

;-----------------------------------------------------------------------
; 機能：文字同時打鍵の割合のスライダー操作
;-----------------------------------------------------------------------
gOlSliderSS:
	Gui,2:Default
	GuiControlGet, g_OverlapSS , , vOlSliderSS, 
	GuiControl,, vOverlapNumSS, %g_OverlapSS%
	return
	
;-----------------------------------------------------------------------
; 機能：連続シフトチェックボックスの操作
;-----------------------------------------------------------------------
gContinue:
	Gui,2:Default
	Gui, Submit, NoHide
	g_Continue := %A_GuiControl%
	if(g_Continue = 1)
	{
		g_Threshold := 100
		g_OverlapOM := 35
		g_OverlapMO := 70
		g_OverlapOMO := 70
	}
	else
	{
		g_Threshold := 150
		g_OverlapOM := 35
		g_OverlapMO := 70
		g_OverlapOMO := 70
	}
	GuiControl,,vThSlider,%g_Threshold%
	GuiControl,,vThresholdNum,%g_Threshold%

	GuiControl,, vOverlapNumOM, %g_OverlapOM%
	GuiControl,,vOlSliderOM,%g_OverlapOM%

	GuiControl,, vOverlapNumMO, %g_OverlapMO%
	GuiControl,,vOlSliderMO,%g_OverlapMO%

	GuiControl,, vOverlapNumOMO, %g_OverlapOMO%
	GuiControl,,vOlSliderOMO,%g_OverlapOMO%
	Return

;-----------------------------------------------------------------------
; 機能：零遅延モードチェックボックスの操作
;-----------------------------------------------------------------------
gZeroDelay:
	Gui,2:Default
	Gui, Submit, NoHide
	g_ZeroDelay := %A_GuiControl%
	Return


;-----------------------------------------------------------------------
; 機能：零遅延モードチェックボックスの操作
;-----------------------------------------------------------------------
gZeroDelaySS:
	Gui,2:Default
	Gui, Submit, NoHide
	g_ZeroDelay := %A_GuiControl%
	Return

;-----------------------------------------------------------------------
; 機能：その他、無効化したＧＵＩ要素の操作・・・ダミー
; ver.0.1.3.7 ... gSpace/gSpaceUp を追加
;-----------------------------------------------------------------------
gOya:
	Gui,2:Default
	Gui, Submit, NoHide
	if(vOyaKey != "…") {
		g_OyaKey := vOyaKey
		RemapOya()
		RefreshLayoutA()
	}
	Return

;-----------------------------------------------------------------------
; 機能：単独打鍵の設定
;-----------------------------------------------------------------------
gKeySingle:
	Gui,2:Default
	Gui, Submit, NoHide
	if(vKeySingle != "…") {
		g_KeySingle := vKeySingle
		if(g_KeySingle = "有効")	; キーリピートON（事後的にOFF可)
		{
			g_KeyRepeat := 1
		} else {
			g_KeyRepeat := 0
		}
		RemapOya()
		RefreshLayoutA()
	}
	return

;-----------------------------------------------------------------------
; 機能：同時打鍵キーの指定
;-----------------------------------------------------------------------
gCurrSimulMode:
	Gui,2:Default
	Gui, Submit, NoHide
	g_CurrSimulMode := vCurrSimulMode
	Gui,Destroy
	Goto,_Settings

;-----------------------------------------------------------------------
; 機能：親指シフトモードの変数設定
;-----------------------------------------------------------------------
RemapOya()
{
	global
	if(ShiftMode["A"] == "親指シフト") {
		RemapOyaKey("A")
	}
	if(ShiftMode["R"] == "親指シフト") {
		RemapOyaKey("R")
	}
	return
}

gDefFile:
	Gui, Submit, NoHide
	;MsgBox % %A_GuiControl%
	Return

;-----------------------------------------------------------------------
; 機能：ファイル選択ボタンの押下
;-----------------------------------------------------------------------
gFileSelect:
	SetTimer,G2PollingLayout,off
	SetWorkingDir, %g_DataDir%
	FileSelectFile, vLayoutFileAbs,0,%g_DataDir%,,Layout File (*.bnz; *.yab)
	
	Gui,2:Default
	if(vLayoutFileAbs<>"")
	{
		vLayoutFile := Path_RelativePathTo(A_WorkingDir, 0x10, vLayoutFileAbs, 0x20)
		if(vLayoutFile = "")
		{
			vLayoutFile := vLayoutFileAbs
		}
		GuiControl,, vFilePath, %vLayoutFile%

		SetTimer,Interrupt16,off
		SetHotkey("off")
		SetHotkeyFunction("off")
		
		Gosub, InitLayout2
		ReadLayoutFile(vLayoutFile)
		if(_error=="")
		{
			Traytip,キーボード配列エミュレーションソフト「紅皿」,benizara %g_Ver% `n%g_layoutName%　%g_layoutVersion%
		} else
		{
			msgbox, %_error%
			
			; 元ファイルを再読み込みする
			Gosub, InitLayout2
			vLayoutFile := g_LayoutFile
			ReadLayoutFile(g_LayoutFile)
			GuiControl,, vFilePath, %vLayoutFile%
		}
		Gosub, SetLayoutProperty
		g_LayoutFile := vLayoutFile
		
		_currentTick := Pf_Count()	;A_TickCount
		g_MojiTick[0] := _currentTick
		g_OyaTick["R"] := _currentTick
		g_OyaTick["L"] := _currentTick
		SetTimer,Interrupt16,on
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
	Gui,2:Default
	Gui, Submit, NoHide
	if(vKeyPause == "Pause" || vKeyPause == "ScrollLock" || vKeyPause == "無効")
	{
		g_KeyPause := vKeyPause
	}
	return

;-----------------------------------------------------------------------
; 機能：一時停止のチェックボックス
;-----------------------------------------------------------------------
gPauseStatus(a_Pause)
{
	if (a_Pause == 0)
	{
		return 1
	}
	return 0
}
;-----------------------------------------------------------------------
; 機能：管理者権限設定ボタン
;-----------------------------------------------------------------------
gButtonAdmin:
	{ 
		try ; leads to having the script re-launching itself as administrator 
		{ 
			if(A_IsCompiled)
			{
				Run *RunAs "%A_ScriptFullPath%" /restart 
			}
			else
			{
				SetWorkingDir, %A_ScriptDir%
				Run *RunAs "%A_ScriptFullPath%" /restart
				;Run *RunAs "%A_AhkPath%" /restart "%A_ScriptFullPath%" 
			}
		} 
		ExitApp 
	}
	return

;-----------------------------------------------------------------------
; 機能：OKボタンの押下
;-----------------------------------------------------------------------

gButtonOk:
	SetWorkingDir, %g_DataDir%
	g_IniFile := g_DataDir . "\benizara.ini"
	IniWrite,%g_LayoutFile%,%g_IniFile%,FilePath,LayoutFile
	IniWrite,%g_Continue%,%g_IniFile%,Key,Continue
	IniWrite,%g_Threshold%,%g_IniFile%,Key,Threshold
	IniWrite,%g_ThresholdSS%,%g_IniFile%,Key,ThresholdSS
	IniWrite,%g_ZeroDelay%,%g_IniFile%,Key,ZeroDelay
	IniWrite,%g_OverlapMO%,%g_IniFile%,Key,OverlapMO
	IniWrite,%g_OverlapOM%,%g_IniFile%,Key,OverlapOM
	IniWrite,%g_OverlapOMO%,%g_IniFile%,Key,OverlapOMO
	IniWrite,%g_OverlapSS%,%g_IniFile%,Key,OverlapSS
	IniWrite,%g_OyaKey%,%g_IniFile%,Key,OyaKey
	IniWrite,%g_KeySingle%,%g_IniFile%,Key,KeySingle
	IniWrite,%g_KeyPause%,%g_IniFile%,Key,KeyPause
	SetTimer,G2PollingLayout,off
	Gui,Destroy
	return

;-----------------------------------------------------------------------
; 機能：キャンセルボタンの押下
;-----------------------------------------------------------------------
gButtonCancel:
GuiClose:
	Gui,2:Default
	SetTimer,G2PollingLayout,off
	SetTimer,G4PollingPause,off
	Gui,Destroy
	g_isDialog := 0
	return

