class_name Main
extends Node3D


signal game_state_changed(game_state: Global.GameState)
@export var game_state: Global.GameState = Global.GameState.GAME_MENU

var IcosahedronPath = load('res://icosahedron/Icosahedron.tscn')

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    game_state_changed.emit(Global.GameState.GAME_MENU)
    var icosahedron = IcosahedronPath.instantiate()
    add_child(icosahedron)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    if Input.is_action_pressed('ui_cancel'):
        setGameState(Global.GameState.GAME_MENU)
    # TODO: use debounce or proper events
    if Input.is_action_pressed('ui_accept'):
        if game_state == Global.GameState.GAME_ACTIVE:
            setGameState(Global.GameState.GAME_PAUSED)
        elif game_state == Global.GameState.GAME_PAUSED:
            setGameState(Global.GameState.GAME_ACTIVE)
        else:
            setGameState(Global.GameState.GAME_ACTIVE)

func setGameState(_game_state: Global.GameState) -> void:
    game_state = _game_state
    game_state_changed.emit(_game_state)
