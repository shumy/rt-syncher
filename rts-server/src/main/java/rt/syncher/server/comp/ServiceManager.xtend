package rt.syncher.server.comp

import rt.syncher.server.IComponent
import rt.syncher.server.pipeline.PipeContext

class ServiceManager implements IComponent {
	override def getName() { return "service" }
	
	override apply(PipeContext ctx) {
		if (ctx.session == null) {
			ctx.fail("No available session")
			return
		}
		
		//TODO: create and delete services
	}	
}