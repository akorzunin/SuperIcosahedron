class_name Main
extends Node3D


@export var game_state := GameStateManager.GameState.GAME_MENU
@onready var signals: Signals = $Signals

func _input(event: InputEvent) -> void:
    pass

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    signals = signals
    var initial_game_state := GameStateManager.GameState.GAME_MENU
    signals.game_state_changed.emit(initial_game_state)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    if Input.is_action_just_pressed('ui_cancel'):
        setGameState(GameStateManager.GameState.GAME_MENU)
    if Input.is_action_just_pressed('ui_accept'):
        if game_state == GameStateManager.GameState.GAME_ACTIVE:
            setGameState(GameStateManager.GameState.GAME_PAUSED)
        elif game_state == GameStateManager.GameState.GAME_PAUSED:
            setGameState(GameStateManager.GameState.GAME_ACTIVE)
        else:
            setGameState(GameStateManager.GameState.GAME_ACTIVE)

func setGameState(_game_state: GameStateManager.GameState) -> void:
    signals.game_state_changed.emit(_game_state)
    game_state = _game_state

