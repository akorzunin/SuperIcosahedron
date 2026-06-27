@tool
extends EditorScript

const INDENT_TYPE_SETTING := "text_editor/behavior/indent/type"
const INDENT_SIZE_SETTING := "text_editor/behavior/indent/size"
const INDENT_TYPE_SPACES := 1
const INDENT_SIZE := 4

func _run() -> void:
    var settings := EditorInterface.get_editor_settings()
    settings.set_setting(INDENT_TYPE_SETTING, INDENT_TYPE_SPACES)
    settings.set_setting(INDENT_SIZE_SETTING, INDENT_SIZE)
    settings.save()
    print("Godot editor indentation set to %d spaces." % INDENT_SIZE)
