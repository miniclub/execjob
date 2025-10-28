Class JobCustom.UploadSample Extends %CSP.Page
{

/// Event handler for <b>PAGE</b> event: this is invoked in order to  
/// generate the content of a csp page.
ClassMethod OnPage() As %Status [ ServerOnly = 1 ]
{
	&html<
		<html>
		<script src="execJob.js"></script>
		<script language="javascript">
		
		function startJob() {
			// バッチ処理クラスのURL
			var url = ((window.location.protocol === "https:")? "wss:":"ws:")
                    + "//"+ window.location.host + "#(%request.URLPrefix_$SYSTEM.CSP.GetDefaultApp($namespace))#" + "/JobCustom.BatchProcess2.cls";
			// ログ出力領域
			var log = document.getElementById("proclog");

			// パラメータ値の取得
			var upfiles=document.getElementById("upfile").files;
			var num = document.getElementById("loopnum").value;
			var interval = document.getElementById("interval").value;
			for ( let i = 0 ; i < upfiles.length ; i++ ) 
			{
				let upfile=upfiles[i];

				// バッチジョブを実行
				execJob(url,log,upfile,num,interval);
			}
		}	
		</script>
		<body>
		<h2>バッチ処理サンプル</h2>
		<p>アップロードファイル <input type="file" id="upfile" multiple></p>
		<p>処理回数 <input type="number" max=100 min=5 id="loopnum" value="10"></p>
		<p>待ち時間 <input type="number" max=60 min=1 id="interval" value="1"></p>
		<button id="execbtn" onclick="startJob();">実行</button>

		<h3>処理結果</h3>
		
		<textarea rows="30" cols="80" readonly id="proclog"></textarea>
		
		</body>
		</html>
	>
	
	Quit $$$OK
}

}
