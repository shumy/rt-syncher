package rt.syncher.server.pipeline

import rt.syncher.server.pipeline.PipeMessage
import org.eclipse.xtend.lib.annotations.Accessors

class PipeResource {
	@Accessors(PUBLIC_GETTER) val String uid
	@Accessors String user
	
	val Pipeline pipeline
	
	val () => void closeCallback
	val (String) => void replyCallback
	
	new(String uid, Pipeline pipeline, () => void closeCallback, (String) => void replyCallback) {
		this.uid = uid
		this.pipeline = pipeline
		
		this.closeCallback = closeCallback
		this.replyCallback = replyCallback
	}
	
	def void processMessage(PipeMessage msg) {
		pipeline.process(this, msg)
	}
	
	def void sendReply(PipeMessage msg) {
		replyCallback.apply(msg.toString)
	}
	
	def void disconnect() {
		closeCallback.apply
	}
}