extends Control
class_name MenuControls

@onready var sfx_player: SfxPlayer = $"/root/MainScene/SfxPlayer"
@onready var menuSpawner := $"../MenuSpawner"
@onready var menu_selector: MenuSelector = %MenuSelector
@onready var menu_scene: Node3D = $'..'
@onready var menu_state: MenuState = %MenuState
@onready var config: Config = $'../Config'
@onready var actions: MenuActions = %MenuActions

@export var controlledNode: Node3D
@export var MENU_ROTATION_SPEED: float

var target = {
    progress = 1,
    quat = Quaternion(),
}
var initial_pos := Vector3()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    MENU_ROTATION_SPEED = G.settings.ROTATION_SPEED

## In menu we apply all rotations to Anshor node
func get_controlled_node() -> Node3D:
    var node = menuSpawner.get_node("Anchor").get_children()
    if len(node) > 0:
        return menuSpawner.get_node("Anchor")
    return null

## Get selected menu intem and execute action that item meant to do
func call_menu_action():
    var selected = menu_selector.get_selected_item()
    if not selected:
        return
    var action = selected.get("action")
    if action == "menu_start_game":
        sfx_player.on_action_select.emit()
    else:
        sfx_player.on_section_select.emit()
    if action != "placeholder_action":
        actions.call(selected.action)
        return
    if selected.get("options"):
        pass
    if selected.get("items"):
        if selected.items.get("options"):
            menuSpawner.open_options_section(controlledNode, selected.items)
            return
        var err := menu_state.forth(selected.items)
        if err != OK:
            return
        menuSpawner.open_menu_section(controlledNode, selected.items)
        return

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

func skip_menu_event(event: InputEvent) -> bool:
    if event is InputEventKey:
        return false
    if event is InputEventAction:
        return false
    return true

func _input(event: InputEvent):
    if skip_menu_event(event):
        return
    check_controlled_node()
    if event.is_action_pressed('ui_accept'):
        if event is InputEventKey and event.alt_pressed:
            return
        call_menu_action()
    if event.is_action_pressed('ui_cancel'):
        var selected = menu_selector.get_selected_item()
        if selected == null:
            return
        if selected.label == "start":
            change_selection(Quats.menu_quat_left(),)
            return
        if selected.label == "exit":
            actions.call("menu_exit_game")
            return
        actions.call("menu_back")
        sfx_player.on_section_select.emit()
        return
    if controlledNode and target.get("progress", 1) < 1:
        return
    if event.is_action('ui_down'):
        change_selection(controlledNode.quaternion * Quats.menu_quat_down(),)
    if event.is_action_pressed('ui_up'):
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

func change_selection(direction: Quaternion, silent := false):
    if not silent:
        sfx_player.on_section_chaged.emit()
    var dur = 0.2
    var val = 0.03
    var tw = controlledNode.create_tween()
    tw.tween_property(controlledNode, "position:y", initial_pos.y - val, dur)
    tw.set_parallel()
    tw.tween_property(controlledNode, "position:z", initial_pos.z - val, dur)
    tw.set_parallel(false)
    tw.tween_property(controlledNode, "position:y", initial_pos.y, dur)
    tw.set_parallel()
    tw.tween_property(controlledNode, "position:z", initial_pos.z, dur)
    tw.play()

    target = {
        prev_pos = controlledNode.quaternion,
        quat = direction,
        progress = 0.,
    }
