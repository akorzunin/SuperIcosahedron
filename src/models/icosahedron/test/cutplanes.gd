@tool
extends Node3D
class_name Cutplanes

const phi := 0.398
## fine analog of 1 for cutplane
const ico_a := 0.934
## fine analog of phi for cutplane
const ico_b := 0.358


const w_2 := .849
const w_3 := 1.369
## correcn value in fine case for dst and dst
const ico_dst := IcosahedronVarints.dst

#@onready var mesh_icosahedron: MeshIcosahedron = $MeshIcosahedron
@onready var pointer_sphere: MeshInstance3D = $PointerSphere
@onready var mesh_icosahedron: MeshInstance3D = $Solid

@export var enable_shader := true:
    set(val):
        enable_shader = val
        var m = mesh_icosahedron.material_override
        m.next_pass.set_shader_parameter("enable", val)

func set_shader_cutplane(_cutplane: Vector4):
    if not mesh_icosahedron:
        return
    var m = mesh_icosahedron.material_override
    m.next_pass.set_shader_parameter("cutplane", _cutplane)

@export var cutplane := Vector4(-0.577, -0.577, -0.577, IcosahedronVarints.dst):
    set(val):
        cutplane = val
        set_shader_cutplane(val)

enum IcoAngle {ZERO_0, ONE_1, NEG_ONE_1, PHI, NEG_PHI, W_1, W_2, W_3}
@export var x := IcoAngle.ONE_1:
    set(val):
        x = val
        if not set_silent:
            cutplane.x = angle_to_float(val)
            upd_cutplane()

@export var y := IcoAngle.ONE_1:
    set(val):
        y = val
        if not set_silent:
            cutplane.y = angle_to_float(val)
            upd_cutplane()

@export var z := IcoAngle.ONE_1:
    set(val):
        z = val
        if not set_silent:
            cutplane.z = angle_to_float(val)
            upd_cutplane()

@export var w := IcoAngle.W_3:
    set(val):
        w = val
        if not set_silent:
            cutplane.w = angle_to_float(val)
            upd_cutplane()

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



func upd_cutplane():
    set_shader_cutplane(cutplane)
    notify_property_list_changed()


enum TransformType {NONE, SOME, NEG_X, NEG_Y, NEG_Z, SWAP_X}
func get_next_cutplane(_cutplane: Vector4, transfrom: TransformType) -> Vector4:
    var c = _cutplane.abs()
    var diag_vec = is_equal_approx(c.x, c.y) \
        and is_equal_approx(c.y, c.z)
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
                _cutplane.x = ico_b * cutplane.x
                _cutplane.y = 0.
                _cutplane.w = w_2
            else:
                _cutplane = Vector4(
                    sign(max(_cutplane.x, 1.)),
                    sign(max(cutplane.y, 1.)),
                    sign(max(cutplane.z, 1.)),
                    w_3
                )
    var a = pointer_sphere.position - mesh_icosahedron.position
    print_debug(a)
    var b = get_closest(a)
    print_debug("v: ", b)
    return Vector4(b.x, b.y, b.z, w_3 if diag_vec else w_2)

func get_closest(v: Vector3) -> Vector3:
    var a = v.clamp(Vector3(-1, -1, -1), Vector3(1,1,1))
    var diag := false
    if a.abs() > Vector3(ico_b,ico_b,ico_b):
        print_debug("a")
    #for i in 3:
        #var s = sign(a[i])
        #if abs(a[i]) < ico_b:
            #a[i] = 0
        #else:
            #a[i] = ico_b * s
        #print_debug(a[i])
    return a

func angle_to_float(ia: IcoAngle) -> float:
    match ia:
        IcoAngle.ZERO_0:
            return 0.
        IcoAngle.ONE_1:
            return ico_a
        IcoAngle.NEG_ONE_1:
            return -ico_a
        IcoAngle.PHI:
            return ico_b
        IcoAngle.NEG_PHI:
            return -ico_b
        IcoAngle.W_1:
            return ico_dst
        IcoAngle.W_2:
            return w_2
        IcoAngle.W_3:
            return w_3
    return 1.

func float_to_angle(f: float) -> IcoAngle:
    if is_equal_approx(f, 0.):
        return IcoAngle.ZERO_0
    elif is_equal_approx(f, ico_a):
        return IcoAngle.ONE_1
    elif is_equal_approx(f, -ico_a):
        return IcoAngle.NEG_ONE_1
    elif is_equal_approx(f, ico_b):
        return IcoAngle.PHI
    elif is_equal_approx(f, ico_b):
        return IcoAngle.NEG_PHI
    elif is_equal_approx(f, ico_dst):
        return IcoAngle.W_1
    elif is_equal_approx(f, w_2):
        return IcoAngle.W_2
    elif is_equal_approx(f, w_3):
        return IcoAngle.W_3
    return IcoAngle.ONE_1

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    pointer_sphere.pointer_changed.connect(_aboba)
    pass # Replace with function body.

func _aboba() -> void:
    trans = TransformType.NONE

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    pass


## icosahedron faces index according to UV map
const faces: Array[Vector3] = [
    Vector3(ico_a, ico_a, -ico_a,), # 0
    Vector3(0, ico_a, -ico_b,), # 1
    Vector3(0, ico_a, ico_b,), # 2
    Vector3(ico_a, ico_a, ico_a,), # 3
    Vector3(ico_a, ico_b, 0,), # 4
    Vector3(ico_a, -ico_b, 0,), # 5
    Vector3(-ico_a, ico_a, ico_a,), # 6
    Vector3(-ico_b, 0, ico_a,), # 7
    Vector3(ico_b, 0, ico_a,), # 8
    Vector3(ico_a, -ico_a, ico_a,), # 9
    Vector3(-ico_a, ico_b, 0), # 10
    Vector3(-ico_a, -ico_b, 0), # 11
    Vector3(-ico_a, -ico_a, ico_a,), # 12
    Vector3(-ico_a, ico_a, -ico_a,), # 13
    Vector3(-ico_b, 0, -ico_a), # 14
    Vector3(-ico_a, -ico_a, -ico_a,), # 15
    Vector3(0, -ico_a, -ico_b), # 16
    Vector3(0, -ico_a, ico_b), # 17
    Vector3(ico_b, 0, -ico_a,), # 18
    Vector3(ico_a, -ico_a, -ico_a,), # 19
]

@export_range(0, 19) var fi: int:
    set(val):
        fi = val
        var v = faces[fi]
        var diag = is_equal_approx(abs(v.x), abs(v.y))
        cutplane = Vector4(v.x, v.y, v.z, ico_dst)
