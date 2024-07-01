extends Node
class_name GameStateManager

enum GameState {GAME_MENU, GAME_ACTIVE, GAME_PAUSED, GAME_END}

signal game_state_changed(old_state: GameState, new_state: GameState)

const GameStateNames = {
    GameState.GAME_MENU: "MENU",
    GameState.GAME_ACTIVE: "ACTIVE",
    GameState.GAME_PAUSED: "PAUSED",
    GameState.GAME_END: "END",
}

@export var game_state := GameState.GAME_MENU

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    game_state_changed.connect(_on_game_state_changed)
    pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    pass

func _on_game_state_changed(old_state: GameState, new_state: GameState) -> void:
    game_state = new_state
