extends Area3D
class_name EndDetector

@onready var game_progress: GameProgress = %GameProgress

func _physics_process(_delta: float) -> void:
    var contacts := get_overlapping_areas()
    # Resolve solid contact first: touching an empty dent and its solid neighbor
    # in the same physics tick must not pass depending on signal order.
    for area in contacts:
        if area is SideCollider and not area.side.is_empty():
            game_progress.resolve_side(area.get_figure(), area.side)
    for area in contacts:
        if area is SideCollider and area.side.is_empty():
            game_progress.resolve_side(area.get_figure(), area.side)
