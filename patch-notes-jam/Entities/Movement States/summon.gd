extends State

@export var state_after: State
@export var enemy_spawned: PackedScene
@export var spawn_points: Array[Marker2D]
@export var spawn_self: bool
@export var level: int = 1
@export var launch_force: float = 600

func enter():
	for i in spawn_points.size():
		var instance: Enemy
		if spawn_self:
			instance = load(actor.scene_file_path).instantiate() as Enemy
		else:
			instance = enemy_spawned.instantiate() as Enemy
		
		instance.level = level
		instance.global_position = spawn_points[i].global_position
		instance.global_rotation = spawn_points[i].global_rotation
		get_tree().get_first_node_in_group("Enemy Spawner").summon_new_enemy(instance)
		instance.launch(Vector2.RIGHT.rotated(spawn_points[i].global_rotation), launch_force)
	
	transition(state_after.name)
