package rt.syncher.ctx

import org.eclipse.xtend.lib.annotations.Accessors
import rt.syncher.data.DService

class Context {
	@Accessors static var Session session
	@Accessors static var DService service
}