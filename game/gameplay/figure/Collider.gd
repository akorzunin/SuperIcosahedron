extends Area3D
class_name Collider

@onready var icosahedron = $".."
@onready var mesh_icosahedron = $"../MeshIcosahedron"

func _ready() -> void:
    # Layer 1 is reserved for the currently controlled figure/end detector.
    # Layer 2 stays enabled so the despawner can still remove old figures.
    set_collision_layer_value(1, false)
    set_collision_layer_value(2, true)
    set_collision_mask_value(1, false)
    set_collision_mask_value(2, true)

func get_cutplane_vector():
    var cv = mesh_icosahedron.cutplane
    var rot = mesh_icosahedron.quaternion
    var f = rot * cv
    return to_global(f)

func get_figure():
    return icosahedron

func despawn():
    return icosahedron.despawn()
