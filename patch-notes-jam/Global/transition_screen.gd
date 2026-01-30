extends CanvasLayer

@onready var animation_player: AnimationPlayer = $AnimationPlayer

var goal_path: String
var has_loaded: bool = false

func change_scene(path: String):
	get_tree().paused = true
	animation_player.play("trans_in")
	await animation_player.animation_finished
	
	ResourceLoader.load_threaded_request(path)
	goal_path = path
	
func _process(delta: float) -> void:
	if goal_path == "": return 
	
	var status = ResourceLoader.load_threaded_get_status(goal_path)
	if status == ResourceLoader.THREAD_LOAD_LOADED:
		var new_scene = ResourceLoader.load_threaded_get(goal_path)
		get_tree().change_scene_to_packed(new_scene)
			
		animation_player.play_backwards("trans_in")
		get_tree().paused = false
