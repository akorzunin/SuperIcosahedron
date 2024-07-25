extends Timer
class_name ScaleTimer

@onready var game_state_manager: GameStateManager = %GameStateManager

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    game_state_manager.game_state_changed.connect(_on_game_state)
    autostart =  true
    # 10 ms
    wait_time = 10. / 1000.

func _on_game_state(old_state: GameStateManager.GameState, new_state: GameStateManager.GameState):
    var gs = GameStateManager.GameState
    if new_state == gs.GAME_END:
        stop()
