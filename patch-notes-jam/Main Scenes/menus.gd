extends CanvasLayer

const RELIC_UI = preload("uid://b4soss4wqnqlv")

@onready var enemy_spawner: EnemySpawner = $"../EnemySpawner"
@onready var win_screen: Panel = $WinScreen
@onready var win_anim: AnimationPlayer = $WinAnim
@onready var lose_screen: Panel = $LoseScreen
@onready var lose_anim: AnimationPlayer = $LoseAnim
@onready var successful_label: RichTextLabel = %SuccessfulLabel
@onready var time_remaining_label: RichTextLabel = %TimeRemainingLabel
@onready var relic_name: RichTextLabel = %RelicName
@onready var relic_desc: RichTextLabel = %RelicDesc
@onready var relic_container: GridContainer = %RelicContainer
@onready var pause_screen: Panel = $PauseScreen

@onready var damage_num: RichTextLabel = %DamageNum
@onready var atk_speed_num: RichTextLabel = %AtkSpeedNum
@onready var shot_speed_num: RichTextLabel = %ShotSpeedNum
@onready var bullet_count_num: RichTextLabel = %BulletCountNum
@onready var spread_num: RichTextLabel = %SpreadNum
@onready var pierce_num: RichTextLabel = %PierceNum
@onready var pierce_damage_loss_num: RichTextLabel = %PierceDamageLossNum
@onready var bomb_damage_num: RichTextLabel = %BombDamageNum
@onready var bomb_cooldown_num: RichTextLabel = %BombCooldownNum
@onready var speed_num: RichTextLabel = %SpeedNum
@onready var time_multi_num: RichTextLabel = %TimeMultiNum
@onready var damage_taken_num: RichTextLabel = %DamageTakenNum

var remaining_time: float:
	set(value):
		remaining_time = value
		var mil = fmod(value, 1) * 100
		var sec = fmod(value, 60)
		var minu = value / 60
		
		var string = "%2d: %02d: %02d" % [minu, sec, mil]
		time_remaining_label.text = "TIME REMAINING:
%s" % string

func _ready() -> void:
	get_parent().game_over.connect(
		func(won: bool):
			if won:
				AudioManager.play_sfx("Punch", 1.2)
				win_anim.play("win")
			else:
				AudioManager.stop_music()
				AudioManager.play_sfx("Lose")
				lose_anim.play("lose")
	)
	
	await get_tree().process_frame
	RunData.player.relic_obtained.connect(add_relic)
	
	update_tooltip(null)
	update_stats()
	
	
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		if get_tree().paused:
			unpause()
		else:
			pause()
	
	
func pause():
	if not win_screen.visible and not lose_screen.visible:
		update_tooltip(null)
		update_stats()
		pause_screen.show()
		get_tree().paused = true

	
	
func unpause():
	pause_screen.hide()
	get_tree().paused = false
	
	
func add_relic(relic: Relic):
	var relic_ui: RelicUI = RELIC_UI.instantiate()
	relic_ui.relic = relic
	relic_container.add_child(relic_ui)
	relic_ui.tooltip_requested.connect(update_tooltip)
	
	
func update_tooltip(relic: Relic):
	if relic:
		relic_name.text = relic.name
		relic_desc.text = relic.desc
	elif RunData.player.relics.is_empty():
		relic_name.text = ""
		relic_desc.text = "[color=gray]NO ITEMS :("
	else:
		relic_name.text = ""
		relic_desc.text = "[color=gray][HOVER OVER AN ITEM]"
		
		
func update_stats():
	var player = RunData.player
	
	damage_num.text = str(int(player.get_stat(Player.Stats.DAMAGE)))
	atk_speed_num.text = str(player.get_stat(Player.Stats.SHOTS_PER_SECOND))
	shot_speed_num.text = str(int(player.get_stat(Player.Stats.SHOT_SPEED)))
	bullet_count_num.text = str(int(player.get_stat(Player.Stats.BULLET_COUNT)))
	spread_num.text = str(int(player.get_stat(Player.Stats.SPREAD)))
	pierce_num.text = str(int(player.get_stat(Player.Stats.PIERCE) - 1))
	pierce_damage_loss_num.text = str(player.get_stat(Player.Stats.PIERCE_DAMAGE_LOSS))
	bomb_damage_num.text = str(int(player.get_stat(Player.Stats.BOMB_DAMAGE)))
	bomb_cooldown_num.text = str(player.get_stat(Player.Stats.BOMB_COOLDOWN))
	speed_num.text = str(int(player.get_stat(Player.Stats.MOVE_SPEED)))
	time_multi_num.text = str(player.get_stat(Player.Stats.TIME_MULTI))
	damage_taken_num.text = str(player.get_stat(Player.Stats.DAMAGE_TAKEN))


func _on_back_to_menu_button_pressed() -> void:
	AudioManager.stop_music()
	TransitionScreen.change_scene("res://Main Scenes/main_menu.tscn")
