#include IME.ahk
StringCaseSense, On
	tmp := Object()
	tmp["A"] := "hello"
	tmp["a"] := "goodbye"
	tmp2 := tmp[0]
	
	;msgbox, % "tmp0 is " . tmp["A"]
	m := "MMm"
	if(m=="MMM") {
		msgbox, % "3m"
	} else if(m=="MMm") {
		msgbox, % "MMm"
	} else {
	}
	return

obj := Object("red", 0xFF0000, "blue", 0x0000FF, "green", 0x00FF00)

	if(obj["purple"] =="") {
	msgbox, % "Null string"
	} else {
	msgbox, % "Not a Null string"
	}
	idx := 10
	msgbox, % "tmp is " . idx

	idx := CountObject(obj)
	msgbox, % "tmp2 is [" . idx . "]" . obj["red"]
	return

CountObject(_obj)
{
	_cnt := 0
	enum := _obj._NewEnum()
	While enum[k, v]
	{
		msgbox, % "k is " . k . ":v is " . v
		_cnt := _cnt + 1
	}
	return _cnt
}

  a := "ー"
  val := Asc(a)
  _tmp := A_ScriptDir
  msgbox %_tmp%
  C := 1200
  c := 100
  
  
  msgbox, % "C is " . C
  
  b := Get_reg_Keyboard_Layouts()
  msgbox Get_reg_Keyboard_Layouts %b%

  b := Get_Layout_Text()
  msgbox Get_Layout_Text %b%
  
  
  
 