extends MeshInstance3D
class_name MeshIcosahedron


@onready var icosahedron: Icosahedron = $'..'
@onready var collider: Collider = $'../Collider'

var angle_good := false
var is_alt := false
var is_rotating := false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    if Utils.main_scene(self) in ['MainScene', 'LoopScene', 'MenuScene']:
        # wierd trick to not get errors when scaling and rotating mesh when its mounted in runtime
        transform.basis = Basis(icosahedron.transform.basis.get_rotation_quaternion())

func set_controlled(state: bool):
    Utils.set_shader_param(self, "enable", state, 2)
    collider.set_collision_mask_value(1, state)
    collider.set_collision_layer_value(1, state)
