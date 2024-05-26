extends Node3D


@export var allow_control := true
@export var ROTATION_SPEED := 0.009

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    pass # Replace with function body.

@onready var controlledNode: Node3D = $"/root/Main/Icosahedron"
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    pass

func _physics_process(delta: float) -> void:
    if not controlledNode:
        return
    if allow_control:
        var rotation
        if Input.is_action_pressed("ui_up"):
            rotation = Quaternion(-ROTATION_SPEED, 0, 0, 1, )
        if Input.is_action_pressed("ui_down"):
            rotation = Quaternion(ROTATION_SPEED, 0, 0, 1, )
        if Input.is_action_pressed("ui_right"):
            rotation = Quaternion(0, ROTATION_SPEED, 0, 1, )
        if Input.is_action_pressed("ui_left"):
            rotation = Quaternion(0, -ROTATION_SPEED, 0, 1, )
    controlledNode.hide()
