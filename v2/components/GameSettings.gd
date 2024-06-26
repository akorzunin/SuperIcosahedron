extends Node
class_name GameSettings

enum SettingsPreset {DEFAULT, DEBUG, CUSTOM}
@export var preset: SettingsPreset:
    set(value):
        preset = value
        parse_preset()
        notify_property_list_changed()

enum DespawneMode {NORMAL = 16633, IMMEDIATE = 0, BEFORE_END = 10000}
@export var DESPAWNER_MODE := DespawneMode.NORMAL

enum SpawnMode {QUEUE, RANDOM, CENTER, SIDE}
@export var SPAWN_MODE := SpawnMode.RANDOM

enum RoatationSpeed {NORMAL = 12, SLOW = 5, FAST = 15}
@export var ROTATION_SPEED := RoatationSpeed.FAST

func parse_preset() -> void:
    var sp = SettingsPreset
    match preset:
        sp.DEFAULT:
            DESPAWNER_MODE = DespawneMode.NORMAL
            SPAWN_MODE = SpawnMode.RANDOM
        sp.DEBUG:
            DESPAWNER_MODE = DespawneMode.BEFORE_END
        sp.CUSTOM:
            pass
