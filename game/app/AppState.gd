extends Node
class_name AppState

enum State { MENU, PLAYING, PAUSED, GAME_OVER, COLLECTION }

signal changed(old_state: State, new_state: State)

var state := State.MENU

func set_state(new_state: State) -> void:
    if state == new_state:
        return
    var old := state
    state = new_state
    changed.emit(old, new_state)
