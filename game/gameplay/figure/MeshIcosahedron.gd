extends MeshInstance3D
class_name MeshIcosahedron

const BASIC_SHADER = preload("res://game/gameplay/figure/shaders/icosahedron_basic.gdshader")
const DENT_MESH: Mesh = preload("res://game/gameplay/figure/assets/ico_dent_full.res")
const DENT_SOURCE_SIDE_ID := 1

@onready var icosahedron: Icosahedron = $".."

var angle_good := false
var is_alt := false
var is_rotating := false
var rotation_tween: Tween
var fade_tween: Tween
const FADE_TIME := 0.3
var opacity := 1.0:
    set(value):
        opacity = value
        for material in _materials:
            material.set_shader_parameter("opacity", opacity)
var currnt_type: int
var cutplane := Vector3.RIGHT
var _materials: Array[ShaderMaterial] = []
var _dents: Array[Dent] = []
var _side_tris: Array[PackedVector3Array] = []
var _controlled := false
var _dent_marker: MeshInstance3D
var _pickup_labels: Array[Label3D] = []
var _passage_faces: Array[MeshInstance3D] = []

func _ready() -> void:
    _build_dents()
    if icosahedron.data:
        apply_side_data(icosahedron.data.sides)
    currnt_type = icosahedron.shader_type
    if currnt_type >= 0:
        set_type(currnt_type)
    else:
        set_default_type()
    transform.basis = Basis(icosahedron.transform.basis.get_rotation_quaternion())

func set_controlled(state: bool):
    _controlled = state
    for material in _materials:
        material.set_shader_parameter("controlled", state)
    _update_dent_marker()

func _update_dent_marker() -> void:
    if not _dent_marker:
        return
    _dent_marker.hide()
    for label in _pickup_labels:
        label.visible = _controlled
    if not _controlled or not _pickup_labels.is_empty():
        return
    for dent in _dents:
        if dent.is_empty():
            var tri := _side_tris[dent.side_id]
            _dent_marker.position = (tri[0] + tri[1] + tri[2]) / 3.0 * 1.03
            _dent_marker.show()
            return

func _process(_delta: float) -> void:
    var camera := get_viewport().get_camera_3d()
    if not camera:
        return
    var candidates: Array[Label3D] = []
    for label in _pickup_labels:
        # Cancel shell growth so fixed-size labels stay screen-sized.
        label.scale = Vector3.ONE / global_basis.get_scale()
        var outward := label.global_position - global_position
        label.hide()
        if _controlled and outward.dot(camera.global_position - label.global_position) > 0 \
        and not camera.is_position_behind(label.global_position):
            candidates.append(label)
    var screen_center := get_viewport().get_visible_rect().size / 2.0
    candidates.sort_custom(func(a, b): return camera.unproject_position(a.global_position).distance_squared_to(screen_center) \
        < camera.unproject_position(b.global_position).distance_squared_to(screen_center))
    var occupied: Array[Rect2] = []
    # Greedy O(n²) suppression, bounded to 20 faces. Use screen-space label layout
    # if more markers are added; rotating reveals labels hidden by nearer choices.
    var pixels_per_unit := camera.get_camera_projection().y.y * screen_center.y
    for label in candidates:
        var font: Font = label.font if label.font else ThemeDB.fallback_font
        var lines := label.text.split("\n")
        var width := 0.0
        for line in lines:
            width = maxf(width, font.get_string_size(line, HORIZONTAL_ALIGNMENT_LEFT, -1, label.font_size).x)
        var size := Vector2(width, font.get_height(label.font_size) * lines.size()) * label.pixel_size * pixels_per_unit
        var rect := Rect2(camera.unproject_position(label.global_position) - size / 2.0, size).grow(6)
        if not occupied.any(func(other): return other.intersects(rect)):
            occupied.append(rect)
            label.show()

func stop_rotation() -> void:
    if rotation_tween:
        rotation_tween.kill()
        rotation_tween = null
    is_rotating = false

func fade_out() -> void:
    if fade_tween:
        return
    burst_dents()
    fade_tween = create_tween()
    fade_tween.tween_property(self, "opacity", 0.0, FADE_TIME)
    fade_tween.tween_callback(hide)

