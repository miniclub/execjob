/// バッチ処理の基底クラス
Class Job.Base Extends %CSP.WebSocket
{

/// The WebSocket Server.  Use the <Method>Read</Method> and <Method>Write</Method> methods
/// to receive data from, and send data to, the client.
/// Call the <Method>EndServer</Method> method to gracefully terminate the WebSocket Server.
/// A WebSocket operating asynchronously (<property>SharedConnection=1</property>) can exit this method
/// (using <b>Quit</B>) and subsequently open the WebSocket using the <Method>OpenServer</Method> method.
Method Server() As %Status
{
	try {
		set %log=$this
		set status=$$$OK
		
		// パラメータをJSON形式で読込む
		set jsonargs=..Read(.len,.status)

		// JSONデータをオブジェクトに変換		
		set arrayargs=##class(%DynamicAbstractObject).%FromJSON(jsonargs)
		set iter=arrayargs.%GetIterator()
		set args=0
		// パラメータを順に取得
		while iter.%GetNext(.key,.value) {
			
			set args=args+1
			if $isobject(value) {
				// オブジェクトの場合、ファイルの内容をストリームに入れる
				set stream=##class(%Stream.FileBinary).%New()
				set stream.Filename=##class(%File).GetFilename(value.name)
				set remain=value.size
				set ..BinaryData=1
				
				while remain>0 {
					// websocketから読込み、ストリームに登録
					set data=..Read(.len,.status)
					quit:$$$ISERR(status)
					do stream.Write(data)
					set remain=remain-len
				}
				// ストリームの属性としてファイル名を保存
				set args(args)=stream
				set ..BinaryData=0
			} else {
				set args(args)=value
			}
		}
		quit:$$$ISERR(status)		

		// 処理を実行
		set status=..OnProcess(args...)
	} catch err {
		set status=err.AsStatus()
	}
	kill %log
	if $$$ISERR(status) {
		do ..WriteLog($SYSTEM.Status.GetErrorText(status))
	}
	Set status=..EndServer()
	Quit $$$OK
}

/// バッチ処理
Method OnProcess() As %Status
{
	quit $$$ERROR($$$NotImplemented)
}

/// ログフォーマットを出力
Method WriteLog(log As %String)
{
	//do ..Write($zdatetime($horolog,3)_" "_$job_" "_log_$char(13,10))
	do ..Write($zdatetime($horolog,3)_" "_$job_" "_log_$char(10))
	quit
}

}
