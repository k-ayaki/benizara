/************************************************************************
    ファイルパス関数群  (Path.ahk)

    DllCallにてAPIを使用 (\ ダメ文字対応)
   (上位からの引数に問題がない限り本関数内で新たに文字化けを起こすことはない筈)
      グローバル変数 : なし
      各関数の依存性 : なし(必要関数だけ切出してコピペでも使えます)

    AHKL Ver:       1.1.08.01
    Language:       Japanease
    Platform:       WinNT  IE 4以上 (SHLWAPI.DLL使用)
    Author:         eamat.    2008.01.30
 ************************************************************************
 2008.12.10
 2009.01.24  コメント修正
 2009.06.20  関数名修正   PathIs_Relative() → Path_IsRelative()
 2009.07.26  パラメータ修正 Path_Canonicalize()
 2009.10.22  SplitPath() 追加 (AHK本来の SplitPathコマンド互換)
 2012.08.20  UTF-8保存 暫定
 2012.11.08  Unicode対応 DllCall時の末尾A削除(A,W自動判別)
             msvcrt.dll\_mbscpy廃止 UInt & → Str
             MAX_PATH 260 → 520
*/
_PathAutoExecuteSample:
    ;コマンドラインのテスト
    ;このファイル(path.ahk)に何かファイルをドラッグして起動してみて下さい。
    if(!_PathCommandLineCheck())    {

        ;関数の戻り値チェック見本 (うざいです）
        _PathTest()
    }
return

;=============================================================================
;   判定系 (存在チェック)
;=============================================================================
;---  ファイルの有無をチェックする 戻り値 0:なし 1:あり ---
; ディレクトリ指定時も1が返る。UNCパス(\\%A_ComputerName%\hoge.txt 等)でもOK
Path_FileExists(path)   {
    Return DllCall("SHLWAPI.DLL\PathFileExists", Str,path, Int)
}

;---  ディレクトリが存在するかチェックする 戻り値 0:なし 0以外:あり ---
; UNCパス(\\%A_ComputerName%\ 等)もOK
; 末尾 \ はあってもなくてもいい模様
Path_IsDirectory(path)  {
    Return DllCall("SHLWAPI.DLL\PathIsDirectory", Str,path, Int)
}

;---- 存在しているUNC(ネットワーク)パスかどうか 0:なし 1:あり ---
Path_IsUNCServerShare(path) {
    Return DllCall("SHLWAPI.DLL\PathIsUNCServerShare", Str,path, Int)
}
/* 
 ; 何故か上手くいかない
;--- 既存のフォルダがシステムフォルダ属性を持つかどうか ---
Path_IsSystemFolder(path="",Attr=0) {
 ;   Return DllCall("SHLWAPI.DLL\PathIsSystemFolder", Str,path, UInt,Attr, Int)
}
 */

;=============================================================================
;   判定系 (文字列の記述ルール チェック)
;   ※ 実際に存在しないパスかの判断ではない
;=============================================================================
;-----------------------------------------------------------
;  文字列がファイル名のみ仕様か(":"や"\"などの区切り文字が含まれていないか)
;   戻り値 0: ":"や"\"あり 1:ファイル名のみ
;-----------------------------------------------------------
Path_IsFileSpec(path)   {
    Return DllCall("SHLWAPI.DLL\PathIsFileSpec", Str,path, Int)
}

;------------------------------------------------------------------
;   指定されたパスの先頭がPrefixで指定された文字列で始まっているか判定
;   prefix : "C:\\" or  "." or ".." or "..\\"
;   戻り値  0:なし 1:あり
;------------------------------------------------------------------
Path_IsPrefix(prefix,path)  {
    Return DllCall("SHLWAPI.DLL\PathIsPrefix", Str,prefix, Str,path, Int)
}

;----- 文字列が相対パスか絶対パスかを判断 0:絶対 1:相対 ---
Path_IsRelative(path)   {
    Return DllCall("SHLWAPI.DLL\PathIsRelative", Str,path, Int)
}

;----- 文字列がルートかどうか判断 0:無効 1:有効 ---
Path_IsRoot(path)   {
    Return DllCall("SHLWAPI.DLL\PathIsRoot", Str,path, Int)
}

;----- 2つのパス文字列が同一のルート要素を持つかどうか判断 0:無効 1:有効 ---
Path_IsSameRoot(path1,path2)    {
    Return DllCall("SHLWAPI.DLL\PathIsSameRoot", Str,path1, Str,path2, Int)
}
;--- 文字列がURLとして解釈できるか 0:できない 1:できる ---
Path_IsURL(url) {
    Return DllCall("SHLWAPI.DLL\PathIsURL", Str,url, Int)
}

;========= ネットワークパス ===========
;--- 文字列が UNC(ネットワークパス)かどうか  0:無効 1:有効 ---
; 記述形式の判断のみ、実際に存在しないパスかの判断はなし
Path_IsUNC(path)    {
    Return DllCall("SHLWAPI.DLL\PathIsUNC", Str,path, Int)
}

;--- 文字列が サーバーパスのみのUNC(ネットワークパス)かどうか 0:無効 1:有効 ---
;   ex) \\hoge  : 1
;       \\      : 1
;       \\hoge\ : 0
Path_IsUNCServer(path)  {
    Return DllCall("SHLWAPI.DLL\PathIsUNCServer", Str,path, Int)
}

;------------------------------------------------------------------------
;  指定のファイル名がワイルドカードを使ったファイルスペックに一致するか
;   filename :ファイル名
;   spec     :ファイルスペック (*.txt や a?c.exeなど)
;   戻り値 0:一致しない 1:する
;------------------------------------------------------------------------
Path_MatchSpec(filename, spec)  {
    return DllCall("SHLWAPI.DLL\PathMatchSpec", Str,filename, Str,spec, Int)
}

;------------------------------------------------------------------------
;  文字cをパスに使用する際にどのように使用できるかを判定する。
;   c   : 判定する文字 (char)
;
;   戻り値:判定結果のビットマスク値で、以下のフラグの組み合わせ 
;
;   GCT_INVALID   0x00  文字は、パスで有効はない
;   GCT_LFNCHAR   0x01  文字は、ロングファイル名で有効です
;   GCT_SEPARATOR 0x08  文字は、パスのセパレータです
;   GCT_SHORTCHAR 0x02  文字は、ショートファイル名(8.3)で有効です
;   GCT_WILD      0x04  文字は、ワイルドカード文字です (*?)
;------------------------------------------------------------------------
Path_GetCharType(c) {
    return DllCall("SHLWAPI.DLL\PathGetCharType", Char,Asc(c), Uint)
}

;=============================================================================
;   変換系
;=============================================================================
;---  ロングファイルネームを返す (※ Win95非対応) ---
Path_GetLongPathName(filePath)  {
    VarSetCapacity(dstPath, 260*2)
    DllCall("GetLongPathName", str,filePath, str,dstPath, Uint,260*2)
    return dstPath
}

;---  8.3形式のファイルネームを返す (※ Win95非対応) ---
Path_GetShortPathName(filePath) {
    VarSetCapacity(dstPath, 260*2)
    DllCall("GetShortPathName", str,filePath, str,dstPath, Uint,260*2)
    return dstPath
}

;---- フルパスを生成する (カレントDirが付加される) ----
Path_SearchAndQualify(file) {
    VarSetCapacity(t,260*2,0) ;↓確保した値の1/2に指定しないとハングするぽい
    DllCall("SHLWAPI.DLL\PathSearchAndQualify", Str,file, str,t, UInt,260)
    return t
}

/* 何故か上手くいかない
;--- パスの形式を統一するためにすべての文字を小文字へ変換(除ﾙｰﾄ文字)
Path_MakePretty(path)   {
    DllCall("SHLWAPI.DLL\PathMakePretty", Str, path)
    return path
}
*/

;---- パス名の最後尾にバックスラッシュをつける -----
Path_AddBackslash(path) {
    DllCall("SHLWAPI.DLL\PathAddBackslash", Str, path)
    return path
}
;--- パス名の最後尾のバックスラッシュを削除 ---
Path_RemoveBackslash(path)  {
    DllCall("SHLWAPI.DLL\PathRemoveBackslash", Str, path)
    return path
}

;--- 文字列から最初と最後のスペースを削除 (Trim?) ---
Path_RemoveBlanks(path) {
    DllCall("SHLWAPI.DLL\PathRemoveBlanks", Str, path)
    return path
}

;---- パス名がスペースを含む時に""でくくる ---
Path_QuoteSpaces(path)  {
    DllCall("SHLWAPI.DLL\PathQuoteSpaces", Str, path)
    return path
}
;---- ""で囲まれたパス名からマークを取り除く ---
Path_UnquoteSpaces(path)    {
    DllCall("SHLWAPI.DLL\PathUnquoteSpaces", Str, path)
    return path
}

;-----------------------------------------------------------
;  フルパス名から拡張子だけを変更したパス名を取得する
;   path    対象パス
;   ext     変更する拡張子
;-----------------------------------------------------------
Path_RenameExtension(path,ext)  {
    ext := ("." != SubStr(ext,1,1)) ? "." ext : ext     ;"."がない時は付加
    DllCall("SHLWAPI.DLL\PathRenameExtension", Str,path, Str,ext)
    Return path
}

;=============================================================================
;   抽出系
;=============================================================================
;---- パス名からルート情報を取得 -----
; ex) c:\hoge.txt -> c:\
Path_StripToRoot(path)  {
    DllCall("SHLWAPI.DLL\PathStripToRoot", Str, path)
    return path
}

