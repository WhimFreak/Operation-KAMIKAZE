class_name Bullet
extends Area2D

@export var damage: float = 2
@export var projectile_speed: float = 800
@export var pierce: int = 1
@export var pierce_damage_loss: float = 0.75
@export var bounces: bool = false

@onready var direction: Vector2 = Vector2.RIGHT.rotated(global_rotation)
@onready var bounce_enemy_search_area: Area2D = $BounceEnemySearchArea

var nearby_enemies: Array[Enemy]

func _ready() -> void:
	if not bounces:
		bounce_enemy_search_area.monitoring = false

func _physics_process(delta: float) -> void:
	position += projectile_speed * direction * delta

func _on_body_entered(body: Node2D) -> void:
	if body is TileMapLayer:
		queue_free()
		
	elif body is Enemy and pierce > 0:
		if not body.is_dying:
			pierce -= 1
			body.take_damage(damage)
			nearby_enemies.erase(body)
			
			if pierce <= 0:
				queue_free()
			else:
				damage *= pierce_damage_loss
				if bounces and not nearby_enemies.is_empty():
					look_at(get_nearest_enemy().global_position)
					direction = Vector2.RIGHT.rotated(global_rotation)
				
func get_nearest_enemy():
	var nearest_enemy: Enemy
	for enemy in nearby_enemies:
		if not nearest_enemy:
			nearest_enemy = enemy
		elif global_position.distance_to(enemy.global_position) < global_position.distance_to(nearest_enemy.global_position):
			nearest_enemy = enemy
	
	return nearest_enemy


func _on_bounce_enemy_search_area_body_entered(body: Node2D) -> void:
	nearby_enemies.append(body)


func _on_bounce_enemy_search_area_body_exited(body: Node2D) -> void:
	nearby_enemies.erase(body)
