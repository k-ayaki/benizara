	SetStoreCapsLockMode,Off
	return


	; Autohotkey のsc出力テスト
*SC027::
	send, {blind}{\ down}
	Return

*SC027 up::
	send, {blind}{\ up}
	Return

*SC002::
	send,{blind}^{c down}
	Return
	
*SC002 up::
	;send, {blind}{vkC0 up}
	Return

*SC003::
	send, +{Right down}
	Return
	
*SC003 up::
	send, {Right up}
	Return

3::
	send, {vkF4}。
	Return
	
3 up::
	Return