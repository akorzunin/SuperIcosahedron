extends MeshInstance3D
class_name CutPlane

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    pass

func get_cut_plane() -> Plane:
    # Multiply rotation matrix by defaul Plane position
    # which can be represented as (0, 1, 0) vector
    # 4th component is simply distance from global origin to plane origin
    return Plane(transform * Vector3(0.0, 1.0, 0.0, ), position.length())
