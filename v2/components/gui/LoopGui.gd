extends Node
@onready var game_state_label: Label = $GameStatePanel/VBoxContainer/HFlowContainer/GameStateLabel

# Called when the node enters the scene tree for the first time.
func _ready():
    game_state_label.set_text("STARTED")
    pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
    pass
