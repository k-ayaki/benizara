;-----------------------------------------------------------------------
; 名前：Benizara / 紅皿 ver.0.1.4.3
; キーボード配列エミュレーションソフトウェア
; 作者：綾木　健一郎
; 令和2年10月20日
;-----------------------------------------------------------------------
１．	始めに
１．１．何をするものなのか
　Benizaraは、Windows環境に接続されたJISキーボードで親指シフト (NICOLA配列) による入力を可能にするエミュレーションソフトウェアです。Windows10のMS-IMEとgoogle日本語入力で動作を確認しています。なお、Benizaraは、設定ファイルを読み込ませることにより、親指シフトに限らず、任意のキーボード配列のエミュレーションが可能です。
　Benizara（紅皿）の名前は、太田道灌の山吹伝説に由来します。

１．２．特徴
・Windows10のストアアプリや、Microsoft Edge上でも親指シフト入力が可能です。
・やまぶきと同様に１２面のシフトモードを実現し、やまぶきの配列定義ファイルをある程度まで読込可能としました。
・やまぶきの打鍵ロジックを参考に実装し、かつ連続シフトモードをサポートしています。よって、やまぶき（やまぶきＲ）からの移行は容易とおもいます。
・Benizaraは、AutoHotKeyのスクリプトを実行ファイル化したものです。ユーザモードでキーフックするタイプのエミュレータなので、導入も停止も簡単です。USBメモリで持ち歩くこともできます。
・親指の友Mk-2 キーボードドライバ V2.0L23に実装された「零遅延モード」を、当該ソフトにも実装しました。零遅延モードとは、親指シフト時の表示遅延をゼロにして、高速打鍵を可能とするモードです。
・Performance Counterを用いて、1ミリ秒単位のキー入力タイミング測定を実現しました。これにより正確な同時打鍵／単独打鍵の判定が行えます。なお、Ver.0.1.2以前はシステムタイマーを用いてキー入力を測定していたため、測定精度は16ミリ秒単位でした。
・管理者権限への切替ボタンを実装しました。紅皿を管理者権限で実行させることにより、管理者権限で実行されているアプリケーションに対してもキー配列のエミュレーションが可能です。
・親指キーの単独打鍵時のキーリピートと、その切り替えを実装しました。
・Google日本語入力のローマ字入力モードに仮対応しました。

１．３．未だ実装していないこと
・機能キーの切り替えは未だ実装していません。
・各ＩＭＥのかな入力モードには対応していません。
・現状の紅皿の「無」キーは、やまぶきの「無」キーとは異なり、単にキー出力しないだけです。

１．４．入力速度ベンチマーク
・落語「じゅげむ」の名前を入力するベンチマークで評価しました。具体的にいうと「じゅげむじゅげむごこうのすりきれ　かいじゃりすいぎょのすいぎょうまつうんらいまつふうらいまつ　くうねるところにすむところ　やぶらこうじのぶらこうじ　ぱいぽぱいぽぱいぽのしゅーりんがん　しゅーりんがんのぐーりんたい　ぐーりんたいのぽんぽこぴーのぽんぽこなーのちょうきゅうめいのちょうすけ」を仮名入力する時間を計測するものです。このベンチマークは、今井士郎さんのブログを参考にしました。
・自分が「じゅげむベンチマーク」を実行した際の親指シフト入力の最速は４５秒、平均は５５秒でした。なお、ローマ字入力の最速は７５秒、平均は８０秒でした。

２．	使い方
２．１．取り扱い種別
　Benizara（紅皿）はフリーソフトウエアであり、IME.ahk, Path.ahkを除く各ソースコードはMITライセンスの下で再利用可能です
　なお、Benizaraのソースコードのうち、IME.ahk, Path.ahk は、eamatさまが作成されたライブラリです。

２．２．動作環境
　Windows7とWindows10で動作確認していますが、NT系のWindowsならば、どの環境でも動作する筈です。
　IMEは、Atok11とMS-IMEとGoogle日本語入力で動作確認しています。
　キーボードはJIS109キーボードと親指シフト表記付きUSBライトタッチキーボードに対応しています。FMV-KB232やFKB7628-801には対応していません。

