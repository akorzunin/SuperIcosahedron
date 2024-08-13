extends Node
class_name CommonControls

signal toggle_debug_stats(state: bool)
@onready var config: Config = $"/root/MainScene/Config"

var prev_window_mode := DisplayServer.window_get_mode()

func _unhandled_input(event: InputEvent) -> void:
    var win_mode = DisplayServer.window_get_mode()
    if event.is_action_pressed("toggle_fullscreen"):
        Utils.change_window_mode(win_mode, prev_window_mode)
        prev_window_mode = win_mode
        get_viewport().set_input_as_handled()

    if event.is_action_pressed("toggle_debug_stats"):
        # TODO refactor w/o toggle_debug_stats.emit
        var state: bool = not G.settings.SHOW_DEBUG_STATS
        toggle_debug_stats.emit(state)
        config._on_debug_stats_state(state)
        get_viewport().set_input_as_handled()
