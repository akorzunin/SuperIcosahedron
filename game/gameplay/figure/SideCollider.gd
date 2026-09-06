extends Area3D
class_name SideCollider

var side: SideData
var figure: Icosahedron

func init(_figure: Icosahedron, _side: SideData) -> SideCollider:
    figure = _figure
    side = _side
    name = "SideCollider_%s" % side.id
    return self

func _ready() -> void:
    collision_layer = 1
    collision_mask = 1

func get_figure() -> Icosahedron:
    return figure
