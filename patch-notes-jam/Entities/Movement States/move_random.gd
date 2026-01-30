extends State

@export var next_state: State
@export var min_dist: float = 250
@export var max_dist: float = 400
@export var speed: float = 150
@export var rotate_speed: float = 5
@export var constantly_rotates: bool

@onready var direction_rays: Node2D = $DirectionRays
@onready var top_ray: RayCast2D = $DirectionRays/TopRay
@onready var left_ray: RayCast2D = $DirectionRays/LeftRay
@onready var right_ray: RayCast2D = $DirectionRays/RightRay
@onready var bottom_ray: RayCast2D = $DirectionRays/BottomRay
@onready var navigation_agent_2d: NavigationAgent2D = %NavigationAgent2D
@onready var collision_check: RayCast2D = $CollisionCheck
@onready var unstuck_timer: Timer = $UnstuckTimer

var target_pos: Vector2
var direction: Vector2

func enter():
	randomize_directions()
	await get_tree().process_frame
	var arena_area: Control = get_tree().get_first_node_in_group("Arena Area")
	target_pos = to_global(get_random_valid_direction())
	target_pos.x = clamp(target_pos.x, arena_area.position.x, arena_area.size.x)
	target_pos.y = clamp(target_pos.y, arena_area.position.y, arena_area.size.y)
	
	await get_tree().create_timer(0.2).timeout
	collision_check.enabled = true
	unstuck_timer.start()
	
	
func exit():
	unstuck_timer.stop()
	collision_check.enabled = false
	target_pos = Vector2.ZERO
	
	
func physics_update(delta: float) -> void:
	if target_pos == Vector2.ZERO:
		return
	
	if (actor.global_position - target_pos).length() < 10 or collision_check.is_colliding():
		transition(next_state.name)
		return
		
	navigation_agent_2d.target_position = target_pos
	direction = actor.global_position.direction_to(navigation_agent_2d.get_next_path_position())
	var new_velocity = speed * direction
	
	if navigation_agent_2d.avoidance_enabled:
		navigation_agent_2d.set_velocity(new_velocity)
	else:
		_on_navigation_agent_2d_velocity_computed(new_velocity)
		
	actor.move_and_slide()
	
	if constantly_rotates:
		actor.rotation_degrees += rotate_speed * delta
	else:
		actor.rotation = lerp_angle(
			actor.rotation, (target_pos - actor.global_position).angle(), rotate_speed * delta)
	

func randomize_directions():
	var dist = randf_range(min_dist, max_dist)
	top_ray.target_position.y = -dist
	left_ray.target_position.x = -dist
	right_ray.target_position.x = dist
	bottom_ray.target_position.y = dist
	
	direction_rays.rotation_degrees = randf_range(0, 360)
	

func get_random_valid_direction():
	var valid_rays: Array[RayCast2D] = [top_ray, left_ray, right_ray, bottom_ray]
	for ray in valid_rays:
		if ray.is_colliding():
			valid_rays.erase(ray)
	
	return valid_rays.pick_random().target_position.rotated(direction_rays.rotation)
		

func _on_navigation_agent_2d_velocity_computed(safe_velocity: Vector2) -> void:
	actor.velocity = safe_velocity


func _on_unstuck_timer_timeout() -> void:
	transition(next_state.name)
