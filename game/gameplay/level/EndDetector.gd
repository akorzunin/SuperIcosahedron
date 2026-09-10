extends Area3D
class_name EndDetector

@onready var game_progress: GameProgress = %GameProgress
@onready var figure_root: FigureRoot = $"../FigureRoot"

var debug_contacts := OS.is_debug_build() and "--collision-debug" in OS.get_cmdline_user_args()

const WINDOW_RADIUS := 0.2
const WINDOW_DEPTH := 0.02
const WINDOW_SEGMENTS := 32

func _ready() -> void:
    # Fixed gameplay camera, not the lab's temporary observer camera.
    var camera: Camera3D = $"../Environment/Camera3D"
    global_transform = camera.global_transform.translated_local(Vector3(0, 0, -1.0))
    var window := ConvexPolygonShape3D.new()
    var points := PackedVector3Array()
    for depth in [-WINDOW_DEPTH / 2.0, WINDOW_DEPTH / 2.0]:
        for i in WINDOW_SEGMENTS:
            var angle := TAU * i / WINDOW_SEGMENTS
            points.append(Vector3(cos(angle) * WINDOW_RADIUS, sin(angle) * WINDOW_RADIUS, depth))
    window.points = points
    window.margin = 0.001
    $CollisionShape3D.shape = window

func get_passing_side(figure: Icosahedron) -> SideData:
    # Uniform radial growth leaves these edge planes unchanged. Moving cameras,
    # translating shells or deforming faces would require a swept-path predictor.
    var mesh := figure.mesh_icosahedron
    var window_shape: CollisionShape3D = $CollisionShape3D
    var window: ConvexPolygonShape3D = window_shape.shape
    for side in figure.data.sides:
        if not side.is_empty():
            continue
        var points := mesh.get_side_points(side.id)
        var fits := true
        for edge in 3:
            var a := mesh.global_basis * points[edge + 1]
            var b := mesh.global_basis * points[(edge + 1) % 3 + 1]
            var inside := mesh.global_basis * points[(edge + 2) % 3 + 1]
            var normal := a.cross(b).normalized()
            if normal.dot(inside) < 0.0:
                normal = -normal
            for point in window.points:
                var relative := window_shape.global_transform * point - mesh.global_position
                if normal.dot(relative) <= 0.0:
                    fits = false
                    break
            if not fits:
                break
        if fits:
            return side
    return _get_union_side(figure)

func _get_union_side(figure: Icosahedron) -> SideData:
    if figure.data.sides.filter(func(side): return side.is_empty()).size() < 2:
        return null
    var mesh := figure.mesh_icosahedron
    var shape: CollisionShape3D = $CollisionShape3D
    var window: ConvexPolygonShape3D = shape.shape
    var center := shape.global_position - mesh.global_position
    var x := shape.global_basis.x.normalized()
    var y := shape.global_basis.y.normalized()
    var z := shape.global_basis.z.normalized()
    var distance := z.dot(center)
    var projected := PackedVector2Array()
    for point in window.points:
        var relative := shape.global_transform * point - mesh.global_position
        if z.dot(relative) * distance <= 0:
            return null
        var on_plane := relative * (distance / z.dot(relative)) - center
        projected.append(Vector2(on_plane.dot(x), on_plane.dot(y)))
    # Perspective projection of the convex prism is a convex polygon. Testing
    # solid-sector intersections covers its interior, not only its vertices.
    var hull := Geometry2D.convex_hull(projected)
    var polygon := PackedVector3Array()
    for point in hull:
        polygon.append(center + x * point.x + y * point.y)
    for side in figure.data.sides:
        if side.is_empty():
            continue
        var clipped := polygon
        var points := mesh.get_side_points(side.id)
        for edge in 3:
            var a := mesh.global_basis * points[edge + 1]
            var b := mesh.global_basis * points[(edge + 1) % 3 + 1]
            var inside := mesh.global_basis * points[(edge + 2) % 3 + 1]
            var normal := a.cross(b).normalized()
            if normal.dot(inside) < 0:
                normal = -normal
            clipped = _clip_half_plane(clipped, normal)
            if clipped.is_empty():
                break
        if not clipped.is_empty():
            return null
    # Crossing an internal open/open border collects exactly one pickup:
    # the face under the window center (lowest ID breaks exact boundary ties).
    var id := FaceTopology.nearest(mesh.global_basis.inverse() * center)
    return figure.data.sides[id] if figure.data.sides[id].is_empty() else null

func _clip_half_plane(polygon: PackedVector3Array, normal: Vector3) -> PackedVector3Array:
    var result := PackedVector3Array()
    if polygon.is_empty():
        return result
    var previous := polygon[polygon.size() - 1]
    var previous_d := normal.dot(previous)
    for current in polygon:
        var current_d := normal.dot(current)
        if (current_d >= 0) != (previous_d >= 0):
            result.append(previous.lerp(current, previous_d / (previous_d - current_d)))
        if current_d >= 0:
            result.append(current)
        previous = current
        previous_d = current_d
    return result

func _physics_process(_delta: float) -> void:
    var contacts: Dictionary = {}
    for area in get_overlapping_areas():
        if not area is SideCollider:
            continue
        var figure: Icosahedron = area.get_figure()
        # Solid edges take precedence only within the SAME figure. A later
        # shell's failure must not erase an earlier shell's simultaneous pass.
        if not contacts.has(figure) or not area.side.is_empty():
            contacts[figure] = area.side
    # Spawn order also excludes menu/presentation colliders in the shared world.
    for figure in figure_root.get_live_figures():
        if contacts.has(figure):
            # Use the same full-window clearance as commit, not physics margins
            # as an extra invisible player radius. Overlap still gates arrival.
            var passing := get_passing_side(figure)
            if passing:
                contacts[figure] = passing
            elif contacts[figure].is_empty():
                # An edge-straddling window must meet the solid neighbor before
                # resolving; touching the empty trigger alone isn't a pass.
                continue
            if debug_contacts and not figure.resolved and not figure.despawning \
            and game_progress.game_state_manager.game_state == GameStateManager.GameState.GAME_ACTIVE:
                var touching: Array[int] = []
                for area in get_overlapping_areas():
                    if area is SideCollider and area.figure == figure:
                        touching.append(area.side.id)
                touching.sort()
                print("COLLISION tick=%s figure=%s stage=%s contacts=%s selected=%s empty=%s scale=%s visible=%s" % [
                    Engine.get_physics_frames(), figure.get_instance_id(), figure.data.stage,
                    touching, contacts[figure].id, contacts[figure].is_empty(),
                    figure.scale, figure.mesh_icosahedron.is_visible_in_tree()])
            game_progress.resolve_side(figure, contacts[figure])
