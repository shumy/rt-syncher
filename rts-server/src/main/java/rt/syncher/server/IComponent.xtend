package rt.syncher.server

import rt.syncher.server.pipeline.PipeContext

interface IComponent extends (PipeContext) => void {
	def String getName()
}