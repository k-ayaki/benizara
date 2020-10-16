#include IME.ahk
  msgbox %A_OSVersion%
 
  a := "ー"
  val := Asc(a)
  msgbox %val%
  
  
  b := Get_reg_Keyboard_Layouts()
  msgbox Get_reg_Keyboard_Layouts %b%

  b := Get_Layout_Text()
  msgbox Get_Layout_Text %b%
  
 