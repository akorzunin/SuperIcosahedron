extends MeshInstance3D
class_name MeshIcosahedron


@onready var icosahedron: Icosahedron = $'..'

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    if Utils.main_scene(self) in ['MainScene', 'LoopScene', 'MenuScene']:
        # wierd trick to not get errors when scaling and rotating mesh when its mounted in runtime
        transform.basis = Basis(icosahedron.transform.basis.get_rotation_quaternion())
    pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    pass
