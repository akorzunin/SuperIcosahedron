class_name MainIcosahedron
extends Node3D

@onready var settings = %Settings
@export var scaling_enabled = false
var SCALE_FACTOR
#@onready var signals: Signals = $"/root/Main/Signals"
#@onready var area: Area3D = $"/root/Main/CollisionContainer"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    SCALE_FACTOR = settings.SCALE_FACTOR
    #signals.new_game_mode.connect(_game_mode_changed)
    #area.area_entered.connect(func (n: Area3D): n.get_parent().queue_free())
    pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
    if scaling_enabled:
        scale_object_local(Vector3(SCALE_FACTOR, SCALE_FACTOR, SCALE_FACTOR, ))

#func _game_mode_changed(game_mode: GameStateManager.GameMode) -> void:
    #scaling_enabled = false if game_mode == GameStateManager.GameMode.PAUSE else true
