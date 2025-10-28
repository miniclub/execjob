/// バッチ処理サンプル
Class JobCustom.BatchProcess2 Extends Job.Base
{

/// バッチ処理
Method OnProcess(file As %Stream.Object, num, interval) As %Status
{
	if $isobject(file) {
		//ファイル情報の取得
		set data=file.Read(80)
		set dump=""
		for i=1:1:80 {
			set dump=dump_$select(i>1:" ",1:"")_$zhex($ascii($extract(data,i)))
		}
		do ..WriteLog("ダンプ情報:"_dump)
	}
	for i=1:1:num {
		hang interval
		do ..WriteLog("ログ出力"_i)
	}
	quit $$$OK
}

}
