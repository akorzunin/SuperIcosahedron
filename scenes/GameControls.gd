extends Node3D
class_name GameControls

@onready var signals: Signals = %Signals

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    process_mode = Node.PROCESS_MODE_ALWAYS


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    if Input.is_action_just_pressed('ui_cancel'):
        setGameState(GameStateManager.GameState.GAME_MENU)
    if Input.is_action_just_pressed('ui_accept'):
        if G.game_state == GameStateManager.GameState.GAME_ACTIVE:
            setGameState(GameStateManager.GameState.GAME_PAUSED)
        elif G.game_state == GameStateManager.GameState.GAME_PAUSED:
            setGameState(GameStateManager.GameState.GAME_ACTIVE)
        else:
            setGameState(GameStateManager.GameState.GAME_ACTIVE)

func setGameState(_game_state: GameStateManager.GameState) -> void:
    signals.game_state_changed.emit(_game_state)
    G.game_state = _game_state
