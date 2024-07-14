extends Node
class_name Config

# TODO enum of presets
@export_file() var config := "user://settings.cfg"

signal set_fps_counter_state(state: bool)

func _init() -> void:
    if OS.has_feature("editor"):
        config = "res://src/components/settings/default_settings.cfg"
    if not G.settings:
        var gs = SettingsConfig.load_gs(config)
        G.settings = gs

func _ready() -> void:
    set_fps_counter_state.connect(_on_fps_counter_state)

func _on_fps_counter_state(state: bool):
# TODO figure out how to change state to visible/invisble for both scenes
    pass
