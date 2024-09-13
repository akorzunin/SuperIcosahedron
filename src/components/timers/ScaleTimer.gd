extends Timer
class_name ScaleTimer

@onready var game_state_manager: GameStateManager = %GameStateManager

# 10 ms
const tick_dur := 10. / 1000.

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    game_state_manager.game_state_changed.connect(_on_game_state)
    autostart =  true
    wait_time = tick_dur

func _on_game_state(old_state: GameStateManager.GameState, new_state: GameStateManager.GameState):
    var gs = GameStateManager.GameState
    if new_state == gs.GAME_END:
        stop()
