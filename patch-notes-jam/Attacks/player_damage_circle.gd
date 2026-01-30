class_name PlayerDamageCircle
extends Area2D

@export var damage: float
@export var duration: float
@export var final_size: float
@export var transparency: float = 0.5

@onready var duration_timer: Timer = $DurationTimer
@onready var sprite_2d: Sprite2D = $Sprite2D

var enemies_in_range: Array[Enemy]


func _ready() -> void:
	modulate = Color(1, 1, 1, transparency)
	var tween := create_tween()
	tween.tween_property(self, "scale", Vector2(final_size, final_size), 0.2)
	
	if duration > 0:
		duration_timer.start(duration)


func _process(delta: float) -> void:
	sprite_2d.rotation_degrees += 50 * delta


func _on_damage_timer_timeout() -> void:
	for enemy in enemies_in_range:
		enemy.take_damage(damage)


func _on_body_entered(body: Node2D) -> void:
	enemies_in_range.append(body)


func _on_body_exited(body: Node2D) -> void:
	enemies_in_range.erase(body)


func _on_duration_timer_timeout() -> void:
	var tween := create_tween()
	tween.tween_property(self, "modulate", Color.TRANSPARENT, 0.2)
	await tween.finished
	queue_free()
