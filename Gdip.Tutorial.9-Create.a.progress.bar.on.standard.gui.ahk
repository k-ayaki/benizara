; gdi+ ahk tutorial 9 written by tic (Tariq Porter)
; Requires Gdip.ahk either in your Lib folder as standard library or using #Include
;
; Example to create a progress bar in a standard gui

#SingleInstance, Force
#NoEnv
SetBatchLines, -1

; Uncomment if Gdip.ahk is not in your standard library
#Include, Gdip.ahk

; Start gdi+
If !pToken := Gdip_Startup()
{
	MsgBox, 48, gdiplus error!, Gdiplus failed to start. Please ensure you have gdiplus on your system
	ExitApp
}
OnExit, Exit

; Before we start there are some design elements we must consider.
; We can either make the script faster. Creating the bitmap 1st and just write the new progress bar onto it every time and updating it on the gui
; and dispose it all at the end/ This will use more RAM
; Or we can create the entire bitmap and write the information to it, display it and then delete it after every occurence
; This will be slower, but will use less RAM and will be modular (can all be put into a function)
; I will go with the 2nd option, but if more speed is a requirement then choose the 1st

;Gui, 1: -DPIScale
; I am first creating a slider, just as a way to change the percentage on the progress bar
Gui, 1: Add, Slider, x10 y10 w400 Range0-100 vPercentage gSlider Tooltip, 50

; The progress bar needs to be added as a picture, as all we are doing is creating a gdi+ bitmap and setting it to this control
; Note we have set the 0xE style for it to accept an hBitmap later and also set a variable in order to reference it (could also use hwnd)
Gui, 1: Add, Picture, x10 y+30 w44 h44 0xE vKeyRectangle
; We will set the initial image on the control before showing the gui
GoSub, Slider
Gui, 1: Show, AutoSize, Example 9 - gdi+ progress bar
Return

;#######################################################################

; This subroutine is activated every time we move the slider as I used gSlider in the options of the slider
Slider:
Gui, 1: Default
Gui, 1: Submit, NoHide
Gui, 1: -DPIScale
if (mod(Percentage,2) ==0)
{
	Gdip_KeyRect(KeyRectangle, 0xffFFC3E1, 0xff000000, "と","ら","し", "げ", 0)
} else {
	Gdip_KeyRect(KeyRectangle, 0xffFFB3D1, 0xff000000, "と","ら","し", "げ", 1)
}
Gui, 1: +DPIScale
Return


;#######################################################################

Gdip_KeyRect(ByRef keyRectangle, Foreground, Background=0x00000000, TextLU="", TextRU="", TextLD="", TextRD="", pushed=0)
{
	GuiControlGet, Pos, Pos, keyRectangle
	GuiControlGet, hwnd, hwnd, keyRectangle
	pBrushFront := Gdip_BrushCreateSolid(Foreground)
	pBrushBack := Gdip_BrushCreateSolid(Background)
	pBitmap := Gdip_CreateBitmap(Posw, Posh)
	G := Gdip_GraphicsFromImage(pBitmap)
	Gdip_SetSmoothingMode(G, 4)
	
	Gdip_FillRectangle(G, pBrushBack, 0, 0, Posw, Posh)
	if(pushed == 0)
	{
		Gdip_FillRoundedRectangle(G, pBrushFront, 2, 2, (Posw-4), Posh-4, 3)
	} else {
		Gdip_FillRoundedRectangle(G, pBrushFront, 4, 4, (Posw-8), Posh-8, 3)
	}
	Gdip_TextToGraphics(G, TextLU, "x10p y6p s31p left cff000000 r4", "Yu Gothic UI", Posw, Posh)
	Gdip_TextToGraphics(G, TextRU, "x50p y6p s31p left cff000000 r4", "Yu Gothic UI", Posw, Posh)
	Gdip_TextToGraphics(G, TextLD, "x10p y50p s31p left cff000000 r4", "Yu Gothic UI", Posw, Posh)
	Gdip_TextToGraphics(G, TextRD, "x50p y50p s31p left cff000000 r4", "Yu Gothic UI", Posw, Posh)
	
	hBitmap := Gdip_CreateHBITMAPFromBitmap(pBitmap)
	SetImage(hwnd, hBitmap)
	Gdip_DeleteBrush(pBrushFront), Gdip_DeleteBrush(pBrushBack)
	Gdip_DeleteGraphics(G)
	Gdip_DisposeImage(pBitmap)
	DeleteObject(hBitmap)
	Return, 0
}

;#######################################################################

GuiClose:
Exit:
; gdi+ may now be shutdown
Gdip_Shutdown(pToken)
ExitApp
Return
