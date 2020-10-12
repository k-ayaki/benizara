;-----------------------------------------------------------------------
;	名称：ShowLayout.ahk
;	機能：配列表示
;	ver.0.1.4.3 .... 2020/10/10
;-----------------------------------------------------------------------
;-----------------------------------------------------------------------
; 機能：配列ダイアログの表示
;-----------------------------------------------------------------------
ShowLayout:
	IfWinExist,紅皿配列
	{
		msgbox, 既に紅皿配列ダイアログは開いています。
		return
	}
	Gui,4:Default
	Gui, 4:New
	Gui, 4:Font,s10 c000000
	;Gui, Add, Button,ggSLButtonClose X620 Y320 W66 H22,閉じる
	Gui, 4:Add, Button,ggSLButtonClose X343 Y308 W77 H22,閉じる
	;Gui, Add, Tab2,X12 Y8 W522 H291, 配列
	;Gui, Tab, 1
	Gui, 4:Font,s10 c000000
	Gosub,SLDrawKeyFrame
	Gosub, gLayout2
	Gui, 4:Show, W720 H341, 紅皿配列
	return
	
	loop
	{
        IfWinNotExist, 紅皿配列
        {
            Gui, 4:Destroy
            return
        }
        Gosub, ReadKeyState3
        ;Gosub, ReadKeyState
        ;Gosub, ReadKeyboardState
        Sleep,64
	}
	return


;-----------------------------------------------------------------------
; 機能：閉じるボタンの押下
;-----------------------------------------------------------------------
gSLButtonClose:
	Gui,Destroy
	isShowLayout := 0
	return
	
;-----------------------------------------------------------------------
; 機能：キーレイアウトの表示
;-----------------------------------------------------------------------
SLDrawKeyFrame:
	_col := 1
	_ypos := 30*(_col - 1)
	_cnt := 13
	loop,%_cnt%
	{
		_xpos := 32*(_col-1) + 50*(A_Index - 1)
		_ch := " "
		Gosub, SLKeyRectangle
		_xpos0 := _xpos + 22
		_ypos0 := _ypos + 11
		Gui, Font,s12 c000000
		Gui, Add, Text,vvkeyRR%_col%%A_Index% X%_xpos0% Y%_ypos0% W12 +Center c000000 BackgroundTrans,%_ch%
		_xpos0 := _xpos + 11
		_ypos0 := _ypos + 33
		Gui, Font,s12 c000000
		Gui, Add, Text,vvkeyRL%_col%%A_Index% X%_xpos0% Y%_ypos0% W12 +Center c000000 BackgroundTrans,%_ch%
		_xpos0 := _xpos + 33
		_ypos0 := _ypos + 33
		Gui, Font,s12 c000000
		Gui, Add, Text,vvkeyRN%_col%%A_Index% X%_xpos0% Y%_ypos0% W12 +Center c000000 BackgroundTrans,%_ch%
		Gosub, SLKeyBorder
	}

	_col := 2
	_ypos := 54*(_col - 1)
	_cnt := 12
	loop,%_cnt%
	{
		_xpos := 32*(_col-1) + 50*(A_Index - 1)
		_ch := " "
		Gosub, SLKeyRectangle
		_xpos0 := _xpos + 22
		_ypos0 := _ypos + 11
		Gui, Font,s12 c000000
		Gui, Add, Text,vvkeyRR%_col%%A_Index% X%_xpos0% Y%_ypos0% W12 +Center c000000 BackgroundTrans,%_ch%
		_xpos0 := _xpos + 11
		_ypos0 := _ypos + 33
		Gui, Font,s12 c000000
		Gui, Add, Text,vvkeyRL%_col%%A_Index% X%_xpos0% Y%_ypos0% W12 +Center c000000 BackgroundTrans,%_ch%
		_xpos0 := _xpos + 33
		_ypos0 := _ypos + 33
		Gui, Font,s12 c000000
		Gui, Add, Text,vvkeyRN%_col%%A_Index% X%_xpos0% Y%_ypos0% W12 +Center c000000 BackgroundTrans,%_ch%
		Gosub, SLKeyBorder
	}
	_col := 3
	_ypos := 54*(_col - 1)
	_cnt := 12
	loop,%_cnt%
	{
		_xpos := 32*(_col-1) + 50*(A_Index - 1)
		_ch := " "
		Gosub, SLKeyRectangle
		_xpos0 := _xpos + 22
		_ypos0 := _ypos + 11
		Gui, Font,s12 c000000
		Gui, Add, Text,vvkeyRR%_col%%A_Index% X%_xpos0% Y%_ypos0% W12 +Center c000000 BackgroundTrans,%_ch%
		_xpos0 := _xpos + 11
		_ypos0 := _ypos + 33
		Gui, Font,s12 c000000
		Gui, Add, Text,vvkeyRL%_col%%A_Index% X%_xpos0% Y%_ypos0% W12 +Center c000000 BackgroundTrans,%_ch%
 		_xpos0 := _xpos + 33
		_ypos0 := _ypos + 33
		Gui, Font,s12 c000000
		Gui, Add, Text,vvkeyRN%_col%%A_Index% X%_xpos0% Y%_ypos0% W12 +Center c000000 BackgroundTrans,%_ch%
		Gosub, SLKeyBorder
	}
	_col := 4
	_ypos := 54*(_col - 1)
	_cnt := 11
	loop,%_cnt%
	{
		_xpos := 32*(_col-1) + 50*(A_Index - 1)
		_ch := " "
		Gosub, SLKeyRectangle
		_xpos0 := _xpos + 22
		_ypos0 := _ypos + 11
		Gui, Font,s12 c000000
		Gui, Add, Text,vvkeyRR%_col%%A_Index% X%_xpos0% Y%_ypos0% W12 +Center c000000 BackgroundTrans,%_ch%
		_xpos0 := _xpos + 11
		_ypos0 := _ypos + 33
		Gui, Font,s12 c000000
		Gui, Add, Text,vvkeyRL%_col%%A_Index% X%_xpos0% Y%_ypos0% W12 +Center c000000 BackgroundTrans,%_ch%
		_xpos0 := _xpos + 33
		_ypos0 := _ypos + 33
		Gui, Font,s12 c000000
		Gui, Add, Text,vvkeyRN%_col%%A_Index% X%_xpos0% Y%_ypos0% W12 +Center c000000 BackgroundTrans,%_ch%
		Gosub, SLKeyBorder
	}
	return

