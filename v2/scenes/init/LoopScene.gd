extends Node3D
class_name LoopScene


const utils = preload("res://v2/components/Utils.gd")
@onready var settings = %Settings
@onready var game_state_manager: GameStateManager = %GameStateManager
var game_settings

func init(props: Dictionary):
    if props.get("game_settings"):
        game_settings = props.game_settings
    return self

func deinit():
    queue_free()
    return

# Called when the node enters the scene tree for the first time.
func _ready():
    var gs := GameStateManager.GameState
    if utils.is_main_scene(self):
        var new_gs := gs.GAME_ACTIVE if not settings.START_PAUSED else gs.GAME_PAUSED
        game_state_manager.game_state_changed.emit(gs.GAME_MENU, new_gs)
    else:
        game_state_manager.game_state_changed.emit(gs.GAME_MENU, gs.GAME_ACTIVE)
    pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
    pass
