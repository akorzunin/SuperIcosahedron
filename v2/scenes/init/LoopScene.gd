extends Node3D


const utils = preload("res://v2/components/Utils.gd")
@onready var settings = %Settings
@onready var game_state_manager: GameStateManager = %GameStateManager
@export var DEBUG_VISUAL = true
@export var START_PAUSED = true

func init():
    return self

func deinit():
    queue_free()
    return

# Called when the node enters the scene tree for the first time.
func _ready():
    var gs := GameStateManager.GameState
    if utils.is_main_scene(self):
        settings.DEBUG_VISUAL = DEBUG_VISUAL
        var new_gs := gs.GAME_ACTIVE if not START_PAUSED else gs.GAME_PAUSED
        game_state_manager.game_state_changed.emit(gs.GAME_MENU, new_gs)
    else:
        game_state_manager.game_state_changed.emit(gs.GAME_MENU, gs.GAME_ACTIVE)
    pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
    pass
