package rt.syncher.server.pipeline

import java.util.Iterator
import rt.syncher.server.pipeline.PipeMessage
import org.eclipse.xtend.lib.annotations.Accessors

class PipeContext {
	@Accessors(PUBLIC_GETTER) val PipeMessage message
	@Accessors(PUBLIC_GETTER) val PipeResource resource
	
	boolean inFail = false
	
	val Pipeline pipeline
	val Iterator<(PipeContext) => void> iter
	
	def getResourceUid() { return resource.uid }
	
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
		val register = pipeline.register
		val service = register.getService(message.service)
		
		if(service == null) {
			//send to internal service...
			try {
				service.apply(this)
			} catch(RuntimeException ex) {
				replyError(service.name, ex.message)
			}
		} else {
			println("OUT(" + message.to + "): " + message)
			register.eb.publish(message.to, message.toString)
		}
	}
	
	/** Does nothing to the pipeline flow and sends a reply back.
	 * @param reply Should be a new PipeMessage
	 */
	def void reply(PipeMessage reply) {
		println("REPLY: " + reply)
		resource.sendReply(reply)
	}
	
	/** Does nothing to the pipeline flow and sends a OK reply back with a pre formatted JSON schema.  
	 * @param rFrom The address that will be on "from".
	 */
	def void replyOK(String rFrom, String value) {
		val reply = new PipeMessage => [
			id = message.id
			cmd = PipeMessage.CMD_OK
			from = rFrom
			body = value
		]

		reply(reply)
	}
	
	/** Does nothing to the pipeline flow and sends a ERROR reply back with a pre formatted JSON schema. 
	 * @param rFrom The address that will be on "from".
	 * @param rError The error descriptor message.
	 */
	def void replyError(String rFrom, String rError) {
		val reply = new PipeMessage => [
			id = message.id
			cmd = PipeMessage.CMD_ERROR
			from = rFrom
			body = rError
		]
		
		reply(reply)
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
					fail("mn:/pipeline", ex.message)
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
	def fail(String from, String error) {
		if(!inFail) {
			inFail = true
			replyError(from, error)
			if(pipeline.failHandler != null) {
				pipeline.failHandler.handle(error)
			}
		}
	}
}