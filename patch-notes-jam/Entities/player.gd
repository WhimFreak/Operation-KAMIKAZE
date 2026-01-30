class_name Player
extends CharacterBody2D

signal relic_obtained(relic: Relic)
signal died

enum States {IDLE, MOVING, DASHING, BOOSTING, DYING}
enum Stats {DAMAGE, SHOTS_PER_SECOND, SHOT_SPEED, BULLET_COUNT, SPREAD, PIERCE,
MOVE_SPEED, DASH_MULTI, BOOST_MULTI, TIME_LOSS_ON_HIT, INACCURACY, PIERCE_DAMAGE_LOSS, TIME_MULTI,
DAMAGE_TAKEN, BOMB_DAMAGE, BOMB_COOLDOWN, BOMB_SIZE, BULLET_SIZE}

@export var starting_relics: Array[Relic]

@onready var camera_2d: Camera2D = $Camera2D
@onready var sprites: Sprite2D = $Sprites
@onready var dash_cooldown_timer: Timer = $DashCooldownTimer
@onready var dash_duration_timer: Timer = $DashDurationTimer
@onready var boost_grace_timer: Timer = $BoostGraceTimer
@onready var boost_particles: GPUParticles2D = $BoostParticles
@onready var player_attack: PlayerAttack = $PlayerAttack
@onready var timer_label: Label = %TimerLabel
@onready var damaged_particles: GPUParticles2D = $DamagedParticles
@onready var popup_text: RichTextLabel = $PopupText
@onready var popup_anim: AnimationPlayer = $PopupAnim
@onready var death_anim: AnimationPlayer = $DeathAnim
@onready var damaged_sfx_interval_timer: Timer = $DamagedSFXIntervalTimer

var relics: Array[Relic]

var state: States = States.IDLE
var direction: Vector2
var last_direction: Vector2
var cam_tween: Tween

var can_dash: bool = true
var damaging_objects: Array

var stats: Dictionary[Stats, float] = {
	Stats.DAMAGE: 10,
	Stats.SHOTS_PER_SECOND: 4,
	Stats.SHOT_SPEED: 800,
	Stats.BULLET_COUNT: 1,
	Stats.SPREAD: 45,
	Stats.PIERCE: 1,
	Stats.MOVE_SPEED: 350,
	Stats.DASH_MULTI: 3,
	Stats.BOOST_MULTI: 1.8,
	Stats.TIME_LOSS_ON_HIT: 15,
	Stats.INACCURACY: 0,
	Stats.PIERCE_DAMAGE_LOSS: 0.6,
	Stats.TIME_MULTI: 1,
	Stats.DAMAGE_TAKEN: 1,
	Stats.BOMB_DAMAGE: 50,
	Stats.BOMB_COOLDOWN: 7,
	Stats.BOMB_SIZE: 1,
	Stats.BULLET_SIZE: 1
}

var stat_flat_mods: Dictionary[String, Dictionary] = {
	"test": {Stats.DAMAGE: 0}
}
var stat_percent_mods: Dictionary[String, Dictionary] = {
	"test": {Stats.DAMAGE: 1}
}


func _ready() -> void:
	await get_tree().process_frame
	for relic in starting_relics:
		obtain_relic(relic)

func _physics_process(delta: float) -> void:
	match state:
		States.IDLE:
			handle_idle(delta)
		States.MOVING:
			handle_move(delta)
		States.DASHING:
			handle_dashing(delta)
		States.BOOSTING:
			handle_boosting(delta)
		States.DYING:
			handle_dying()
		
	move_and_slide()
	
	
func _process(delta: float) -> void:
	if state == States.DYING:
		return
		
	if RunData.current_time == 0:
		die()
		return
		
	for relic in relics:
		relic.update(self, delta)	
		
	sprites.look_at(get_global_mouse_position())
	
	if Input.is_action_pressed("shoot"):
		player_attack.shoot()
		if state == States.BOOSTING:
			_on_boost_grace_timer_timeout()
	if Input.is_action_just_pressed("bomb"):
		player_attack.shoot_bomb()
		if state == States.BOOSTING:
			_on_boost_grace_timer_timeout()
	
	timer_label.text = RunData.get_time()
	
	damaging_objects = damaging_objects.filter(func(obj): return obj != null)
	if not damaging_objects.is_empty() and state != States.DASHING:
		RunData.reduce_time(get_stat(Stats.TIME_LOSS_ON_HIT) * get_stat(Stats.DAMAGE_TAKEN) * delta)
		damaged_particles.emitting = true
		
		if damaged_sfx_interval_timer.is_stopped():
			damaged_sfx_interval_timer.start()
		
	else:
		damaged_particles.emitting = false
	
	
func _input(event: InputEvent) -> void:
	if state == States.DYING:
		return
		
	if event.is_action_pressed("dash") and state != States.DASHING and can_dash:
		dash()
			

func dash():
	state = States.DASHING
	can_dash = false
	dash_duration_timer.start()
	AudioManager.play_sfx("PlayerDash")
	
	for relic in relics:
		relic.on_dash_start(self)

func die():
	state = States.DYING
	death_anim.play("death")
	await death_anim.animation_finished
	
	died.emit()


func handle_dying():
	velocity = Vector2.ZERO
	damaged_particles.emitting = false
	

