extends Node
class_name Utils

## Only works in scene level script
static func is_main_scene(_self) -> bool:
    if _self.get_parent() == _self.get_tree().root \
        and ProjectSettings.get_setting("application/run/main_scene") == _self.scene_file_path:
        return true
    return false

## Returns current main scene name
static func main_scene(_self) -> String:
    # Globals always loads first so index of main scene is 1
    return _self.get_tree().root.get_child(1).name

static func set_scene(_self: Node, scene_name: String):
    _self.get_tree().root.get_child(1).change_scene(scene_name)
    pass
