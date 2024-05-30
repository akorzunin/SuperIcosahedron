extends Node
class_name LoopGui

@onready var game_state_manager: GameStateManager = %GameStateManager
@onready var game_state_label: Label = $GameStatePanel/VBoxContainer/HFlowContainer/GameStateLabel

# Called when the node enters the scene tree for the first time.
func _ready():
    game_state_manager.game_state_changed.connect(_on_game_state_changed)
    pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
    pass


func _on_game_state_changed(old_state: GameStateManager.GameState, new_state: GameStateManager.GameState):
    game_state_label.set_text(GameStateManager.GameStateNames[new_state])
