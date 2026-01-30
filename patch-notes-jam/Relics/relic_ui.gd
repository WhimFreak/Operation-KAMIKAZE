class_name RelicUI
extends PanelContainer

signal tooltip_requested(relic: Relic)

@export var relic: Relic

@onready var icon: TextureRect = $Icon

func _ready() -> void:
	icon.texture = relic.sprite


func _on_mouse_entered() -> void:
	get_theme_stylebox("panel").set("border_color", Color.WHITE)
	tooltip_requested.emit(relic)
	

func _on_mouse_exited() -> void:
	get_theme_stylebox("panel").set("border_color", Color.TRANSPARENT)
	tooltip_requested.emit(null)
