package rt.syncher.server.pipeline

import java.util.ArrayList
import io.vertx.core.Handler
import rt.syncher.server.pipeline.PipeMessage
import org.eclipse.xtend.lib.annotations.Accessors

class Pipeline {
	@Accessors(PUBLIC_GETTER) val PipeRegistry registry
	@Accessors Handler<String> failHandler = null
	
	val handlers = new ArrayList<(PipeContext) => void>
	
	def void process(PipeResource resource, PipeMessage msg) {
		val iter = handlers.iterator
		if(iter.hasNext) {
			val ctx = new PipeContext(this, resource, iter, msg)
			try {
				iter.next.apply(ctx)
			} catch(RuntimeException ex) {
				ctx.fail(ex.message)
				return
			}
		}
	}
	
	new(PipeRegistry registry) {
		this.registry = registry
	}
	
	def createResource(String uid, () => void closeCallback) {
		return new PipeResource(uid, this, closeCallback)
	}
	
	def void addHandler((PipeContext) => void handler) {
		handlers.add(handler)
	}
}