func burst_dents() -> void:
    if not visible or not _dents.any(func(dent: Dent): return dent.visible):
        return
    stop_rotation()
    set_controlled(false)
    for face in _passage_faces:
        face.hide()
    # Visual-only fragments: keep the original radial colliders intact for passage.
    var fragments := Node3D.new()
    fragments.name = "DentBurst"
    icosahedron.get_parent().get_parent().add_child(fragments)
    var tween := fragments.create_tween().set_parallel(true)
    for dent in _dents:
        if not dent.visible:
            continue
        var tri := _side_tris[dent.side_id]
        var center := (tri[0] + tri[1] + tri[2]) / 3.0
        var world_center := global_transform * center
        var direction := (world_center - global_position).normalized()
        var shard := MeshInstance3D.new()
        shard.mesh = dent.mesh
        shard.material_override = dent.material_override.duplicate()
        shard.cast_shadow = dent.cast_shadow
        fragments.add_child(shard)
        shard.global_transform = dent.global_transform
        dent.hide()
        var distance := world_center.distance_to(global_position) * 0.8
        tween.tween_property(shard, "global_position", shard.global_position + direction * distance, 1.1)
        var material := shard.material_override as ShaderMaterial
        tween.tween_method(func(value: float): material.set_shader_parameter("opacity", value),
            opacity, 0.0, 0.8).set_delay(0.3)
    tween.chain().tween_callback(fragments.queue_free)

func set_cutplane(v: Vector4):
    cutplane = Vector3(v.x, v.y, v.z).normalized()

func set_color(c: Variant):
    var color: Color = c if c is Color else Color(c.x, c.y, c.z, 1.0)
    for material in _materials:
        material.set_shader_parameter("color", color)

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

func apply_side_data(sides: Array[SideData]) -> void:
    for label in _pickup_labels:
        label.free()
    _pickup_labels.clear()
    for face in _passage_faces:
        face.free()
    _passage_faces.clear()
    for side in sides:
        if side.id >= 0 and side.id < _dents.size():
            _dents[side.id].apply_data(side)
            if side.is_empty():
                var face := MeshInstance3D.new()
                var surface := SurfaceTool.new()
                surface.begin(Mesh.PRIMITIVE_TRIANGLES)
                var triangle := _side_tris[side.id]
                var center := (triangle[0] + triangle[1] + triangle[2]) / 3.0
                var face_basis := _basis_for_triangle(triangle)
                var radius := triangle[0].distance_to(center)
                for vertex in triangle:
                    var local := face_basis.inverse() * (vertex - center)
                    surface.set_uv(Vector2(local.x, local.y) / (2.0 * radius) + Vector2(0.5, 0.5))
                    surface.add_vertex(vertex)
                face.mesh = surface.commit()
                var material := ShaderMaterial.new()
                material.shader = preload("res://game/gameplay/figure/shaders/passage_face.gdshader")
                material.set_shader_parameter("noise_texture", preload("res://game/gameplay/figure/assets/passage_noise.png"))
                if side.modifier:
                    material.set_shader_parameter("tint", side.modifier.pickup_color)
                    for entry in UpgradeCatalog.data.pickups:
                        if entry.id == side.modifier.id:
                            material.set_shader_parameter("vortex", entry.value > 1)
                            break
                face.material_override = material
                face.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
                add_child(face)
                _passage_faces.append(face)
            if side.is_empty() and side.modifier and icosahedron.data and icosahedron.data.easy_side >= 0:
                var label := Label3D.new()
                label.text = "◆"
                label.modulate = side.modifier.pickup_color if side.modifier else Color.WHITE
                label.font_size = 48
                label.outline_size = 10
                label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
                label.no_depth_test = true
                label.fixed_size = true
                label.pixel_size = 0.001
                var tri := _side_tris[side.id]
                label.position = (tri[0] + tri[1] + tri[2]) / 3.0 * 1.03
                add_child(label)
                _pickup_labels.append(label)
    _update_dent_marker()

func get_dents() -> Array[Dent]:
    return _dents

func _build_dents() -> void:
    var source := mesh
    if not source or get_node_or_null("Dents"):
        return
    var root := Node3D.new()
    root.name = "Dents"
    add_child(root)
    _side_tris.resize(20)
    var base_basis := _basis_for_triangle(_side_triangle(source, DENT_SOURCE_SIDE_ID))
    for i in 20:
        var dent := Dent.new().init(i, DENT_MESH)
        var tri := _side_triangle(source, i)
        _side_tris[i] = tri
        dent.transform.basis = _basis_for_triangle(tri) * base_basis.inverse()
        var mat := ShaderMaterial.new()
        mat.shader = BASIC_SHADER
        dent.material_override = mat
        dent.cast_shadow = cast_shadow
        _materials.append(mat)
        _dents.append(dent)
        root.add_child(dent)
    mesh = null
    _dent_marker = MeshInstance3D.new()
    _dent_marker.name = "OpenDentMarker"
    var quad := QuadMesh.new()
    quad.size = Vector2(2.0, 2.0)
    _dent_marker.mesh = quad
    var marker_material := ShaderMaterial.new()
    marker_material.shader = preload("res://game/gameplay/figure/shaders/dent_marker.gdshader")
    marker_material.render_priority = 1
    _dent_marker.material_override = marker_material
    _dent_marker.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
    # The billboard is screen-sized; its local quad bounds do not describe its rendered size.
    _dent_marker.extra_cull_margin = 16384.0
    add_child(_dent_marker)
    _dent_marker.hide()

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
