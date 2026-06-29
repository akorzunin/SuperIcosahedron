extends MeshInstance3D
class_name MeshIcosahedron

const BASIC_SHADER = preload("res://src/models/icosahedron/shaders/icosahedron_basic.gdshader")
const DENT_MESH: Mesh = preload("res://src/models/icosahedron/assets/ico_dent_full.res")
const DENT_SOURCE_SIDE_ID := 1

@onready var icosahedron: Icosahedron = $".."
@onready var collider: Collider = $'../Collider'

var angle_good := false
var is_alt := false
var is_rotating := false
var currnt_type: int
var cutplane := Vector3.RIGHT
var _materials: Array[ShaderMaterial] = []
var _side_tris: Array[PackedVector3Array] = []

func _ready() -> void:
    _build_side_dents()
    currnt_type = icosahedron.shader_type
    if currnt_type >= 0:
        set_type(currnt_type)
    else:
        set_default_type()
    if Utils.main_scene(self) in ['MainScene', 'LoopScene', 'MenuScene']:
        transform.basis = Basis(icosahedron.transform.basis.get_rotation_quaternion())

func set_controlled(state: bool):
    if collider:
        collider.set_collision_mask_value(1, state)
        collider.set_collision_layer_value(1, state)
    var c := Color(1.0, 0.9, 0.3, 1.0) if state else _color_for_type(currnt_type)
    set_color(c)

func set_cutplane(v: Vector4):
    cutplane = Vector3(v.x, v.y, v.z).normalized()

func set_color(c: Variant):
    var color: Color = c if c is Color else Color(c.x, c.y, c.z, 1.0)
    for i in _materials.size():
        _materials[i].set_shader_parameter("color", color.lightened(float(i) * 0.012))

func set_type(type: int):
    currnt_type = type
    var variant: Vector4 = IcosahedronVarints.figure_variants_v2.get(type, Vector4(1, 0, 0, 0))
    set_cutplane(variant)
    set_color(_color_for_type(type))

func set_default_type():
    currnt_type = -1
    set_color(Color(0.35, 0.85, 1.0, 1.0))

func _color_for_type(type: int) -> Color:
    var c: Array = TwTheme.figure_variants_v2.get(type, [])
    if c.size() >= 3:
        return Color(float(c[0]), float(c[1]), float(c[2]), 1.0)
    return Color(0.35, 0.85, 1.0, 1.0)

func _build_side_dents() -> void:
    var source := mesh
    if not source or get_node_or_null("Sides"):
        return
    var root := Node3D.new()
    root.name = "Sides"
    add_child(root)
    _side_tris.resize(20)
    var base_basis := _basis_for_triangle(_side_triangle(source, DENT_SOURCE_SIDE_ID))
    for i in 20:
        var side := MeshInstance3D.new()
        side.name = "Side_%02d" % i
        side.mesh = DENT_MESH
        var tri := _side_triangle(source, i)
        _side_tris[i] = tri
        side.transform.basis = _basis_for_triangle(tri) * base_basis.inverse()
        var mat := ShaderMaterial.new()
        mat.shader = BASIC_SHADER
        side.material_override = mat
        side.cast_shadow = cast_shadow
        _materials.append(mat)
        root.add_child(side)
    mesh = null

func get_side_points(side_id: int) -> PackedVector3Array:
    var tri: PackedVector3Array = _side_tris[side_id]
    return PackedVector3Array([Vector3.ZERO, tri[0], tri[1], tri[2]])

func _side_triangle(source: Mesh, side_id: int) -> PackedVector3Array:
    var best := PackedVector3Array()
    var best_dot := -INF
    var target4: Vector4 = IcosahedronVarints.figure_variants_v2[side_id]
    var target := Vector3(target4.x, target4.y, target4.z).normalized()
    for surface in source.get_surface_count():
        var arrays := source.surface_get_arrays(surface)
        var vertices: PackedVector3Array = arrays[Mesh.ARRAY_VERTEX]
        var indices: PackedInt32Array = arrays[Mesh.ARRAY_INDEX]
        var triangle_count := indices.size() / 3 if indices.size() > 0 else vertices.size() / 3
        for t in triangle_count:
            var tri := PackedVector3Array()
            for j in 3:
                tri.append(vertices[indices[t * 3 + j] if indices.size() > 0 else t * 3 + j])
            var n := (tri[1] - tri[0]).cross(tri[2] - tri[0]).normalized()
            var center := (tri[0] + tri[1] + tri[2]) / 3.0
            if n.dot(center) < 0.0:
                n = -n
            var d := n.dot(target)
            if d > best_dot:
                best_dot = d
                best = tri
    return best

func _basis_for_triangle(tri: PackedVector3Array) -> Basis:
    var center := (tri[0] + tri[1] + tri[2]) / 3.0
    var normal := (tri[1] - tri[0]).cross(tri[2] - tri[0]).normalized()
    if normal.dot(center) < 0.0:
        normal = -normal
    var tangent := (tri[0] - center).normalized()
    var bitangent := normal.cross(tangent).normalized()
    return Basis(tangent, bitangent, normal).orthonormalized()
