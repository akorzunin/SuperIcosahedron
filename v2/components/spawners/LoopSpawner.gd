extends Marker3D
class_name LoopSpawner


@onready var settings: Settings = %Settings
@export var figureRoot: FigureRoot
const IcosahedronScene = preload('res://v2/models/icosahedron/Icosahedron.tscn')
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

        var new_figure = IcosahedronScene.instantiate() \
            .init(
                settings.SCALE_FACTOR,
                settings.SCALING_ENABLED,
            )

        new_figure.get_node('CutPlane').hide()
        # TODO add methods to figure root to safely add and get figures
        figureRoot.get_node("Anchor").add_child(new_figure)
# TODO spawn on timer signals
# TODO spawn on game state signal
