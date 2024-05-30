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

@export var _game_state := GameState.GAME_MENU

#@onready var signals: Signals = $"/root/Main/Signals"
#@onready var game_state_label: Label = $ '../Gui/GameStatePanel/VBoxContainer/HFlowContainer/GameStateLabel'

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    #game_state_label.set_text(GameStateManager.GameStateNames[_game_state])
    pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    pass


#func _on_signals_game_state_changed(game_state: GameState) -> void:
    #game_state_label.set_text(GameStateNames[game_state])
    #if _game_state == GameState.GAME_MENU and game_state == GameState.GAME_ACTIVE:
        #signals.new_game_mode.emit(GameMode.START)
    #elif _game_state == GameState.GAME_ACTIVE and game_state == GameState.GAME_PAUSED:
        #signals.new_game_mode.emit(GameMode.PAUSE)
        #get_tree().paused = true
    #elif _game_state == GameState.GAME_PAUSED and game_state == GameState.GAME_ACTIVE:
        #signals.new_game_mode.emit(GameMode.RESUME)
        #get_tree().paused = false
    #_game_state = game_state
