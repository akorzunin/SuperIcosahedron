class_name MeshIcosahedron
extends MeshInstance3D

@export var ROTATION_SPEED := 0.009

#@onready var cutplane: CutPlane = $'../CutPlane'
@onready var _main: Main = $"/root/Main"
@onready var signals: Signals = $"/root/Main/Signals"

var allow_control := true

# Called when the node enters the scene tree for the first time.
func _ready():
    if randi_range(0, 1):
        set_instance_shader_parameter("cutplane", Vector4(-1.875, 0.725, 0., 1.578))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
    transform.basis = Basis(transform.basis.get_rotation_quaternion())
    pass


func _game_mode_changed(game_mode: GameStateManager.GameMode) -> void:
    if game_mode == GameStateManager.GameMode.PAUSE:
        allow_control = false
    else:
        allow_control = true
