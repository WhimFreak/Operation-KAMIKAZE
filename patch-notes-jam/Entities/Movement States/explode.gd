extends ShootState

const AREA_EXPOSION = preload("uid://elc51myh3rvs")

@export var delay: float = 1
@export var final_size: float = 5
@export var warning_speed: float = 0.2
@export var explosion_speed: float = 2

var done_shooting: bool = false
var done_exploding: bool = false

func enter():
	super.enter()
	done_exploding = false
	done_shooting = false
	
	
func trigger_action():
	super.trigger_action()
	var explosion: Explosion = AREA_EXPOSION.instantiate()
	explosion.global_position = global_position
	explosion.delay = delay
	explosion.warning_speed = warning_speed
	explosion.explosion_speed = explosion_speed
	explosion.final_size = final_size
		
	get_tree().get_first_node_in_group("Enemy Container").call_deferred("add_child", explosion)
	explosion.finished.connect(
		func():
			done_exploding = true
			if done_shooting:
				transition(state_after.name))
	
	
func finish_attack():
	done_shooting = true
	if done_exploding:
		transition(state_after.name)
			
