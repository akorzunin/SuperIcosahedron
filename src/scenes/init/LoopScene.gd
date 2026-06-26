extends Node3D
class_name LoopScene


@onready var game_state_manager: GameStateManager = %GameStateManager
var game_settings
var start_inactive := false

func init(props: Dictionary):
    if props.get("game_settings"):
        game_settings = props.game_settings
    start_inactive = props.get("start_inactive", false)
    return self

func deinit():
    queue_free()
    return

# Called when the node enters the scene tree for the first time.
func _ready():
    if start_inactive:
        return
    var gs := GameStateManager.GameState
    if Utils.is_main_scene(self):
        var new_gs := gs.GAME_ACTIVE if not G.settings.get("START_PAUSED", false) else gs.GAME_PAUSED
        game_state_manager.change_state(new_gs)
    else:
        game_state_manager.change_state(gs.GAME_ACTIVE)
    pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
    pass
