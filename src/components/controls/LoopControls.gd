extends Node
class_name LoopControls

@export var figureRoot: FigureRoot
@export var controlledNode: MeshIcosahedron
@export var ROTATION_SPEED: float
@onready var game_progress: GameProgress = %GameProgress

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    ROTATION_SPEED = G.settings.ROTATION_SPEED

func set_controlled_node(node: MeshIcosahedron):
    if controlledNode != null and controlledNode is MeshIcosahedron:
        # TODO implemet comments in mesh node
        #controlledNode.set_controlled(false)
        Utils.set_shader_param(controlledNode, "enable", false, 2)
        controlledNode.collider.set_collision_mask_value(1, false)
        controlledNode.collider.set_collision_layer_value(1, false)
    #node.set_controlled(true)
    controlledNode = node
    game_progress.add_one()
    Utils.set_shader_param(controlledNode, "enable", true, 2)

func update_controlled_node():
    var figures = figureRoot.get_node("Anchor").get_children() as Array[Icosahedron]
    var unchecked_mesh: MeshIcosahedron
    for figure in figures:
        if not figure.mesh_icosahedron.angle_good:
            unchecked_mesh = figure.mesh_icosahedron
            break
    if unchecked_mesh and controlledNode != unchecked_mesh:
        set_controlled_node(unchecked_mesh)

func pass_next_node(node: Collider):
    if controlledNode != null \
    and not controlledNode.angle_good \
    and node.mesh_icosahedron == controlledNode:
        controlledNode.angle_good = true
    update_controlled_node()

func _input(event: InputEvent) -> void:
    if event.is_action_pressed('ui_accept'):
        if Utils.main_scene(self) == 'LoopScene':
            get_tree().paused = false
            get_tree().reload_current_scene()
            return
    if get_tree().paused and event.is_action_pressed('ui_cancel'):
        if Utils.main_scene(self) == 'LoopScene':
            get_tree().paused = false
            get_tree().reload_current_scene()
            return
        Utils.set_scene(self, 'LoopScene')
        return
    if event.is_action_pressed('ui_cancel'):
        if Utils.main_scene(self) == 'LoopScene':
            return
        Utils.set_scene(self, 'MenuScene')
        return

    pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    if not controlledNode:
        update_controlled_node()
        return
    var rotation: Quaternion
    var rs := ROTATION_SPEED / 10. * delta

    if Input.is_action_pressed("ui_up"):
        rotation = rotation * Quaternion(0, 0, -rs, 1, )
    if Input.is_action_pressed("ui_down"):
        rotation = rotation * Quaternion(0, 0, rs, 1, )
    if Input.is_action_pressed("ui_right"):
        rotation = rotation * Quaternion(0, rs, 0, 1, )
    if Input.is_action_pressed("ui_left"):
        rotation = rotation * Quaternion(0, -rs, 0, 1, )
    if controlledNode and rotation:
        var t = rotation.normalized() * controlledNode.quaternion
        controlledNode.transform.basis = Basis(t).orthonormalized()
    pass
