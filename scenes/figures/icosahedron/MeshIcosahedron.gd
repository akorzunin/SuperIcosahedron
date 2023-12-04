class_name MeshIcosahedron
extends MeshInstance3D

@export var SCALE_FACTOR := 1.009
@export var scaling_enabled = true
@onready var signals: Signals = $"/root/Main/Signals"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    signals.new_game_mode.connect(_game_mode_changed)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    if scaling_enabled:
        scale_object_local(Vector3(SCALE_FACTOR, SCALE_FACTOR, SCALE_FACTOR, ))


func _game_mode_changed(game_mode: GameStateManager.GameMode) -> void:
    if game_mode == GameStateManager.GameMode.PAUSE:
        scaling_enabled = false
    else:
        scaling_enabled = true
