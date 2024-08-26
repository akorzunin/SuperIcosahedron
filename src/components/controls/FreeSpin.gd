extends RefCounted
class_name FreeSpin

static func handle_free_spin_input(controlledNode: MeshInstance3D, rot_speed: float, is_inverted := false):
    if not controlledNode:
        return
    var rotation: Quaternion

    if Input.is_action_pressed("ui_up"):
        rotation = rotation * Quaternion(0, 0, -rot_speed, 1, )
    if Input.is_action_pressed("ui_down"):
        rotation = rotation * Quaternion(0, 0, rot_speed, 1, )
    if Op.xor(is_inverted, Input.is_action_pressed("ui_right")):
        rotation = rotation * Quaternion(0, rot_speed, 0, 1, )
    if Op.xor(is_inverted, Input.is_action_pressed("ui_left")):
        rotation = rotation * Quaternion(0, -rot_speed, 0, 1, )
    if rotation:
        var t = rotation.normalized() * controlledNode.quaternion
        controlledNode.transform.basis = Basis(t).orthonormalized()
