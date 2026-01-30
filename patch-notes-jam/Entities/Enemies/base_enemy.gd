class_name Enemy
extends CharacterBody2D

signal died

const LevelColors = [Color("ffd080"), Color("ff9e7d"), Color("fe546f")]

@export var enemy_name: String
@export var max_hp: float = 20
@export var enhanced_max_hp: float = 40
@export var difficulty_value: int = 1
@export_range(1, 3) var level: int = 1
@export var contact_damage: float = 3
@export var immune: bool = false
@export var pause_time_on_death: bool = false

@export_group("Explode On Death")
@export var death_explosion: PackedScene
@export var delay: float = 1
@export var final_size: float = 5
@export var enhanced_final_size: float = 8
@export var warning_speed: float = 0.2
@export var explosion_speed: float = 2


@export_group("Spawn Enemies On Death")
@export var enemy_spawned: PackedScene
@export var spawn_self: bool = false
@export var enemy_count: int = 0
@export var enemy_level: int = 1
@export var spawn_req_enhanced: bool = false


@export_group("Shoot On Death")
@export var bullet: PackedScene
@export var sources_parent: Node2D
@export var projectile_speed: float = 350
@export var bullet_count: int = 1
@export_range(0, 360) var spread: float = 45
@export var size: float = 1
@export var aim_towards_player: bool = false
@export var max_innacuracy: float = 0
@export var shoot_req_enhanced: bool = false


@onready var state_manager: StateManager = $StateManager
@onready var health_bar: TextureProgressBar = $HealthBar
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var death_particles: GPUParticles2D = $DeathParticles
@onready var boss_pre_death_particles: GPUParticles2D = $BossPreDeathParticles
@onready var boss_explosion_particles: GPUParticles2D = $BossExplosionParticles
@onready var hit_anim: AnimationPlayer = $HitAnim
@onready var navigation_agent_2d: NavigationAgent2D = %NavigationAgent2D
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D

var hp: float:
	set(value):
		hp = value
		
		if level == 2:
			health_bar.max_value = enhanced_max_hp
		else:
			health_bar.max_value = max_hp
		
		health_bar.value = hp

var immobile: bool = false

var is_spawning: bool = true
var is_dying: bool = false
var is_launched: bool = false
var launch_dir: Vector2
var launch_force: float

func _ready() -> void:
	if level == 2:
		hp = enhanced_max_hp
	else:
		hp = max_hp
	
	health_bar.tint_progress = LevelColors[level - 1]
	
	death_particles.process_material.set("color", LevelColors[level - 1])
	boss_pre_death_particles.process_material.set("color", LevelColors[level - 1])
	boss_explosion_particles.process_material.set("color", LevelColors[level - 1])
	
	animation_player.play("spawn")
	
	await animation_player.animation_finished
	
	navigation_agent_2d.avoidance_enabled = true
	state_manager.setup()
	is_spawning = false
	
	
func launch(dir: Vector2, force: float = 500):
	is_launched = true
	launch_dir = dir
	launch_force = force
	
	
func _process(delta: float) -> void:
	if is_dying or is_spawning or is_launched or immobile:
		return
		
	state_manager.update(delta)
	
func _physics_process(delta: float) -> void:
	if is_dying or immobile:
		return
		
	
	if is_launched:
		handle_launch(delta)
	elif not is_spawning:	
		state_manager.physics_update(delta)
	

func handle_launch(delta: float):
	set_collision_mask_value(3, false)
	velocity = launch_dir * launch_force
	launch_force = lerp(launch_force, 0.0, 5 * delta)
	
	var collision = move_and_collide(velocity * delta)
	if launch_force < 30 or collision:
		set_collision_mask_value(3, true)
		is_launched = false
	

func take_damage(amount: float, ignore_immune = false):
	if is_dying or is_spawning or (not ignore_immune and immune):
		return
		
	hp -= amount
	hit_anim.play("hit")
	if hp <= 0:
		die()
	else:
		AudioManager.play_sfx("EnemyHit", randf_range(0.8, 1.2))
	
func die():
	if is_dying or is_spawning:
		return
	
	state_manager.exit_all()
	navigation_agent_2d.avoidance_enabled = false
	set_collision_mask_value(3, false)
	set_collision_layer_value(3, false)
	
	is_dying = true
	AudioManager.play_sfx("EnemyDie", randf_range(0.9, 1.1))
	
	if level == 3:
		animation_player.play("boss_death")
	else:
		animation_player.play("death")
		
	if pause_time_on_death:
		RunData.timer_active = false
	
	spawn_on_death()
	shoot_on_death()
	
	if death_explosion:
		var explosion: Explosion = death_explosion.instantiate()
		explosion.global_position = global_position
		explosion.delay = delay
		explosion.warning_speed = warning_speed
		explosion.explosion_speed = explosion_speed
		
		if level == 2:
			explosion.final_size = enhanced_final_size
		else:
			explosion.final_size = final_size
		
		get_tree().get_first_node_in_group("Enemy Container").call_deferred("add_child", explosion)
		explosion.finished.connect(
			func():
				await get_tree().process_frame
				died.emit()
				queue_free())
		return
	
	await animation_player.animation_finished
	
	died.emit()
	queue_free()


func spawn_on_death():
	if not enemy_spawned and not spawn_self:
		return
		
	if spawn_req_enhanced and level != 2:
		return
		
	for i in enemy_count:
		var instance: Enemy
		if spawn_self:
			instance = load(self.scene_file_path).instantiate() as Enemy
		else:
			instance = enemy_spawned.instantiate() as Enemy
		
		instance.level = enemy_level
		instance.global_position = global_position + Vector2(randf_range(-16, 16), randf_range(-16, 16))
		get_tree().get_first_node_in_group("Enemy Spawner").summon_new_enemy(instance)
		instance.launch(Vector2(randf_range(-1, 1), randf_range(-1, 1)), 800)


func shoot_on_death():
	if not bullet:
		return
		
	if shoot_req_enhanced and level != 2:
		return
		
	
	var angle_offset: float = randf_range(-max_innacuracy, max_innacuracy)
			
	for source in sources_parent.get_children():
		var instance = BulletPool.take_from_pool()
		instance.projectile_speed = projectile_speed
		instance.global_position = source.global_position
		instance.scale = Vector2(size, size)
		if aim_towards_player:
			instance.global_rotation = (RunData.player.global_position - global_position).angle() + angle_offset
		else:
			instance.global_rotation = source.global_rotation + angle_offset
			
		instance.call_deferred("reparent", get_tree().get_first_node_in_group("Projectile Container"))
		instance.enable()


func _on_contact_hurtbox_body_entered(body: Node2D) -> void:
	if is_dying or is_spawning or is_launched:
		return
		
	if body is Player:
		body.hit(self, contact_damage)


func _on_contact_hurtbox_body_exited(body: Node2D) -> void:
	if body is Player:
		body.damaging_objects.erase(self)
		
		
func play_audio(id: String):
	AudioManager.play_sfx(id)
