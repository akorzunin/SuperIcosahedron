extends Node

@onready var gameplay: LoopScene = $Gameplay
@onready var status: Label = $UI/Panel/Buttons/Status

func _ready() -> void:
    $UI/Panel/Buttons/Restart.pressed.connect(gameplay.restart)
    $UI/Panel/Buttons/Pause.pressed.connect(gameplay.toggle_pause)
    gameplay.menu_requested.connect(func():
        status.text = "Menu request intercepted. Restart to play again."
    )
    gameplay.game_state_manager.game_state_changed.connect(func(_old, state):
        status.text = GameStateManager.GameStateNames[state]
    )
    status.text = "ACTIVE — legacy end detector pending replacement"
