extends Area3D
class_name EndDetector

@onready var game_progress: GameProgress = %GameProgress
@onready var loop_controls: LoopControls = %LoopControls
@onready var debug_stats_container: DebugStatsContainer = %DebugStatsContainer

func _ready() -> void:
    area_entered.connect(_on_area_entered)

func _physics_process(_delta: float) -> void:
    for area in get_overlapping_areas():
        _try_resolve(area)

func _on_area_entered(area: Area3D) -> void:
    _try_resolve(area)

func _try_resolve(area: Area3D) -> void:
    if area is Collider:
        if area.mesh_icosahedron != loop_controls.controlledNode:
            return
        var figure := area.get_figure() as Icosahedron
        game_progress.resolve_side(figure, _get_facing_side(figure))
        return
    # Kept as a fallback for older/debug scenes, but gameplay should use the
    # single figure collider. Per-side convex colliders are unreliable on edges.
    if area is SideCollider:
        game_progress.resolve_side(area.get_figure(), area.side)

func _get_facing_side(figure: Icosahedron) -> SideData:
    if not figure or not figure.data:
        return null
    var pass_dir := (global_position - figure.global_position).normalized()
    var mesh_basis := figure.mesh_icosahedron.global_transform.basis.orthonormalized()
    var best_side: SideData
    var best_dot := -INF
    for side in figure.data.sides:
        var world_normal := (mesh_basis * side.normal).normalized()
        var d := world_normal.dot(pass_dir)
        if d > best_dot:
            best_dot = d
            best_side = side
    if debug_stats_container and best_side:
        debug_stats_container.angle.label_text = str(acos(clamp(best_dot, -1.0, 1.0)))
    return best_side
