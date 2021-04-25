
	; Autohotkey のユニコード直接出力
1::
	send, {@}
	Return

	; Autohotkey の通常のキー出力
2::
	send, {blind}{^ down}{^ up}
	Return

3::
	send, {blind}{LShift up}{@ down}{@ up}{LShift down}
	Return

+3::
	send, {blind}{LShift up}{@ down}{@ up}{LShift down}
	Return
