class_name Main
extends Node3D


@export var game_state: G.GameState = G.GameState.GAME_MENU
@onready var game_state_label = $Gui/GameStatePanel/VBoxContainer/HFlowContainer/GameStateLabel
var IcosahedronPath = load('res://icosahedron/Icosahedron.tscn')
@onready var signals: Node = $Signals

func _input(event: InputEvent) -> void:
    pass

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    signals = signals
    var initial_game_state := G.GameState.GAME_MENU
    signals.game_state_changed.emit(initial_game_state)
    game_state_label.set_text(G.GameStateNames[initial_game_state])
    var icosahedron = IcosahedronPath.instantiate()
    add_child(icosahedron)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    if Input.is_action_just_pressed('ui_cancel'):
        setGameState(G.GameState.GAME_MENU)
    if Input.is_action_just_pressed('ui_accept'):
        if game_state == G.GameState.GAME_ACTIVE:
            setGameState(G.GameState.GAME_PAUSED)
        elif game_state == G.GameState.GAME_PAUSED:
            setGameState(G.GameState.GAME_ACTIVE)
        else:
            setGameState(G.GameState.GAME_ACTIVE)

func setGameState(_game_state: G.GameState) -> void:
    game_state = _game_state
    game_state_label.set_text(G.GameStateNames[_game_state])
    signals.game_state_changed.emit(_game_state)
