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
    return null

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
