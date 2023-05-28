;*****************************************************************************
;  高精度タイマー関数群 (PfCount.ahk)
;
;	グローバル変数 : TickFrequency, Ticks0
;	使い方：Pf_Init()を呼び出したのちに Pf_Count() を呼び出す
;   AutoHotkey:     L 1.1.29.01
;    Language:       Japanease
;    Platform:       NT系
;    Author:         Kenichiro Ayaki
;*****************************************************************************


;-----------------------------------------------------------
; Performance Counterの初期化
;   戻り値          1:成功 / 0:失敗
;-----------------------------------------------------------
Pf_Init()
{
	global TickFrequency, global Ticks0
	TickFrequency := 0, Ticks0 := 0
	ret := DllCall("QueryPerformanceFrequency","Int64*",TickFrequency) ;obtain ticks per second
	if(ret)
	{
		ret := DllCall("QueryPerformanceCounter","Int64*",Ticks0) ;obtain the performance counter value
	}
	
	if(!ret)
	{
		TickFrequency := 0, Ticks0 := 0
	}
	return ret
}
;-----------------------------------------------------------
; Performance Counterによる起動後の経過時間（ミリ秒）
;   戻り値	0以外 起動後の経過時間 / 0:失敗
;-----------------------------------------------------------
Pf_Count()
{
	global TickFrequency, global Ticks0
	if(TickFrequency = 0)
	{
		return A_Tickcount
	}

	Ticks1 := 0
	If !DllCall("QueryPerformanceCounter","Int64*",Ticks1) ;obtain the performance counter value
	{
		return 0
	}
	myTick := (Ticks1 - Ticks0)*1000.0/TickFrequency
	iTick := Floor(myTick)
	return iTick
}
