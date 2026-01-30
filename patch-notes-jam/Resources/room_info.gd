class_name RoomInfo
extends Resource

enum RoomTypes {ENCOUNTER, BOSS, RELIC, FINAL}

@export var type: RoomTypes
@export var icon: Texture2D
@export var label: String
@export_multiline var clear_popup_text: String

@export var time_added: float
@export var stat_flat_mods: Dictionary[Player.Stats, float]
@export var stat_percent_mods: Dictionary[Player.Stats, float]
