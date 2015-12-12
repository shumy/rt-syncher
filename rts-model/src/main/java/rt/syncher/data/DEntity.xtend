package rt.syncher.data

import org.eclipse.xtend.lib.annotations.Accessors
import rt.syncher.data.schema.Schema

abstract class DEntity {
	@Accessors(PUBLIC_GETTER, PACKAGE_SETTER) var long id = 0

	protected var DTable table = null	
	protected static var Schema schema = null
}