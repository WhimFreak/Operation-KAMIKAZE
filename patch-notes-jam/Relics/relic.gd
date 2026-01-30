class_name Relic
extends Resource

@export var name: String
@export var sprite: Texture2D
@export_multiline var desc: String

@export var stat_flat_mods: Dictionary[Player.Stats, float]
@export var stat_percent_mods: Dictionary[Player.Stats, float]

func obtain(player: Player):
	player.relics.append(self)
	apply_stats(player)
	on_obtain(player)


func on_obtain(_player: Player):
	pass


func apply_stats(player: Player):
	for stat in stat_flat_mods:
		player.add_stat("Stat Rewards", stat, stat_flat_mods[stat], true)
	
	for stat in stat_percent_mods:
		player.add_stat("Stat Rewards", stat, stat_percent_mods[stat], false)
		
		
func on_stage_clear(_player: Player, _remaining_time: float):
	pass
	
	
func on_dash_start(_player: Player):
	pass
	
	
func on_boost_start(_player: Player):
	pass
	
	
func on_boost_end(_player: Player):
	pass
	
	
func on_shoot(_player: Player):
	pass
	

func update(_player: Player, _delta: float):
	pass	

	
func modify_bullet(_player: Player, bullet: Bullet):
	return bullet
	
	
func modify_bomb(_player: Player, bomb: PlayerBomb):
	return bomb


func on_bomb_explode(_player: Player, _bomb: PlayerBomb):
	pass
