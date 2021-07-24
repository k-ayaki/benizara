		hotkey,*sc02A,gSC02A		;LShift
		hotkey,*sc02A up,gSC02Aup		
		hotkey,*sc02A,on
		hotkey,*sc02A up,on
		;hotkey,*sc136,gSC136		;RShift
		;hotkey,*sc136 up,gSC136up
		;hotkey,*sc136,off
		;hotkey,*sc136 up,off

		;hotkey,Backspace,gBACKSPACE	; \b
		;hotkey,+Backspace,gBACKSPACE	; \b
		;hotkey,Backspace up,gBACKSPACEup
		;hotkey,+Backspace up,gBACKSPACEup
		SetTimer,Interrupt10,10		
		tmpKey := ""
		_lShift := 0
		_rShift := 0
		;IME_Set(1)
		;IME_SetConvMode(25)	
		return
#include IME.ahk


b::
	if(_lShift==1) {
		send,^{sc01D}
	} else {
		send,{blind}^{a}
	}
	return

gSC02A:
	_lShift := 1
	return

gSC02Aup:
	_lShift := 0
	return

gSC136:
	_rShift := 1
	return
	
gSC136up:
	_rShift := 0
	return

;----------------------------------------------------------------------
; 10[mSEC]ごとの割込処理
;----------------------------------------------------------------------
Interrupt10:
	;_tmpL := DllCall("GetKeyState", "UInt", 0x1D)
	;_tmpR := DllCall("GetKeyState", "UInt", 0x1C)
	_tmpL := GetKeyState("vkA0","P")
	_tmpR := GetKeyState("vkA1","P")
	_tmp2L := DllCall("GetAsyncKeyState", "UInt", 0xA0)
	_tmp2R := DllCall("GetAsyncKeyState", "UInt", 0xA1)
	tmpKey := _tmpL . _tmpR
	;vImeMode := IME_GET() & 32767
	;vImeConvMode :=IME_GetConvMode()
	Tooltip, %_lShift%%_rShift%:%tmpKey%:%_tmp2L%%_tmp2R%, 0, 0, 2 ; debug
	return
