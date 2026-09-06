extends MeshInstance3D
class_name SkyIcosahedron

func _process(delta: float) -> void:
    rotate_object_local(Vector3(-1,1,1).normalized(), .02 * delta)
