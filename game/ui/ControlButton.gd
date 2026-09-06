extends Button
class_name GameButton

enum InputType {ACTION, EVENT}
@export var input_type := InputType.EVENT
enum ActionType {UI_CANCEL, UI_ACCEPT, UI_LEFT, UI_RIGHT, UI_UP, UI_DOWN}
@export var action := ActionType.UI_CANCEL
@onready var scene: = $'../../..'
@onready var game_state_manager: GameStateManager

func get_action_name(at: ActionType) -> StringName:
    match at:
        ActionType.UI_RIGHT:
            return 'ui_right'
        ActionType.UI_LEFT:
            return 'ui_left'
        ActionType.UI_UP:
            return 'ui_up'
        ActionType.UI_DOWN:
            return 'ui_down'
        ActionType.UI_ACCEPT:
            return 'ui_accept'
        _:
            return 'ui_cancel'

func _gui_input(event: InputEvent) -> void:
    if not event is InputEventScreenTouch:
        return
    if event.is_released():
        Input.action_release(get_action_name(action))
        return

    if input_type == InputType.EVENT or \
        (game_state_manager and game_state_manager.game_state == GameStateManager.GameState.GAME_END):
        InputEmit.new().emit({
            action = get_action_name(action),
            scene = scene,
        })
    elif input_type == InputType.ACTION:
        Input.action_press(get_action_name(action))
        #Input.action_release(get_action_name(action))

## Width of side touch panels, as a fraction of the viewport.
const SIDE_PANEL := 0.20
## Height of top/bottom touch panels, as a fraction of the viewport.
const VERTICAL_PANEL := 0.30

func set_button_size():
    custom_minimum_size = Vector2.ZERO
    set_offsets_preset(Control.PRESET_FULL_RECT)

    match action:
        ActionType.UI_LEFT:
            anchor_left = 0.0
            anchor_right = SIDE_PANEL
            anchor_top = 0.0
            anchor_bottom = 1.0
        ActionType.UI_RIGHT:
            anchor_left = 1.0 - SIDE_PANEL
            anchor_right = 1.0
            anchor_top = 0.0
            anchor_bottom = 1.0
        ActionType.UI_UP:
            anchor_left = SIDE_PANEL
            anchor_right = 1.0 - SIDE_PANEL
            anchor_top = 0.0
            anchor_bottom = VERTICAL_PANEL
        ActionType.UI_DOWN:
            anchor_left = SIDE_PANEL
            anchor_right = 1.0 - SIDE_PANEL
            anchor_top = 1.0 - VERTICAL_PANEL
            anchor_bottom = 1.0
        ActionType.UI_ACCEPT:
            anchor_left = SIDE_PANEL
            anchor_right = 1.0 - SIDE_PANEL
            anchor_top = VERTICAL_PANEL
            anchor_bottom = 1.0 - VERTICAL_PANEL
        _:
            anchor_left = 0.0
            anchor_right = 1.0
            anchor_top = 0.0
            anchor_bottom = 1.0

    offset_left = 0.0
    offset_top = 0.0
    offset_right = 0.0
    offset_bottom = 0.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    game_state_manager = get_node_or_null('%GameStateManager')
    process_mode = Node.PROCESS_MODE_ALWAYS
    focus_mode = FocusMode.FOCUS_NONE
    set_button_size()
    get_viewport().size_changed.connect(set_button_size)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    #if event is InputEventScreenTouch:

    pass
