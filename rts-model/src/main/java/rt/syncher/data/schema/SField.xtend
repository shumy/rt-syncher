package rt.syncher.data.schema

import org.eclipse.xtend.lib.annotations.Accessors

class SField {
	@Accessors val String name
	@Accessors val String type

	new(String name, String type) {
		this.name = name
		this.type = type
	}
}