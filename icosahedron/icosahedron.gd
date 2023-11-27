extends Node3D


@export var ROTATION_SPEED := 0.009

#var basis = Basis()
# Contains the following default values:

@onready var main = get_node("/root/Main").transform.basis

# Called when the node enters the scene tree for the first time.
func _ready():
    pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
    # make it on signal: game_start
    # var b = Quaternion(1, 0, 0, 1)
    var bb = transform.basis
    var a = Quaternion(transform.basis)
    var t = a * Quaternion(main)
    if Input.is_action_pressed("ui_up"):
        t = t * Quaternion(
                -ROTATION_SPEED,  # x, # y, # z
                0,
                0,
                1,  # w
            )
        # rotate_x(-ROTATION_SPEED)
    if Input.is_action_pressed("ui_down"):
        t = t * Quaternion(
                ROTATION_SPEED,  # x, # y, # z
                0,
                0,
                1,  # w
            )
    if Input.is_action_pressed("ui_right"):
        t = t * Quaternion(
                0,
                ROTATION_SPEED,  # x, # y, # z
                0,
                1,  # w
            )
    if Input.is_action_pressed("ui_left"):
        t = t * Quaternion(
                0,
                -ROTATION_SPEED,  # x, # y, # z
                0,
                1,  # w
            )
    transform.basis = Basis(t).orthonormalized()
    # rotation = rotation.linear_interpolate(new_rotation, delta * movement_time)
#check if we can hide bject when it reaches certain scale

