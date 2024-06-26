extends Node
class_name LoopControls

@onready var settings = %Settings

@export var figureRoot: FigureRoot
@export var controlledNode: MeshIcosahedron
@export var ROTATION_SPEED: float
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    ROTATION_SPEED = settings.ROTATION_SPEED
    pass # Replace with function body.

func set_controlled_node(node: MeshIcosahedron):
    if controlledNode != null and controlledNode is MeshIcosahedron:
        Utils.set_shader_param(controlledNode, "enable", false, 2)
        controlledNode.collider.set_collision_mask_value(1, false)
        controlledNode.collider.set_collision_layer_value(1, false)
    controlledNode = node
    Utils.set_shader_param(controlledNode, "enable", true, 2)

func update_controlled_node():
    var a = figureRoot.get_node("Anchor").get_children() as Array[Icosahedron]
    var b = Array() as Array[MeshIcosahedron]
    for i in a:
        if not i.mesh_icosahedron.angle_good:
            b.append(i.mesh_icosahedron)

    if len(b) > 0 and controlledNode != b[0]:
        set_controlled_node(b[0])

    return null

func get_controlled_node() -> Node3D:
    var a = figureRoot.get_node("Anchor").get_children() as Array[Icosahedron]
    for i in a:
        if i.mesh_icosahedron.angle_good:
            Utils.set_shader_param(i.mesh_icosahedron, "enable", false, 2)
            continue
        Utils.set_shader_param(i.mesh_icosahedron, "enable", true, 2)
        return i.mesh_icosahedron

    if controlledNode:
        return controlledNode
    return null

func pass_next_node(node: Collider):
    if controlledNode != null \
    and not controlledNode.angle_good \
    and node.mesh_icosahedron == controlledNode:
        controlledNode.angle_good = true
    update_controlled_node()

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

    if not controlledNode:
        update_controlled_node()
        return
    var rotation: Quaternion
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
