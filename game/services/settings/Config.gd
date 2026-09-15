extends Node
class_name Config

const user_config := "user://settings.cfg"

enum ConfigName {
    USER,
    LOCAL,
    LOOP_SCENE,
    MENU_SCENE,
}
@export var config_name := ConfigName.USER:
    set(val):
        config_name = val
        match val:
            ConfigName.USER:
                config = user_config
            ConfigName.LOCAL:
                config = "res://game/services/settings/default_settings.cfg"

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


func reset_user_settings() -> Error:
    var defaults := SettingsConfig.dict_to_config(DafaultConfig.settings)
    var error := defaults.save(config)
    if error != OK:
        return error
    _on_reload_settings()
    return OK


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
    var enabled := state > 2
    G.settings.FULLSCREEN_ENABLED = enabled
    SettingsConfig.write_key(config, "user_settings", "FULLSCREEN_ENABLED", enabled)


func set_vsync_state(state: int):
    var enabled := state > 0
    G.settings.VSYNC_ENABLED = enabled
    SettingsConfig.write_key(config, "user_settings", "VSYNC_ENABLED", enabled)


func set_render_scale(percent: int):
    percent = clampi(roundi(percent / 10.0) * 10, 10, 100)
    G.settings.RENDER_SCALE_PERCENT = percent
    get_viewport().scaling_3d_scale = percent / 100.0
    SettingsConfig.write_key(config, "user_settings", "RENDER_SCALE_PERCENT", percent)


func set_control_type(new_type: LoopControls.ControlType):
    var str_type: String = LoopControls.ControlType.keys()[new_type]
    G.settings.CONTROL_TYPE = str_type
    SettingsConfig.write_key(
        config,
        "user_settings",
        "CONTROL_TYPE",
        \
        str_type,
    )


func set_control_invert_x(state: bool):
    G.settings.IS_CONTROL_INVERTED = state
    SettingsConfig.write_key(config, "user_settings", "IS_CONTROL_INVERTED", state)