;---- パス名からドライブ番号を取得 (ドライブ a:→ 0番 エラー時:-1) -----
Path_GetDriveNumber(path)   {
    Return DllCall("SHLWAPI.DLL\PathGetDriveNumber", Str,path, Int)
}

;---- フルパス名からファイル名のみを取り出す -----
Path_FindFileName(path) {
    Return DllCall("SHLWAPI.DLL\PathFindFileName", Str,path, Str)
}

;---- 指定されたファイル名からパス部分を削除 -----
; (Path_FindFileName() と結果同じ？)
Path_StripPath(path)    {
    DllCall("SHLWAPI.DLL\PathStripPath", Str, path)
    return path
}

;--------------------------------------------------------------
;    フルパス名からディレクトリを取出す
;    ※ パスから\とその後ろのファイル名を削除する
;       \なしDIRを指定すると最後のフォルダが削られるので注意!
;        ex c:\foo\bar\hoge.txt -> c:\foo\bat
;           c:\foo\bar\         -> c:\foo\bar
;           c:\foo\bar          -> c:\foo
;--------------------------------------------------------------
Path_RemoveFileSpec(path)   {
    DllCall("SHLWAPI.DLL\PathRemoveFileSpec", Str,path)
    return path
}

;---- パスから共有名部分を除く ---
Path_SkipRoot(path) {
   return DllCall("SHLWAPI.DLL\PathSkipRoot", Str, path, Str)
}

