@tool
extends Node3D
class_name Cutplanes

@onready var mesh_icosahedron: MeshIcosahedron = $MeshIcosahedron

@export var enable_shader := true:
    set(val):
        enable_shader = val
        var m = mesh_icosahedron.get_active_material(0) as ShaderMaterial
        m.set_shader_parameter("enable", val)

@export var cutplane := Vector4(-0.577, -0.577, -0.577, IcosahedronVarints.dst):
    set(val):
        cutplane = val
        var m = mesh_icosahedron.get_active_material(0) as ShaderMaterial
        m.set_shader_parameter("cutplane", cutplane)
        #notify_property_list_changed()

enum IcoAngle {ZERO_0, ONE_1, NEG_ONE_1, PHI, NEG_PHI, W_1, W_2, W_3}
@export var x := IcoAngle.ONE_1:
    set(val):
        x = val
        if not set_silent:
            var m = mesh_icosahedron.get_active_material(0) as ShaderMaterial
            cutplane.x = angle_to_float(val)
            m.set_shader_parameter("cutplane", cutplane)
            notify_property_list_changed()

@export var y := IcoAngle.ONE_1:
    set(val):
        y = val
        if not set_silent:
            var m = mesh_icosahedron.get_active_material(0) as ShaderMaterial
            cutplane.y = angle_to_float(val)
            m.set_shader_parameter("cutplane", cutplane)
            notify_property_list_changed()

@export var z := IcoAngle.ONE_1:
    set(val):
        z = val
        if not set_silent:
            var m = mesh_icosahedron.get_active_material(0) as ShaderMaterial
            cutplane.z = angle_to_float(val)
            m.set_shader_parameter("cutplane", cutplane)
            notify_property_list_changed()

@export var w := IcoAngle.W_3:
    set(val):
        w = val
        if not set_silent:
            var m = mesh_icosahedron.get_active_material(0) as ShaderMaterial
            cutplane.w = angle_to_float(val)
            m.set_shader_parameter("cutplane", cutplane)
            notify_property_list_changed()

var set_silent := false
@export var trans := TransformType.NONE:
    set(val):
        trans = val
        cutplane = get_next_cutplane(cutplane, val)
        set_silent = true
        print_debug(cutplane)
        x = float_to_angle(cutplane.x)
        y = float_to_angle(cutplane.y)
        z = float_to_angle(cutplane.z)
        w = float_to_angle(cutplane.w)
        set_silent = false
        notify_property_list_changed()


enum TransformType {NONE, NEG_X, NEG_Y, NEG_Z, SWAP_X}
func get_next_cutplane(_cutplane, transfrom):
    var diag_vec = _cutplane.x == _cutplane.y and _cutplane.y == _cutplane.z
    match transfrom:
        TransformType.NEG_X:
            _cutplane.x = -_cutplane.x
            return _cutplane
        TransformType.NEG_Y:
            _cutplane.y = -_cutplane.y
            return _cutplane
        TransformType.NEG_Z:
            _cutplane.z = -_cutplane.z
            return _cutplane
        TransformType.SWAP_X:
            if diag_vec:
                _cutplane.x = phi * cutplane.x
                _cutplane.y = 0.
                _cutplane.w = w_2
            else:
                _cutplane = Vector4(sign(max(_cutplane.x, 1.)),sign(max(cutplane.y, 1.)),sign(max(cutplane.z, 1.)), w_3)
    return _cutplane

const phi := 0.398
const w_2 := .849
const w_3 := 1.369

func angle_to_float(ia: IcoAngle) -> float:
    var phi = 0.398
    match ia:
        IcoAngle.ZERO_0:
            return 0.
        IcoAngle.ONE_1:
            return 1.
        IcoAngle.NEG_ONE_1:
            return -1.
        IcoAngle.PHI:
            return phi
        IcoAngle.NEG_PHI:
            return -phi
        IcoAngle.W_1:
            return IcosahedronVarints.dst
        IcoAngle.W_2:
            return .849
        IcoAngle.W_3:
            return 1.369
    return .5

func float_to_angle(f: float) -> IcoAngle:
    var phi = 0.398
    var neg_phi = phi * -1.
    var neg_one = -1.
    var epsilon = 0.00001
    if abs(f - 0.) < epsilon:
        return IcoAngle.ZERO_0
    elif abs(f - 1.) < epsilon:
        return IcoAngle.ONE_1
    elif abs(f + 1.) < epsilon:
        return IcoAngle.NEG_ONE_1
    elif abs(f - phi) < epsilon:
        return IcoAngle.PHI
    elif abs(f + phi) < epsilon:
        return IcoAngle.NEG_PHI
    elif abs(f - IcosahedronVarints.dst) < epsilon:
        return IcoAngle.W_1
    elif abs(f - 0.849) < epsilon:
        return IcoAngle.W_2
    elif abs(f - 1.369) < epsilon:
        return IcoAngle.W_3
    return IcoAngle.ONE_1

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    pass
