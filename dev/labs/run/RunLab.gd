extends Node

@onready var gameplay: LoopScene = $Gameplay
@onready var status: Label = $UI/Panel/Buttons/Status

var collision_debug: Node3D

func _ready() -> void:
    collision_debug = preload("res://dev/labs/run/CollisionDebug.gd").new()
    collision_debug.gameplay = gameplay
    add_child(collision_debug)
    var toggle := CheckButton.new()
    # Keep steering active after mouse clicks, like Restart and Pause.
    toggle.focus_mode = Control.FOCUS_NONE
    toggle.name = "Collisions"
    toggle.text = "Colliders: red solid / green pass / magenta player"
    toggle.toggled.connect(collision_debug.set_enabled)
    $UI/Panel/Buttons.add_child(toggle)
    var observer := CheckButton.new()
    observer.focus_mode = Control.FOCUS_NONE
    observer.name = "Observer"
    observer.text = "Side camera (view only; aim still at player ring)"
    observer.toggled.connect(collision_debug.set_observer)
    $UI/Panel/Buttons.add_child(observer)
    $UI/Panel/Buttons/Restart.pressed.connect(gameplay.restart)
    $UI/Panel/Buttons/Pause.pressed.connect(gameplay.toggle_pause)
    gameplay.menu_requested.connect(func():
        status.text = "Menu request intercepted. Restart to play again."
    )
    gameplay.game_state_manager.game_state_changed.connect(func(_old, state):
        status.text = GameStateManager.GameStateNames[state]
    )
    status.text = "ACTIVE — align the empty dent; accept commits early"
