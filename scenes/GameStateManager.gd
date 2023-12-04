class_name GameStateManager
extends Node

enum GameState {GAME_MENU, GAME_ACTIVE, GAME_PAUSED}

const GameStateNames = {
    GameState.GAME_MENU: "MENU",
    GameState.GAME_ACTIVE: "ACTIVE",
    GameState.GAME_PAUSED: "PAUSED",
}

enum GameMode {START, PAUSE, RESUME, END}

@export var _game_state := GameState.GAME_MENU

@onready var signals: Signals = $"/root/Main/Signals"
@onready var game_state_label: Label = $ '../Gui/GameStatePanel/VBoxContainer/HFlowContainer/GameStateLabel'

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    game_state_label.set_text(GameStateManager.GameStateNames[_game_state])


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    pass


func _on_signals_game_state_changed(game_state: GameState) -> void:
    game_state_label.set_text(GameStateNames[game_state])
    if _game_state == GameState.GAME_MENU and game_state == GameState.GAME_ACTIVE:
        signals.new_game_mode.emit(GameMode.START)
    elif _game_state == GameState.GAME_ACTIVE and game_state == GameState.GAME_PAUSED:
        signals.new_game_mode.emit(GameMode.PAUSE)
    elif _game_state == GameState.GAME_PAUSED and game_state == GameState.GAME_ACTIVE:
        signals.new_game_mode.emit(GameMode.RESUME)
    _game_state = game_state
