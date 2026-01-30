class_name TraversalManager
extends Node2D

signal room_entered(room: RoomInfo)

@export var encounter_rooms: Array[RoomInfo]
@export var boss_room: RoomInfo
@export var relic_room: RoomInfo
@export var final_room: RoomInfo

@onready var open_walls: Control = $OpenWalls
@onready var tile_map: Node2D = %TileMap
@onready var arena_area: Control = $ArenaArea
@onready var projectile_container: Node2D = %ProjectileContainer

@onready var top: Area2D = $TraversalAreas/Top
@onready var left: Area2D = $TraversalAreas/Left
@onready var right: Area2D = $TraversalAreas/Right
@onready var bottom: Area2D = $TraversalAreas/Bottom

var sides: Array[String] = ["Top", "Left", "Right", "Bottom"]
var side_rooms: Dictionary[String, RoomInfo] = {
	"Top": null,
	"Left": null,
	"Right": null,
	"Bottom": null
	}
var last_travelled_side: String

var boss_room_appearance: int = 9
var relic_appearance: Array[int]

func _ready() -> void:
	top.body_entered.connect(on_traversal_area_entered.bind("Top"))
	left.body_entered.connect(on_traversal_area_entered.bind("Left"))
	right.body_entered.connect(on_traversal_area_entered.bind("Right"))
	bottom.body_entered.connect(on_traversal_area_entered.bind("Bottom"))

func setup_options(amount: int, room: int, stage: int = 1):
	var valid_sides: Array[String] = sides.duplicate()
	valid_sides.erase(last_travelled_side)
	var open_sides: Array[String] = []
	
	var valid_rewards: Array[RoomInfo] = encounter_rooms.duplicate()
	valid_rewards.shuffle()
	
	if stage == 4:
		valid_rewards = [final_room]
		amount = 1
	
	elif relic_appearance.has(room):
		valid_rewards = [valid_rewards.pick_random(), relic_room]
	
	elif room == boss_room_appearance:
		valid_rewards = [boss_room]
		amount = 1
		
	
	for i in amount:
		var random_side: String = valid_sides.pop_at(randi_range(0, valid_sides.size() - 1))
		open_sides.append(random_side)
		
		var random_reward = valid_rewards.pop_at(randi_range(0, valid_rewards.size() - 1))
		side_rooms[random_side] = random_reward

		var shadow = open_walls.find_child(random_side)
		var tile_wall = tile_map.find_child(random_side)
		var icon = shadow.find_child("RoomInfo").find_child("RoomIcon")
		var label = shadow.find_child("RoomInfo").find_child("RoomLabel")
		
		shadow.show()
		tile_wall.enabled = false
		icon.texture = side_rooms[random_side].icon
		label.text = side_rooms[random_side].label
		

func reset():
	for side in sides:
		var shadow = open_walls.find_child(side)
		var tile_wall = tile_map.find_child(side)
		
		shadow.hide()
		tile_wall.enabled = true
		
	side_rooms = {
	"Top": null,
	"Left": null,
	"Right": null,
	"Bottom": null
	}
		
func on_traversal_area_entered(body: Node2D, side: String):
	if not body is Player:
		return
		
	last_travelled_side = side
	
	match side:
		"Top":
			body.global_position.y += arena_area.size.y
		"Left":
			body.global_position.x += arena_area.size.x
		"Right":
			body.global_position.x -= arena_area.size.x
		"Bottom":
			body.global_position.y -= arena_area.size.y
			
	room_entered.emit(side_rooms[side])
	
	reset()
	for proj in projectile_container.get_children():
		if proj is HostileBullet:
			proj.recycle()
		else:
			proj.queue_free()
	

func setup_relic():
	var rooms = [1, 2, 3, 4, 5, 6, 7, 8]
	var rand1 = rooms.pop_at(randi_range(0, rooms.size() - 1))
	var rand2 = rooms.pop_at(randi_range(0, rooms.size() - 1))
	relic_appearance = [rand1, rand2]
