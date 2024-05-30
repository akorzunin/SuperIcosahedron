extends Node
class_name Utils


static func is_main_scene(_self) -> bool:
    if _self.get_parent() == _self.get_tree().root and ProjectSettings.get_setting("application/run/main_scene") == _self.filename:
        return true
    return false
