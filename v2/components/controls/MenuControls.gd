extends Node
class_name MenuControls


@onready var settings = %Settings
@onready var figureRoot := $"../MenuSpawner"

@export var controlledNode: Node3D
@export var MENU_ROTATION_SPEED: float
var target = {progress = 1}
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    MENU_ROTATION_SPEED = settings.ROTATION_SPEED

    pass # Replace with function body.

func get_controlled_node() -> Node3D:
    var a = figureRoot.get_node("Anchor").get_children()
    if len(a) > 0:
        return a[0].get_node("MeshIcosahedron")
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
            quat = Quaternion(0, 0, -0.32, 1, ).normalized(),
            progress = 0.,
        }
        #rotation = rotation * Quaternion(0, 0, -MENU_ROTATION_SPEED, 1, )
        #rotation = rotation * Quaternion(0, 0, -0.32, 1, )
    if Input.is_action_just_pressed("ui_up"):
        target = {
            prev_pos = controlledNode.quaternion,
            quat = Quaternion(0, 0, 0, 1, ).normalized(),
            progress = 0.,
        }
    if Input.is_action_just_pressed("ui_right"):
        target = {
            prev_pos = controlledNode.quaternion,
            quat = Quaternion(0, 0.32, 0, 1, ).normalized(),
            progress = 0.,
        }
    if Input.is_action_just_pressed("ui_left"):
        target = {
            prev_pos = controlledNode.quaternion,
            quat = Quaternion(0, -0.32, 0, 1, ).normalized(),
            progress = 0.,
        }
    if controlledNode and target.get("progress", 1) < 1:
        target.progress += 0.01
        var t = target.prev_pos.slerp(target.quat, target.progress)
        controlledNode.transform.basis = Basis(t).orthonormalized()
    pass
