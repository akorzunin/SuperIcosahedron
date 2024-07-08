extends Node
class_name MenuGui

@onready var debug_stats_container: DebugStatsContainer = %DebugStatsContainer
@onready var common_controls: CommonControls = %CommonControls

func _ready() -> void:
    common_controls.toggle_debug_stats.connect(_on_debug_stats_toggle)
    if G.settings.SHOW_DEBUG_STATS:
        debug_stats_container.show()
    else:
        debug_stats_container.hide()

func _on_debug_stats_toggle(v: bool):
    DebugStatsContainer.toggle(v, debug_stats_container)
