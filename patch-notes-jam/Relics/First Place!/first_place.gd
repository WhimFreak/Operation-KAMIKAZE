extends Relic

@export var time_req: float

func on_stage_clear(player: Player, remaining_time: float):
	var dmg_gained = int(remaining_time / time_req)
	
	if dmg_gained > 0:
		player.show_popup_text("+ %s DAMAGE" % dmg_gained)
		player.add_stat(name, Player.Stats.DAMAGE, dmg_gained, true)
