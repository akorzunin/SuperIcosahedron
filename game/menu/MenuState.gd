extends Node
class_name MenuState

var init_state = MenuStruct.menu_items
var state: Dictionary = MenuStruct.menu_items
var history: Array[Dictionary] = []
var restored_rotation := Quaternion.IDENTITY
var is_easter_egged := false


func back() -> Dictionary:
    if history.is_empty():
        return state
    var previous: Dictionary = history.pop_back()
    state = previous.state
    restored_rotation = previous.rotation
    return state


func forth(new_state: Dictionary, rotation := Quaternion.IDENTITY) -> Error:
    if not new_state.has("items") and not new_state.has("options"):
        push_warning("invalid state")
        return FAILED
    history.append({ state = state, rotation = rotation })
    state = new_state
    return OK


func toggle_easter_egg_state():
    is_easter_egged = !is_easter_egged
    init_state = MenuStruct.menu_items_emoji if is_easter_egged else MenuStruct.menu_items
    state = init_state
    history.clear()
    G.font_changed.emit(G.FontType.EMOJI if is_easter_egged else G.FontType.HEX)
