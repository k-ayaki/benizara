;-----------------------------------------------------------------------
;	名称：Logs1.ahk
;	機能：紅皿のログ表示
;	ver.0.1.3.1 .... 2019/3/17
;-----------------------------------------------------------------------
;-----------------------------------------------------------------------
; 機能：ログダイアログの表示
;-----------------------------------------------------------------------
Logs:
	IfWinExist,紅皿ログ
	{
		msgbox, 既に紅皿ログ・ダイアログは開いています。
		return
	}
	Gui,3:Default	
	Gui, 3:New
	Gui, Font,s9 c000000
	Gui, Add, Button,ggButtonSave  X343 Y766 W77 H22,ログ保存
	Gui, Add, Button,ggButtonClose X431 Y766 W77 H22,閉じる
	Gui, Show, W547 H800, 紅皿ログ
	Gui, Font,s10 c000000,ＭＳ ゴシック
	Gui, Add, Text,X30 Y10,TIME   INPUT  MD SEND
	loop, 64
	{
		_yaxis := A_Index*11 + 16
		_disp := "_                                                               "
		Gui, Add, Text,vdisp%A_Index% X30 Y%_yaxis%, %_disp%
	}
	SetTimer LogRedraw,100
	return

	loop
	{
        IfWinNotExist, 紅皿ログ
        {
            Gui, 3:Destroy
            return
        }
		loop, 64
		{
			_idx := (idxLogs - aLogCnt + A_Index - 1) & 63
			_disp := aLog%_idx% . "                                                                "
			GuiControl,,disp%A_Index%, %_disp%
		}
        Sleep,500
	}
	return

LogRedraw:
	loop, 64
	{
		_idx := (idxLogs - aLogCnt + A_Index - 1) & 63
		_disp := aLog%_idx% . "                                                                "
		GuiControl,3:,disp%A_Index%, %_disp%
	}
	return

;-----------------------------------------------------------------------
; 機能：ログ保存ボタンの押下
;-----------------------------------------------------------------------
gButtonSave:
	SetWorkingDir, %A_ScriptDir%
	FileSelectFile, vLogFileAbs,0,.\%A_Now%.log,,Log File (*.log)
	
	if vLogFileAbs<>
	{
		file := FileOpen(vLogFileAbs, "w")
		file.WriteLine(g_Ver . "`r`n")
		file.WriteLine("オーバラップ=" . g_Overlap . "`r`n")
		file.WriteLine("同時打鍵間隔=" . g_Threshold . "`r`n")
		file.WriteLine("連続モード=" . g_Continue . "`r`n")
		file.WriteLine("零遅延モード=" . g_ZeroDelay . "`r`n")
		file.WriteLine("親指キー単独打鍵=" . g_KeySingle . "`r`n")
		file.WriteLine("親指キーリピート=" . g_KeyRepeat . "`r`n")
		file.WriteLine("TIME   INPUT  MD SEND`r`n")
		loop, 64
		{
			_idx := (idxLogs - aLogCnt + A_Index - 1) & 63
			file.WriteLine(aLog%_idx% . "`r`n")
		}
		file.close()
	}
	Gui,3:Destroy
	Goto,Logs

;-----------------------------------------------------------------------
; 機能：閉じるボタンの押下
;-----------------------------------------------------------------------
gButtonClose:
	Gui,3:Destroy
	return
