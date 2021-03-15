;-----------------------------------------------------------------------
;	名称：ShowLayout.ahk
;	機能：配列表示
;	ver.0.1.4.3 .... 2020/10/16
;-----------------------------------------------------------------------
;-----------------------------------------------------------------------
; 機能：配列ダイアログの表示
;-----------------------------------------------------------------------

	g_LayoutFile := ".\NICOLA配列.bnz"
	Gosub,ReadLayout
	Gosub, ShowLayout
	Gosub, InitLayout2
	return

#include ReadLayout6.ahk
#include Path.ahk

ShowLayout:
	IfWinExist,紅皿配列
	{
		msgbox, 既に紅皿配列ダイアログは開いています。
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
	g_gui := 4
_ShowLayout:
	Gui,4:Default
	Gui,4:New
	Gui, Font,s10 c000000,Meiryo UI
	Gui, Add, Button,ggSLButtonOk X530 Y405 W80 H24,ＯＫ
	Gui, Add, Button,ggSLButtonCancel X620 Y405 W80 H24,キャンセル
	Gui, Add, Tab3,X10 Y10 W690 H390, 配列||
	Gui, Tab,1

	Gui, Add, Text,X30 Y40, 配列定義ファイル：
	Gui, Add, Edit,vvFilePath ggSLDefFile X150 Y40 W380 H20 ReadOnly, %_LayoutFile%
	Gui, Add, Button,ggSLFileSelect X550 Y40 W32 H21,…

	Gui, Add, Text,X30 Y70,親指シフトキー：
	if(_OyaKey = "無変換－変換")
		Gui, Add, DropDownList,ggSLOya vvOyaKey X133 Y70 W125,無変換－変換||無変換－空白|空白－変換|
	else if(_OyaKey = "無変換－空白")
		Gui, Add, DropDownList,ggSLOya vvOyaKey X133 Y70 W125,無変換－変換|無変換－空白||空白－変換|
	else
		Gui, Add, DropDownList,ggSLOya vvOyaKey X133 Y70 W125,無変換－変換|無変換－空白|空白－変換||

	Gui, Add, Text,X290 Y70,単独打鍵：
	if(_KeySingle = "無効")
		Gui, Add, DropDownList,ggSLKeySingle vvKeySingle X360 Y70 W95,無効||有効|
	else
		Gui, Add, DropDownList,ggSLKeySingle vvKeySingle X360 Y70 W95,無効|有効||

	Gui, Font,s10 c000000,Meiryo UI
	Gosub,SLDrawKeyFrame
	Gui, Font,s9 c000000,Meiryo UI
	Gui, Add, Edit,vvEdit X60 Y370 W600 H20 -Vscroll,
	Gosub,SLRefreshLayout
	Gui, Show, W720 H440, 紅皿配列
	SetTimer,SLPollingLayout,100
	GuiControl,Focus,vEdit
	return
	
;-----------------------------------------------------------------------
; 機能：閉じるボタンの押下
;-----------------------------------------------------------------------
gSLButtonOk:
	Gui,Destroy
	return
;-----------------------------------------------------------------------
; 機能：閉じるボタンの押下
;-----------------------------------------------------------------------
gSLButtonCancel:
	Gui,Destroy
	return
	
;-----------------------------------------------------------------------
; 機能：ファイル名のテキストボックス
;-----------------------------------------------------------------------
gSLDefFile:
	Gui, Submit, NoHide
	Return
;-----------------------------------------------------------------------
; 機能：その他、無効化したＧＵＩ要素の操作・・・ダミー
; ver.0.1.3.7 ... gSpace/gSpaceUp を追加
;-----------------------------------------------------------------------
gSLOya:
	Gui, Submit, NoHide
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

;-----------------------------------------------------------------------
; 機能：無変換・変換キーの単独打鍵
;-----------------------------------------------------------------------
gSLKeySingle:
	Gui, Submit, NoHide
	g_KeySingle := vKeySingle
	return
;-----------------------------------------------------------------------
; 機能：ファイル選択ボタンの押下
;-----------------------------------------------------------------------
gSLFileSelect:
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
	Goto,_ShowLayout

;-----------------------------------------------------------------------
; 機能：キーレイアウトの表示
;-----------------------------------------------------------------------
SLDrawKeyFrame:
	Gui,Add,GroupBox,X20 Y90 W670 H270,キー配列
	_col := 1
	_ypos := 110
	_cnt := 13
	loop,%_cnt%
	{
		_row := A_Index
		_xpos := 32*(_col-1) + 48*(_row - 1) + 40
		_ch := " "
		Gosub, SLKeyRectangle
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
		Gosub, SLKeyBorder
	}

	_col := 2
	_ypos := _ypos + 48
	_cnt := 12
	loop,%_cnt%
	{
		_row := A_Index
		_xpos := 32*(_col-1) + 48*(_row - 1) + 40
		_ch := " "
		Gosub, SLKeyRectangle
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
		Gosub, SLKeyBorder
	}
	_col := 3
	_ypos := _ypos + 48
	_cnt := 12
	loop,%_cnt%
	{
		_row := A_Index
		_xpos := 32*(_col-1) + 48*(_row - 1) + 40
		_ch := " "
		Gosub, SLKeyRectangle
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
		Gosub, SLKeyBorder
	}
	_col := 4
	_ypos := _ypos + 48
	_cnt := 11
	loop,%_cnt%
	{
		_row := A_Index
		_xpos := 32*(_col-1) + 48*(_row - 1) + 40
		_ch := " "
		Gosub, SLKeyRectangle
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
		Gosub, SLKeyBorder
	}
	_col := 5
	_ypos := _ypos + 48
	_row := 1
	_xpos := 32*(_col-1) + 48*(_row + 2 - 1) + 40
	Gosub, SLKeyRectangle5
	_xpos0 := _xpos + 6
	_ypos0 := _ypos + 10
	Gui, Font,s9 c000000,Meiryo UI
	Gui, Add, Text,vvkeyFA%_col%%_row% X%_xpos0% Y%_ypos0% W42 +Center c000000 BackgroundTrans,左親指
	_xpos0 := _xpos + 6
	_ypos0 := _ypos + 30
	Gui, Font,s9 c000000,Meiryo UI
	Gui, Add, Text,vvkeyFB%_col%%_row% X%_xpos0% Y%_ypos0% W42 +Center c000000 BackgroundTrans,　　　
	Gosub, SLKeyBorder

	_row := 2
	_xpos := 32*(_col-1) + 48*(_row + 2 - 1) + 40
	Gosub, SLKeyRectangle5
	_xpos0 := _xpos + 6
	_ypos0 := _ypos + 10
	Gui, Font,s9 c000000,Meiryo UI
	Gui, Add, Text,vvkeyFA%_col%%_row% X%_xpos0% Y%_ypos0% W42 +Center c000000 BackgroundTrans,　　　
	_xpos0 := _xpos + 6
	_ypos0 := _ypos + 30
	Gui, Font,s9 c000000,Meiryo UI
	Gui, Add, Text,vvkeyFB%_col%%_row% X%_xpos0% Y%_ypos0% W42 +Center c000000 BackgroundTrans,　　　
	Gosub, SLKeyBorder

	_row := 3
	_xpos := 32*(_col-1) + 48*(_row + 2 - 1) + 40
	Gosub, SLKeyRectangle5
	_xpos0 := _xpos + 6
	_ypos0 := _ypos + 10
	Gui, Font,s9 c000000,Meiryo UI
	Gui, Add, Text,vvkeyFA%_col%%_row% X%_xpos0% Y%_ypos0% W42 +Center c000000 BackgroundTrans,右親指
	_xpos0 := _xpos + 6
	_ypos0 := _ypos + 30
	Gui, Font,s9 c000000,Meiryo UI
	Gui, Add, Text,vvkeyFB%_col%%_row% X%_xpos0% Y%_ypos0% W42 +Center c000000 BackgroundTrans,　  
	Gosub, SLKeyBorder

	return

;-----------------------------------------------------------------------
; 機能：各キーの矩形表示
;-----------------------------------------------------------------------
SLKeyRectangle:
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
SLKeyRectangle5:
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
SLKeyBorder:
	Gui, Font,s45 c000000,Yu Gothic UI
	_ypos0 := _ypos - 12
	_xpos0 := _xpos - 3
	Gui, Add, Text,vvkeyDN%_col%%_row% X%_xpos0% X%_xpos0% Y%_ypos0% +Center BackgroundTrans,　
	vkeyDN%_col%%A_Index% := "　"
	return

;-----------------------------------------------------------------------
; 機能：キー配列変更に係る変数の監視
;-----------------------------------------------------------------------
SLPollingLayout:
	Gui,4:Default
	if(s_Romaji != g_Romaji) 
	{
		s_Romaji := g_Romaji
		Gosub,SLRefreshLayout
	}
	if(s_kOyaL != kOyaL || s_kOyaR != kOyaR || s_KeySingle != g_KeySingle)
	{
		s_kOyaL := kOyaL 
		s_kOyaR := kOyaR
		s_KeySingle := g_KeySingle
		Gosub,SLRefreshLayout5
	}
	return

;-----------------------------------------------------------------------
; 機能：キー配列表示の切り替え
;-----------------------------------------------------------------------
SLRefreshLayout5:
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
SLRefreshLayout:
	Gui, Submit, NoHide
	loop,4
	{
		_col := A_Index
		org := StrSplit(LF["NUL" . _colcnv[_col]],",")
		loop,% org.MaxIndex()
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
		if(LF[g_Romaji . "NK" . _colcnv[_col]] != "")
		{
			org := StrSplit(LF[g_Romaji . "NK" . _colcnv[_col]],",")
		}
		else
		{
			org := StrSplit(LF["ADK" . _colcnv[_col]],",")
		}
		loop,% org.MaxIndex()
		{
			_ch := org[A_Index]
			GuiControl,,vkeyRK%_col%%A_Index%,%_ch%
		}
	}
	loop,4
	{
		_col := A_Index
		if(LF[g_Romaji . "NN" . _colcnv[_col]] != "")
		{
			org := StrSplit(LF[g_Romaji . "NN" . _colcnv[_col]],",")
		}
		else
		{
			org := StrSplit(LF["ADN" . _colcnv[_col]],",")
		}
		loop,% org.MaxIndex()
		{
			_ch := org[A_Index]
			GuiControl,,vkeyRN%_col%%A_Index%,%_ch%
		}
	}
	loop,4
	{
		_col := A_Index
		if(LF[g_Romaji . "LN" . _colcnv[_col]] != "")
		{
			org := StrSplit(LF[g_Romaji . "LN" . _colcnv[_col]],",")
		}
		else
		{
			org := StrSplit(LF["NUL" . _colcnv[_col]],",")
		}
		loop,% org.MaxIndex()
		{
			_ch := org[A_Index]
			GuiControl,,vkeyRL%_col%%A_Index%,%_ch%
		}
	}
	loop,4
	{
		_col := A_Index
		if(LF[g_Romaji . "RN" . _colcnv[_col]] != "")
		{
			org := StrSplit(LF[g_Romaji . "RN" . _colcnv[_col]],",")
		}
		else
		{
			org := StrSplit(LF["NUL" . _colcnv[_col]],",")
		}
		loop,% org.MaxIndex()
		{
			_ch := org[A_Index]
			GuiControl,,vkeyRR%_col%%A_Index%,%_ch%
		}
	}
	loop,4
	{
		_col := A_Index
		org := StrSplit(LF["NUL" . _colcnv[_col]],",")
		loop,% org.MaxIndex()
		{
			GuiControl,+Redraw,vkeyDN%_col%%A_Index%
			GuiControl,+Redraw,vkeyRK%_col%%A_Index%
			GuiControl,+Redraw,vkeyRN%_col%%A_Index%
			GuiControl,+Redraw,vkeyRL%_col%%A_Index%
			GuiControl,+Redraw,vkeyRR%_col%%A_Index%
		}
	}
	return


