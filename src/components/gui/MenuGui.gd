extends Node
class_name MenuGui

@onready var debug_stats_container: DebugStatsContainer = %DebugStatsContainer
@onready var common_controls: CommonControls = %CommonControls

const CommonControls = preload('res://src/components/controls/CommonControls.gd')

func _ready() -> void:
    common_controls.toggle_debug_stats.connect(_on_toggle)

func _on_toggle(v: bool):
    if v:
        debug_stats_container.hide()
    else:
        debug_stats_container.show()
