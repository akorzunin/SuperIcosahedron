extends Area3D
class_name Collider

@onready var icosahedron = $".."
@onready var mesh_icosahedron = $"../MeshIcosahedron"

func get_cutplane_vector():
    var a = icosahedron.cutplane_vector
    var e = mesh_icosahedron.quaternion
    var f = e * a
    return to_global(f)

func get_figure():
    return icosahedron
