extends Node3D
class_name Icosahedron

@export var DEBUG_VISUAL: bool
@export var scaling_enabled = false
@export var scale_factor: float
@export var shader_type: int
@onready var cut_plane: CutPlane = $CutPlane
@onready var mesh_icosahedron: MeshIcosahedron = $MeshIcosahedron

func init(settings: Settings, _shader_type: int = 0) -> Icosahedron:
    scale_factor = settings.SCALE_FACTOR
    scaling_enabled = settings.SCALING_ENABLED
    DEBUG_VISUAL = settings.DEBUG_VISUAL
    shader_type = _shader_type
    return self

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    if not DEBUG_VISUAL:
        cut_plane.hide()
    match shader_type:
        1:
            mesh_icosahedron.set_instance_shader_parameter("cutplane", Vector4(-1.875, 0.725, 0., 1.578))
    pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
    if scaling_enabled:
        scale_object_local(Vector3(scale_factor, scale_factor, scale_factor, ))
