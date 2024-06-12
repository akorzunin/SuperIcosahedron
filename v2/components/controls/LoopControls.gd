extends Node
class_name LoopControls

@onready var settings = %Settings

@export var figureRoot: FigureRoot
@export var controlledNode: Node3D
@export var ROTATION_SPEED: float
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    ROTATION_SPEED = settings.ROTATION_SPEED
    pass # Replace with function body.

func angle_good():
    if not controlledNode:
        return
    controlledNode.angle_good = true
    controlledNode = get_controlled_node()

func get_controlled_node() -> Node3D:
    var a = figureRoot.get_node("Anchor").get_children()
    if len(a) > 0:
        if len(a) > 1 and a[0].get_node("MeshIcosahedron").angle_good:
            return a[1].get_node("MeshIcosahedron")
        return a[0].get_node("MeshIcosahedron")
    return null

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    if get_tree().paused:
        if Input.is_action_just_pressed("ui_cancel"):
            if Utils.main_scene(self) == 'LoopScene':
                get_tree().paused = false
                get_tree().reload_current_scene()
                return
            Utils.set_scene(self, 'LoopScene')
    if Input.is_action_just_pressed("ui_cancel"):
        if Utils.main_scene(self) == 'LoopScene':
            return
        Utils.set_scene(self, 'MenuScene')
    var rotation: Quaternion
    if not controlledNode:
        controlledNode = get_controlled_node()
    if Input.is_action_pressed("ui_up"):
        rotation = rotation * Quaternion(0, 0, -ROTATION_SPEED, 1, )
    if Input.is_action_pressed("ui_down"):
        rotation = rotation * Quaternion(0, 0, ROTATION_SPEED, 1, )
    if Input.is_action_pressed("ui_right"):
        rotation = rotation * Quaternion(0, ROTATION_SPEED, 0, 1, )
    if Input.is_action_pressed("ui_left"):
        rotation = rotation * Quaternion(0, -ROTATION_SPEED, 0, 1, )
    if controlledNode and rotation:
        var t = rotation.normalized() * controlledNode.quaternion
        controlledNode.transform.basis = Basis(t).orthonormalized()
    pass
