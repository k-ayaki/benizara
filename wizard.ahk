	IfWinExist,紅皿ウイザード
	{
		msgbox, 既に紅皿ウイザードは開いています。
		return
	}
	idx := 0
	Gui,5:Default
	Gui, 5:New
	Gui, Font,s10 c000000,
	Gui, Add, Button,ggButton2Ok X343 Y308 W77 H22,ＯＫ
	Gui, Add, Button,ggButton2Cancel X431 Y308 W77 H22,キャンセル
	Gui, Font,s12 c000000,MS Pゴシック
	Gosub, Monar00
	Gui, Color,FFFFFF,FFFFFF
	Gui, Add, Edit,vvDispAA X20 Y20 W300 H280 ReadOnly -Vscroll,%aa_monar00%
	Gui, Show, W720 H341, 紅皿ウイザード
	return
	
gButton2Ok:
	idx := idx + 1
	_text := aa_monar0%idx%
	GuiControl,5:,vDispAA, %_text%
	return

;-----------------------------------------------------------------------
; 機能：キャンセルボタンの押下
;-----------------------------------------------------------------------
gButton2Cancel:
	Gui,5:Destroy
	return

;-----------------------------------------------------------------------
; 機能：モナ―AA
; https://w.atwiki.jp/aapose/pages/318.html
;-----------------------------------------------------------------------

Monar00:
	aa_monar00 := "
(





　　　　　　　∧＿∧
　　　　 　 |l（　´∀｀）
　 　 ＿＿|（つｌｌ￣￣￣|＿_
　　　|＼　　＼||　＿＿_|	
)"
	aa_monar01 := "
(





　　　　 ∧＿∧
　＿＿（´∀｀　）
　＼　　＼と　 ）
　　　iニニニi￣
)"

	aa_monar02 := "
(





　　　　　∧＿∧
　 　　　（´∀｀　）
　　　　 ノ　 　 ヽ
￣ ＼￣￣＼とノ￣￣￣
　　　￣￣￣￣￣
)"
	aa_monar03 := "
(





　　∧＿∧　 　∧＿∧
　 （　´∀｀）　 （・∀・　）
＿_(_つ/￣￣￣/　　　）
　　＼/＿＿＿/￣
)"
	aa_monar04 := "
(





　　∧＿∧
　 （　・∀・）　 ∧ ∧
　（　　⊃ ）　 (ﾟДﾟ；)
￣￣￣￣￣ （つ＿つ＿＿
￣￣￣日∇￣＼| BIBLO |＼
　　　 　 　￣　　　=======　　＼
)"

	aa_monar05 := "
(





　　 ∧＿∧　　　 　　∧ ∧
　　（　・∀・）　　 　~（；・Д・）
￣（⊃＿⊃＿＿　　（つ＿つ＿＿＿
￣＼|P III Dual |＼￣＼|P III Dual |＼
　　　=========　　　　　.=========.. ＼
)"

	aa_monar06 := "
(





|
|__∧　　　　　　 　　　∧ ∧
|∀・）　　　　　　 　~（；・Д・）
|⊂　＿＿＿＿　　　（つ＿つ＿＿＿
￣＼|P III Dual |＼￣＼|P III Dual |＼
　　　=========　　　　　.=========.. ＼
)"
	aa_monar07 := "
(





　　∧＿∧　　ｶﾀ
　 （　´∀｀）＿＿ｶﾀ___ _
　 （ つ＿ ||￣￣￣￣￣|
　 　 　|＼.||　　VAIO　　|
　 　 　'＼,,|==========|
)"
	aa_monar08 := "
(





　　　∧＿∧
　　 （　´∀｀）
　__〇　＿/￣￣￣/
,,|＼￣ヽ/　　　　 /＼
,,|＼＼　o＝＝＝o　 ＼
　　 ＼|￣￣￣￣￣￣ |
　　　　|￣￣￣￣￣￣ |
)"
	aa_monar09 := "
(






　 ｶﾀｶﾀ ∧＿∧
　　　　 （・∀・　）
　　 ＿|￣￣||＿）＿
　／旦|――||/／ ／|
　|￣￣￣￣￣|￣| . |
　|＿＿＿＿＿|三|／
)"
	return