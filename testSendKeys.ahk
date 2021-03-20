		hotkey,*Backspace,gSC01E		;a
		hotkey,*Backspace up,gSC01Eup
		return

gSC01E:
	msgbox, % "this hotkey is " . A_thishotkey
	Return

gSC01Eup:
	msgbox, % "up ! this hotkey is " . A_thishotkey
	Return


b::
	msgbox, % "this hotkey is " . A_thishotkey
	Return

+b up::
	msgbox, % "up ! this hotkey is " . A_thishotkey
	Return
