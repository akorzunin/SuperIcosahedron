extends Control
class_name MenuControls


@onready var settings = %Settings
@onready var menuSpawner := $"../MenuSpawner"
@onready var menu_selector: MenuSelector = %MenuSelector
@onready var menu_scene: Node3D = $'..'

@export var controlledNode: Node3D
@export var MENU_ROTATION_SPEED: float

var target = {
    progress = 0,
    quat = Quaternion(),
}
var initial_pos := Vector3()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    MENU_ROTATION_SPEED = settings.gs.ROTATION_SPEED

    pass  # Replace with function body.

## In menu we apply all rotations to Anshor node
func get_controlled_node() -> Node3D:
    var a = menuSpawner.get_node("Anchor").get_children()
    if len(a) > 0:
        return menuSpawner.get_node("Anchor")
    return null

## Get selected menu intem and execute action that item meant to do
func call_menu_action():
    var selected = menu_selector.get_selected_item()
    if not selected:
        return
    if selected.get("action") != "placeholder_action":
        call(selected.action)
        return
    if selected.get("items"):
        menuSpawner.open_menu_section(controlledNode, selected.items)
        return

func menu_start_game():
    if Utils.main_scene(self) == 'MenuScene':
        get_tree().quit()
        return
    Utils.set_scene(self, 'LoopScene')

func menu_exit_game():
    get_tree().quit()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
    if controlledNode and target.get("progress", 1) < 1:
        target.progress += 0.05
        var t = target.prev_pos.slerp(target.quat, ease(target.progress, -5))
        controlledNode.transform.basis = Basis(t).orthonormalized()
        return

func check_controlled_node():
    if not controlledNode:
        controlledNode = get_controlled_node()
        initial_pos = controlledNode.position
        target.prev_pos = controlledNode.quaternion

func _input(event: InputEvent):
    check_controlled_node()
    if event.is_action_pressed('ui_accept'):
        call_menu_action()
    if controlledNode and target.get("progress", 1) < 1:
        return
    if event.is_action('ui_down'):
        change_selection(controlledNode.quaternion * Quats.menu_quat_down(),)
    if event.is_action_pressed('ui_up') or event.is_action_pressed('ui_cancel'):
        change_selection(Quaternion(),)
    if event.is_action('ui_right'):
        change_selection(controlledNode.quaternion * Quats.menu_quat_left().inverse(),)
    if event.is_action('ui_left'):
        change_selection(controlledNode.quaternion * Quats.menu_quat_left(),)
    pass

func _unhandled_input(event: InputEvent) -> void:
    if event is InputEventScreenTouch:
        InputEmit.new().emit({
            action = 'ui_accept'
        })

func change_selection(direction, ):
    var dur = 0.2
    var val = 0.03
    var tw = controlledNode.create_tween().set_loops(1)
    tw.tween_property(controlledNode, "position:y", initial_pos.y - val, dur)
    tw.set_parallel()
    tw.tween_property(controlledNode, "position:z", initial_pos.z - val, dur)
    tw.set_parallel(false)
    tw.tween_property(controlledNode, "position:y", initial_pos.y, dur)
    tw.set_parallel()
    tw.tween_property(controlledNode, "position:z", initial_pos.z, dur)

    target = {
        prev_pos = controlledNode.quaternion,
        quat = direction,
        progress = 0.,
    }
