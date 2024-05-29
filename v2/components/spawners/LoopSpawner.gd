extends Marker3D
class_name LoopSpawner

@export var figureRoot: FigureRoot
const IcosahedronScene = preload('res://scenes/figures/icosahedron/Icosahedron.tscn')
# Called when the node enters the scene tree for the first time.
func _ready():
    pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
    pass

class Figure:
    var type: String
    func _init(_type: String = 'new'):
        self.type = _type

func _on_spawn_figure(figure: Figure) -> void:
    if figure.type == "new":

        #Node3D()
        #var new_figure = IcosahedronNode.new()
        var new_figure := IcosahedronScene.instantiate()
        print_debug(typeof(new_figure))
        # TODO add methods to figure root to safely add and get figures
        figureRoot.get_node("Anchor").add_child(new_figure)
