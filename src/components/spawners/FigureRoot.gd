extends Node3D
class_name FigureRoot

@onready var spawn_point = $SpawnPoint
@onready var gui: LoopGui = $'../Gui'

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    pass

func add_figure(new_figure) -> void:
    var anchor = get_node("Anchor")
    anchor.add_child(new_figure)
    gui.debug_stats_container.figures_count.label_text = str(anchor.get_child_count())
