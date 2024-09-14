extends Node3D
class_name MenuScene

var game_settings

func init(props: Dictionary):
    if props.get("game_settings"):
        game_settings = props.game_settings
    G.reload_settings.emit()
    return self

func deinit():
    queue_free()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
    pass
