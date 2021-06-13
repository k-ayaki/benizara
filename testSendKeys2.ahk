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
	send,{capslock}
	send,{: down}
	send,{capslock}
	Return
	
*SC002 up::
	send,{capslock}
	send,{: up}
	send,{capslock}
	Return

*SC003::
	send, {け}{ん}{ち}
	Return
	
*SC003 up::
	send, {Right up}
	Return

3::
	send, {vkF4}。
	Return
	
3 up::
	Return