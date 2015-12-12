package rt.syncher.game

import rt.syncher.Entity
import rt.syncher.Field
import rt.syncher.Command

@Entity("unit")
class Unit {
	@Field String type
	@Field Point position

	@Command 
	def fire(String type) {
	
	}
}