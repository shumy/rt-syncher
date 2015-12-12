package rt.syncher.data.schema

import java.util.List
import org.eclipse.xtend.lib.annotations.Accessors

class Schema {
	@Accessors val List<SField> fields
	
	new(List<SField> fields) {
		this.fields = fields
	}
}