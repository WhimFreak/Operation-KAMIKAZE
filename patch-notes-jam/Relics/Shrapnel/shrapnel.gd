extends Relic

@export var bullet_count: int = 12
@export var bullet_dmg_multi: float = 1.5

func on_bomb_explode(player: Player, bomb: PlayerBomb):
	player.player_attack.fire_bullet(bomb.global_position, bomb.global_rotation, bullet_count, 360,
	RunData.player.get_stat(Player.Stats.DAMAGE) * bullet_dmg_multi)
