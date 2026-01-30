extends State

const HOSTILE_BULLET = preload("uid://6oa8kg27uuq4")

@export var state_after: State
@export var bullet_amount: int = 5
@export_range(0, 360) var spread: float = 90
@export var projectile_speed: float = 400

@onready var bullet_source: Marker2D = $BulletSource

func enter():
	fire_bullets()
	transition(state_after.name)

func fire_bullets():
	for i in bullet_amount:	
		var bullet = BulletPool.take_from_pool()
		
		bullet.projectile_speed = projectile_speed
		bullet.global_position = bullet_source.global_position
		bullet.global_rotation = bullet_source.global_rotation
		
		if bullet_amount > 1:
			var rad_arc = deg_to_rad(spread)
			if bullet_amount < 3:
				rad_arc *= 0.25
			var spread_increment = rad_arc / (bullet_amount - 1 if spread < 360 else bullet_amount)
			bullet.global_rotation = (bullet_source.global_rotation + spread_increment * i - rad_arc / 2)
		else:
			bullet.global_rotation = bullet_source.global_rotation
		
		bullet.call_deferred("reparent", get_tree().get_first_node_in_group("Projectile Container"))
		bullet.enable()
