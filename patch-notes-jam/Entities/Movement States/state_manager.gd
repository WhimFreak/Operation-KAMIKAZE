class_name StateManager
extends Node2D

@export var default_state: State

var current_state: State

func _ready() -> void:
	for child in get_children():
		if child is State:
			child.actor = get_parent()
			child.transition_requested.connect(switch_to_state)

func setup():
	if default_state:
		current_state = default_state
		current_state.enter()
	
func switch_to_state(id: String):
	var prev_state = current_state
	var new_state: State = find_child(id)
	
	if new_state == prev_state:
		return
		
	if new_state:
		if prev_state:
			prev_state.exit()
		current_state = new_state
		new_state.enter()
		
		
func update(delta: float):
	if current_state:
		current_state.update(delta)
	
	
func physics_update(delta: float):
	if current_state:
		current_state.physics_update(delta)


func exit_all():
	if current_state:
		current_state.exit()
		current_state = null
