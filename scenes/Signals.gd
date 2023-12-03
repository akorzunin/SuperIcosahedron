class_name Signals
extends Node

signal game_state_changed(game_state: G.GameState)
signal spawn_figure(figure: Figure)
signal start_game

class Figure:
    var type: String = "new"
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    pass  # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    pass
