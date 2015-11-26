package rt.syncher.server

import rt.syncher.server.pipeline.PipeContext

class SessionManager implements IComponent {
	override def getName() { return "serv:session" }
	
	override def apply(PipeContext ctx) {
		val msg = ctx.message
		
		if (msg.cmd == "login") {
			if(msg.from == null) {
				ctx.fail("No mandatory field 'from'")
				return
			}

			if(msg.service == null) {
				ctx.fail("No mandatory field 'service'")
				return
			}
			
			if (true /*TODO: verify password*/ ) {
				ctx.registry.deleteSession(ctx.resource.session);
				
				val session = ctx.registry.createSession(msg.from, msg.service, ctx.resource.uid)
				ctx.resource.session = session
				ctx.replyOK(session.token)
			} else {
				ctx.fail("Login fail")
			}
		}
		
		if (msg.cmd == "logout") {
			ctx.registry.deleteSession(ctx.resource.session);
			ctx.resource.session = null
			
			ctx.replyOK
		}
		
		if (msg.cmd == "session") {
			if(msg.token == null) {
				ctx.fail("No mandatory field 'token'")
				return	
			}
			
			val session = ctx.registry.resolve(msg.token)
			if(session == null) {
				ctx.fail("No available session")
				return
			}
			
			ctx.resource.session = session
			ctx.replyOK
		}
		
		if (msg.cmd == "close") {
			ctx.disconnect
		}

	}
}