;---- フルパス名から拡張子だけを取り出す ------
Path_FindExtension(path)    {
    Return DllCall("SHLWAPI.DLL\PathFindExtension", Str,path, Str)
}

;---- フルパス名から拡張子のみを除いたパス名を取得する ----
Path_RemoveExtension(path)  {
    DllCall("SHLWAPI.DLL\PathRemoveExtension", Str, path)
    return path
}

;-----  Pathで指定されたコマンド文から、コマンドライン引数を抽出 ---
Path_GetArgs(path)  {
    return DllCall("SHLWAPI.DLL\PathGetArgs", Str,path, str)
}

;--- Pathで指定されたコマンド文から、引数部分を削除 ---
Path_RemoveArgs(path)   {
    DllCall("SHLWAPI.DLL\PathRemoveArgs", Str,path)
    return path
}

;-----------------------------------------------------------
;  ファイルパス文字列を指定した長さに縮める
;   path    対象パス
;   ext     何文字に縮めるか
;-----------------------------------------------------------
Path_CompactPathEx(Path,Max)    {
    ;※ 2バイト文字があると文字化け → U版なら大丈夫ぽい 2012.11.06
    VarSetCapacity(t,260*2,0)
    DllCall("SHLWAPI.DLL\PathCompactPathEx", Str,t, Str,path, UInt,max, Uint,"\")
    Return t
}

;-----------------------------------------------------------
;  ２つのパス名の先頭から共通するディレクトリ名を取得する
;   p1 p2   比較 対象パス
;-----------------------------------------------------------
Path_CommonPrefix(p1, p2)   {
    VarSetCapacity(t,260*2,0)
    DllCall("SHLWAPI.DLL\PathCommonPrefix", Str,p1, Str,p2, str,t)
    Return t
}

/*  ;値取得できず。 断念
Path_FIndOnPath(file,paths) {
    a := DllCall("SHLWAPI.DLL\PathFIndOnPath", Str,file, str,paths, Int)
    return file
}
*/

;=============================================================================
;   相対パス関連
;=============================================================================
;------------------------------------------------------
;   相対パスを作成
;   From : ベースパス
;   To   : 相対にするパス
;   atr  : ファイル属性を指定
;          ディレクトリ 0x10 (FILE_ATTRIBUTE_DIRECTORY)
;          ファイル     0x20 (FILE_ATTRIBUTE_ARCHIVE)
;------------------------------------------------------
Path_RelativePathTo(From,atrFrom,To,atrTo)  {
    VarSetCapacity(t,260*2,0)

    DllCall("SHLWAPI.DLL\PathRelativePathTo", Str,t
            , str,From, Uint,atrFrom
            , str,To,   Uint,atrTo)
    return t
}

;------------------------------------------------------------
;  ファイルパス文字列を結合 (..\ 等の展開もOK)
;  末尾に \ がなくても自動で付加される。
;
;   path    対象パス
;   more    繋げるパス
;------------------------------------------------------------
Path_Combine(path,more) {
    VarSetCapacity(t,260*2,0)
    DllCall("SHLWAPI.DLL\PathCombine", Str,t, str,path, str,more)
    return t
}

;----  ..\ を展開(絶対パスへ) ----
Path_Canonicalize(path) {
    VarSetCapacity(t,260*2,0)
    DllCall("SHLWAPI.DLL\PathCanonicalize", Str,t, str,path)
    return t
}

;=============================================================================
;   AHKコマンド互換関数
;=============================================================================

;--- SplitPath互換 ダメ文字対応版  ---
Path_SplitPath(path, byref OutFileName="", byref OutDir="", byref OutExtension="", byref OutNameNoExt="", byref OutDrive=""){

    ;URL処理は本家に任せる
    If(Instr(path,"://"))   {
        SplitPath,path,OutFileName,OutDir,OutExtension,OutNameNoExt,OutDrive
        return
    }

    ;フォルダパスを除いたファイル名
    ;フォルダパスのみの場合は、空になる 
    OutFileName := DllCall("SHLWAPI.DLL\PathFindFileName", Str,path, Str)
    If (RegExMatch(OutFileName,"(?:^|[^\x80-\x9F\xE0-\xFC])\\"))
        OutFileName := ""

    ;フォルダパス(最後の「\」を含まない)
    ;ファイル名のみの場合は、空になる。 
    VarSetCapacity(OutDir,260,0)
    DllCall("msvcrt.dll\_mbscpy",UInt,&OutDir,Str,path)
    DllCall("SHLWAPI.DLL\PathRemoveFileSpec", Str, OutDir)
    OutDir := RegExReplace(OutDir,"(?<=[^\x80-\x9F\xE0-\xFC])\\$")

    ;ファイルの拡張子(「.」は含まない)
    OutExtension := RegExReplace(DllCall("SHLWAPI.DLL\PathFindExtension"
                                         ,Str,path, Str),"^\.")

    ;拡張子を除いた名前部分を格納する
    OutNameNoExt :=RegExReplace(OutFileName,"\..*$")


    ;ドライブ文字(「:」付き)やネットワーク上のパスのマシン名を格納する
    OutDrive:=SubStr(path,2,1)=":"  ? SubStr(path,1,2)
            : SubStr(path,1,2)="\\" ? RegExReplace(path
                                 ,"(?<=[^\x80-\x9F\xE0-\xFC])\\.*$","","",-1,3)
            : ""
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
;
; 動作確認用 内部ルーチン 
;  単体起動時にAutoExecuteから呼ばれてるだけなので削除しても問題なし

_PathCommandLineCheck()    {
    global
    local filename
    filename = %1%
    if (filename)   {
        msgbox, コマンドライン引数`n%1%`n`n※ AHKは D&Dでファイルを渡すと8.3形`式ファイルパスになるっぽい
        return 1
    }
}

_PathTest()    {
    a := A_ScriptFullPath

    r1 := Path_FileExists(a)
    r2 := Path_FileExists(A_ScriptDir)
    msgbox ,1,ファイル存在チ`ェック,Path_FileExists(path)`n`n%a% = %r1%`n%A_ScriptDir% = %r2%
    IfMsgBox,Cancel,    return

    r1 := Path_IsDirectory(a)
    r2 := Path_IsDirectory(A_ScriptDir)
    r3 := Path_IsDirectory("c:\hoge")
    msgbox ,1,ディレクトリ存在チ`ェック,Path_IsDirectory(path)`n`n%a% = %r1%`n%A_ScriptDir% = %r2%`nc:\hoge = %r3%
    IfMsgBox,Cancel,    return

    r1 := Path_IsUNCServerShare("\\foo\bar\hoge.txt")  ;無効なパス
    p  := "\\" A_ComputerName "\共有フォルダ"       ;← ※有効なパスを入れて
    r2 := Path_IsUNCServerShare(p)
    r3 := Path_IsUNCServerShare(A_ScriptFullPath)
    msgbox ,1,ネットワークパス存在チ`ェック,Path_IsUNCServerShare(path)`n`n\\foo\bar\hoge.txt = %r1%`n%p% = %r2%`n%A_ScriptFullPath% = %r3%
    IfMsgBox,Cancel,    return

    r1 := Path_IsFileSpec(a)
    r2 := Path_IsFileSpec(A_ScriptName)
    msgbox,1,ファイル仕様チ`ェック(ファイル名のみ有効),Path_IsFileSpec(path)`n`n%a% = %r1%`n%A_ScriptName% = %r2%
    IfMsgBox,Cancel,    return

    r1 := Path_IsPrefix("..\",a)
    r2 := Path_IsPrefix("..\","..\System32\readme.txt")
    msgbox,1,パスの先頭の文字列を判定,Path_IsPrefix(prefix,path)`n `nprefix: ..\`ntarget: %a%`n --> %r1%`n`nprefix: ..\`ntarget: ..\System32\readme.txt`n --> %r2%
    IfMsgBox,Cancel,    return

    r1 := Path_IsRelative(a)
    r2 := Path_IsRelative("..\System32\readme.txt")
    msgbox,1,パスの相対判定,Path_IsRelative(path)`n `n%a% = %r1%`n..\System32\readme.txt = %r2%
    IfMsgBox,Cancel,    return

    
    r1 := Path_IsRoot(A_ScriptDir)
    r2 := Path_IsRoot("Q:\")
    r3 := Path_IsRoot("\\hoge\")
    msgbox,1,ルートディレクトリかどうか,Path_IsRoot(path)`n `n%A_ScriptDir% = %r1%`nQ:\ = %r2%`n\\hoge\ = %r3%
    IfMsgBox,Cancel,    return

    r1 := Path_IsSameRoot(a,A_AhkPath)
    r2 := Path_IsSameRoot(A_WinDir, A_ScriptDir)
    msgbox,1,2つのパスが同一のルートか,Path_IsSameRoot(path1,path2)`n`n1: %a%`n2: %A_AhkPath%`n --> %r1%`n`n1: %A_WinDir%`n2: %A_ScriptDir%`n --> %r2%
    IfMsgBox,Cancel,    return

    r1 := Path_IsURL("http://hoge/")
    r2 := Path_IsURL("\\foo\bar\hoge.txt")
    msgbox,1,文字列がURLか,Path_IsURL(url)`n `nhttp://hoge/ = %r1%`n\\foo\bar\hoge.txt = %r2%
    IfMsgBox,Cancel,    return

    r1 := Path_IsUNC(a)
    r2 := Path_IsUNC("\\foo\bar\hoge.txt")
    msgbox,1,パスがネットワークパスか,Path_IsUNC(path)`n `n%a% = %r1%`n\\foo\bar\hoge.txt = %r2%
    IfMsgBox,Cancel,    return

    r1 := Path_IsUNCServer("\\foo")
    r2 := Path_IsUNCServer("\\foo\")
    r3 := Path_IsUNCServer("\\")
    msgbox,1,パスがネットワークルートか,Path_IsUNCServer(path)`n `n\\foo = %r1%`n\\foo\ = %r2%`n\\ = %r3%
    IfMsgBox,Cancel,    return

    r1 := Path_MatchSpec(a,"*.exe")
    r2 := Path_MatchSpec(a,"*.ahk")
    msgbox,1,ファイルMatchチ`ェック,Path_MatchSpec(filename, spec)`n `n%a%`n*.exe = %r1%   *.ahk = %r2%
    IfMsgBox,Cancel,    return

    r1 := Path_GetCharType("/")
    r2 := Path_GetCharType(",")
    r3 := Path_GetCharType("a")
    r4 := Path_GetCharType("\")
    r5 := Path_GetCharType("*")
    msgbox,1,パス文字種判定,Path_GetCharType(c) `n `n/ = %r1%`n, = %r2%`na = %r3%`n\ = %r4%`n* = %r5%
    IfMsgBox,Cancel,    return

    r1 := Path_GetLongPathName(a)               ;ロングパス
    r2 := Path_GetShortPathName(r1)             ;8.3形式
    msgbox,1,ロング/ショートファイル,Path_GetLongPathName(filePath)`nPath_GetShortPathName(filePath)`n`norg = %a%`nLongFile = %r1%`nShortFile = %r2%
    IfMsgBox,Cancel,    return

    r1 := Path_SearchAndQualify("hoge.txt")
    r2 := Path_SearchAndQualify("..\hage.txt")
    msgbox,1,パスを補完して絶対パスに,Path_SearchAndQualify(file)`n`nhoge.txt`n-> %r1%`n`nhage.txt`n-> %r2%
    IfMsgBox,Cancel,    return
    
;    r1 := Path_MakePretty("C:\HOGE\HOGE.txt")
;    msgbox パスを小文字へ`n   C:\HOGE\HOGE.txt`n-->%r1%

    r1 := Path_AddBackslash(A_WinDir)
    r2 := Path_AddBackslash(A_WinDir . "\")
    msgbox,1,バックスラッシュ付加,Path_AddBackslash(path)`n`n%A_WinDir% = %r1%`n%A_WinDir%\ = %r2%
    IfMsgBox,Cancel,    return

    r1 := Path_RemoveBackslash(A_WinDir)
    r2 := Path_RemoveBackslash(A_WinDir . "\")
    msgbox,1, バックスラッシュ削除,Path_RemoveBackslash(path)`n `n%A_WinDir% = %r1%`n%A_WinDir%\ = %r2%
    IfMsgBox,Cancel,    return

    r1 := " " . A_WinDir . " "
    r2 := Path_RemoveBlanks(r1)
    msgbox,1, スペース削除,Path_RemoveBlanks(path)`n `n[%r1%]`n[%r2%]
    IfMsgBox,Cancel,    return

    r1 := Path_QuoteSpaces(A_WinDir)
    r2 := Path_QuoteSpaces(A_ProgramFiles)
    msgbox,1, スペース含むパスに" " 付加,Path_QuoteSpaces(path)`n `n%r1%`n%r2%
    IfMsgBox,Cancel,    return

    r3 := Path_UnquoteSpaces(r1 . "\hoge.exe")
    r4 := Path_UnquoteSpaces(r2)
    r5 := Path_UnquoteSpaces(r2 . "\hoge.exe")
    msgbox,1, " " 除去,Path_UnquoteSpaces(path)`n `n%r1%\hoge.exe = %r3%`n%r2% = %r4%`n%r2%\hoge.exe = %r5%
    IfMsgBox,Cancel,    return

    b := Path_RenameExtension(a,".old")   ;拡張子を変更
    msgbox ,1,拡張子変更,Path_RenameExtension(path,ext)`n`n%a%`n%b%
    IfMsgBox,Cancel,    return

    r1  := Path_GetDriveNumber(a)
    r2  := Path_FindFileName(a)
    r3  := Path_FindExtension(a)
    r4  := Path_RemoveExtension(a)
    r5  := Path_RemoveFileSpec(a)
    msgbox,1,抽出系,Path_GetDriveNumber(path)`nPath_FindFileName(path)`nPath_FindExtension(path)`nPath_RemoveExtension(path)`nPath_RemoveFileSpec(path)`n`n %a%`n`nドライブNo. = %r1%`nDir除去 = %r2%`n拡張子 = %r3%`n拡張子除去 = %r4%`nファイル名除去 = %r5%
    IfMsgBox,Cancel,    return


    r1 := Path_StripToRoot(A_ScriptDir)
    msgbox,1, ルート情報取得,Path_StripToRoot(path)`n`n%A_ScriptDir%`n->%r1%
    IfMsgBox,Cancel,    return

    r1 := Path_RemoveFileSpec(A_ScriptDir)
    msgbox,1, ファイル名除去,Path_RemoveFileSpec(path)`n`n%A_ScriptDir%`n->%r1%
    IfMsgBox,Cancel,    return

    r1 := Path_StripPath(a)
    msgbox,1, ファイル名からパス部分を削除,Path_StripPath(path)`n`n%a%`n->%r1%
    IfMsgBox,Cancel,    return

    r1 = \\foo\bar\hoge.txt
    r2 := Path_SkipRoot(a)
    r3 := Path_SkipRoot(r1)
    msgbox,1, パスから共有名部分を除去,Path_SkipRoot(path)`n `n%a%`n-> %r2%`n`n%r1%`n-> %r3%
    IfMsgBox,Cancel,    return

    c = %A_AhkPath% /hoge "%A_ScriptDir%"
    r1 := Path_GetArgs(c)
    msgbox,1,コマンドライン抽出,Path_GetArgs(path)`n`n%c%`n --> %r1%
    IfMsgBox,Cancel,    return

    r1 := Path_RemoveArgs(c)
    msgbox,1,パラメータ削除,Path_RemoveArgs(path)`n`n%c%`n --> %r1%
    IfMsgBox,Cancel,    return

    r1 := Path_CommonPrefix(a,A_AhkPath)
    msgbox,1,共通Dir抽出,Path_CommonPrefix(p1, p2)`n`n1:%a%`n2:%A_AhkPath%`n --> %r1%
    IfMsgBox,Cancel,    return

    r2 := Path_Combine(r1,A_AhkPath)
    r3 := Path_Combine(A_ScriptDir,A_ScriptName)
    r4 := Path_Combine(A_ScriptDir,".\..\hoge.exe")
    msgbox,1,path連結,Path_Combine(path,more)`n`n`n1:%r1%`n2:%A_AhkPath%`n --> %r2%`n`n1:%A_ScriptDir%`n2:%A_ScriptName%`n --> %r3%`n`n1:%A_ScriptDir%`n2: .\..\hoge.exe`n -->%r4%
    IfMsgBox,Cancel,    return

    r1 := Path_RelativePathTo(A_ScriptFullPath,0x20,A_AhkPath,0x20)
    msgbox,1,相対パス作成,Path_RelativePathTo(From,atrFrom,To,atrTo)`n`n1: %A_ScriptFullPath% `n2: %A_AhkPath%`n--> %r1%
    IfMsgBox,Cancel,    return

    r1 = %A_ScriptDir%\..\..\hoge.txt
    r2 := Path_Canonicalize(r1)
    msgbox,1,絶対パスへ,Path_Canonicalize(path)`n`n%r1%`n --> %r2%
    IfMsgBox,Cancel,    return
}
