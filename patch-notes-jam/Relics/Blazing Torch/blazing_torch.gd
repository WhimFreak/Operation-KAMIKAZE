extends Relic

const PLAYER_DAMAGE_CIRCLE = preload("uid://cwn5rqrrx236x")

@export var damage: float = 10
@export var size: float = 3
@export var transparency: float = 0.2

var circle: PlayerDamageCircle

func on_obtain(player: Player):
	circle = PLAYER_DAMAGE_CIRCLE.instantiate()
	circle.duration = 0
	circle.damage = damage
	circle.final_size = size
	circle.transparency = transparency
	
	player.add_child(circle)
