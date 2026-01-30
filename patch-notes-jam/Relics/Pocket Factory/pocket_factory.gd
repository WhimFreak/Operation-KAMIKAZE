extends Relic

@export var shots_req: int = 15

var shot_counter: int = 0

func on_shoot(player: Player):
	shot_counter += 1
	print(shot_counter)
	
	if shot_counter >= shots_req:
		shot_counter = 0
		player.player_attack.recharge_bomb()
