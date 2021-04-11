		hotkey,*sc07B,gSC07B		;
		hotkey,*sc07B up,gSC07Bup
		hotkey,*sc079,gSC079		;
		hotkey,*sc079 up,gSC079up
		hotkey,*sc07B,on
		hotkey,*sc07B up,on
		hotkey,*sc079,on
		hotkey,*sc079 up,on

		SetTimer,Interrupt10,10		
		return
#include IME.ahk

gSC07B:
gSC079:
	return
gSC07Bup:
gSC079up:
	return

1::
	return

;----------------------------------------------------------------------
; 10[mSEC]ごとの割込処理
;----------------------------------------------------------------------
Interrupt10:
	;_tmpL := DllCall("GetKeyState", "UInt", 0x1D)
	;_tmpR := DllCall("GetKeyState", "UInt", 0x1C)
	_tmpL := GetKeyState("vk1D","P")
	_tmpR := GetKeyState("vk1C","P")
	vImeMode := IME_GET() & 32767
	vImeConvMode :=IME_GetConvMode()
	Tooltip, %vImeMode% %vImeConvMode%, 0, 0, 2 ; debug
	return
