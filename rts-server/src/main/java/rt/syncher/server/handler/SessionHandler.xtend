package rt.syncher.server.handler

import rt.syncher.server.IComponent
import rt.syncher.server.pipeline.PipeContext
import rt.syncher.server.pipeline.PipeMessage
import java.util.UUID

class SessionHandler implements IComponent {
	override def getName() { return "handler:session" }

	override def apply(PipeContext ctx) {
		val msg = ctx.message
		
		if (msg.to == name) {
			if (msg.cmd == "open") {
				//register.bind(msg.from, ctx.resourceUid)
				//ctx.resource.user = msg.from
				
				val newToken = UUID.randomUUID.toString
				val user = msg.from
				val service = msg.service
				
				//TODO: bind token -> (user, service)
				
				
				ctx.replyOK(name, newToken)
				return
			}
			
			if (msg.cmd == "close") {
				//register.unbind(msg.from)
				
				//TODO: unbind token
				
				ctx.disconnect
				return
			}
		}
		
		//TODO: process token

		ctx.next
	}
}