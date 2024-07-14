extends Node
class_name MenuState

var init_state = MenuStruct.menu_items
var state : Dictionary = MenuStruct.menu_items
var prev_state := {}

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
