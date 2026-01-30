class_name PlayerBomb
extends CharacterBody2D

const PLAYER_EXPLOSION = preload("uid://cl5mu1kms3oje")

@export var projectile_speed: float = 800
@export var explosion_damage: float = 20
@export var explosion_speed: float
@export var final_size: float
@export var homing: bool = false
@export var rotation_speed: float = 6

@onready var direction: Vector2 = Vector2.RIGHT.rotated(global_rotation)
@onready var homing_enemy_detection: Area2D = $HomingEnemyDetection

var nearby_enemies: Array[Enemy]

func _ready() -> void:
	if not homing:
		homing_enemy_detection.monitoring = false


func _physics_process(delta: float) -> void:
	rotation_degrees += 300 * delta
	
	if homing and not nearby_enemies.is_empty():
		direction = lerp(direction, global_position.direction_to(get_nearest_enemy().global_position), rotation_speed * delta)
	velocity = projectile_speed * direction
	
	var collision = move_and_collide(velocity * delta)
	if collision:
		explode()
	

func get_nearest_enemy():
	var nearest_enemy: Enemy
	for enemy in nearby_enemies:
		if not nearest_enemy:
			nearest_enemy = enemy
		elif global_position.distance_to(enemy.global_position) < global_position.distance_to(nearest_enemy.global_position):
			nearest_enemy = enemy
	
	return nearest_enemy
	
func explode():
	var explosion: PlayerExplosion = PLAYER_EXPLOSION.instantiate()
	explosion.global_position = global_position
	explosion.explosion_speed = explosion_speed
	explosion.final_size = final_size
	explosion.damage = explosion_damage
	
	for relic in RunData.player.relics:
		relic.on_bomb_explode(RunData.player, self)
	
	AudioManager.play_sfx("BombExplode", randf_range(1.4, 1.5))
	get_tree().get_first_node_in_group("Projectile Container").call_deferred("add_child", explosion)
	queue_free()


func _on_homing_enemy_detection_body_entered(body: Node2D) -> void:
	nearby_enemies.append(body)


func _on_homing_enemy_detection_body_exited(body: Node2D) -> void:
	nearby_enemies.erase(body)
