@tool
extends RayCast3D
class_name EndRay

## vactor that points at EndGame marker
var pass_vec: Vector3

func _ready():
    pass_vec = global_position.normalized()
    target_position = -global_position

func _physics_process(delta):
    var node = get_collider()
    if not node:
        return
    if not node.has_method("get_cutplane_vector"):
        return
    var v = node.get_cutplane_vector()
    var miss_angle := pass_vec.angle_to(v)
    print_debug(miss_angle)
    pass
