extends Node3D
class_name FigureRoot

@onready var settings = %Settings
@onready var spawn_point = $SpawnPoint

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if not settings.DEBUG_VISUAL:
		spawn_point.hide()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    pass

func add_figure(new_figure) -> void:
    get_node("Anchor").add_child(new_figure)
