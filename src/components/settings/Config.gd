extends Node
class_name Config

const user_config := "user://settings.cfg"

enum ConfigName {USER, LOCAL, LOOP_SCENE, MENU_SCENE}
@export var config_name := ConfigName.USER:
    set(val):
        config_name = val
        match val:
            ConfigName.USER:
                config = user_config
            ConfigName.LOCAL:
                config = "res://src/components/settings/default_settings.cfg"

var config := user_config

signal set_fps_counter_state(state: bool)

func _init() -> void:
    if not OS.has_feature("editor"):
        config = user_config
    if not G.settings:
        var gs = SettingsConfig.load_gs(config)
        G.settings = gs

func _ready() -> void:
    set_fps_counter_state.connect(_on_fps_counter_state)

func _on_fps_counter_state(state: bool):
# TODO figure out how to change state to visible/invisble for both scenes
    pass
