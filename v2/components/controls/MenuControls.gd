extends Node
class_name MenuControls


@onready var settings = %Settings
@onready var figureRoot := $"../MenuSpawner"
@onready var menu_selector: MenuSelector = %MenuSelector
@onready var menu_scene: Node3D = $'..'

@export var controlledNode: Node3D
@export var MENU_ROTATION_SPEED: float

var target = {
    progress = 0,
    quat = Quaternion(),
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

## Get selected menu intem and execute action that item meant to do
func call_menu_action():
    var selected = menu_selector.get_selected_item()
    if selected.get("action"):
        call(selected.action)
        return

func menu_start_game():
    if Utils.main_scene(self) == 'MenuScene':
        get_tree().quit()
        return
    Utils.set_scene(self, 'LoopScene')

func menu_exit_game():
    get_tree().quit()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    if not controlledNode:
        controlledNode = get_controlled_node()
        target.prev_pos = controlledNode.quaternion
    if Input.is_action_just_pressed("ui_accept"):
        call_menu_action()
    if controlledNode and target.get("progress", 1) < 1:
        target.progress += 0.05
        var t = target.prev_pos.slerp(target.quat, target.progress)
        controlledNode.transform.basis = Basis(t).orthonormalized()
        return
    if Input.is_action_just_pressed("ui_down"):
        change_selection(controlledNode.quaternion * Quats.menu_quat_down(),)
    if Input.is_action_just_pressed("ui_up") or Input.is_action_just_pressed('ui_cancel'):
        change_selection(Quaternion(),)
    if Input.is_action_just_pressed("ui_right"):
        change_selection(controlledNode.quaternion * Quats.menu_quat_left().inverse(),)
    if Input.is_action_just_pressed("ui_left"):
        change_selection(controlledNode.quaternion * Quats.menu_quat_left(),)
    pass

func change_selection(direction, ):
    var dur = 0.2
    var val = 0.03
    var tw = controlledNode.create_tween().set_loops(1)
    tw.tween_property(controlledNode, "position:y", controlledNode.position.y - val, dur)
    tw.set_parallel()
    tw.tween_property(controlledNode, "position:z", controlledNode.position.y - val, dur)
    tw.set_parallel(false)
    tw.tween_property(controlledNode, "position:y", controlledNode.position.y, dur)
    tw.tween_property(controlledNode, "position:z", controlledNode.position.y, dur)

    target = {
        prev_pos = controlledNode.quaternion,
        quat = direction,
        progress = 0.,
    }
