class_name Explosion
extends Node2D

signal finished

@export var delay: float = 1
@export var final_size: float = 5
@export var warning_speed: float = 0.2
@export var explosion_speed: float = 2
@export var damage: float = 3

@onready var explosion: Area2D = $Explosion
@onready var explosion_sprite: Sprite2D = $Explosion/ExplosionSprite
@onready var explosion_warning: Sprite2D = $ExplosionWarning
@onready var delay_timer: Timer = $DelayTimer

var done: bool = false

func _ready() -> void:
	
	if delay <= 0:
		_on_timer_timeout()
		return
		
	var tween := create_tween()
	tween.tween_property(explosion_warning, "scale", Vector2(final_size * 0.9, final_size * 0.9), warning_speed)
	
	delay_timer.start(delay)

func _on_timer_timeout() -> void:
	explosion_warning.hide()
	AudioManager.play_sfx("BombExplode", randf_range(0.5, 0.7))
	
	var tween := create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE).set_parallel(true)
	tween.tween_property(explosion, "scale", Vector2(final_size, final_size), explosion_speed)
	
	await tween.finished
	tween = create_tween()
	tween.tween_property(explosion, "modulate", Color.TRANSPARENT, 0.2)
	
	await tween.finished
	
	done = true
	finished.emit()
	
	get_tree().get_first_node_in_group("Enemy Spawner").check_enemies()
	queue_free()

func _on_explosion_area_body_entered(body: Node2D) -> void:
	if body is Player:
		body.hit(self, damage)


func _on_explosion_area_body_exited(body: Node2D) -> void:
	if body is Player:
		body.damaging_objects.erase(self)
