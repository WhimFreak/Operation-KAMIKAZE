extends CanvasLayer

@onready var anims: AnimationPlayer = $Anims
@onready var bomb_scene: Control = $BombScene
@onready var music_slider: HSlider = %MusicSlider
@onready var sfx_slider: HSlider = %SFXSlider

func _physics_process(_delta: float) -> void:
	if ParticlesLoader.loaded:
		set_physics_process(false)
		
		bomb_scene.show()
		anims.play("intro")
		
		music_slider.value = AudioServer.get_bus_volume_linear(1)
		sfx_slider.value = AudioServer.get_bus_volume_linear(2)
	

func _on_play_button_pressed() -> void:
	AudioManager.stop_music()
	TransitionScreen.change_scene("res://Main Scenes/base_scene.tscn")


func _on_music_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_linear(1, value)
	

func _on_sfx_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_linear(2, value)
	
	
func play_sfx(id: String, pitch: float = 1):
	AudioManager.play_sfx(id, pitch)
	
	
func play_menu_music():
	AudioManager.play_music("Menu")
