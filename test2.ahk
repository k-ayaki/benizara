		hotkey,*vk060,gVK060		;LShift
		hotkey,*vk060 up,gVK060up		
		hotkey,*vk060,on
		hotkey,*vk060 up,on
		hotkey,*vk02D,gVK02D		;LShift
		hotkey,*vk02D up,gVK02Dup		
		hotkey,*vk02D,on
		hotkey,*vk02D up,on
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


gVK060:
	send,{blind}{a down}
	return

gVK060up:
	send,{blind}{a up}
	return

gVK02D:
	send,{blind}{b down}
	return

gVK02Dup:
	send,{blind}{b up}
	return


;----------------------------------------------------------------------
; 10[mSEC]ごとの割込処理
;----------------------------------------------------------------------
Interrupt10:
	;_tmpL := DllCall("GetKeyState", "UInt", 0x1D)
	;_tmpR := DllCall("GetKeyState", "UInt", 0x1C)
	_tmpL := GetKeyState("vkA0","P")
	_tmpR := GetKeyState("vkA1","P")
	_nlock := GetKeyState("NumLock", "T") 
	_clock := GetKeyState("CapsLock", "T") 
	_tmp2L := DllCall("GetAsyncKeyState", "UInt", 0xA0)
	_tmp2R := DllCall("GetAsyncKeyState", "UInt", 0xA1)
	tmpKey := _tmpL . _tmpR
	;vImeMode := IME_GET() & 32767
	;vImeConvMode :=IME_GetConvMode()
	Tooltip, %_nlock%%_clock% %_lShift%%_rShift%:%tmpKey%:%_tmp2L%%_tmp2R%, 0, 0, 2 ; debug
	return
