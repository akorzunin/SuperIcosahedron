class_name Icosahedron
extends Node3D

@export var ROTATION_SPEED := 0.009
@export var allow_control := true
@onready var main = get_node("/root/Main").transform.basis

# Called when the node enters the scene tree for the first time.
func _ready():
    pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
    # make it on signal: game_start
    # var b = Quaternion(1, 0, 0, 1)
    if allow_control:
        var bb = transform.basis
        var a = Quaternion(transform.basis)
        var t = a * Quaternion(main)
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


func _on_signals_pause_game() -> void:
    self.allow_control = false


func _on_signals_start_game() -> void:
    allow_control = true
