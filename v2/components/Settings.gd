extends Node
class_name Settings

@export var DEBUG_VISUAL: bool = false

@export_range(1.005, 1.02, 0.005) var SCALE_FACTOR := 1.01
@export var SCALING_ENABLED: bool = false
@export var START_PAUSED = false

enum SpawnSpeeds {SPEED_0 = 7, SPEED_1 = 10, SPEED_2 = 20, SPEED_3 = 50}
@export var spawn_speed: SpawnSpeeds

var gs: GameSettings = GameSettings.new()

func _ready() -> void:
    var scene = get_parent()
    if scene.game_settings:
        gs = scene.game_settings
        pass
