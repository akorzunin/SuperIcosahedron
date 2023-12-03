extends Node

@export var _game_state: G.GameState = G.GameState.GAME_MENU

@onready var main: Main = $ '..'
@onready var game_state_label: Label = $ '../Gui/GameStatePanel/VBoxContainer/HFlowContainer/GameStateLabel'

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    game_state_label.set_text(G.GameStateNames[_game_state])


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    pass


func _on_signals_game_state_changed(game_state: G.GameState) -> void:
    game_state_label.set_text(G.GameStateNames[game_state])
    if _game_state == G.GameState.GAME_MENU and game_state == G.GameState.GAME_ACTIVE:
        main.signals.start_game.emit()
    pass  # Replace with function body.
