extends Node
class_name CommonControls

signal toggle_debug_stats(state: bool)
@export var display_debug_stats := false
var prev_window_mode := DisplayServer.window_get_mode()

func _input(event):
    var m = DisplayServer.window_get_mode()
    if Input.is_action_just_pressed("toggle_fullscreen"):
        # R:TDOO unwarap enums or move to another func
        match m:
            0, 1, 2:
                DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
            3:
                DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_MAXIMIZED)
            4:
                if prev_window_mode == 2:
                    DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_MAXIMIZED)
                else:
                    DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
        prev_window_mode = m

    if Input.is_action_just_pressed("toggle_debug_stats"):
        display_debug_stats = not display_debug_stats
        toggle_debug_stats.emit(display_debug_stats)
