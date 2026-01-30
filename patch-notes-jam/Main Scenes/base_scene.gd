extends Node2D

const RELIC_PICKUP = preload("uid://dvn34dxff2vfd")

signal game_over(won: bool)

@export var player: Player
@export var starting_time: Array[float]
@export var stage_floor_colors: Array[Color]
@export var stage_wall_colors: Array[Color]
@export var relic_pool: Array[Relic]

@onready var enemy_spawner: EnemySpawner = $EnemySpawner
@onready var traversal_manager: TraversalManager = $TraversalManager
@onready var floor: ColorRect = %Floor
@onready var tile_map: Node2D = %TileMap
@onready var relic_container: Node2D = $RelicContainer
@onready var menus: CanvasLayer = $Menus

var current_room: RoomInfo
var stage: int = 1
var room: int = 1

var next_wall_color: Color = Color("01cbcf")
var next_floor_color: Color = Color("0a000e")


func _ready() -> void:
	AudioManager.play_music("Game")
	RunData.timer_active = false
	RunData.player = player
	RunData.current_time = starting_time[0]
	
	enemy_spawner.room_cleared.connect(on_room_cleared)
	traversal_manager.room_entered.connect(on_room_entered)
	
	await get_tree().process_frame
	traversal_manager.setup_relic()
	
	traversal_manager.setup_options(2, 1, 1)


func on_room_cleared():
	if current_room:
		for stat in current_room.stat_flat_mods:
			RunData.player.add_stat("Stat Rewards", stat, current_room.stat_flat_mods[stat], true)
	
		for stat in current_room.stat_percent_mods:
			RunData.player.add_stat("Stat Rewards", stat, current_room.stat_percent_mods[stat], false)
			
		RunData.current_time += current_room.time_added
			
		RunData.player.show_popup_text(current_room.clear_popup_text)
		
		if current_room.type == RoomInfo.RoomTypes.BOSS:
			RunData.timer_active = false
			RunData.player.on_stage_clear()
			
			stage += 1
			room = 1
			
			next_wall_color = stage_wall_colors[stage - 1]
			next_floor_color = stage_floor_colors[stage - 1]
			
			if stage < 4:
				spawn_relic()
				RunData.current_time += starting_time[stage - 1]
				
			enemy_spawner.enhance_enemies(2)
			traversal_manager.setup_relic()

		
		elif current_room.type == RoomInfo.RoomTypes.RELIC:
			spawn_relic()
			traversal_manager.relic_appearance.clear()
			
	
	traversal_manager.setup_options(2, room, stage)
	

func spawn_relic():
	var valid_pool: Array[Relic] = relic_pool.duplicate()
	for relic in RunData.player.relics:
		valid_pool.erase(relic)
	
	if valid_pool.is_empty():
		return
		
	var relic = RELIC_PICKUP.instantiate()
	relic.global_position = (floor.global_position + floor.size) / 2
	relic.relic = valid_pool.pick_random()
	relic_container.add_child(relic)
	

func on_room_entered(room_info: RoomInfo):
	if not RunData.timer_active:
		RunData.timer_active = true
	room += 1
	current_room = room_info
	match room_info.type:
		RoomInfo.RoomTypes.ENCOUNTER:
			enemy_spawner.spawn_enemies(stage, room)
		RoomInfo.RoomTypes.RELIC:
			enemy_spawner.spawn_enemies(stage, room)
		RoomInfo.RoomTypes.BOSS:
			enemy_spawner.spawn_boss(stage)
		RoomInfo.RoomTypes.FINAL:
			menus.remaining_time = RunData.current_time
			RunData.player.add_stat("Finale", Player.Stats.TIME_MULTI, 50, false)
			enemy_spawner.spawn_boss(stage)
			
	var recolor_tween := create_tween().set_parallel(true)
	recolor_tween.tween_property(floor, "color", next_floor_color, 1)
	recolor_tween.tween_property(tile_map, "modulate", next_wall_color, 1)
	
	for child in relic_container.get_children():
		child.queue_free()


func _on_player_died() -> void:
	game_over.emit(stage == 4)
