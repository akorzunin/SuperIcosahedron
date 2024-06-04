extends Node
class_name MenuControls


@onready var settings = %Settings
@onready var figureRoot := $"../MenuSpawner"

@export var controlledNode: Node3D
@export var MENU_ROTATION_SPEED: float
var target = {
    progress = 0,
    quat = Quaternion(0, 0, 0, 1, ).normalized(),
}
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    MENU_ROTATION_SPEED = settings.ROTATION_SPEED

    pass  # Replace with function body.

## In menu we apply all rotations to Anshor node
func get_controlled_node() -> Node3D:
    var a = figureRoot.get_node("Anchor").get_children()
    if len(a) > 0:
        return figureRoot.get_node("Anchor")
    return null

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    if not controlledNode:
        controlledNode = get_controlled_node()
        target.prev_pos = controlledNode.quaternion
    var rotation: Quaternion
    if Input.is_action_just_pressed("ui_down"):
        target = {
            prev_pos = controlledNode.quaternion,
            quat = controlledNode.quaternion * Quaternion(-0.345, 0, 0, 0.939, ).normalized(),
            progress = 0.,
        }
    if Input.is_action_just_pressed("ui_up") or Input.is_action_just_pressed('ui_cancel'):
        target = {
            prev_pos = controlledNode.quaternion,
            quat = Quaternion(0, 0, 0, 1, ).normalized(),
            progress = 0.,
        }
    if Input.is_action_just_pressed("ui_right"):
        target = {
            prev_pos = controlledNode.quaternion,
            quat = controlledNode.quaternion * Quaternion(0, -0.506, -0.302, 0.808, ).normalized(),
            progress = 0.,
        }
    if Input.is_action_just_pressed("ui_left"):
        target = {
            prev_pos = controlledNode.quaternion,
            quat = controlledNode.quaternion * Quaternion(0, 0.506, 0.302, 0.808, ).normalized(),
            progress = 0.,
        }
    if controlledNode and target.get("progress", 1) < 1:
        target.progress += 0.05
        var t = target.prev_pos.slerp(target.quat, target.progress)
        controlledNode.transform.basis = Basis(t).orthonormalized()
    pass
