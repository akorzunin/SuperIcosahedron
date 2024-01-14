extends MeshInstance3D
class_name MeshInstance3D_
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    pass

static func get_x() -> float:
    return randf_range(0.5, 1.0)

func get_plane_normal() -> Plane:
    #Plane(transform)
    #return basis.get_rotation_quaternion()
    return Plane(transform * Vector3(0.0, 1.0, 0.0, ), position.length())
