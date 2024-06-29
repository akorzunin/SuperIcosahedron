extends Button
class_name GameButton

enum InputType {ACTION, EVENT}
@export var input_type := InputType.EVENT
enum ActionType {UI_CANCEL, UI_ACCEPT, UI_LEFT, UI_RIGHT, UI_UP, UI_DOWN}
@export var action := ActionType.UI_CANCEL
@onready var scene: = $'../../..'

#const BASE = preload('res://v2/themes/Base.theme')

func get_action_name(a: ActionType) -> StringName:
    match a:
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
    if event is InputEventScreenTouch:
        if event.is_pressed():
            if input_type == InputType.EVENT:
                InputEmit.new().emit({
                    action = get_action_name(action),
                    scene = scene,
                })
            elif input_type == InputType.ACTION:
                Input.action_press(get_action_name(action))
                #Input.action_release(get_action_name(action))
        elif event.is_released():
            Input.action_release(get_action_name(action))

## width of side panel
const a := 20
## height of top/bot panel
const c := 30
const b := 100 - 2 * a
const d := 100 - 2 * c
func set_button_size():
    #var screenSize = get_window().size
    var screenSize = get_viewport_rect().size
    match action:
        ActionType.UI_LEFT:
            custom_minimum_size.x = int(screenSize.x * (a / 100.))
            custom_minimum_size.y = int(screenSize.y)
        ActionType.UI_RIGHT:
            custom_minimum_size.x = int(screenSize.x * (a / 100.))
            custom_minimum_size.y = int(screenSize.y)
        ActionType.UI_UP:
            custom_minimum_size.x = int(screenSize.x * (b / 100.))
            custom_minimum_size.y = int(screenSize.y * (c / 100.))
        ActionType.UI_DOWN:
            custom_minimum_size.x = int(screenSize.x * (b / 100.))
            custom_minimum_size.y = int(screenSize.y * (c / 100.))
        ActionType.UI_ACCEPT:
            custom_minimum_size.x = int(screenSize.x * (b / 100.))
            custom_minimum_size.y = int(screenSize.y * (d / 100.))
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    process_mode = Node.PROCESS_MODE_ALWAYS
    set_button_size()
    pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    #if event is InputEventScreenTouch:

    pass
