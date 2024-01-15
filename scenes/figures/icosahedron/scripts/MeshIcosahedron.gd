class_name MeshIcosahedron
extends MeshInstance3D

@export var ROTATION_SPEED := 0.009

@onready var cutplane: CutPlane = $'../CutPlane'
@onready var _main: Main = $"/root/Main"
@onready var signals: Signals = $"/root/Main/Signals"

var allow_control := true

# Called when the node enters the scene tree for the first time.
func _ready():
    if randi_range(0, 1):
        material_override.set_shader_parameter("cutplane", Vector4(-1.875, 0.725, 0., 1.578))
    pass
    #signals.new_game_mode.connect(_game_mode_changed)



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta):

    if allow_control:
        var bb = transform.basis
        var a = Quaternion(transform.basis)
        var t = a
        #var t = a * Quaternion(_main.transform.basis)
        if Input.is_action_pressed("ui_up"):
            t = t * Quaternion(-ROTATION_SPEED, 0, 0, 1, )
        if Input.is_action_pressed("ui_down"):
            t = t * Quaternion(ROTATION_SPEED, 0, 0, 1, )
        if Input.is_action_pressed("ui_right"):
            t = t * Quaternion(0, ROTATION_SPEED, 0, 1, )
        if Input.is_action_pressed("ui_left"):
            t = t * Quaternion(0, -ROTATION_SPEED, 0, 1, )
        transform.basis = Basis(t).orthonormalized()
        # rotation = rotation.linear_interpolate(new_rotation, delta * movement_time)

func _game_mode_changed(game_mode: GameStateManager.GameMode) -> void:
    if game_mode == GameStateManager.GameMode.PAUSE:
        allow_control = false
    else:
        allow_control = true
