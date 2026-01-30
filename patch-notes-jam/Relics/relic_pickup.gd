class_name RelicPickup
extends Area2D

@export var relic: Relic

@onready var relic_sprite: Sprite2D = $RelicSprite
@onready var tooltip_anim: AnimationPlayer = $TooltipAnim
@onready var relic_name: RichTextLabel = %RelicName
@onready var relic_desc: RichTextLabel = %RelicDesc
@onready var relic_anim: AnimationPlayer = $RelicAnim


var player_in_range: bool = false


func _ready() -> void:
	relic_sprite.texture = relic.sprite
	relic_name.text = relic.name
	relic_desc.text = relic.desc
	
	
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pickup") and player_in_range:
		player_in_range = false
		RunData.player.obtain_relic(relic)
		
		relic_anim.play("pickup")
		AudioManager.play_sfx("RelicPickup")
		await relic_anim.animation_finished
		queue_free()


func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		tooltip_anim.play("open_tooltip")
		player_in_range = true


func _on_body_exited(body: Node2D) -> void:
	tooltip_anim.play_backwards("open_tooltip")
	player_in_range = false
