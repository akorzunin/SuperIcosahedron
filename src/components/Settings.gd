extends Node
class_name Settings

@export var DEBUG_VISUAL: bool = false

@export var SCALING_ENABLED: bool = false
@export var START_PAUSED = false

enum SpawnSpeeds {SPEED_0 = 7, SPEED_1 = 10, SPEED_2 = 20, SPEED_3 = 50}
@export var spawn_speed: SpawnSpeeds

const settings_config = preload('res://src/components/settings/SettingsConfig.gd')
# TODO: fix wrong init order
var gs: GameSettings:
    get = get_gs

func get_gs():
    if not gs:
        gs = get_settings_config()

    return gs

var config: SettingsConfig:
    get = get_settings_config

func get_settings_config():
    var _config = SettingsConfig.new()
    var config_file = _config.load_config()
    return GameSettings.new().load_from_config(config_file)


func _ready() -> void:
    var scene = get_parent()
    if scene.game_settings:
        gs = scene.game_settings
        pass
