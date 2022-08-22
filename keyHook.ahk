;-----------------------------------------------------------------------
;	名称：keyHook.ahk
;	機能：キーフック
;	作者：Ken'ichiro Ayaki
;-----------------------------------------------------------------------


;----------------------------------------------------------------------
; キーを押下されたときに呼び出されるGotoラベルにフックする
;----------------------------------------------------------------------
SetHotkeyInit()
{
	SetHotkeyInitByPos("H01")	;NumpadDiv
	SetHotkeyInitByPos("H02")	;NumpadMult
	SetHotkeyInitByPos("H03")	;NumpadAdd
	SetHotkeyInitByPos("H04")	;NumpadSub
	SetHotkeyInitByPos("H05")	;NumpadEnter
	SetHotkeyInitByPos("H06")	;Numpad0
	SetHotkeyInitByPos("H07")	;Numpad1
	SetHotkeyInitByPos("H08")	;Numpad2
	SetHotkeyInitByPos("H09")	;Numpad3
	SetHotkeyInitByPos("H10")	;Numpad4
	SetHotkeyInitByPos("H11")	;Numpad5
	SetHotkeyInitByPos("H12")	;Numpad6
	SetHotkeyInitByPos("H13")	;Numpad7
	SetHotkeyInitByPos("H14")	;Numpad8
	SetHotkeyInitByPos("H15")	;Numpad9
	SetHotkeyInitByPos("H16")	;NumpadDot

	SetHotkeyInitByPos("G01")	;PrintScreen
	SetHotkeyInitByPos("G02")	;ScrollLock
	SetHotkeyInitByPos("G03")	;Pause
	SetHotkeyInitByPos("G04")	;Insert
	SetHotkeyInitByPos("G05")	;Home
	SetHotkeyInitByPos("G06")	;PgUp
	SetHotkeyInitByPos("G07")	;Delete
	SetHotkeyInitByPos("G08")	;End
	SetHotkeyInitByPos("G09")	;PgDn
	SetHotkeyInitByPos("G10")	;Up
	SetHotkeyInitByPos("G11")	;Left
	SetHotkeyInitByPos("G12")	;Down
	SetHotkeyInitByPos("G13")	;Right

	SetHotkeyInitByPos("F00")	;Esc
	SetHotkeyInitByPos("F01")	;F1
	SetHotkeyInitByPos("F02")	;F2
	SetHotkeyInitByPos("F03")	;F3
	SetHotkeyInitByPos("F04")	;F4
	SetHotkeyInitByPos("F05")	;F5
	SetHotkeyInitByPos("F06")	;F6
	SetHotkeyInitByPos("F07")	;F7
	SetHotkeyInitByPos("F08")	;F8
	SetHotkeyInitByPos("F09")	;F9
	SetHotkeyInitByPos("F10")	;F10
	SetHotkeyInitByPos("F11")	;F11
	SetHotkeyInitByPos("F12")	;F12

	SetHotkeyInitByPos("E00")	;半角／全角
	SetHotkeyInitByPos("E01")	;1
	SetHotkeyInitByPos("E02")	;2
	SetHotkeyInitByPos("E03")	;3
	SetHotkeyInitByPos("E04")	;4
	SetHotkeyInitByPos("E05")	;5
	SetHotkeyInitByPos("E06")	;6
	SetHotkeyInitByPos("E07")	;7
	SetHotkeyInitByPos("E08")	;8
	SetHotkeyInitByPos("E09")	;9
	SetHotkeyInitByPos("E10")	;0
	SetHotkeyInitByPos("E11")	;-
	SetHotkeyInitByPos("E12")	;^
	SetHotkeyInitByPos("E13")	;\
	SetHotkeyInitByPos("E14")	;\b
	
	SetHotkeyInitByPos("D00")	;\t
	SetHotkeyInitByPos("D01")	;q
	SetHotkeyInitByPos("D02")	;w
	SetHotkeyInitByPos("D03")	;e
	SetHotkeyInitByPos("D04")	;r
	SetHotkeyInitByPos("D05")	;t
	SetHotkeyInitByPos("D06")	;y
	SetHotkeyInitByPos("D07")	;u
	SetHotkeyInitByPos("D08")	;i
	SetHotkeyInitByPos("D09")	;o
	SetHotkeyInitByPos("D10")	;p
	SetHotkeyInitByPos("D11")	;@
	SetHotkeyInitByPos("D12")	;[

	SetHotkeyInitByPos("C01")	;a
	SetHotkeyInitByPos("C02")	;s
	SetHotkeyInitByPos("C03")	;d
	SetHotkeyInitByPos("C04")	;f
	SetHotkeyInitByPos("C05")	;g
	SetHotkeyInitByPos("C06")	;h
	SetHotkeyInitByPos("C07")	;j
	SetHotkeyInitByPos("C08") 	;k
	SetHotkeyInitByPos("C09") 	;l
	SetHotkeyInitByPos("C10")	;';'
	SetHotkeyInitByPos("C11")	;'*'
	SetHotkeyInitByPos("C12")	;']'
	SetHotkeyInitByPos("C13")	;\r
	
	SetHotkeyInitByPos("B01")	;z
	SetHotkeyInitByPos("B02")	;x
	SetHotkeyInitByPos("B03")	;c
	SetHotkeyInitByPos("B04")	;v
	SetHotkeyInitByPos("B05")	;b
	SetHotkeyInitByPos("B06")	;n
	SetHotkeyInitByPos("B07")	;m
	SetHotkeyInitByPos("B08")	;,
	SetHotkeyInitByPos("B09")	;.
	SetHotkeyInitByPos("B10")	;/
	SetHotkeyInitByPos("B11")	;\
	;-----------------------------------------------------------------------
	; 機能：モディファイアキー
	;-----------------------------------------------------------------------
	;WindowsキーとAltキーをホットキー登録すると、
	;WindowsキーやAltキーの単体押しが効かなくなるのでコメントアウトする。
	;代わりにInterrupt10 でA_Priorkeyを見て、Windowsキーを監視する。
	;但し、WindowsキーやAltキーを離したことを感知できないことに留意。
	;ver.0.1.3 にて、GetKeyState でWindowsキーとAltキーとを監視
	;ver.0.1.3.7 ... Ctrlはやはり必要なので戻す
	SetHotkeyInitByPos("A00")	;LCtrl
	SetHotkeyInitByPos("A01")	;無変換
	SetHotkeyInitByPos("A02")	;Space
	SetHotkeyInitByPos("A03")	;変換
	SetHotkeyInitByPos("A04")	;ひらがな／カタカナ
	SetHotkeyInitByPos("A05")	;RCtrl
	SetHotkeyInitByPos("A06")	;左Shift
	SetHotkeyInitByPos("A07")	;左Win
	SetHotkeyInitByPos("A08")	;左Alt
	SetHotkeyInitByPos("A09")	;右Alt
	SetHotkeyInitByPos("A10")	;右Win
	SetHotkeyInitByPos("A11")	;Applications
	SetHotkeyInitByPos("A12")	;右Shift
	return
}
;----------------------------------------------------------------------
; 一つのキーを初期化する
;----------------------------------------------------------------------
SetHotkeyInitByPos(_pos)
{
	global
	local _sCode
	
	_sCode := ScanCodeHash[_pos]
	if(_sCode != "") {
		keyHook[_pos] := "off"
		hotkey,*%_sCode%,g%_sCode%
		hotkey,*%_sCode%,off
		hotkey,*%_sCode% up,g%_sCode%up
		hotkey,*%_sCode% up,off
	}
}
;----------------------------------------------------------------------
; ファンクションキーをオン・オフする
;----------------------------------------------------------------------
SetHotkeyFunction(flg)
{
	SetHotkeyFunctionByName("Esc", flg)
	SetHotkeyFunctionByName("F1", flg)
	SetHotkeyFunctionByName("F2", flg)
	SetHotkeyFunctionByName("F3", flg)
	SetHotkeyFunctionByName("F4", flg)
	SetHotkeyFunctionByName("F5", flg)
	SetHotkeyFunctionByName("F6", flg)
	SetHotkeyFunctionByName("F7", flg)
	SetHotkeyFunctionByName("F8", flg)
	SetHotkeyFunctionByName("F9", flg)
	SetHotkeyFunctionByName("F10", flg)
	SetHotkeyFunctionByName("F11", flg)
	SetHotkeyFunctionByName("F12", flg)

	SetHotkeyFunctionByName("半角/全角", flg)

	SetHotkeyFunctionByName("左Ctrl", flg)
	SetHotkeyFunctionByName("無変換", flg)
	SetHotkeyFunctionByName("Space", flg)
	SetHotkeyFunctionByName("変換", flg)
	SetHotkeyFunctionByName("カタカナ/ひらがな", flg)
	SetHotkeyFunctionByName("右Ctrl", flg)

	SetHotkeyFunctionByName("左Shift", flg)
	SetHotkeyFunctionByName("右Shift", flg)

	SetHotkeyFunctionByName("左Win", flg)
	SetHotkeyFunctionByName("左Alt", flg)
	SetHotkeyFunctionByName("右Alt", flg)
	SetHotkeyFunctionByName("右Win", flg)
	SetHotkeyFunctionByName("Applications", flg)

	SetHotkeyFunctionByName("PrintScreen", flg)
	SetHotkeyFunctionByName("ScrollLock", flg)
	SetHotkeyFunctionByName("Pause", flg)
	SetHotkeyFunctionByName("Insert", flg)
	SetHotkeyFunctionByName("Home", flg)
	SetHotkeyFunctionByName("PageUp", flg)
	SetHotkeyFunctionByName("Delete", flg)
	SetHotkeyFunctionByName("End", flg)
	SetHotkeyFunctionByName("PageDown", flg)
	SetHotkeyFunctionByName("上", flg)
	SetHotkeyFunctionByName("左", flg)
	SetHotkeyFunctionByName("右", flg)
	SetHotkeyFunctionByName("下", flg)

	SetHotkeyFunctionByName("Tab", flg)
	SetHotkeyFunctionByName("Enter", flg)
}
;----------------------------------------------------------------------
; テンキーをオン・オフする
;----------------------------------------------------------------------
SetHotkeyNumpad(flg)
{
	SetHotkeyFunctionByName("NumpadDiv", flg)
	SetHotkeyFunctionByName("NumpadMult", flg)
	SetHotkeyFunctionByName("NumpadAdd", flg)
	SetHotkeyFunctionByName("NumpadSub", flg)
	SetHotkeyFunctionByName("HNumpadEnter", flg)
	SetHotkeyFunctionByName("Numpad0", flg)
	SetHotkeyFunctionByName("Numpad1", flg)
	SetHotkeyFunctionByName("Numpad2", flg)
	SetHotkeyFunctionByName("Numpad3", flg)
	SetHotkeyFunctionByName("Numpad4", flg)
	SetHotkeyFunctionByName("Numpad5", flg)
	SetHotkeyFunctionByName("Numpad6", flg)
	SetHotkeyFunctionByName("Numpad7", flg)
	SetHotkeyFunctionByName("Numpad8", flg)
	SetHotkeyFunctionByName("Numpad9", flg)
	SetHotkeyFunctionByName("NumpadDot", flg)
}

;----------------------------------------------------------------------
; 指定された名称のキーのHotkeyをオン・オフする
;----------------------------------------------------------------------
SetHotkeyFunctionByName(_kName, _flg)
{
	global
	local _pos, _sCode
	
	_pos := fkeyPosHash[_kName]
	_sCode := fkeyCodeHash[_kName]
	if(_pos=="" || _sCode=="")
	{
		return
	}
	if(keyAttribute3[g_Romaji . KoyubiOrSans(g_Koyubi,g_sans) . _pos]!="") {
		hotkey,*%_sCode%,%_flg%
		;if(kup_save[_pos]=="" || _sCode == "sc029")
		;{
			keyHook[_pos] := _flg
			hotkey,*%_sCode% up,%_flg%
		;}
	} else {
		hotkey,*%_sCode%,off
		;if(kup_save[_pos]=="" || _sCode == "sc029")
		;{
			keyHook[_pos] := "off"
			hotkey,*%_sCode% up,off
		;}
	}
}
;----------------------------------------------------------------------
; 動的にホットキーをオン・オフする
; flg : 文字キーと機能キー
;----------------------------------------------------------------------
SetHotkey(flg)
{
	global
	g_HotKey := flg
	SetHotkeyByPos("E01",flg)	;1
	SetHotkeyByPos("E02",flg)	;2
	SetHotkeyByPos("E03",flg)	;3
	SetHotkeyByPos("E04",flg)	;4
	SetHotkeyByPos("E05",flg)	;5
	SetHotkeyByPos("E06",flg)	;6
	SetHotkeyByPos("E07",flg)	;7
	SetHotkeyByPos("E08",flg)	;8
	SetHotkeyByPos("E09",flg)	;9
	SetHotkeyByPos("E10",flg)	;0
	SetHotkeyByPos("E11",flg)	;-
	SetHotkeyByPos("E12",flg)	;^
	SetHotkeyByPos("E13",flg)	;\
	SetHotkeyByPos("E14",flg)	;\b
	
	SetHotkeyByPos("D01",flg)	;q
	SetHotkeyByPos("D02",flg)	;w
	SetHotkeyByPos("D03",flg)	;e
	SetHotkeyByPos("D04",flg)	;r
	SetHotkeyByPos("D05",flg)	;t
	SetHotkeyByPos("D06",flg)	;y
	SetHotkeyByPos("D07",flg)	;u
	SetHotkeyByPos("D08",flg)	;i
	SetHotkeyByPos("D09",flg)	;o
	SetHotkeyByPos("D10",flg)	;p
	SetHotkeyByPos("D11",flg)	;@
	SetHotkeyByPos("D12",flg)	;[
	
	SetHotkeyByPos("C01",flg)	;a
	SetHotkeyByPos("C02",flg)	;s
	SetHotkeyByPos("C03",flg)	;d
	SetHotkeyByPos("C04",flg)	;f
	SetHotkeyByPos("C05",flg)	;g
	SetHotkeyByPos("C06",flg)	;h
	SetHotkeyByPos("C07",flg)	;j
	SetHotkeyByPos("C08",flg)	;k
	SetHotkeyByPos("C09",flg)	;l
	SetHotkeyByPos("C10",flg)	;';'
	SetHotkeyByPos("C11",flg)	;*
	SetHotkeyByPos("C12",flg)	;]
	
	SetHotkeyByPos("B01",flg)	;z
	SetHotkeyByPos("B02",flg)	;x
	SetHotkeyByPos("B03",flg)	;c
	SetHotkeyByPos("B04",flg)	;v
	SetHotkeyByPos("B05",flg)	;b
	SetHotkeyByPos("B06",flg)	;n
	SetHotkeyByPos("B07",flg)	;m
	SetHotkeyByPos("B08",flg)	;,
	SetHotkeyByPos("B09",flg)	;.
	SetHotkeyByPos("B10",flg)	;/
	SetHotkeyByPos("B11",flg)	;\
	return
}
;----------------------------------------------------------------------
; 動的にキーをオン・オフする
;----------------------------------------------------------------------
SetHotkeyByPos(_pos, _flg)
{
	global
	local _sCode
	
	_sCode := scanCodeHash[_pos]
	if(_pos=="" || _sCode=="") {
		return
	}
	if(keyAttribute3[g_Romaji . KoyubiOrSans(g_Koyubi,g_sans) . _pos]!="") {
		hotkey,*%_sCode%,%_flg%
		if(kup_save[_pos]=="")
		{
			keyHook[_pos] := _flg
			hotkey,*%_sCode% up,%_flg%
		}
	} else {
		hotkey,*%_sCode%,off
		if(kup_save[_pos]=="")
		{
			keyHook[_pos] := "off"
			hotkey,*%_sCode% up,off
		}
	}
}

