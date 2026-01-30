extends Node

signal time_reduced
signal time_toggled(active: bool)

var player: Player
var current_time: float:
	set(value):
		current_time = clamp(value, 0, 599)

var timer_active: bool = false:
	set(value):
		timer_active = value
		time_toggled.emit(value)

func start_timer(amount: float):
	current_time = amount
	timer_active = true

func _process(delta: float) -> void:
	var mult: float = 1
	if player:
		mult = player.get_stat(Player.Stats.TIME_MULTI)
		
	if timer_active:
		current_time -= delta * mult
		
func reduce_time(amount: float):
	current_time -= amount
	time_reduced.emit()
		
func get_time_with_mil():
	var mil = fmod(current_time, 1) * 100
	var sec = fmod(current_time, 60)
	var minu = current_time / 60
	
	var string = "%2d: %02d: %02d" % [minu, sec, mil]
	return string
	
func get_time():
	var sec = fmod(current_time, 60)
	var minu = current_time / 60
	
	var string = "%2d:%02d" % [minu, sec]
	return string
	
func get_seconds():
	return str(current_time)
