extends Node3D
class_name MenuScene

@onready var settings: Settings = %Settings
var game_settings

func init(props: Dictionary):
    if props.get("game_settings"):
        game_settings = props.game_settings
    return self

func deinit():
    queue_free()

# Called when the node enters the scene tree for the first time.
func _ready():
    pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
    pass
