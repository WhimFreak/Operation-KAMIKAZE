extends Relic

@export var time_mult: float = 0.8

func on_boost_start(player: Player):
	player.add_stat("Coffee", Player.Stats.TIME_MULTI, time_mult, false)
	
func on_boost_end(player: Player):
	player.add_stat("Coffee", Player.Stats.TIME_MULTI, (1 - time_mult) + 1, false)
