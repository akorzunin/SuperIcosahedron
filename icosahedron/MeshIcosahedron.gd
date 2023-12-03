class_name MeshIcosahedron
extends MeshInstance3D

@export var SCALE_FACTOR := 1.009
@export var scaling_enabled = true
@onready var main: Main = get_node("/root/Main")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    main.signals.start_game.connect(_game_started)
    main.signals.pause_game.connect(_game_paused)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    if scaling_enabled:
        scale_object_local(Vector3(SCALE_FACTOR, SCALE_FACTOR, SCALE_FACTOR, ))


func _game_started():
    scaling_enabled = true

func _game_paused():
    scaling_enabled = false
