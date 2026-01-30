extends Node2D

@export var texture: TextureRect
@export var x_margin: float = 10
@export var y_margin: float = 10

var active: bool = true
var start_position: Vector2

func _ready() -> void:
	await get_tree().process_frame
	start_position = texture.global_position
	get_parent().hide()

func toggle(is_active: bool):
	active = is_active
	
func _process(delta: float) -> void:
	if not active:
		return
		
	var canvas := get_canvas_transform()
	var top_left := -canvas.origin / canvas.get_scale()
	var size := get_viewport_rect().size / canvas.get_scale()
	
	if start_position:
		texture.global_position = start_position
		set_sprite_pos(Rect2(top_left, size))
	
func set_sprite_pos(bounds: Rect2):
	texture.global_position.x = clamp(texture.global_position.x, bounds.position.x + x_margin, bounds.end.x - x_margin * 5)
	texture.global_position.y = clamp(texture.global_position.y, bounds.position.y + y_margin, bounds.end.y - y_margin * 4)
	
	texture.pivot_offset = texture.size / 2
	if bounds.has_point(global_position):
		texture.scale = Vector2.ONE
	else:
		texture.scale = Vector2(0.5, 0.5)
		
