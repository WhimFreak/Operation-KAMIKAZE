class_name EnemySpawner
extends Node2D

signal room_cleared

@export var enemy_pool: Array[PackedScene]
@export var enemy_levels: Array[int]
@export var bosses: Array[PackedScene]
@export var difficulty_values: Dictionary[int, Array] = {
	1: [3, 4, 5, 6, 7, 7, 8, 8, 10],
	2: [9, 10, 11, 13, 14, 15, 16, 17, 17],
	3: [14, 15, 17, 19, 21, 22, 24, 25, 28, 30],
	4: [1]
}

@onready var spawn_area: Control = $SpawnArea
@onready var enemy_container: Node2D = $EnemyContainer
@onready var wave_complete_anim: AnimationPlayer = $WaveCompleteAnim
@onready var projectile_container: Node2D = %ProjectileContainer
@onready var boss_container: Node2D = $BossContainer
@onready var boss_ui: MarginContainer = %BossUI
@onready var boss_health_bar: ProgressBar = %BossHealthBar
@onready var boss_name: RichTextLabel = %BossName
@onready var boss_spawn_points: Node2D = $BossSpawnPoints

var combat_active: bool

func _process(_delta: float) -> void:
	update_boss_ui()
	
	
func update_boss_ui():
	if boss_container.get_child_count() <= 0:
		boss_ui.hide()
		return
	
	boss_name.text = boss_container.get_child(0).enemy_name
	
	var total_max_hp: float = 0
	var total_hp: float = 0
	for enemy in boss_container.get_children():
		if enemy is Enemy:
			total_max_hp += enemy.max_hp
			total_hp += enemy.hp
			
	boss_health_bar.max_value = total_max_hp
	boss_health_bar.value = total_hp
	
	boss_ui.show()
	
func spawn_enemies(stage: int, room: int):
	combat_active = true
	
	var amount: int = difficulty_values[stage][room - 1]
	var valid_enemy_pool: Array[PackedScene] = enemy_pool.duplicate()
	
	while amount > 0:
		valid_enemy_pool.shuffle()
		for enemy in valid_enemy_pool:
			var level = enemy_levels[enemy_pool.find(enemy)]
			var sample = enemy.instantiate()
			if sample.difficulty_value <= amount:
				amount -= sample.difficulty_value
				sample.level = level
				ready_enemy(sample)
				break
			sample.queue_free()
		

func ready_enemy(instance):
	instance.global_position = Vector2(
	randf_range(spawn_area.position.x, spawn_area.size.x + spawn_area.position.x),
	randf_range(spawn_area.position.y, spawn_area.size.y + spawn_area.position.y))
	instance.global_rotation_degrees = randf_range(0, 360)
	enemy_container.call_deferred("add_child", instance)
	instance.died.connect(check_enemies)
	
	
func summon_new_enemy(enemy: Enemy):
	enemy_container.call_deferred("add_child", enemy)
	enemy.died.connect(check_enemies)


func check_enemies():
	if not combat_active or RunData.player.state == Player.States.DYING:
		return
		
	var no_enemies: bool = true
	
	for enemy in enemy_container.get_children():
		if enemy is Enemy:
			if not enemy.is_dying:
				no_enemies = false
		elif enemy is Explosion:
			if not enemy.done:
				no_enemies = false
		else:
			no_enemies = false
			
	for enemy in boss_container.get_children():
		if enemy is Enemy:
			if not enemy.is_dying:
				no_enemies = false
		else:
			no_enemies = false
	
	if no_enemies and combat_active:
		combat_active = false
		wave_complete_anim.play("wave_complete")
		AudioManager.play_sfx("RoomClear")
		room_cleared.emit()
		
		for proj in projectile_container.get_children():
			if proj is HostileBullet:
				proj.recycle()
			else:
				proj.queue_free()
			

func spawn_boss(stage: int):
	combat_active = true
	match stage:
		1:
			for marker in boss_spawn_points.find_child("QuadSpawnPoints").get_children():
				var quad: Enemy = bosses[0].instantiate() as Enemy
				quad.global_position = marker.global_position
				quad.global_rotation = marker.global_rotation
				boss_container.call_deferred("add_child", quad)
				quad.died.connect(check_enemies)
		2:
			var starrage: Enemy = bosses[1].instantiate() as Enemy
			starrage.global_position = boss_spawn_points.find_child("Center").global_position
			boss_container.call_deferred("add_child", starrage)
			starrage.died.connect(check_enemies)
		3:
			var sir_kill: Enemy = bosses[2].instantiate() as Enemy
			sir_kill.global_position = boss_spawn_points.find_child("Center").global_position
			boss_container.call_deferred("add_child", sir_kill)
			sir_kill.died.connect(check_enemies)
		4:
			var heart: Enemy = bosses[3].instantiate() as Enemy
			heart.global_position = boss_spawn_points.find_child("Center").global_position
			boss_container.call_deferred("add_child", heart)
			
				
func enhance_enemies(amount: int):
	var enhancable_indexes: Array[int]
	for i in enemy_levels.size():
		if enemy_levels[i] < 2:
			enhancable_indexes.append(i)
	
	for i in amount:
		if enhancable_indexes.is_empty():
			break
		
		var random_index = enhancable_indexes.pick_random()
		enemy_levels[random_index] = 2
		enhancable_indexes.erase(random_index)
