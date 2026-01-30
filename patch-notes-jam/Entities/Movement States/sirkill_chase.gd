extends Chase

const AREA_EXPOSION = preload("uid://elc51myh3rvs")

@export var state_after: State
@export var explosion_interval: float = 0.5
@export var delay: float = 1
@export var final_size: float = 5
@export var warning_speed: float = 0.2
@export var explosion_speed: float = 2

@onready var duration_timer: Timer = $DurationTimer
@onready var explosion_timer: Timer = $ExplosionTimer


func enter():
	super.enter()
	duration_timer.start()
	explosion_timer.start(explosion_interval)
	
	
func exit():
	explosion_timer.stop()
	
	
func explode():
	var explosion: Explosion = AREA_EXPOSION.instantiate()
	var arena = get_tree().get_first_node_in_group("Arena Area")
	explosion.global_position = Vector2(randf_range(arena.position.x, arena.size.x),
	randf_range(arena.position.y, arena.size.y))
	explosion.delay = delay
	explosion.warning_speed = warning_speed
	explosion.explosion_speed = explosion_speed
	explosion.final_size = final_size
		
	get_tree().get_first_node_in_group("Enemy Container").call_deferred("add_child", explosion)
	
	
func _on_duration_timer_timeout() -> void:
	transition(state_after.name)


func _on_explosion_timer_timeout() -> void:
	explode()
