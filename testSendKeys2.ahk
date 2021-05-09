
	; Autohotkey のsc出力テスト
*SC027::
	send, {blind}{\ down}
	Return

*SC027 up::
	send, {blind}{\ up}
	Return

1::
	send, {blind}{. down}
	Return
	
1 up::
	send, {blind}{. up}
	Return

2::
	send, {blind}{sc034 down}
	Return
	
2 up::
	send, {blind}{sc034 up}
	Return

3::
	send, {blind}{vkBE down}
	Return
	
3 up::
	send, {blind}{vkBE up}
	Return