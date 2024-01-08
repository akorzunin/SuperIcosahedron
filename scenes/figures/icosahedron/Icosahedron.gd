@tool
class_name Icosahedron
extends MeshInstance3D

@export var ROTATION_SPEED := 0.009
var allow_control := true
@onready var main: Main = $"/root/Main"
@onready var signals: Signals = $"/root/Main/Signals"

# Called when the node enters the scene tree for the first time.
func _ready():
    signals.new_game_mode.connect(_game_mode_changed)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
    # make it on signal: game_start
    # var b = Quaternion(1, 0, 0, 1)
    #if allow_control:
    var bb = transform.basis
    var a = Quaternion(transform.basis)
    var t = a * Quaternion(main.transform.basis)
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
