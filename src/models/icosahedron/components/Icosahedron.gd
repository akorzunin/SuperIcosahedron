extends Node3D
class_name Icosahedron

const ICOSAHEDRON_SHADER_V_1 = preload('res://src/models/icosahedron/shaders/icosahedron_shader_v1.gdshader')
const CUTPLANE_EFFECT_V_2 = preload("res://src/models/icosahedron/shaders/cutplane_effect_v2.gdshader")
const OUTLINE_V_1 = preload('res://src/models/icosahedron/shaders/outline_v1.gdshader')

@export var DEBUG_VISUAL: bool
@export var scaling_enabled = false
@export var scale_factor: float
@export var shader_type: int
@export var inital_transfrm: Quaternion
@onready var cut_plane: CutPlane = $CutPlane
@onready var mesh_icosahedron: MeshIcosahedron = $MeshIcosahedron

var cutplane_vector := Vector3(1,1,1).normalized()
var scale_timer: ScaleTimer
var sf: float

func init(settings: Settings, shader_args: Dictionary, transform_args: Dictionary = {}) -> Icosahedron:
    scale_factor = settings.gs.SCALE_FACTOR
    scaling_enabled = settings.SCALING_ENABLED
    DEBUG_VISUAL = settings.DEBUG_VISUAL
    shader_type = shader_args.get("type", 0)
    inital_transfrm = transform_args.get("quat", Quaternion())
    scale_timer = transform_args.get("scale_timer")

    return self

func set_cutplane(v: Vector4):
    Utils.set_shader_param(mesh_icosahedron, "cutplane", v)
    Utils.set_shader_param(mesh_icosahedron, "cutplane", v, 1)
    cutplane_vector = Vector3(v.x, v.y, v.z).normalized()
    if DEBUG_VISUAL:
        var ray = RayCast3D.new()
        ray.target_position = $Collider.get_cutplane_vector()
        mesh_icosahedron.add_child(ray)

func set_color(arr: Array):
    Utils.set_shader_param(mesh_icosahedron, "color", Vector3(arr[0], arr[1], arr[2]))
    Utils.set_shader_param(mesh_icosahedron, "color", Vector3(arr[0], arr[1], arr[2]), 1)

const dst := IcosahedronVarints.dst

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    if not DEBUG_VISUAL:
        cut_plane.hide()
    if scale_timer:
        scale_timer.timeout.connect(_on_scale_tick)
    if scale_factor:
        sf = (scale_factor + 1000.) / 1000.
    var variant = IcosahedronVarints.figure_variants[shader_type]
    var sm = ShaderMaterial.new()
    sm.shader = ICOSAHEDRON_SHADER_V_1
    var sm2 = ShaderMaterial.new()
    sm2.shader = CUTPLANE_EFFECT_V_2
    var sm3 = ShaderMaterial.new()
    sm3.shader = OUTLINE_V_1
    mesh_icosahedron.material_override = sm
    mesh_icosahedron.material_override.next_pass = sm2
    mesh_icosahedron.material_override.next_pass.next_pass = sm3
    if variant.get("cutplane"):
        set_cutplane(variant.cutplane)
    else:
        Utils.set_shader_param(mesh_icosahedron, "cutplate_visible", false)
        Utils.set_shader_param(mesh_icosahedron, "enable", false, 1)
        Utils.set_shader_param(mesh_icosahedron, "enable", false, 2)
    if Utils.get_render_method() == Utils.RenderMethods.GL_COMPATIBILITY:
        Utils.set_shader_param(mesh_icosahedron, "use_web_colors", true)
        Utils.set_shader_param(mesh_icosahedron, "use_web_colors", true, 1)
    set_color(G.theme.figure_variants.get(variant.name, G.theme.base_color))

    if inital_transfrm:
        transform.basis = Basis(inital_transfrm).orthonormalized()

    pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _on_scale_tick() -> void:
    if scaling_enabled:
        scale_object_local(Vector3(sf, sf, sf))
