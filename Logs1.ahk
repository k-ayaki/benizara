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
		;msgbox, 既に紅皿ログ・ダイアログは開いています。
		WinActivate,紅皿ログ
		return
	}
	Gui,3:Default	
	Gui, 3:New
	Gui, Font,s9 c000000
	Gui, Add, Button,ggButtonSave  X343 Y666 W77 H22,ログ保存
	Gui, Add, Button,ggButtonClose X431 Y666 W77 H22,閉じる
	Gui, Show, W547 H700, 紅皿ログ
	Gui, Font,s9 c000000,ＭＳ ゴシック
	Gui, Add, Text,X30 Y10,TIME   INPUT  MD  EV  SEND
	loop, 64
	{
		_yaxis := A_Index*10 + 10
		_disp := "_                                                               _                                                               "
		Gui, Add, Text,vdisp%A_Index% X30 Y%_yaxis%, %_disp%
	}
	SetTimer,LogRedraw,100
	return


LogRedraw:
	loop, 64
	{
		_idx := (idxLogs - aLogCnt + A_Index - 1) & 63
		_disp := aLog%_idx% . "                                                                _                                                               "
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
		file.WriteLine("オーバラップ文字親指=" . g_OverlapMO . "`r")
		file.WriteLine("オーバラップ親指文字=" . g_OverlapOM . "`r")
		file.WriteLine("オーバラップ文字同時=" . g_OverlapSS . "`r")
		file.WriteLine("親指シフト同時打鍵間隔=" . g_Threshold . "`r")
		file.WriteLine("文字同時打鍵間隔=" . g_ThresholdSS . "`r")
		file.WriteLine("連続モード=" . g_Continue . "`r")
		file.WriteLine("零遅延モード=" . g_ZeroDelay . "`r")
		file.WriteLine("親指キー単独打鍵=" . g_KeySingle . "`r")
		file.WriteLine("親指キーリピート=" . g_KeyRepeat . "`r")
		file.WriteLine("TIME   INPUT  MD TG SEND`r")
		loop, 64
		{
			_idx := (idxLogs - aLogCnt + A_Index - 1) & 63
			file.WriteLine(aLog%_idx% . "`r")
		}
		file.close()
	}
	SetTimer LogRedraw,Off
	Gui,Destroy
	Goto,Logs

;-----------------------------------------------------------------------
; 機能：閉じるボタンの押下
;-----------------------------------------------------------------------
gButtonClose:
	SetTimer LogRedraw,Off
	Gui,Destroy
	return
