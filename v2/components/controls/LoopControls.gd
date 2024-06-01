extends Node
class_name LoopControls

@export var figureRoot: FigureRoot
@export var controlledNode: Node3D
@export var allow_control := true
@export var ROTATION_SPEED := 0.009
@export var base_rotation := Quaternion()
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
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
    var rotation: Quaternion
    if 1:
        if Input.is_action_pressed("ui_up"):
            rotation = rotation * Quaternion(0, 0, -ROTATION_SPEED, 1, )
        if Input.is_action_pressed("ui_down"):
            rotation = rotation * Quaternion(0, 0, ROTATION_SPEED, 1, )
        if Input.is_action_pressed("ui_right"):
            rotation = rotation * Quaternion(0, ROTATION_SPEED, 0, 1, )
        if Input.is_action_pressed("ui_left"):
            rotation = rotation * Quaternion(0, -ROTATION_SPEED, 0, 1, )
    if controlledNode and rotation:
        var t = rotation * controlledNode.quaternion
        controlledNode.transform.basis = Basis(t).orthonormalized()
    pass
