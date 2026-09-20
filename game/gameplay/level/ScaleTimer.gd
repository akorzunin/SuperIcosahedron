extends Node
class_name ScaleTimer

@onready var game_state_manager: GameStateManager = %GameStateManager

# Reference interval for the original growth multiplier, not a ticking timer.
const tick_dur := 10. / 1000.

var paused := false
var running := false


func start() -> void:
    running = true


func stop() -> void:
    running = false


func is_stopped() -> bool:
    return not running


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    game_state_manager.game_state_changed.connect(_on_game_state)


func _on_game_state(old_state: GameStateManager.GameState, new_state: GameStateManager.GameState):
    var gs = GameStateManager.GameState
    if new_state == gs.GAME_PAUSED:
        paused = true
    elif new_state == gs.GAME_ACTIVE:
        paused = false
        if is_stopped():
            start()
    elif new_state in [gs.GAME_END, gs.GAME_MENU]:
        stop()