;-----------------------------------------------------------------------
; 機能：各キーの矩形表示
;-----------------------------------------------------------------------
SLKeyRectangle:
	Gui, Font,s48 c000000
	_ypos0 := _ypos - 2
	_xpos0 := _xpos - 3
	Gui, Add, Text,X%_xpos0% X%_xpos0% Y%_ypos0% W48 +Center BackgroundTrans,■
	if(A_Index = 1)
	{
		Gui, Font,S44 cFFC3E1
	}
	else if A_Index in 2,3
	{
		Gui, Font,S44 cFFFFC3
	}
	else if A_Index in 4,5
	{
		Gui, Font,S44 cC3FFC3
	}
	else if A_Index in 6,7
	{
		Gui, Font,S44 cC3FFFF
	}
	else if A_Index in 8,9
	{
		Gui, Font,S44 cE1C3FF
	}
	else
	{
		Gui, Font,s44 cC0C0C0
	}
	_ypos0 := _ypos
	_xpos0 := _xpos - 1
	Gui, Add, Text,X%_xpos0% Y%_ypos0% W44 +Center BackgroundTrans,■
	return

SLKeyBorder:
	Gui, Font,s48 c000000
	_ypos0 := _ypos - 2
	_xpos0 := _xpos - 3 + 8
	Gui, Add, Text,vvkeyX%_col%%A_Index% X%_xpos0% X%_xpos0% Y%_ypos0% W48 +Center BackgroundTrans,　
	vkeyX%_col%%A_Index% := "　"
	return

