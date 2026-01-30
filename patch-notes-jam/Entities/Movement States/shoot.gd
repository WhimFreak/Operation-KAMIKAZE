class_name ShootState
extends State

@export var state_after: State
@export var rotate_speed: float = 10
@export var constantly_rotates: bool

@export_group("Bullet")
@export var bullet: PackedScene
@export var sources_parent: Node2D
@export var projectile_speed: float = 350
@export var burst_count: int = 1
@export var enhanced_burst_count: int = 1
@export var bullet_count: int = 1
@export_range(0, 360) var spread: float = 45
@export var delay_between_shots: float = 0.2
@export var size: float = 1
@export var aim_towards_player: bool = false
@export var max_innacuracy: float = 0

@onready var windup_anim: AnimationPlayer = $WindupAnim

var can_shoot: bool = false

func enter():
	can_shoot = true
	windup_anim.play("windup")
	

func exit():
	can_shoot = false

	
func physics_update(delta: float) -> void:
	if constantly_rotates:
		actor.rotation_degrees += rotate_speed * delta
	else:
		actor.rotation = lerp_angle(
			actor.rotation, (RunData.player.global_position - actor.global_position).angle(), rotate_speed * delta)

func trigger_action():
	var burst_count_used: int = 0
	if actor.level == 2:
		burst_count_used = enhanced_burst_count
	else:
		burst_count_used = burst_count
	
	for i in burst_count_used:
		var angle_offset: float = randf_range(-max_innacuracy, max_innacuracy)
		if not can_shoot:
			break
		
		AudioManager.play_sfx("EnemyShoot", randf_range(0.9, 1.1))
		
		for source in sources_parent.get_children():
			
			for num in bullet_count:
				var instance = BulletPool.take_from_pool()
				var base_rotation
				instance.projectile_speed = projectile_speed
				instance.global_position = source.global_position
				instance.scale = Vector2(size, size)
				if aim_towards_player:
					base_rotation = (RunData.player.global_position - actor.global_position).angle() + angle_offset
				else:
					base_rotation = source.global_rotation + angle_offset
				
				if bullet_count > 1:
					var rad_arc = deg_to_rad(spread)
					if bullet_count < 3:
						rad_arc *= 0.25
					var spread_increment = rad_arc / (bullet_count - 1 if spread < 360 else bullet_count)
					instance.global_rotation = (base_rotation + spread_increment * num - rad_arc / 2)
				else:
					instance.global_rotation = base_rotation
				
				instance.call_deferred("reparent", get_tree().get_first_node_in_group("Projectile Container"))
				instance.enable()
				
		await get_tree().create_timer(delay_between_shots).timeout
		
	finish_attack()
		
func finish_attack():
	transition(state_after.name)
