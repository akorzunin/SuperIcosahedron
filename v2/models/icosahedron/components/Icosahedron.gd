extends Node3D
class_name Icosahedron

@export var DEBUG_VISUAL: bool
@export var scaling_enabled = false
@export var scale_factor: float
@export var shader_type: int
@export var inital_transfrm: Quaternion
@onready var cut_plane: CutPlane = $CutPlane
@onready var mesh_icosahedron: MeshIcosahedron = $MeshIcosahedron

func init(settings: Settings, shader_args: Dictionary, transform_args: Dictionary = {}) -> Icosahedron:
    scale_factor = settings.SCALE_FACTOR
    scaling_enabled = settings.SCALING_ENABLED
    DEBUG_VISUAL = settings.DEBUG_VISUAL
    shader_type = shader_args.get("type")
    inital_transfrm = transform_args.get("quat", Quaternion())

    return self

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    if not DEBUG_VISUAL:
        cut_plane.hide()
    match shader_type:
        5: # top top left
            mesh_icosahedron.set_instance_shader_parameter("cutplane", Vector4(0, 0.334, -0.128, 0.284))
        4: # top top right
            mesh_icosahedron.set_instance_shader_parameter("cutplane", Vector4(0, 0.334, 0.128, 0.284))
        3: # bot mid
            mesh_icosahedron.set_instance_shader_parameter("cutplane", Vector4(-.334, -.128, 0., 0.284))
        2: # top mid
            mesh_icosahedron.set_instance_shader_parameter("cutplane", Vector4(-.334, .128, 0., 0.284))
        1: # top left
            mesh_icosahedron.set_instance_shader_parameter("cutplane", Vector4(-1., 1., -1., 1.345))
        0: # top right
            mesh_icosahedron.set_instance_shader_parameter("cutplane", Vector4(-1., 1., 1., 1.345))
        _:
            mesh_icosahedron.set_instance_shader_parameter("cutplate_visible", false)
    if inital_transfrm:
        transform.basis = Basis(inital_transfrm).orthonormalized()

    #if 1:
        #var a = cut_plane.get_cut_plane()
        #print_debug(a)

    pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
    if scaling_enabled:
        scale_object_local(Vector3(scale_factor, scale_factor, scale_factor, ))
