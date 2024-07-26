extends Node3D
class_name FigureRoot

@onready var spawn_point = $SpawnPoint
@onready var gui: LoopGui = $'../Gui'
@onready var anchor: Anchor = %Anchor

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    pass

func add_figure(new_figure) -> void:
    anchor.add_child(new_figure)
    gui.debug_stats_container.figures_count.label_text = str(anchor.get_child_count())

func clean_all():
    var anc = anchor.get_children() as Array[Icosahedron]
    for node in anc:
        node.despawn()
