#include IME.ahk

	hash := Object()
	hash[0x3041] := "la"	;ぁ
	hash[0x3042] := "a"		;あ
	hash[0x3043] := "xi"	;ぃ
	hash[0x3044] := "i"		;い
	hash[0x3045] := "lu"	;ぅ
	hash[0x3046] := "u"		;う
	hash[0x3047] := "le"	;ぇ
	hash[0x3048] := "e"		;え
	hash[0x3049] := "lo"	;ぉ
	hash[0x304A] := "o"		;お
	hash[0x304B] := "ka"	;か
	hash[0x304C] := "ga"	;が
	hash[0x304D] := "ki"	;き
	hash[0x304E] := "gi"	;ぎ
	hash[0x304F] := "ku"	;く
	hash[0x3050] := "gu"	;ぐ
	hash[0x3051] := "ke"	;け
	hash[0x3052] := "ge"	;げ
	hash[0x3053] := "ko"	;こ
	hash[0x3054] := "go"	;ご
	hash[0x3055] := "sa"	;さ
	hash[0x3056] := "za"	;ざ
	hash[0x3057] := "si"	;し
	hash[0x3058] := "zi"	;じ
	hash[0x3059] := "su"	;す
	hash[0x305A] := "zu"	;ず
	hash[0x305B] := "se"	;せ
	hash[0x305C] := "ze"	;ぜ
	hash[0x305D] := "so"	;そ
	hash[0x305E] := "zo"	;ぞ
	hash[0x305F] := "ta"	;た
	hash[0x3060] := "da"	;だ
	hash[0x3061] := "ti"	;ち
	hash[0x3062] := "di"	;ぢ
	hash[0x3063] := "ltu"	;っ
	hash[0x3064] := "tu"	;つ
	hash[0x3065] := "du"	;づ
	hash[0x3066] := "te"	;て
	hash[0x3067] := "de"	;で
	hash[0x3068] := "to"	;と
	hash[0x3069] := "do"	;ど
	hash[0x306A] := "na"	;な
	hash[0x306B] := "ni"	;に
	hash[0x306C] := "nu"	;ぬ
	hash[0x306D] := "ne"	;ね
	hash[0x306E] := "no"	;の
	hash[0x306F] := "ha"	;は
	hash[0x3070] := "ba"	;ば
	hash[0x3071] := "pa"	;ぱ
	hash[0x3072] := "hi"	;ひ
	hash[0x3073] := "bi"	;び
	hash[0x3074] := "pi"	;ぴ
	hash[0x3075] := "fu"	;ふ
	hash[0x3076] := "bu"	;ぶ
	hash[0x3077] := "pu"	;ぷ
	hash[0x3078] := "he"	;へ
	hash[0x3079] := "be"	;べ
	hash[0x307A] := "pe"	;ぺ
	hash[0x307B] := "ho"	;ほ
	hash[0x307C] := "bo"	;ぼ
	hash[0x307D] := "po"	;ぽ
	hash[0x307E] := "ma"	;ま
	hash[0x307F] := "mi"	;み
	hash[0x3080] := "mu"	;む
	hash[0x3081] := "me"	;め
	hash[0x3082] := "mo"	;も
	hash[0x3083] := "lya"	;ゃ
	hash[0x3084] := "ya"	;や
	hash[0x3085] := "lyu"	;ゅ
	hash[0x3086] := "yu"	;ゆ
	hash[0x3087] := "lyo"	;ょ
	hash[0x3088] := "yo"	;よ
	hash[0x3089] := "ra"	;ら
	hash[0x308A] := "ri"	;り
	hash[0x308B] := "ru"	;る
	hash[0x308C] := "re"	;れ
	hash[0x308D] := "ro"	;ろ
	hash[0x308E] := "lwa"	;ゎ
	hash[0x308F] := "wa"	;わ
	hash[0x3090] := "wi"	;ゐ
	hash[0x3091] := "we"	;ゑ
	hash[0x3092] := "wo"	;を
	hash[0x3093] := "nn"	;ん
	hash[0x3094] := "vu"	;ゔ
	hash[0x3095] := "lka"	;ゕ
	hash[0x3096] := "lke"	;ゖ
	MsgBox, % "氏名 : " . hash[0x304B]
	MsgBox, % "氏名 : " . hash[0x3097]

	return

1::	;1
	SetKeyDelay -1
	Send {ASC 334440}
	return
