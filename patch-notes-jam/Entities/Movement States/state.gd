class_name State
extends Node2D

signal transition_requested(state_id: String)

var actor: Enemy

func enter():
	pass
	
func exit():
	pass
	
func update(_delta: float):
	pass
	
func physics_update(_delta: float) -> void:
	pass

func transition(state_id: String):
	transition_requested.emit(state_id)
