package rt.syncher.server.pipeline

import java.util.Iterator
import rt.syncher.server.pipeline.PipeMessage
import org.eclipse.xtend.lib.annotations.Accessors

class PipeContext {
	@Accessors val PipeMessage message
	@Accessors val PipeResource resource
	
	def getRegistry() { return pipeline.registry }
	def getSession() { return resource.session }
	
	boolean inFail = false
	
	val Pipeline pipeline
	val Iterator<(PipeContext) => void> iter
	
	new(Pipeline pipeline, PipeResource resource, Iterator<(PipeContext) => void> iter, PipeMessage message) {
		println("IN: " + message)
		this.pipeline = pipeline
		this.resource = resource
		this.iter = iter
		this.message = message
	}
	
	/** Sends the context to the delivery destination. Normally this methods is called in the end of the pipeline process.
	 *  So most of the time there is no need to call this.
	 */
	def void deliver() {
		if(!inFail) {
			val comp = registry.getComponent(message.to)
			if(comp != null) {
				println("DELIVER(" + message.to + "): " + message)
				try {
					comp.apply(this)
				} catch(RuntimeException ex) {
					ex.printStackTrace
					replyError(ex.message)
				}
			} else {
				println("NO-DELIVER(" + message.to + "): " + message)
			}	
		}
	}
	
	/** Does nothing to the pipeline flow and sends a reply back.
	 * @param reply Should be a new PipeMessage
	 */
	def void reply(PipeMessage reply) {
		if(!inFail) {
			println("REPLY: " + reply)
			resource.sendReply(reply)	
		}
	}
	
	/** Does nothing to the pipeline flow and sends a OK reply back with a pre formatted JSON schema.  
	 */
	def void replyOK() {
		if(!inFail) {
			val reply = new PipeMessage => [
				id = message.id
				cmd = PipeMessage.CMD_OK
				from = message.to
			]
	
			reply(reply)			
		}
	}
	
	/** Does nothing to the pipeline flow and sends a OK reply back with a pre formatted JSON schema.
	 * @param value The address that will be on "from".
	 */
	def void replyOK(String value) {
		if(!inFail) {
			val reply = new PipeMessage => [
				id = message.id
				cmd = PipeMessage.CMD_OK
				from = message.to
				body = value
			]
	
			reply(reply)			
		}
	}
	
	/** Does nothing to the pipeline flow and sends a ERROR reply back with a pre formatted JSON schema. 
	 * @param error The error descriptor message.
	 */
	def void replyError(String error) {
		if(!inFail) {
			val reply = new PipeMessage => [
				id = message.id
				cmd = PipeMessage.CMD_ERROR
				from = message.to
				body = error
			]
			
			reply(reply)	
		}
	}
	
	/** Order the underlying resource channel to disconnect. But the client can be configured to reconnect, so most of the times a reconnection is made by the client.
	 * To avoid this, the method should only be used when the client orders the disconnection.
	 */
	def void disconnect() {
		resource.disconnect
	}
	
	/** Used by interceptors, order the pipeline to execute the next interceptor. If no other interceptor exits, a delivery is proceed.
	 */
	def next() {
		if(!inFail) {
			if(iter.hasNext) {
				try {
					iter.next.apply(this)
				} catch(RuntimeException ex) {
					fail(ex.message)
				}
			} else {
				deliver
			}
		}
	}
	
	/** Interrupts the pipeline flow and sends an error message back to the original "from". After this, other calls to "next()" or "fail(..)" are useless.
	 * @param from The address that will be on reply "header.from".
	 * @param error The error descriptor message.
	 */
	def fail(String error) {
		if(!inFail) {
			inFail = true
			replyError(error)
			if(pipeline.failHandler != null) {
				pipeline.failHandler.handle(error)
			}
		}
	}
}