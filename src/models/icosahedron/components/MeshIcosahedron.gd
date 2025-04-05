extends MeshInstance3D
class_name MeshIcosahedron

const ICOSAHEDRON_SHADER_V_1 = preload('res://src/models/icosahedron/shaders/icosahedron_shader_v1.gdshader')
const CUTPLANE_EFFECT_V_2 = preload("res://src/models/icosahedron/shaders/cutplane_effect_v4.gdshader")
const OUTLINE_V_1 = preload('res://src/models/icosahedron/shaders/outline_v1.gdshader')
const EDGE_HIGHLIGHT_V_1 = preload('res://src/models/icosahedron/shaders/edge_highlight_v1.gdshader')

const EDGE_NOISE = preload('res://src/models/icosahedron/resources/edge_noise.res')
#doesnt work in web build
#const TEXTURE_TEST_V_1 = preload('res://assets/build/textures/texture-test-v1.png')
#still dont works in web build but w/ a lot less errors
const NEW_COMPRESSED_TEXTURE_2D = preload('res://src/models/icosahedron/resources/new_compressed_texture_2d.tres')

var MATERIAL_002

@export var applied_shaders := [
    ICOSAHEDRON_SHADER_V_1,
    CUTPLANE_EFFECT_V_2,
    OUTLINE_V_1,
    EDGE_HIGHLIGHT_V_1,
]

@export var default_shaders := [
    ICOSAHEDRON_SHADER_V_1,
    OUTLINE_V_1,
]

@onready var icosahedron: Icosahedron = $".."
@onready var collider: Collider = $'../Collider'

var angle_good := false
var is_alt := false
var is_rotating := false
var currnt_type : int
var show_face_numbers := false
var cutplane: Vector3

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    if OS.has_feature('editor'):
        MATERIAL_002 = load('res://src/models/icosahedron/test/Material.face_index.tres')
    currnt_type = icosahedron.shader_type
    show_face_numbers = icosahedron.show_face_numbers
    if currnt_type >= 0:
        set_type(currnt_type)
    else:
        set_default_type()
    if Utils.main_scene(self) in ['MainScene', 'LoopScene', 'MenuScene']:
        # wierd trick to not get errors when scaling and rotating mesh when its mounted in runtime
        transform.basis = Basis(icosahedron.transform.basis.get_rotation_quaternion())

func set_controlled(state: bool):
    ShaderUtils.set_shader_param(self, "enable", state, 2)
    collider.set_collision_mask_value(1, state)
    collider.set_collision_layer_value(1, state)

func set_cutplane(v: Vector4):
    cutplane = Vector3(v[0], v[1], v[2])
    for i in applied_shaders.size():
        ShaderUtils.set_shader_param(self, "cutplane", v, i)
        ShaderUtils.set_shader_param(self, "noise_pattern", EDGE_NOISE, i)
        ShaderUtils.set_shader_param(self, "TEXTURE", NEW_COMPRESSED_TEXTURE_2D, i)

func set_color(c: Vector3):
    for i in applied_shaders.size():
        ShaderUtils.set_shader_param(self, "color", c, i)

func set_type(type: int):
    var variant: Vector4 = IcosahedronVarints.figure_variants_v2.get(type, Vector4())
    var variant_color: Array = TwTheme.figure_variants_v2.get(type, [])
    if not variant or not variant_color:
        push_warning("type ", type, " not found")
        set_default_type()
        return
    ShaderUtils.apply_shaders(applied_shaders, self)
    if show_face_numbers:
        self.material_overlay = MATERIAL_002
    set_cutplane(variant)
    set_color(Op.v3(variant_color))

func set_default_type():
    if show_face_numbers:
        self.material_overlay = MATERIAL_002
    ShaderUtils.apply_shaders(default_shaders, self)
    ShaderUtils.set_shader_param(self, "cutplane_visible", false, 0)
    var variant_color: Array = TwTheme.T.figure_variants.default
    set_color(Op.v3(variant_color))
