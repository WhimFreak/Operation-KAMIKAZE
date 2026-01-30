class_name HostileBullet
extends Area2D

@export var projectile_speed: float = 800
@export var init_damage: float = 3

@onready var direction: Vector2 = Vector2.RIGHT.rotated(global_rotation)

func _physics_process(delta: float) -> void:
	direction = Vector2.RIGHT.rotated(global_rotation)
	position += projectile_speed * direction * delta
	

func _on_body_entered(body: Node2D) -> void:
	if body is TileMapLayer:
		recycle()
		
	elif body is Player:
		body.hit(self, init_damage)
		

func _on_body_exited(body: Node2D) -> void:
	if body is Player:
		body.damaging_objects.erase(self)


func recycle():
	if RunData.player:
		RunData.player.damaging_objects.erase(self)
	visible = false
	set_process(false)
	set_physics_process(false)
	set_deferred("monitoring", false)
	BulletPool.add_to_pool(self)
	
	
func enable():
	set_process(true)
	set_physics_process(true)
	visible = true
	set_deferred("monitoring", true)
	
	
