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
			
			println("WS-OPEN")
			val resource = pipeline.createResource(ws.textHandlerID)[ws.close]
			
			ws.frameHandler[
				resource.processMessage(new PipeMessage(textData))
			]
						
			ws.closeHandler[
				println("WS-CLOSE")
			]
		]
	}
}