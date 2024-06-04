extends Node3D
class_name Icosahedron

@export var DEBUG_VISUAL: bool
@export var scaling_enabled = false
@export var scale_factor: float
@export var shader_type: int
@export var inital_transfrm: Quaternion
@onready var cut_plane: CutPlane = $CutPlane
@onready var mesh_icosahedron: MeshIcosahedron = $MeshIcosahedron

func init(settings: Settings, shader_args: Dictionary, transform_args: Dictionary={}) -> Icosahedron:
    scale_factor = settings.SCALE_FACTOR
    scaling_enabled = settings.SCALING_ENABLED
    DEBUG_VISUAL = settings.DEBUG_VISUAL
    shader_type = shader_args.get("type", 0)
    inital_transfrm = transform_args.get("quat", Quaternion())

    return self

func set_cutplane(v: Vector4):
    mesh_icosahedron.set_instance_shader_parameter("cutplane", v)

func set_color(arr: Array):
    mesh_icosahedron.set_instance_shader_parameter("color", Vector3(arr[0], arr[1], arr[2]))

const FigureVariants = {
    8: {name = "top_left"},
    7: {name = "top_right"},
    6: {name = "bot_left"},
    5: {name = "bot_right"},
    4: {name = "bot_mid"},
    3: {name = "mid_mid"},
    2: {name = "mid_left"},
    1: {name = "mid_right"},
    0: {name = "default"},
}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    if not DEBUG_VISUAL:
        cut_plane.hide()
    # magical number that represent distance between cutplane and origin
    var dst: float = 0.78
    match shader_type:
        8: # top left
            set_cutplane(Vector4(0.0, 0.934, -0.358, dst))
            set_color(G.theme.base_color)
        7: # top right
            set_cutplane(Vector4(0.0, 0.934, 0.358, dst))
            set_color(G.theme.base_color)
        6: # bot left
            set_cutplane(Vector4( - 0.577, -0.577, -0.577, dst))
            set_color(G.theme.base_color)
        5: # bot right
            set_cutplane(Vector4( - 0.577, -0.577, 0.577, dst))
            set_color(G.theme.base_color)
        4: # bot mid
            set_cutplane(Vector4( - 0.934, -0.358, 0., dst))
            set_color(G.theme.base_color)
        3: # mid mid
            set_cutplane(Vector4( - 0.934, 0.358, 0., dst))
            set_color(G.theme.base_color)
        2: # mid left
            set_cutplane(Vector4( - 0.577, 0.577, -0.577, dst))
            set_color(G.theme.base_color)
        1: # mid right
            set_cutplane(Vector4( - 0.577, 0.577, 0.577, dst))
            set_color(G.theme.base_color)
        0: # default (no cutplane)
            mesh_icosahedron.set_instance_shader_parameter("cutplate_visible", false)
            set_color(G.theme.base_color)
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
