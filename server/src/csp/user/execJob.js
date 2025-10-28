		/// バッチ処理の実行
		function execJob(url,log,...args){

			// WebSocketを作成
			const ws = new WebSocket(url);

			// ソケットがOpenされたときのイベント処理
			ws.onopen = function(event) {
				log.textContent = `${log.textContent}log - connected\n`;
				var files=new Array();
				// パラメータの送信
				args.forEach(function(elem,index){
					if( elem.constructor.name == "File") {
						// ファイルオブジェクトの場合、必要な情報をコピーする
						files.push(elem);
						args[index]={
								'lastModified': elem.lastModified,
								'name': elem.name,
								'size': elem.size,
								'type': elem.type
						};
					}
				}); 
				// パラメータリストを送信
				ws.send(JSON.stringify(args)); // パラメータ
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
			};
		}