２．３．インストール方法
（１）インストーラ版では、Benizara_0143.zipを所望のパスに解凍して、setup.exe を実行してください。お使いのJIS109キーボードが親指シフト (NICOLA配列) に切り替わります。
（２）実行ファイル版では、BenizaraEXE_0143.zipを所望のパスに解凍してください。benizara.exe を実行すると、お使いのJIS109キーボードが親指シフト (NICOLA配列) に切り替わります。
SetBenizaraTask.exeを実行すると、タスクスケジューラにbenizaraが設定され、以降はログインごとに自動起動します。


３．	紅皿設定の説明
タスクトレイの紅皿アイコンを右クリックして、紅皿設定をクリックすると以下の設定ダイアログが表示されます。各タブの下のOKボタンをクリックすると変更が反映され、キャンセルボタンをクリックすると変更が破棄されます。

３．１．配列タブ
・配列定義ファイルを表示し、かつ切り替える機能を備えたタブです。
・その下側には、親指シフトキーの選択コンボボックスと単独打鍵コンボボックスが表示され更にキー配列が表示されています。このキー配列は、リアルタイムで打鍵が表示されます。
・親指シフトキーのコンボボックスは、無変換−変換と無変換−空白と空白−変換とが選択可能です。無変換−変換を選択した場合、無変換キーが左親指キー、変換キーが右親指キーです。無変換−空白を選択した場合、無変換キーが左親指キー、空白キーが右親指キーであり、かつ単独打鍵時には空白が打鍵されます。このとき、変換キーの機能はそのままです。空白−変換を選択した場合、空白キーが左親指キー、変換キーが右親指キーです。
・単独打鍵のコンボボックスは、無効と有効が選択可能です。有効の場合には、左右の親指シフトキーを単独打鍵した場合、対応するキーが入力されます。


３．２．親指シフトタブ
親指シフトに関する設定画面です。
・連続シフトのチェックポックスは、親指シフトキーの押下中に、連続してシフトモードの文字を入力するためのものです。推奨設定はオンです。
・零遅延モードのチェックポックスは、キー押下と共に遅延無く文字を出力する「零遅延モード」をオンするものであり、推奨設定はオンです。この零遅延モードは、親指の友Mk-2キーボードドライバ（聖人さま作）の機能を参考としました。
・キーリピートのチェックボックスは、チェック有り（有効）と無し（無効）に設定可能です。
・文字と親指シフトの同時打鍵の割合は、20〜80[%]の間で可変です。親指シフトキーの押下に対して文字キーの押下が重なったとき、この割合を満たしたならば同時打鍵となります。推奨値は40〜60%です。
・文字と親指シフトの同時打鍵の判定時間は、10〜400[mSEC]の間で可変です。NICOLA規格では、50〜200[mSEC]が推奨されています。
推奨値は、連続シフトの場合で50[mSEC]、連続シフトしない場合で150[mSEC]です。

 
３．３．管理者権限タブ
・紅皿が管理者権限と通常権限のいずれで動作しているかを示すタブです。
・通常権限の場合には、「管理者権限に切替」ボタンか表示されています。この「管理者権限に切替」ボタンをクリックすると、管理者権限に切り替わります。これにより管理者権限で動作しているアプリケーション（例えばタスクスケジューラ）上でも親指シフト入力が可能になります。
管理者権限から通常権限に切り替える方法は提供していません。

３．４．紅皿についてタブ
バージョン情報や紅皿の概要が書かれたタブです。

３．５．ログの説明
タスクトレイの紅皿アイコンを右クリックして、ログをクリックすると紅皿ログが表示されます。
表示内容は左から、時間間隔（ミリ秒単位）、入力キーとそのdown/up、状態、アプリケーションへの送信キー内容です。

４．	キー配列（デフォルト）
　紅皿は、やまぶきと同様に、ローマ字モード６面と、英数モード６面の全１２面のキーボードレイアウトを持っています。ローマ字モードは、ＩＭＥをローマ字入力のひらがな・全角カタカナ・半角カタカナに設定したときのモードであり、英数モードは、ＩＭＥを全角英数・半角英数・直接入力に設定したときのモードです。以下表に、各レイアウト名とシフト操作との関係を示します。

