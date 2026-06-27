@tool
extends EditorPlugin

const INDENT_TYPE_SETTING := "text_editor/behavior/indent/type"
const INDENT_SIZE_SETTING := "text_editor/behavior/indent/size"
const INDENT_TYPE_SPACES := 1
const INDENT_SIZE := 4

func _enter_tree() -> void:
    _apply_space_indentation()

func _apply_space_indentation() -> void:
    var settings := EditorInterface.get_editor_settings()
    settings.set_setting(INDENT_TYPE_SETTING, INDENT_TYPE_SPACES)
    settings.set_setting(INDENT_SIZE_SETTING, INDENT_SIZE)
    print("Indent Settings: Godot editor indentation set to %d spaces." % INDENT_SIZE)
