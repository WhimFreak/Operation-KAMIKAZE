extends Node

@onready var sfx: Node = $SFX
@onready var dupes: Node = $Dupes
@onready var music: Node = $Music

func play_sfx(id: String, pitch: float = 1):
	var sound: AudioStreamPlayer = sfx.find_child(id)
	if sound.playing:
		var dupe: AudioStreamPlayer = sound.duplicate()
		dupes.add_child(dupe)
		dupe.finished.connect(func(): dupe.queue_free())
		
		dupe.pitch_scale = pitch
		dupe.play()
	else:
		sound.pitch_scale = pitch
		sound.play()
		
		
func play_music(id: String):
	var sound: AudioStreamPlayer = music.find_child(id)
	if sound:
		sound.play()

func get_sfx(id: String):
	return sfx.find_child(id)


func stop_music():
	for child: AudioStreamPlayer in music.get_children():
		child.stop()
		
