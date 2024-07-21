extends Node
class_name MenuState

var init_state = MenuStruct.menu_items
var state : Dictionary = MenuStruct.menu_items
var prev_state := {}
var is_easter_egged := false

func back():
    if not prev_state:
        return init_state
    state = prev_state
    # can be onlt level 2 deep for now
    prev_state = init_state
    return state

func forth(new_state: Dictionary) -> Error:
    if not new_state.get("items"):
        push_warning("invalid state")
        return FAILED
    prev_state = state
    state = new_state
    return OK

func toggle_easter_egg_state():
    is_easter_egged = !is_easter_egged
    if is_easter_egged:
        state = MenuStruct.menu_items_emoji
        return
    state = init_state
