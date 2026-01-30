extends Relic

const PLAYER_DAMAGE_CIRCLE = preload("uid://cwn5rqrrx236x")

@export var damage: float = 10
@export var duration: float = 0.8
@export var size: float = 1
@export var interval: float = 0.1
@export var transparency: float = 0.4

var timer: float = 0
var just_boosted: bool = false

func on_boost_start(player: Player):
	spawn_circle(player)
	timer = 0
	just_boosted = true
	
func on_boost_end(_player: Player):
	just_boosted = false
	
func update(player: Player, delta: float):
	if just_boosted:
		timer += delta
		
		if timer >= interval:
			spawn_circle(player)
			timer = 0
	
func spawn_circle(player: Player):
	var circle = PLAYER_DAMAGE_CIRCLE.instantiate()
	circle.duration = duration
	circle.damage = damage
	circle.final_size = size
	circle.global_position = player.global_position
	circle.transparency = transparency
	
	player.get_tree().get_first_node_in_group("Projectile Container").add_child(circle)
