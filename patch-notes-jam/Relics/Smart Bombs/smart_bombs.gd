extends Relic

@export var bomb_speed: float = 200

func modify_bomb(_player: Player, bomb: PlayerBomb):
	bomb.projectile_speed += bomb_speed
	bomb.homing = true
	
	return bomb