func handle_idle(delta: float):
	velocity = velocity.move_toward(Vector2.ZERO, 2000 * delta)
	
	direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	if direction:
		state = States.MOVING
	
	boost_particles.emitting = false
	
	#if camera_2d.zoom != Vector2.ONE:
		#cam_tween = create_tween().set_ease(Tween.EASE_OUT)
		#cam_tween.tween_property(camera_2d, "zoom", Vector2.ONE, 0.1)
	

func handle_move(_delta: float):
	direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	if direction:
		last_direction = direction
	else:
		state = States.IDLE	

	velocity = direction * get_stat(Stats.MOVE_SPEED)
	

func handle_dashing(_delta: float):
	if direction:
		velocity = direction * get_stat(Stats.MOVE_SPEED) * get_stat(Stats.DASH_MULTI)
		boost_particles.process_material.set("direction", Vector3(-direction.x, -direction.y, 0))
	else:
		velocity = last_direction * get_stat(Stats.MOVE_SPEED) * get_stat(Stats.DASH_MULTI)
		boost_particles.process_material.set("direction", Vector3(-last_direction.x, -last_direction.y, 0))
		
		
	boost_particles.emitting = true
		

func handle_boosting(_delta: float):
	direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	if direction:
		last_direction = direction
		boost_grace_timer.stop()
	else:
		if boost_grace_timer.is_stopped():
			boost_grace_timer.start()

	velocity = direction * get_stat(Stats.MOVE_SPEED) * get_stat(Stats.BOOST_MULTI)
	boost_particles.emitting = true
	
	if direction:
		boost_particles.process_material.set("direction", Vector3(-direction.x, -direction.y, 0))


func _on_dash_cooldown_timer_timeout() -> void:
	can_dash = true


func _on_dash_duration_timer_timeout() -> void:
	dash_cooldown_timer.start()
	velocity = Vector2.ZERO
	
	
	direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	if direction and not Input.is_action_pressed("shoot"):
		state = States.BOOSTING
		AudioManager.get_sfx("PlayerBoosting").playing = true
		
		for relic in relics:
			relic.on_boost_start(self)
		
	else:
		state = States.IDLE
		

func _on_boost_grace_timer_timeout() -> void:
	if state == States.BOOSTING:
		for relic in relics:
			relic.on_boost_end(self)
	state = States.IDLE
	AudioManager.get_sfx("PlayerBoosting").playing = false
	
	
func get_stat(id: Stats):
	if not stats.has(id):
		return 0
	
	var total: float = stats[id]
	
	for mod in stat_flat_mods:
		if stat_flat_mods[mod].has(id):
			total += stat_flat_mods[mod][id]
	
	for mod in stat_percent_mods:
		if stat_percent_mods[mod].has(id):
			total *= stat_percent_mods[mod][id]
			
	return total
	
func add_stat(mod_id: String, stat_id: Stats, amount: float, is_flat: bool):
	if is_flat:
		if stat_flat_mods.has(mod_id):
			if stat_flat_mods[mod_id].has(stat_id):
				stat_flat_mods[mod_id][stat_id] += amount
			else:
				stat_flat_mods[mod_id][stat_id] = amount
		else:
			stat_flat_mods[mod_id] = {stat_id: amount}
	else:
		if stat_percent_mods.has(mod_id):
			if stat_percent_mods[mod_id].has(stat_id):
				stat_percent_mods[mod_id][stat_id] += amount - 1
			else:
				stat_percent_mods[mod_id][stat_id] = 1 + (amount - 1)
		else:
			stat_percent_mods[mod_id] = {stat_id: amount}
	
		
func remove_mod(mod_id: String, is_flat: bool):
	if is_flat:
		stat_flat_mods.erase(mod_id)
	else:
		stat_percent_mods.erase(mod_id)
	
	
func remove_stat(mod_id: String, stat_id: Stats, is_flat: bool):
	if is_flat:
		if stat_flat_mods.has(mod_id):
			stat_flat_mods[mod_id].erase(stat_id)
	else:
		if stat_percent_mods.has(mod_id):
			stat_percent_mods[mod_id].erase(stat_id)
			
			
func set_stat_mod(mod_id: String, stat_id: Stats, amount: float, is_flat: bool):
	if is_flat:
		if not stat_flat_mods.has(mod_id):
			add_stat(mod_id, stat_id, amount, is_flat)
		else:
			stat_flat_mods[mod_id][stat_id] = amount
	else:
		if not stat_percent_mods.has(mod_id):
			add_stat(mod_id, stat_id, amount, is_flat)
		else:
			stat_percent_mods[mod_id][stat_id] = amount
		

func show_popup_text(text: String):
	popup_text.text = text
	popup_anim.play("popup")
	

func hit(obj, init_damage: float = 0):
	if damaging_objects.has(obj) or state == States.DYING:
		return
	
	if state != States.DASHING:
		RunData.reduce_time(init_damage * get_stat(Stats.DAMAGE_TAKEN))
		
	damaging_objects.append(obj)

	
func obtain_relic(relic: Relic):
	relic.obtain(self)
	show_popup_text(relic.name)
	
	relic_obtained.emit(relic)
	

func on_stage_clear():
	for relic in relics:
		relic.on_stage_clear(self, int(RunData.current_time))


func _on_kill_explosion_body_entered(body: Node2D) -> void:
	if body is Enemy:
		body.take_damage(99999, true)


func _on_damaged_sfx_interval_timer_timeout() -> void:
	AudioManager.play_sfx("PlayerDamaged", randf_range(0.9, 1))


func play_sfx(id: String, pitch: float = 1):
	AudioManager.play_sfx(id, pitch)
