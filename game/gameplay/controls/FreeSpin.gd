extends RefCounted
class_name FreeSpin

static func rotate(target: MeshInstance3D, direction: Vector2, rot_speed: float) -> void:
    if not target or direction == Vector2.ZERO:
        return
    var rotation := Quaternion(0, 0, direction.y * rot_speed, 1).normalized() \
        * Quaternion(0, direction.x * rot_speed, 0, 1).normalized()
    target.basis = Basis(rotation * target.quaternion).orthonormalized()

# Menu input still uses this entry point; rotation math is shared with gameplay.
static func handle_free_spin_input(target: MeshInstance3D, rot_speed: float, is_inverted := false):
    var direction := Vector2(
        Input.get_axis("ui_left", "ui_right"),
        Input.get_axis("ui_up", "ui_down")
    )
    if is_inverted:
        direction.x = -direction.x
    rotate(target, direction, rot_speed)
