extends Node3D
class_name Icosahedron

@export var DEBUG_VISUAL: bool
@export var scaling_enabled = false
@export var scale_factor: float
@export var shader_type: int
@export var inital_transfrm: Quaternion
@onready var cut_plane: CutPlane = $CutPlane
@onready var mesh_icosahedron: MeshIcosahedron = $MeshIcosahedron
var cutplane_vector := Vector3(1,1,1).normalized()

func init(settings: Settings, shader_args: Dictionary, transform_args: Dictionary = {}) -> Icosahedron:
    scale_factor = settings.SCALE_FACTOR
    scaling_enabled = settings.SCALING_ENABLED
    DEBUG_VISUAL = settings.DEBUG_VISUAL
    shader_type = shader_args.get("type", 0)
    inital_transfrm = transform_args.get("quat", Quaternion())

    return self

func set_cutplane(v: Vector4):
    mesh_icosahedron.set_instance_shader_parameter("cutplane", v)
    cutplane_vector = Vector3(v.x, v.y, v.z).normalized()

func set_color(arr: Array):
    mesh_icosahedron.set_instance_shader_parameter("color", Vector3(arr[0], arr[1], arr[2]))

# magical number that represent distance between cutplane and origin
const dst := 0.794
const figure_variants = {
    8: {
        name = "top_left",
        cutplane = Vector4(0.0, 0.934, -0.358, dst),
    },
    7: {
        name = "top_right",
        cutplane = Vector4(0.0, 0.934, 0.358, dst),
    },
    6: {
        name = "bot_left",
        cutplane = Vector4( -0.577, -0.577, -0.577, dst),
    },
    5: {
        name = "bot_right",
        cutplane = Vector4( -0.577, -0.577, 0.577, dst),
    },
    4: {
        name = "bot_mid",
        cutplane = Vector4( -0.934, -0.358, 0., dst),
    },
    3: {
        name = "mid_mid",
        cutplane = Vector4( -0.934, 0.358, 0., dst),
    },
    2: {
        name = "mid_left",
        cutplane = Vector4( -0.577, 0.577, -0.577, dst),
    },
    1: {
        name = "mid_right",
        cutplane = Vector4( -0.577, 0.577, 0.577, dst),
    },
    0: {
        name = "default",
    },
}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    if not DEBUG_VISUAL:
        cut_plane.hide()

    var variant = figure_variants[shader_type]
    if variant.get("cutplane"):
        set_cutplane(variant.cutplane)
    else:
        mesh_icosahedron.set_instance_shader_parameter("cutplate_visible", false)
    set_color(G.theme.figure_variants.get(variant.name, G.theme.base_color))

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
