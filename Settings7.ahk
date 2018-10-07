;-----------------------------------------------------------------------
;	名称：Settings7.ahk
;	機能：紅皿のパラメータ設定
;	ver.0.1.1 .... 2018/10/04
;-----------------------------------------------------------------------

	Gosub,Init
	g_LayoutFile =.\NICOLA配列.bnz
	Gosub,ReadLayout
	Gosub, Settings
	return

#include ReadLayout6.ahk
#include Path.ahk

;-----------------------------------------------------------------------
; Iniファイルの読み込み
;-----------------------------------------------------------------------
Init:
	g_IniFile = .\benizara.ini
	if Path_FileExists(g_IniFile) = 0
	{
		g_LayoutFile =
		IniWrite,%g_LayoutFile%,%g_IniFile%,FilePath,LayoutFile
		g_Continue = 1
		IniWrite,%g_Continue%,%g_IniFile%,Key,Continue
		g_Threshold = 100
		IniWrite,%g_Threshold%,%g_IniFile%,Key,Threshold
		g_ZeroDelay = 1
		IniWrite,%g_ZeroDelay%,%g_IniFile%,Key,ZeroDelay
		g_Overlap = 50
		IniWrite,%g_Overlap%,%g_IniFile%,Key,Overlap
		g_ThumbKey = 無変換－変換
		IniWrite,%g_ThumbKey%,%g_IniFile%,Key,ThumbKey
	}
	IniRead,g_LayoutFile,%g_IniFile%,FilePath,LayoutFile
	IniRead,g_Continue,%g_IniFile%,Key,Continue
	if g_Continue>1 
		g_Continue = 1
	if g_Continue<0
		g_Continue = 0
	IniRead,g_ZeroDelay,%g_IniFile%,Key,ZeroDelay
	if g_ZeroDelay>1 
		g_ZeroDelay = 1
	if g_ZeroDelay<0
		g_ZeroDelay = 0
	IniRead,g_Threshold,%g_IniFile%,Key,Threshold
	if g_Threshold < 10
		g_Threshold = 10
	if g_Threshold > 400
		g_Threshold = 400
	IniRead,g_Overlap,%g_IniFile%,Key,Overlap
	if g_Overlap < 20
		g_Overlap = 20
	if g_Overlap > 80
		g_Overlap = 80
	IniRead,g_ThumbKey,%g_IniFile%,Key,ThumbKey
	if g_ThumbKey not in 無変換－変換,無変換－空白
		g_ThumbKey = 無変換－変換
	return
	
;-----------------------------------------------------------------------
; 機能：設定ダイアログの表示
;-----------------------------------------------------------------------
Settings:
	_Continue := g_Continue
	_ZeroDelay := g_ZeroDelay
	_Threshold := g_Threshold
	_LayoutFile := g_LayoutFile
	_allTheLayout := g_allTheLayout
	_Overlap := g_Overlap
	_ThumbKey := g_ThumbKey
