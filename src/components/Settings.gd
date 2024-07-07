extends Node
class_name Settings

@export var DEBUG_VISUAL: bool = false

@export var SCALING_ENABLED: bool = false
@export var START_PAUSED = false

enum SpawnSpeeds {SPEED_0 = 7, SPEED_1 = 10, SPEED_2 = 20, SPEED_3 = 50}
@export var spawn_speed: SpawnSpeeds

var gs: Dictionary = {}

func _init() -> void:
    # TODO: check if node running from main scene or not
    #var preset_file = "user://settings.cfg"
    var preset_file = "res://src/components/settings/default_settings.cfg"
    gs = SettingsConfig.load_gs(preset_file)
