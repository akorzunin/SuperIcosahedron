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
    G.reload_settings.connect(_on_reload_settings)

func _on_reload_settings():
    var gs = SettingsConfig.load_gs(config)
    G.settings = gs

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

func set_fullscreen_state(state: int):
    G.settings.FULLSCREEN_ENABLED = state
    SettingsConfig.write_key(config, "user_settings", "FULLSCREEN_ENABLED", \
        true if state > 2 else false)

func set_vsync_state(state: int):
    G.settings.VSYNC_ENABLED = state
    SettingsConfig.write_key(config, "user_settings", "VSYNC_ENABLED", \
        true if state > 0 else false)

func set_control_type(new_type: LoopControls.ControlType):
    var str_type: String = LoopControls.ControlType.keys()[new_type]
    G.settings.CONTROL_TYPE = str_type
    SettingsConfig.write_key(config, "user_settings", "CONTROL_TYPE", \
        str_type)

func set_control_invert_x(state: bool):
    G.settings.IS_CONTROL_INVERTED = state
    SettingsConfig.write_key(config, "user_settings", "IS_CONTROL_INVERTED", state)
