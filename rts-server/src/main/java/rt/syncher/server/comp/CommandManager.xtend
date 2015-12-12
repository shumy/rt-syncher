package rt.syncher.server.comp

import rt.syncher.server.IComponent
import rt.syncher.server.pipeline.PipeContext

class CommandManager implements IComponent {
	override def getName() { return "cmd" }
	
	override def apply(PipeContext ctx) {
		if (ctx.session == null) {
			ctx.fail("No available session")
			return
		}
		
		//TODO: get service-database from registry
		//TODO: get entity from service-database 
		//TODO: invoke method on entity
		//TODO: process result and reply
	}
}