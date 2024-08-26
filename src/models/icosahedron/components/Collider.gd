extends Area3D
class_name Collider

@onready var icosahedron = $".."
@onready var mesh_icosahedron = $"../MeshIcosahedron"

func get_cutplane_vector():
    var cv = mesh_icosahedron.cutplane
    var rot = mesh_icosahedron.quaternion
    var f = rot * cv
    return to_global(f)

func get_figure():
    return icosahedron

func despawn():
    return icosahedron.despawn()
