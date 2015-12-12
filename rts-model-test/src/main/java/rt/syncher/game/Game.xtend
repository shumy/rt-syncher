package rt.syncher.game

import rt.syncher.Service
import rt.syncher.RefList
import rt.syncher.Command

@Service
class Game {
	@RefList Unit units

	@Command 
	def createUnit(String type) {
		//val unit = new Unit(type)
		//units += unit

		//return unit.id
	}
}