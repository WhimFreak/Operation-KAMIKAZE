extends Relic

@export var time_gained: float = 30

func on_obtain(_player: Player):
	RunData.current_time += time_gained
	
func on_stage_clear(_player: Player, _remaining_time: float):
	RunData.current_time += time_gained
