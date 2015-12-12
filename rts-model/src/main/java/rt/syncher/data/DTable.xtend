package rt.syncher.data

import java.util.HashMap

class DTable {
	var eID = 0L
	val entities = new HashMap<Long, DEntity>
	
	def getEntity(long id) { return entities.get(id) }
	
	def void createEntity(DEntity entity) {
		eID++
		
		entity.id = eID
		entities.put(eID, entity)
		
		//TODO: fire create event
	}
	
	def void deleteEntity(DEntity entity) {
		entities.remove(entity.id)
		
		//TODO: fire delete event
	}
}