;-----------------------------------------------------------------------
; 機能：キー配列コンボポックスの切り替えとキー配列表示の切り替え
;-----------------------------------------------------------------------
gLayout2:
	Gui, Submit, NoHide
	loop,4
	{
		_col := A_Index
		StringSplit org,LFRNN%_col%,`,
		loop,%org0%
		{
			_ch := org%A_Index%
			GuiControl,,vkeyRN%_col%%A_Index%,%_ch%
		}
	}
	loop,4
	{
		_col := A_Index
		StringSplit org,LFRLN%_col%,`,
		loop,%org0%
		{
			_ch := org%A_Index%
			GuiControl,,vkeyRL%_col%%A_Index%,%_ch%
		}
	}
	loop,4
	{
		_col := A_Index
		StringSplit org,LFRRN%_col%,`,
		loop,%org0%
		{
			_ch := org%A_Index%
			GuiControl,,vkeyRR%_col%%A_Index%,%_ch%
		}
	}
	return

;-----------------------------------------------------------------------
; 機能：LCTRLキーの読取
;-----------------------------------------------------------------------
ReadKeyState:
	Critical
	_vkey := 0x31
	_keyname := "11"
	Gosub,SetKeyGui
	_vkey := 0x32
	_keyname := "12"
	Gosub,SetKeyGui
	_vkey := 0x33
	_keyname := "13"
	Gosub,SetKeyGui
	_vkey := 0x34
	_keyname := "14"
	Gosub,SetKeyGui
	_vkey := 0x35
	_keyname := "15"
	Gosub,SetKeyGui
	_vkey := 0x36
	_keyname := "16"
	Gosub,SetKeyGui
	_vkey := 0x37
	_keyname := "17"
	Gosub,SetKeyGui
	_vkey := 0x38
	_keyname := "18"
	Gosub,SetKeyGui
	_vkey := 0x39
	_keyname := "19"
	Gosub,SetKeyGui
	_vkey := 0x30
	_keyname := "110"
	Gosub,SetKeyGui
	_vkey := 0xBD			;-
	_keyname := "111"
	Gosub,SetKeyGui
	_vkey := 0xDE			;^
	_keyname := "112"
	Gosub,SetKeyGui
	_vkey := 0xDC			;\
	_keyname := "113"
	Gosub,SetKeyGui

	_vkey := 0x51			;q
	_keyname := "21"
	Gosub,SetKeyGui
	_vkey := 0x57			;w
	_keyname := "22"
	Gosub,SetKeyGui
	_vkey := 0x45			;e
	_keyname := "23"
	Gosub,SetKeyGui
	_vkey := 0x52			;r
	_keyname := "24"
	Gosub,SetKeyGui
	_vkey := 0x54			;t
	_keyname := "25"
	Gosub,SetKeyGui
	_vkey := 0x59			;y
	_keyname := "26"
	Gosub,SetKeyGui
	_vkey := 0x55			;u
	_keyname := "27"
	Gosub,SetKeyGui
	_vkey := 0x49			;i
	_keyname := "28"
	Gosub,SetKeyGui
	_vkey := 0x4F			;o
	_keyname := "29"
	Gosub,SetKeyGui
	_vkey := 0x50			;p
	_keyname := "210"
	Gosub,SetKeyGui
	_vkey := 0xC0			;@
	_keyname := "211"
	Gosub,SetKeyGui
	_vkey := 0xDB			;[
	_keyname := "212"
	Gosub,SetKeyGui

	critical,off
	return

SetKeyGui:
	stCurr := DllCall("GetKeyState", "UInt", _vkey) & 128
	if(stCurr != 0) 
	{
		_ch := "　"
	}
	else
	{
		_ch := "■"
	}
	if(_ch != vkeyD%_keyname%)
	{
		GuiControl,,vkeyX%_keyname%,%_ch%
	}
	vkeyD%_keyname% := _ch
	return

ReadKeyState2:
	Critical
	_key := "1"
	_keyname := "11"
	Gosub,SetKeyGuiX
	_key := "2"
	_keyname := "12"
	Gosub,SetKeyGuiX
	_key := "3"
	_keyname := "13"
	Gosub,SetKeyGuiX
	_key := "4"
	_keyname := "14"
	Gosub,SetKeyGuiX
	_key := "5"
	_keyname := "15"
	Gosub,SetKeyGuiX
	_key := "6"
	_keyname := "16"
	Gosub,SetKeyGuiX
	_key := "7"
	_keyname := "17"
	Gosub,SetKeyGuiX
	_key := "8"
	_keyname := "18"
	Gosub,SetKeyGuiX
	_key := "9"
	_keyname := "19"
	Gosub,SetKeyGuiX
	_key := "0"
	_keyname := "110"
	Gosub,SetKeyGuiX
	_key := "-"			;-
	_keyname := "111"
	Gosub,SetKeyGuiX
	_key := "^"			;^
	_keyname := "112"
	Gosub,SetKeyGuiX
	_key := "\"			;\
	_keyname := "113"
	Gosub,SetKeyGuiX

	_key := "q"			;q
	_keyname := "21"
	Gosub,SetKeyGuiX
	_key := "w"			;w
	_keyname := "22"
	Gosub,SetKeyGuiX
	_key := "e"			;e
	_keyname := "23"
	Gosub,SetKeyGuiX
	_key := "r"			;r
	_keyname := "24"
	Gosub,SetKeyGuiX
	_key := "t"			;t
	_keyname := "25"
	Gosub,SetKeyGuiX
	_key := "y"			;y
	_keyname := "26"
	Gosub,SetKeyGuiX
	_key := "u"			;u
	_keyname := "27"
	Gosub,SetKeyGuiX
	_key := "i"			;i
	_keyname := "28"
	Gosub,SetKeyGuiX
	_key := "o"			;o
	_keyname := "29"
	Gosub,SetKeyGuiX
	_key := "p"			;p
	_keyname := "210"
	Gosub,SetKeyGuiX
	_key := "@"			;@
	_keyname := "211"
	Gosub,SetKeyGuiX
	_key := "["			;[
	_keyname := "212"
	Gosub,SetKeyGuiX
	critical,off
	return

SetKeyGuiX:
	stCurr := GetKeyState(_key)
	if(stCurr != 0) 
	{
		_ch := "・"
	}
	else
	{
		_ch := "■"
	}
	if(_ch != vkeyD%_keyname%)
	{
		GuiControl,,vkeyX%_keyname%,%_ch%
	}
	vkeyD%_keyname% := _ch
	return

ReadKeyState3:
	_keyname := "11"
	Gosub,SetKeyGui3
	_keyname := "12"
	Gosub,SetKeyGui3
	_keyname := "13"
	Gosub,SetKeyGui3
	_keyname := "14"
	Gosub,SetKeyGui3
	_keyname := "15"
	Gosub,SetKeyGui3
	_keyname := "16"
	Gosub,SetKeyGui3
	_keyname := "17"
	Gosub,SetKeyGui3
	_keyname := "18"
	Gosub,SetKeyGui3
	_keyname := "19"
	Gosub,SetKeyGui3
	_keyname := "110"
	Gosub,SetKeyGui3
	_keyname := "111"
	Gosub,SetKeyGui3
	_keyname := "112"
	Gosub,SetKeyGui3
	_keyname := "113"
	Gosub,SetKeyGui3
	
	_keyname := "21"
	Gosub,SetKeyGui3
	_keyname := "22"
	Gosub,SetKeyGui3
	_keyname := "23"
	Gosub,SetKeyGui3
	_keyname := "24"
	Gosub,SetKeyGui3
	_keyname := "25"
	Gosub,SetKeyGui3
	_keyname := "26"
	Gosub,SetKeyGui3
	_keyname := "27"
	Gosub,SetKeyGui3
	_keyname := "28"
	Gosub,SetKeyGui3
	_keyname := "29"
	Gosub,SetKeyGui3
	_keyname := "210"
	Gosub,SetKeyGui3
	_keyname := "211"
	Gosub,SetKeyGui3
	_keyname := "212"
	Gosub,SetKeyGui3

	_keyname := "31"
	Gosub,SetKeyGui3
	_keyname := "32"
	Gosub,SetKeyGui3
	_keyname := "33"
	Gosub,SetKeyGui3
	_keyname := "34"
	Gosub,SetKeyGui3
	_keyname := "35"
	Gosub,SetKeyGui3
	_keyname := "36"
	Gosub,SetKeyGui3
	_keyname := "37"
	Gosub,SetKeyGui3
	_keyname := "38"
	Gosub,SetKeyGui3
	_keyname := "39"
	Gosub,SetKeyGui3
	_keyname := "310"
	Gosub,SetKeyGui3
	_keyname := "311"
	Gosub,SetKeyGui3
	_keyname := "312"
	Gosub,SetKeyGui3
	
	_keyname := "41"
	Gosub,SetKeyGui3
	_keyname := "42"
	Gosub,SetKeyGui3
	_keyname := "43"
	Gosub,SetKeyGui3
	_keyname := "44"
	Gosub,SetKeyGui3
	_keyname := "45"
	Gosub,SetKeyGui3
	_keyname := "46"
	Gosub,SetKeyGui3
	_keyname := "47"
	Gosub,SetKeyGui3
	_keyname := "48"
	Gosub,SetKeyGui3
	_keyname := "49"
	Gosub,SetKeyGui3
	_keyname := "410"
	Gosub,SetKeyGui3
	_keyname := "411"
	Gosub,SetKeyGui3
	return

SetKeyGui3:
	if(vkeyD%_keyname% != vkeyE%_keyname%) 
	{
		_ch := vkeyD%_keyname%
		GuiControl,,vkeyX%_keyname%,%_ch%
		vkeyE%_keyname% := _ch
	}
	return

ReadKeyboardState:
	Critical

	VarSetCapacity(stKtbl, cbSize:=256, 0)
	NumPut(cbSize, stKtbl,  0, "UChar")   ;   DWORD   cbSize;	
	stCurr := DllCall("GetKeyboardState", "UPtr", &stKtbl)
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
	_vkey := 0x59			;w
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
	critical,off
	return

SetKeyGui2:
	if((NumGet(stKtbl,_vkey,"UChar") & 0x80)!= 0) 
	{
		_ch := "・"
	}
	else
	{
		_ch := "■"
	}
	if(_ch != vkeyD%_keyname%)
	{
		GuiControl,,vkeyX%_keyname%,%_ch%
	}
	vkeyD%_keyname% := _ch
	return

