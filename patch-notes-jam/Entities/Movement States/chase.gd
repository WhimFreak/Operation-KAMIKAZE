class_name Chase
extends State

@export var speed: float = 250
@export var enhanced_speed: float = 350
@export var rotate_speed: float = 5

@onready var navigation_agent_2d: NavigationAgent2D = %NavigationAgent2D

var direction: Vector2
var cur_speed: float


func enter():
	cur_speed = 0

	
func physics_update(delta: float) -> void:
	var player: Player = RunData.player
	if not player:
		return
	
	var speed_used: float
	if actor.level == 2:
		speed_used = enhanced_speed
	else:
		speed_used = speed
		
	
	cur_speed = lerp(cur_speed, speed_used, 5 * delta)
		
	
	navigation_agent_2d.target_position = player.global_position
	direction = actor.global_position.direction_to(navigation_agent_2d.get_next_path_position())
	
	var new_velocity = cur_speed * direction
	
	if navigation_agent_2d.avoidance_enabled:
		navigation_agent_2d.set_velocity(new_velocity)
	else:
		_on_navigation_agent_2d_velocity_computed(new_velocity)
		
	actor.move_and_slide()
	
	actor.rotation = lerp_angle(
		actor.rotation, (player.global_position - actor.global_position).angle(), rotate_speed * delta)

func _on_navigation_agent_2d_velocity_computed(safe_velocity: Vector2) -> void:
	actor.velocity = safe_velocity
