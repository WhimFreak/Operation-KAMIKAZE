extends CanvasLayer

@onready var timer_label: RichTextLabel = $TimerLabel
@onready var timer_animations: AnimationPlayer = $TimerAnimations

func _ready() -> void:
	RunData.time_reduced.connect(on_time_reduced)
	RunData.time_toggled.connect(on_time_toggled)

func _process(delta: float) -> void:
	timer_label.text = RunData.get_time_with_mil()

func on_time_reduced():
	if timer_animations.is_playing() and timer_animations.current_animation == &"freeze":
		return
	timer_animations.stop()
	timer_animations.play("reduce")

func on_time_toggled(on: bool):
	if on:
		timer_animations.play_backwards("freeze")
	else:
		timer_animations.play("freeze")
