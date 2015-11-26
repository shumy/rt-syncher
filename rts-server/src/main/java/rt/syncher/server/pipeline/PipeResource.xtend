package rt.syncher.server.pipeline

import rt.syncher.server.pipeline.PipeMessage
import org.eclipse.xtend.lib.annotations.Accessors

class PipeResource {
	@Accessors(PUBLIC_GETTER) val String uid
	@Accessors PipeSession session
	
	val Pipeline pipeline
	val () => void closeCallback
	
	new(String uid, Pipeline pipeline, () => void closeCallback) {
		this.uid = uid
		this.pipeline = pipeline
		
		this.closeCallback = closeCallback
	}
	
	def void processMessage(PipeMessage msg) {
		pipeline.process(this, msg)
	}
	
	def void sendReply(PipeMessage reply) {
		pipeline.registry.eb.send(uid, reply.toString)
	}
	
	def void disconnect() {
		pipeline.registry.deleteSession(session)
		session = null
		
		closeCallback.apply
	}
}