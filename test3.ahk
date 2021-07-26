Gui, Add, ListView, x2 y0 w400 h500, Process Name|Command Line
for proc in ComObjGet("winmgmts:").ExecQuery("Select * from Win32_Process")
    LV_Add("", proc.Name, proc.CommandLine)
Gui, Show,, Process List