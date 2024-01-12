class_name Main
extends Node3D

@export var game_state := GameStateManager.GameState.GAME_MENU
@export var GAME_AUTO_START: bool = true
@onready var signals: Signals = $Signals

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    var initial_game_state := GameStateManager.GameState.GAME_MENU
    signals.game_state_changed.emit(initial_game_state)

    if GAME_AUTO_START: autostart()

func autostart():
    await get_tree().create_timer(0.5).timeout
    setGameState(GameStateManager.GameState.GAME_ACTIVE)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    pass

func setGameState(_game_state: GameStateManager.GameState) -> void:
    signals.game_state_changed.emit(_game_state)
    game_state = _game_state

