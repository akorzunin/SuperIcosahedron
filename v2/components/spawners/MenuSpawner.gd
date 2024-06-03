extends Node3D
class_name MenuSpawner

@onready var settings: Settings = %Settings
const IcosahedronScene = preload('res://v2/models/icosahedron/Icosahedron.tscn')
@onready var anchor: Marker3D = %Anchor

# Called when the node enters the scene tree for the first time.
func _ready():
    var new_figure = IcosahedronScene.instantiate() \
                .init(
                    settings,
                    { type = 0 },
                    {quat = Quaternion(0, 0.707, 0, 0.707)}
                )
    if (anchor.get_child_count() <= 0):
        anchor.add_child(new_figure)
    pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
    pass
