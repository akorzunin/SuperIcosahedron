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
signal set_debug_stats_state(state: bool)

func _init() -> void:
    if not OS.has_feature("editor"):
        config = user_config
    if not G.settings:
        var gs = SettingsConfig.load_gs(config)
        G.settings = gs

func _ready() -> void:
    set_fps_counter_state.connect(_on_fps_counter_state)
    set_debug_stats_state.connect(_on_debug_stats_state)

func _on_fps_counter_state(state: bool):
    G.settings.FPS_COUNTER_ENABLED = state
    SettingsConfig.write_key(config, "user_settings", "FPS_COUNTER_ENABLED", state)

func _on_debug_stats_state(state: bool):
    G.settings.SHOW_DEBUG_STATS = state
    SettingsConfig.write_key(config, "user_settings", "SHOW_DEBUG_STATS", state)

func set_sfx_state(state: bool):
    G.settings.SFX_ENABLED = state
    SettingsConfig.write_key(config, "user_settings", "SFX_ENABLED", state)

func set_music_state(state: bool):
    G.settings.MUSIC_ENABLED = state
    SettingsConfig.write_key(config, "user_settings", "MUSIC_ENABLED", state)
