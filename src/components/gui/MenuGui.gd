extends Node
class_name MenuGui

@onready var debug_stats_container: DebugStatsContainer = %DebugStatsContainer
@onready var common_controls: CommonControls = %CommonControls

func _ready() -> void:
    common_controls.toggle_debug_stats.connect(_on_toggle)
    if G.settings.SHOW_DEBUG_STATS:
        debug_stats_container.show()
    else:
        debug_stats_container.hide()

# R:TODO rename
func _on_toggle(v: bool):
    if v:
        debug_stats_container.show()
    else:
        debug_stats_container.hide()
