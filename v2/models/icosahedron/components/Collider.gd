extends Area3D
class_name Collider

@onready var icosahedron = $".."
@onready var mesh_icosahedron = $"../MeshIcosahedron"

func get_cutplane_vector():
    var a = to_global(icosahedron.cutplane_vector)
    var e = mesh_icosahedron.quaternion
    var f = a * e
    return f

func get_figure():
    return icosahedron
