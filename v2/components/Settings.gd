extends Node
class_name Settings

@export var DEBUG_VISUAL: bool = false
@export var ROTATION_SPEED := 0.009
@export_range(1.005, 1.02, 0.005) var SCALE_FACTOR := 1.01
@export var SCALING_ENABLED: bool = false

enum SpawnSpeeds {SPEED_0 = -1, SPEED_1 = 1, SPEED_2 = 3, SPEED_3 = 20}
@export var spawn_speed: SpawnSpeeds
