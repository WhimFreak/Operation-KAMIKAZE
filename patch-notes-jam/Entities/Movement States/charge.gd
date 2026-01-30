extends State

@export var state_after: State
@export var charge_speed: float = 800
@export var charge_delay: float = 1
@export var rotate_speed: float = 10

@onready var wall_check: RayCast2D = $WallCheck
@onready var danger_indicator: Line2D = $DangerIndicator
@onready var navigation_agent_2d: NavigationAgent2D = %NavigationAgent2D
@onready var charge_delay_timer: Timer = $ChargeDelayTimer

var direction: Vector2
var charging: bool = false


func enter():
	charging = false
	actor.set_collision_mask_value(3, false)
	actor.navigation_agent_2d.set_avoidance_layer_value(3, false)
	charge_delay_timer.start(charge_delay)
	

func exit():
	danger_indicator.clear_points()
	actor.set_collision_mask_value(3, true)
	actor.navigation_agent_2d.set_avoidance_layer_value(3, true)

func physics_update(delta: float) -> void:
	actor.health_bar.rotation = lerp_angle(actor.health_bar.rotation, 0, rotate_speed * delta)
	
	if not charging:
		handle_aiming(delta)
	else:
		handle_movement(delta)
		

func handle_aiming(delta: float):
	wall_check.rotation = lerp_angle(
		wall_check.rotation, (RunData.player.global_position - actor.global_position).angle() - actor.rotation, rotate_speed * delta)
	actor.rotation = lerp_angle(
		actor.rotation, (RunData.player.global_position - actor.global_position).angle(), rotate_speed * delta)
	direction = Vector2.RIGHT.rotated(actor.rotation).normalized()
	
	danger_indicator.clear_points()
	
	danger_indicator.add_point(Vector2.ZERO)
	danger_indicator.add_point(to_local(wall_check.get_collision_point()))
	
	
func handle_movement(delta: float):
	danger_indicator.clear_points()
	
	actor.look_at(actor.global_position + direction)
		
	actor.velocity = direction * charge_speed
	var collision = actor.move_and_collide(actor.velocity * delta)
	if collision:
		AudioManager.play_sfx("WallCollide")
		transition(state_after.name)


func _on_charge_delay_timer_timeout() -> void:
	charging = true
	
