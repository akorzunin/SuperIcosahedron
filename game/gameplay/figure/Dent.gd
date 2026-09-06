extends MeshInstance3D
class_name Dent

var side_id := 0
var data: SideData

func init(_side_id: int, _mesh: Mesh) -> Dent:
    side_id = _side_id
    name = "Dent_%02d" % side_id
    mesh = _mesh
    return self

func apply_data(side: SideData) -> void:
    data = side
    visible = not side.is_empty()

func is_empty() -> bool:
    return data != null and data.is_empty()