レイアウト名　　　　　　｜	シフト操作
−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−
ローマ字シフト無し　　　｜	シフト無し
ローマ字右親指シフト　　｜	右親指キーと共に文字キー打鍵
ローマ字左親指シフト　　｜	左親指キーと共に文字キー打鍵
ローマ字小指シフト　　　｜	※１
ローマ字小指右親指シフト｜	※１
ローマ字小指左親指シフト｜	※１
英数シフト無し　　　　　｜	シフト無し
英数右親指シフト　　　　｜	右親指キーと共に文字キー打鍵
英数左親指シフト　　　　｜	左親指キーと共に文字キー打鍵
英数小指シフト　　　　　｜	小指シフト
英数小指右親指シフト　　｜	小指シフトした状態で、右親指キーと共に文字キー打鍵
英数小指左親指シフト　　｜	小指シフトした状態で、右親指キーと共に文字キー打鍵

※１：ローマ字モードでシフトキーを打鍵すると、英数モードに一時的に遷移します。ローマ字モードにおいて、このレイアウトは全て小指シフトとして機能します。

　上記のレイアウトは、紅皿が読み込むキー配列ファイルによって変更することができます。

５．	アンインストール方法
５．１．インストーラ版
タスクトレイの紅皿アイコンを右クリックして、終了をクリックしてbenizaraを停止させます。そして、コントロールパネルの「プログラムのアンインストール」を選択し、Benizaraを削除してください。
５．２．実行ファイル版
タスクトレイの紅皿アイコンを右クリックして、終了をクリックしてbenizaraを停止させます。そして、DelBenizaraTask.batを実行したのちに、Benizara.exeが格納されたフォルダを削除してください。

６．	作者への連絡方法
Linkedin：https://www.linkedin.com/in/ken-ichiro-ayaki-965b2a8a/
Mail: kenichiro_ayaki@users.osdn.me

７．	配布ファイルとその構成
Benizara.exe・・・ 紅皿の実行ファイルです。
Benizara.ini・・・紅皿の設定情報ファイルです。
NICOLA配列.bnz・・・NICOLA配列のファイルです。
Dvorak配列.bnz・・・Dvorak配列のファイルです。
orz配列.bnz・・・orz配列のファイルです。
親指シフト表記付きUSBライトタッチキーボード配列.bnz・・・親指シフト表記付きUSBライトタッチキーボード（ライフラボ社）のキーボード配列です。

８．	履歴
ver.0.1.1　…　初版
ver.0.1.2　…　WindowsキーとAltキーの単独押し動作を許可するため
　　　　　　　　Hotkey登録を外し、タイマー割込みで監視するようにした
ver.0.1.3　…　Performance Counter 対応、管理者権限への昇格機能、IME判定の不具合対応。
ver.0.1.3.1　…　親指キーの単独打鍵時のキーリピート、ログ機能追加。
ver.0.1.3.2　…　空白と変換を親指キーに設定可能。親指キー単体のタイムアウト抑止。
ver.0.1.3.3　…　キーレイアウトファイルの変更が次回起動時に反映されなかった不具合の対処。
ver.0.1.3.4　…　キーレイアウトファイルの読み込み時のエラー処理の追加。
ver.0.1.3.5　…　親指キーオン→文字キーオン→他の親指キーオンの処理Bと、親指キーオン文字キーオンオフの処理Eを仕様書に適合するように修正。
ver.0.1.3.6　…　同時複数起動の抑止、シフトキーとコントロールキーと上下左右カーソルキーのフックを外す、google日本語入力への仮対応、タイプウェルで仮名文字を入力する際の配列を除外。
Ver.0.1.4.0　…　英数モードのように、入力キーとアプリケーションへの出力キーとが一致している場合にキーをフックしないように変更。入力キーorz配列で、かな長音がおかしくなる件に対応。親指シフト表記付きUSBライトタッチキーボード配列の「ぁ」の入力ができなかった件に対応。
Ver.0.1.4.2　…　Windows 10 May 2020 Updateに対応するため、アプリに出力する文字をすべて半角または制御記号とした。
Ver.0.1.4.3　…　キー配列ファイルに平仮名を記載可能とし、紅皿設定のキーレイアウトにリアルタイムのキー情報を表示させた。
以上
