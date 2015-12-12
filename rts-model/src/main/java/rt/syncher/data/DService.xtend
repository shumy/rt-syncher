package rt.syncher.data

import org.eclipse.xtend.lib.annotations.Accessors
import java.util.HashMap
import rt.syncher.data.schema.Schema

class DService {
	@Accessors val String name
	
	val tables = new HashMap<String, DTable>
	
	new(String name) {
		this.name =  name
	}
	
	def getOrCreateTable(String name, Schema schema) {
		var table = tables.get(name)
		if (table == null) {
			table = new DTable
			tables.put(name, table)
		}
		
		return table
	}
}