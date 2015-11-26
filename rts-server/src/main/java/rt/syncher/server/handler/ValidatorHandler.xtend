package rt.syncher.server.handler

import rt.syncher.server.IComponent
import rt.syncher.server.pipeline.PipeContext

class ValidatorHandler implements IComponent {

	override def getName() { return "handler:validator" }

	override def apply(PipeContext ctx) {
		val msg = ctx.message
		
		if(msg.cmd == null)
			ctx.fail("No mandatory field 'cmd'")

		if(msg.to == null)
			ctx.fail("No mandatory field 'to'")

		ctx.next
	}
}