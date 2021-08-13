		hotkey,*sc02D,gSC02D		;x
		hotkey,*sc02D up,gSC02Dup		
		hotkey,*sc02D,on
		hotkey,*sc02D up,on

		hotkey,*sc002,gSC002		;1
		hotkey,*sc002 up,gSC002up	
		hotkey,*sc002,on
		hotkey,*sc002 up,on

		hotkey,*sc003,gSC003		;2
		hotkey,*sc003 up,gSC003up	
		hotkey,*sc003,on
		hotkey,*sc003 up,on

		hotkey,*sc004,gSC004		;3
		hotkey,*sc004 up,gSC004up	
		hotkey,*sc004,on
		hotkey,*sc004 up,on

		hotkey,*sc01D,gSC01D
		hotkey,*sc01D up,gSC01Dup
		hotkey,*sc01D,on
		hotkey,*sc01D up,on

		hotkey,*sc15B,gSC15B		;x
		hotkey,*sc15B up,gSC15Bup		
		hotkey,*sc15B,on
		hotkey,*sc15B up,on
				
		hotkey,*sc15B,off
		hotkey,*sc15B up,off
		
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


gSC15B:
	send,{lwin down}
	return

gSC15Bup:
	send,{lwin up}
	return
	
gSC01D:
	send,{lCtrl down}
	return

gSC01Dup:
	send,{lCtrl up}
	return

gSC02D:
	send,{blind}{a down}
	return

gSC02Dup:
	send,{blind}{a up}
	return

gSC002:
	send,{LCtrl up}
	send,{a down}
	send,{LCtrl down}
	return

gSC003:
	send,{LCtrl up}
	send,{blind}{a down}
	send,{LCtrl down}
	return

gSC004:
	send,{a down}
	return

gSC002up:
gSC003up:
gSC004up:
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
	;Tooltip, %_nlock%%_clock% %_lShift%%_rShift%:%tmpKey%:%_tmp2L%%_tmp2R%, 0, 0, 2 ; debug
	ControlGetFocus, OutputVar, A
	WinGetClass, MyClass, A
	ret := WinExist("ahk_class " . "#32768")
	Tooltip, %OutputVar% %MyClass% %ret%, 0, 0, 2 ; debug
	return
