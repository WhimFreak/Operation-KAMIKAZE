extends State

@export var speed: float = 250
@export var rotate_speed: float = 300
@export var min_trans_time: float = 5
@export var max_trans_time: float = 10
@export var state_after: State
@export var enhanced_state_after: State

@onready var navigation_agent_2d: NavigationAgent2D = %NavigationAgent2D
@onready var transition_timer: Timer = $TransitionTimer

var desired_dir: Vector2
var direction: Vector2

func enter():
	desired_dir = Vector2.RIGHT.rotated(actor.global_rotation) + Vector2(randf_range(-0.1, 0.1), randf_range(-0.1, 0.1))
	transition_timer.start(randf_range(min_trans_time, max_trans_time))
	
func physics_update(delta: float) -> void:
	actor.velocity = desired_dir * speed
	var collision = actor.move_and_collide(actor.velocity * delta)
	if collision:
		desired_dir = actor.velocity.bounce(collision.get_normal()).normalized()
	actor.health_bar.rotation_degrees += rotate_speed * delta

func _on_transition_timer_timeout() -> void:
	if actor.level == 2:
		transition(enhanced_state_after.name)
	else:
		transition(state_after.name)
