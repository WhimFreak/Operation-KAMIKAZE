extends Node2D

@onready var particles: Node2D = $Particles

var loaded: bool = false
var frames: int = 0

func _ready() -> void:
	for particle: GPUParticles2D in particles.get_children():
		particle.one_shot = true
		particle.modulate = Color.TRANSPARENT
		particle.emitting = true
		
		
func _physics_process(delta: float) -> void:
	if frames > 3:
		loaded = true
		set_physics_process(false)
	
	frames += 1
