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
    gui.debug_stats_container.figures_count.label_text = str(_live_figure_count())

func clean_all(immediate := false):
    for node in anchor.get_children():
        if node.is_queued_for_deletion():
            continue
        if immediate or not node is Icosahedron:
            node.queue_free()
        else:
            node.despawn()
    gui.debug_stats_container.figures_count.label_text = "0"

func get_live_figures() -> Array[Icosahedron]:
    var figures: Array[Icosahedron] = []
    for node in anchor.get_children():
        if node is Icosahedron and not node.is_queued_for_deletion() and not node.despawning:
            figures.append(node)
    return figures

func _live_figure_count() -> int:
    return get_live_figures().size()
