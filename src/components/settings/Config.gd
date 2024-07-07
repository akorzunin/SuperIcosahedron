extends Node
class_name Config

# TODO enum of presets
@export_file() var config := "res://src/components/settings/default_settings.cfg"

func _init() -> void:
    if not G.settings:
        var gs = SettingsConfig.load_gs(config)
        G.settings = gs
