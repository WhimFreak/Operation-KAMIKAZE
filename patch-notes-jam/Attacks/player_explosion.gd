class_name PlayerExplosion
extends Area2D

@export var final_size: float = 5
@export var explosion_speed: float = 2
@export var damage: float = 3

func _ready() -> void:
	final_size *= 2
	
	var tween := create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE).set_parallel(true)
	tween.tween_property(self, "scale", Vector2(final_size, final_size), explosion_speed)
	
	await tween.finished
	tween = create_tween()
	tween.tween_property(self, "modulate", Color.TRANSPARENT, 0.2)
	
	await tween.finished
	
	queue_free()


func _on_body_entered(body: Node2D) -> void:
	if body is Enemy:
		body.take_damage(damage)
