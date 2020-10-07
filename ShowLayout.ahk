;-----------------------------------------------------------------------
;	名称：ShowLayout.ahk
;	機能：配列表示
;	ver.0.1.4.3 .... 2020/10/4
;-----------------------------------------------------------------------
;-----------------------------------------------------------------------
; 機能：配列ダイアログの表示
;-----------------------------------------------------------------------
ShowLayout:
	Gui, New
	Gui, Font,s9 c000000
	Gui, Add, Button,ggSLButtonClose X620 Y320 W66 H22,閉じる
	Gui, Show, W780 H350, 紅皿の配列
	Gui, Font,s10 c000000,ＭＳ ゴシック
	Gosub,SLDrawKeyFrame
	loop
	{
        IfWinNotExist, 紅皿の配列
        {
            Gui, Destroy
            return
        }
		loop, 64
		{

		}
        Sleep,500
	}
	return


;-----------------------------------------------------------------------
; 機能：閉じるボタンの押下
;-----------------------------------------------------------------------
gSLButtonClose:
	Gui,Destroy
	return
	
;-----------------------------------------------------------------------
; 機能：キーレイアウトの表示
;-----------------------------------------------------------------------
SLDrawKeyFrame:
	_col := 1
	_ypos := 44 + 30*(_col - 1)
	_cnt := 13
	loop,%_cnt%
	{
		_xpos := 32*(_col-1) + 54*(A_Index - 1)
		_ch := "あ"
		Gosub, SLKeyRectangle
		_xpos0 := _xpos + 12
		_ypos0 := _ypos + 12
		Gui, Font,s12 c000000
		Gui, Add, Text,X%_xpos0% Y%_ypos0% W12 +Center c000000 BackgroundTrans,%_ch%
		_xpos0 := _xpos + 36
		_ypos0 := _ypos + 12
		Gui, Font,s12 c000000
		Gui, Add, Text,X%_xpos0% Y%_ypos0% W12 +Center c000000 BackgroundTrans,%_ch%
		_xpos0 := _xpos + 12
		_ypos0 := _ypos + 36
		Gui, Font,s12 c000000
		Gui, Add, Text,X%_xpos0% Y%_ypos0% W12 +Center c000000 BackgroundTrans,%_ch%
		_xpos0 := _xpos + 36
		_ypos0 := _ypos + 36
		Gui, Font,s12 c000000
		Gui, Add, Text,X%_xpos0% Y%_ypos0% W12 +Center c000000 BackgroundTrans,%_ch%
	}

	_col := 2
	_ypos := 44 + 58*(_col - 1)
	_cnt := 12
	loop,%_cnt%
	{
		_xpos := 32*(_col-1) + 54*(A_Index - 1)
		_ch := "い"
		Gosub, SLKeyRectangle
		_xpos0 := _xpos + 12
		_ypos0 := _ypos + 12
		Gui, Font,s12 c000000
		Gui, Add, Text,X%_xpos0% Y%_ypos0% W12 +Center c000000 BackgroundTrans,%_ch%
		_xpos0 := _xpos + 36
		_ypos0 := _ypos + 12
		Gui, Font,s12 c000000
		Gui, Add, Text,X%_xpos0% Y%_ypos0% W12 +Center c000000 BackgroundTrans,%_ch%
		_xpos0 := _xpos + 12
		_ypos0 := _ypos + 36
		Gui, Font,s12 c000000
		Gui, Add, Text,X%_xpos0% Y%_ypos0% W12 +Center c000000 BackgroundTrans,%_ch%
		_xpos0 := _xpos + 36
		_ypos0 := _ypos + 36
		Gui, Font,s12 c000000
		Gui, Add, Text,X%_xpos0% Y%_ypos0% W12 +Center c000000 BackgroundTrans,%_ch%
	}
	_col := 3
	_ypos := 44 + 58*(_col - 1)
	_cnt := 12
	loop,%_cnt%
	{
		_xpos := 32*(_col-1) + 54*(A_Index - 1)
		_ch := "う"
		Gosub, SLKeyRectangle
		_xpos0 := _xpos + 12
		_ypos0 := _ypos + 12
		Gui, Font,s12 c000000
		Gui, Add, Text,X%_xpos0% Y%_ypos0% W12 +Center c000000 BackgroundTrans,%_ch%
		_xpos0 := _xpos + 36
		_ypos0 := _ypos + 12
		Gui, Font,s12 c000000
		Gui, Add, Text,X%_xpos0% Y%_ypos0% W12 +Center c000000 BackgroundTrans,%_ch%
		_xpos0 := _xpos + 12
		_ypos0 := _ypos + 36
		Gui, Font,s12 c000000
		Gui, Add, Text,X%_xpos0% Y%_ypos0% W12 +Center c000000 BackgroundTrans,%_ch%
		_xpos0 := _xpos + 36
		_ypos0 := _ypos + 36
		Gui, Font,s12 c000000
		Gui, Add, Text,X%_xpos0% Y%_ypos0% W12 +Center c000000 BackgroundTrans,%_ch%
	}
	_col := 4
	_ypos := 44 + 58*(_col - 1)
	_cnt := 11
	loop,%_cnt%
	{
		_xpos := 32*(_col-1) + 54*(A_Index - 1)
		_ch := "え"
		Gosub, SLKeyRectangle
		_xpos0 := _xpos + 12
		_ypos0 := _ypos + 12
		Gui, Font,s12 c000000
		Gui, Add, Text,X%_xpos0% Y%_ypos0% W12 +Center c000000 BackgroundTrans,%_ch%
		_xpos0 := _xpos + 36
		_ypos0 := _ypos + 12
		Gui, Font,s12 c000000
		Gui, Add, Text,X%_xpos0% Y%_ypos0% W12 +Center c000000 BackgroundTrans,%_ch%
		_xpos0 := _xpos + 12
		_ypos0 := _ypos + 36
		Gui, Font,s12 c000000
		Gui, Add, Text,X%_xpos0% Y%_ypos0% W12 +Center c000000 BackgroundTrans,%_ch%
		_xpos0 := _xpos + 36
		_ypos0 := _ypos + 36
		Gui, Font,s12 c000000
		Gui, Add, Text,X%_xpos0% Y%_ypos0% W12 +Center c000000 BackgroundTrans,%_ch%
	}
	Gui, color,,FFC3E1
	return

;-----------------------------------------------------------------------
; 機能：各キーの矩形表示
;-----------------------------------------------------------------------
SLKeyRectangle:
	Gui, Font,s50 c000000
	_ypos0 := _ypos
	_xpos0 := _xpos
	Gui, Add, Text,X%_xpos0% Y%_ypos0% W50 +Center,■

	if(A_Index = 1)
	{
		Gui, Font,s48 cFFC3E1
	}
	else if A_Index in 2,3
	{
		Gui, Font,s48 cFFFFC3
	}
	else if A_Index in 4,5
	{
		Gui, Font,s48 cC3FFC3
	}
	else if A_Index in 6,7
	{
		Gui, Font,s48 cC3FFFF
	}
	else if A_Index in 8,9
	{
		Gui, Font,s48 cE1C3FF
	}
	else
	{
		Gui, Font,s48 cC0C0C0
	}
	_ypos0 := _ypos - 1
	_xpos0 := _xpos - 1
	Gui, Add, Text,X%_xpos0% Y%_ypos0% W48 +Center,■
	return