_Settings:
	Gui, New
	Gui, Font,s10 c000000
	Gui, Add, Button,ggButtonOk X343 Y308 W77 H22,ＯＫ
	Gui, Add, Button,ggButtonCancel X431 Y308 W77 H22,キャンセル
	Gui, Add, Tab2,X12 Y8 W522 H291, 配列||親指シフト|紅皿について

	Gui, Tab, 1
	Gui, Font,s10 c000000
	Gui, Add, Text,X40 Y57, 配列定義ファイル：
	Gui, Add, Edit,vvFilePath ggDefFile X59 Y78 W375 H18 ReadOnly, %_LayoutFile%
	Gui, Add, Button,ggFileSelect X453 Y78 W32 H19,…

	Gui, Add, Text,X40 Y110, 配列のモード：
	Gui, Add, ComboBox,ggLayout vvLayout X128 Y110,%_allTheLayout%
		;英数シフト無し|英数小指シフト|ローマ字シフト無し||ローマ字左親指シフト|ローマ字右親指シフト|ローマ字小指シフト
	Gosub,DrawKeyFrame
	StringSplit _thisLayout,_allTheLayout,|
	vLayout := _thisLayout1
	Gosub, gLayout
	
	Gui, Tab, 2
	Gui, Font,s10 c000000
	Gui, Add, Text,X30 Y52,親指シフトキー：
	if _ThumbKey = 無変換－変換
		Gui, Add, ComboBox,ggThumb vvThumbKey X133 Y52 W125,無変換－変換||無変換－空白|
	else
		Gui, Add, ComboBox,ggThumb vvThumbKey X133 Y52 W125,無変換－変換|無変換－空白||
	;GuiControl,,vThumbKey,%_ThumbKey%
	Gui, Add, Checkbox,ggContinue vvContinue X292 Y52,連続シフト
	GuiControl,,vContinue,%_Continue%

	Gui, Add, Checkbox,ggZeroDelay vvZeroDelay X392 Y52,零遅延モード
	GuiControl,,vZeroDelay,%_ZeroDelay%
	
	Gui, Font,s10 c000000
	Gui, Add, Text,X57 Y92,単独打鍵：
	Gui, Add, ComboBox,ggKeySingle vvKeySingle X137 Y92 W95,有効|無効||
	GuiControl,Disable,vKeySingle
	Gui, Add, Checkbox,ggKeyRepeat vvKeyRepeat X292 Y92,キーリピート
	GuiControl,Disable,vKeyRepeat
	
	Gui, Font,s10 c000000
	Gui, Add, Text,X30 Y132 c000000,文字と親指シフトの同時打鍵の割合：
	Gui, Add, Edit,vvOverlapNum X263 Y130 W30 ReadOnly, %_Overlap%
	Gui, Add, Text,X300 Y132 c000000,[`%]
	
	Gui, Add, Slider, X49 Y172 ggOlSlider w400 vvOlSlider Range20-80 line10 TickInterval10
	GuiControl,,vOlSlider,%_Overlap%
	
	Gui, Add, Text,X30 Y212 c000000,文字と親指シフトの同時打鍵の判定時間：
	Gui, Add, Edit,vvThresholdNum X263 Y210 W30 ReadOnly, %_Threshold%
	Gui, Add, Text,X300 Y212 c000000,[mSEC]
	
	Gui, Add, Slider, X49 Y252 ggThSlider w400 vvThSlider Range10-400 line10 TickInterval10
	GuiControl,,vThSlider,%_Threshold%

	Gui, Tab, 3
	Gui, Font,s10 c000000
	Gui, Add, Text,X30 Y52,名称：benizara / 紅皿
	Gui, Add, Text,X30 Y92,機能：Yet another NICOLA Emulaton Software / キーボード配列エミュレーションソフト
	Gui, Add, Text,X30 Y132,パージョン：ver.0.1.1 / 2018年10月 7日
	Gui, Add, Text,X30 Y172,作者：Ken'ichiro Ayaki
	Gui, Show, W547 H341, 紅皿
	return

;-----------------------------------------------------------------------
; 機能：キーレイアウトの表示
;-----------------------------------------------------------------------
DrawKeyFrame:
	_col =1
	_ypos := 148 + 36*(_col - 1)
	_cnt := 13
	loop,%_cnt%
	{
		_xpos := 24+18*(_col-1) + 38*(A_Index - 1)
		_ch := " "
		Gosub, KeyRectangle
		Gui, Font,s10 c000000
		Gui, Add, Text,vvkey%_col%%A_Index% X%_xpos% Y%_ypos% W34 +Center c000000 BackgroundTrans, %_ch%
	}
	_col =2
	_ypos := 148 + 36*(_col - 1)
	_cnt := 12
	loop,%_cnt%
	{
		_xpos := 24+18*(_col-1) + 38*(A_Index - 1)
		_ch := " "
		Gosub, KeyRectangle
		Gui, Font,s10 c000000
		Gui, Add, Text,vvkey%_col%%A_Index% X%_xpos% Y%_ypos% W34 +Center c000000 BackgroundTrans, %_ch%
	}
	_col =3
	_ypos := 148 + 36*(_col - 1)
	_cnt := 12
	loop,%_cnt%
	{
		_xpos := 24+18*(_col-1) + 38*(A_Index - 1)
		_ch := " "
		Gosub, KeyRectangle
		Gui, Font,s10 c000000
		Gui, Add, Text,vvkey%_col%%A_Index% X%_xpos% Y%_ypos% W34 +Center c000000 BackgroundTrans, %_ch%
	}
	_col =4
	_ypos := 148 + 36*(_col - 1)
	_cnt := 11
	loop,%_cnt%
	{
		_xpos := 24+18*(_col-1) + 38*(A_Index - 1)
		_ch := " "
		Gosub, KeyRectangle
		Gui, Font,s10 c000000
		Gui, Add, Text,vvkey%_col%%A_Index% X%_xpos% Y%_ypos% W34 +Center c000000 BackgroundTrans, %_ch%
	}
	return

;-----------------------------------------------------------------------
; 機能：各キーの矩形表示
;-----------------------------------------------------------------------
KeyRectangle:
	Gui, Font,s36 c000000
	_ypos0 := _ypos - 17
	_xpos0 := _xpos - 7
	Gui, Add, Text,X%_xpos0% Y%_ypos0% W36 +Center BackgroundTrans, ■
	if A_Index = 1
	{
		Gui, Font,s34 cFFC3E1
	}
	else if A_Index = 2
	{
		Gui, Font,s34 cFFE1C3
	}
	else if A_Index = 3
	{
		Gui, Font,s34 cFFFFC3
	}
	else if A_Index = 4
	{
		Gui, Font,s34 cC3FFC3
	}
	else if A_Index = 5
	{
		Gui, Font,s34 cC3FFC3
	}
	else if A_Index = 6
	{
		Gui, Font,s34 cC3FFFF
	}
	else if A_Index = 7
	{
		Gui, Font,s34 cC3FFFF
	}
	else if A_Index = 8
	{
		Gui, Font,s34 cC3E1FF
	}
	else if A_Index = 9
	{
		Gui, Font,s34 cE1C3FF
	}
	else
	{
		Gui, Font,s34 cC0C0C0
	}
	_ypos0 := _ypos - 16
	_xpos0 := _xpos - 6
	Gui, Add, Text,X%_xpos0% Y%_ypos0% W34 +Center BackgroundTrans, ■
	return

;-----------------------------------------------------------------------
; 機能：キー配列コンボポックスの切り替えとキー配列表示の切り替え
;-----------------------------------------------------------------------
gLayout:
	Gui, Submit, NoHide
	_mode := Layout2Mode(vLayout)
	if _mode=
		return
	_col =1
	loop,4
	{
		_col := A_Index
		_cnt := org%_mode%%_col%0
		loop,%_cnt%
		{
			_ch := org%_mode%%_col%%A_Index%
			GuiControl,,vkey%_col%%A_Index%,%_ch%
		}
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
;-----------------------------------------------------------------------
gThumb:
	Gui, Submit, NoHide	
RemapThumb:
	if vThumbKey = 無変換－変換
	{
		Hotkey,Space,gSpace
		Hotkey,Space up,gSpaceUp
		Hotkey,*sc079,gThumbR
		Hotkey,*sc079 up,gThumbRUp
		Hotkey,*sc07B,gThumbL
		Hotkey,*sc07B up,gThumbLUp
	}
	else if vThumbKey = 無変換－空白
	{
		Hotkey,*sc079,gSpace
		Hotkey,*sc079 up,gSpaceUp
		Hotkey,Space,gThumbR
		Hotkey,Space up,gThumbRUp
		Hotkey,*sc07B,gThumbL
		Hotkey,*sc07B up,gThumbLUp
	}
	_ThumbKey = vThumbKey
	Return

gKeySingle:
gKeyRepeat:
gDefFile:
	Gui, Submit, NoHide
	;MsgBox % %A_GuiControl%
	Return

;-----------------------------------------------------------------------
; 機能：ファイル選択ボタンの押下
;-----------------------------------------------------------------------
gFileSelect:
	SetWorkingDir, %A_ScriptDir%
	FileSelectFile, vLayoutFileAbs,0,.,,Layout File (*.bnz; *.yab)
	
	if vLayoutFileAbs<>
	{
		vLayoutFile := Path_RelativePathTo(A_WorkingDir, 0x10, vLayoutFileAbs, 0x20)
		GuiControl,, vFilePath, %vLayoutFile%

		Gosub, InitLayout
		Gosub, Layout2Key
		GoSub, ReadLayoutFile
		if _error <>
		{
			msgbox, %_error%
			Gosub, InitLayout
			Gosub, Layout2Key
			_LayoutFile := g_LayoutFile
			GoSub, ReadLayoutFile
		}
		_allTheLayout := vAllTheLayout
		_LayoutFile := vLayoutFile
	}
	Gui,Destroy
	Goto,_Settings

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
	g_ThumbKey := _ThumbKey

	g_IniFile = .\benizara.ini
	IniWrite,%g_LayoutFile%,%g_IniFile%,FilePath,LayoutFile
	IniWrite,%g_Continue%,%g_IniFile%,Key,Continue
	IniWrite,%g_Threshold%,%g_IniFile%,Key,Threshold
	IniWrite,%g_ZeroDelay%,%g_IniFile%,Key,ZeroDelay
	IniWrite,%g_Overlap%,%g_IniFile%,Key,Overlap
	IniWrite,%g_ThumbKey%,%g_IniFile%,Key,ThumbKey
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

