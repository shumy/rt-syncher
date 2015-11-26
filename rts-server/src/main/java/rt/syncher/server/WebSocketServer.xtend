package rt.syncher.server

import io.vertx.core.http.HttpServer
import rt.syncher.server.pipeline.Pipeline
import rt.syncher.server.pipeline.PipeMessage

class WebSocketServer {
	def static void init(HttpServer server, Pipeline pipeline) {
		server.websocketHandler[ ws |
			if(ws.uri != "/ws") {
				ws.reject
			}
			
			val () => void onClose = [ws.close]
			val (String) => void onReply = [ws.writeFinalTextFrame(it)]
						
			println("WS-OPEN")
			val resource = pipeline.createResource(ws.textHandlerID, onClose, onReply)
			
			ws.frameHandler[
				resource.processMessage(new PipeMessage(textData))
			]
						
			ws.closeHandler[
				println("WS-CLOSE")
			]
		]
	}
}