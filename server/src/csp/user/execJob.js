		// 引数の保存領域
		const savedargs =[];
		var execStatus=0; // 停止

		/// Websocket通信処理
		function connect(url,log) {
			// WebSocketを作成
			var ws = new WebSocket(url);

			// ソケットがOpenされたときのイベント処理
			ws.onopen = function(event) {
				let params = savedargs.shift()
				log.textContent = `${log.textContent}log - connected\n`;
				var files=new Array();
				// パラメータの送信
				params.forEach(function(elem,index){
					if( elem.constructor.name == "File") {
						// ファイルオブジェクトの場合、必要な情報をコピーする
						files.push(elem);
						params[index]={
								'lastModified': elem.lastModified,
								'name': elem.name,
								'size': elem.size,
								'type': elem.type
						};
					}
				}); 
				// パラメータリストを送信
				ws.send(JSON.stringify(params)); // パラメータ
				// ファイルパラメータがある場合、その内容を送信
				if( files.length>0) {
					ws.binaryType="arraybuffer";
					var reader = new FileReader();
					var rawData = new ArrayBuffer();
					reader.loadend = function() {
							ws.binaryType="blob";
						};
					reader.onload = function(e) {
						rawData = e.target.result;
						ws.send(rawData);
					}
					reader.readAsArrayBuffer(files[0]);
				}
			};
			// データを受信たときのイベント処理
			ws.onmessage = function(event) {
				log.textContent = `${log.textContent}${event.data}`;
			};
			// データを受信たときのイベント処理
			ws.onclose = function(event) {
				log.textContent = `${log.textContent}log - closed\n`;
				if( savedargs.length > 0) {
					// 次のWebsocketに接続
					setTimeout(function() {
						log.textContent+=`log - reconnect\n`;
						connect(url,log);
					}, 1000);					
				} else {
					execStatus = 0;
				}
			};
		}

		/// バッチ処理の実行
		function execJob(url,log,...args){

			// 引数をスタックに積んで終了
			savedargs.push(args);
			// 終了
			if( execStatus > 0) {
				return;
			}
			execStatus = 1;
			connect(url,log);

		}