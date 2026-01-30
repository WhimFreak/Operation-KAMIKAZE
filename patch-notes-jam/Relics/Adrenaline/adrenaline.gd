extends Relic

@export var atk_speed_bonus: float = 1.35
@export var time_mult_bonus: float = 0.7
@export var move_speed_bonus: float = 1.2

var active: bool = false

func update(player: Player, _delta: float):
	if RunData.current_time > 60:
		active = false
		update_bonuses(player)
	else:
		active = true
		update_bonuses(player)
		
func update_bonuses(player: Player):
	if active:
		player.set_stat_mod("Adrenaline", Player.Stats.SHOTS_PER_SECOND, atk_speed_bonus, false)
		player.set_stat_mod("Adrenaline", Player.Stats.MOVE_SPEED, move_speed_bonus, false)
		player.set_stat_mod("Adrenaline", Player.Stats.TIME_MULTI, time_mult_bonus, false)
	else:
		player.set_stat_mod("Adrenaline", Player.Stats.SHOTS_PER_SECOND, 1, false)
		player.set_stat_mod("Adrenaline", Player.Stats.MOVE_SPEED, 1, false)
		player.set_stat_mod("Adrenaline", Player.Stats.TIME_MULTI, 1, false)
