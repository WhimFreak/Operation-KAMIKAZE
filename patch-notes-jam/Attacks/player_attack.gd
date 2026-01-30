class_name PlayerAttack
extends Node2D

const PLAYER_BULLET = preload("uid://bkfkfeisc6tqw")
const PLAYER_BOMB = preload("uid://dmyy37qgmopc3")

@onready var facing_indicator: Sprite2D = %FacingIndicator
@onready var attack_cooldown: Timer = $AttackCooldown
@onready var bomb_cooldown: Timer = $BombCooldown
@onready var bomb_bar: TextureProgressBar = %BombBar

var can_shoot: bool = true
var bomb_available: bool = true
var bomb_tween: Tween

func shoot(shots_per_second: float = get_parent().get_stat(Player.Stats.SHOTS_PER_SECOND)):
	if not can_shoot:
		return
		
	can_shoot = false
	
	fire_bullet()
	attack_cooldown.start(1 / shots_per_second)
	
	for relic in get_parent().relics:
		relic.on_shoot(get_parent())
	
	AudioManager.play_sfx("PlayerShoot", randf_range(0.8, 1.2))
	
	
func fire_bullet(bullet_position: Vector2 = facing_indicator.global_position,
bullet_rotation: float = facing_indicator.global_rotation,
bullet_count: int = int(get_parent().get_stat(Player.Stats.BULLET_COUNT)),
spread: float = get_parent().get_stat(Player.Stats.SPREAD),
damage: float = get_parent().get_stat(Player.Stats.DAMAGE),
shot_speed: float = get_parent().get_stat(Player.Stats.SHOT_SPEED),
pierce: float = get_parent().get_stat(Player.Stats.PIERCE),
shots_per_second: float = get_parent().get_stat(Player.Stats.SHOTS_PER_SECOND),
inaccuracy: float = get_parent().get_stat(Player.Stats.INACCURACY),
pierce_damage_loss: float = get_parent().get_stat(Player.Stats.PIERCE_DAMAGE_LOSS),
size: float = get_parent().get_stat(Player.Stats.BULLET_SIZE)):
	
	for i in bullet_count:
		var bullet: Bullet = PLAYER_BULLET.instantiate()
		bullet.global_position = bullet_position
		bullet.global_rotation = bullet_rotation
		bullet.damage = damage
		bullet.projectile_speed = shot_speed
		bullet.pierce = round(pierce)
		bullet.pierce_damage_loss = pierce_damage_loss
		bullet.scale = Vector2(size, size)
 	
		if bullet_count > 1:
			var rad_arc = deg_to_rad(spread)
			if bullet_count < 3:
				rad_arc = deg_to_rad(5)
			var spread_increment = rad_arc / (bullet_count - 1 if spread < 360 else bullet_count)
			bullet.global_rotation = (bullet_rotation + spread_increment * i - rad_arc / 2)
		else:
			bullet.global_rotation = bullet_rotation
			
		for relic in get_parent().relics:
			bullet = relic.modify_bullet(get_parent(), bullet)
		
		bullet.global_rotation += randf_range(-inaccuracy, inaccuracy)
		get_tree().get_first_node_in_group("Projectile Container").add_child(bullet)


func shoot_bomb():
	if not bomb_available:
		return
	
	bomb_available = false
	
	fire_bomb()
	
	bomb_cooldown.start(get_parent().get_stat(Player.Stats.BOMB_COOLDOWN))
	AudioManager.play_sfx("PlayerShootBomb", randf_range(0.8, 1.2))
	
	bomb_bar.value = 0
	bomb_bar.modulate = Color("0188a5")
	bomb_tween = create_tween()
	bomb_tween.tween_property(bomb_bar, "value", bomb_bar.max_value, get_parent().get_stat(Player.Stats.BOMB_COOLDOWN))

func fire_bomb():
	var bomb: PlayerBomb = PLAYER_BOMB.instantiate()
	bomb.global_position = facing_indicator.global_position
	bomb.global_rotation = facing_indicator.global_rotation
	bomb.explosion_damage = get_parent().get_stat(Player.Stats.BOMB_DAMAGE) + get_parent().get_stat(Player.Stats.DAMAGE)
	bomb.final_size = get_parent().get_stat(Player.Stats.BOMB_SIZE)
	
	for relic in get_parent().relics:
		bomb = relic.modify_bomb(get_parent(), bomb)
	
	get_tree().get_first_node_in_group("Projectile Container").add_child(bomb)


func _on_attack_cooldown_timeout() -> void:
	can_shoot = true


func _on_bomb_cooldown_timeout() -> void:
	bomb_bar.modulate = Color.WHITE
	bomb_available = true


func recharge_bomb():
	bomb_tween.kill()
	bomb_bar.modulate = Color.WHITE
	bomb_bar.value = bomb_bar.max_value
	bomb_available = true
	bomb_cooldown.stop()
