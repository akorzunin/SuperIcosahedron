extends Area3D
class_name Collider

@onready var icosahedron = $".."
@onready var mesh_icosahedron = $"../MeshIcosahedron"

func _ready() -> void:
    # This coarse body is only for cleanup; SideColliders detect dent contact.
    collision_layer = 2
    collision_mask = 2

func get_cutplane_vector():
    var cv = mesh_icosahedron.cutplane
    var rot = mesh_icosahedron.quaternion
    var f = rot * cv
    return to_global(f)

func get_figure():
    return icosahedron

func despawn():
    return icosahedron.despawn()
