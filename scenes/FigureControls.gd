extends Node
class_name FigureControls

@export var figureRoot: FigureRoot
@export var allow_control := true
@export var ROTATION_SPEED := 0.009
# Called when the node enters the scene tree for the first time.
func _ready() -> void:

    pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    var rotation
    if 1:
        if Input.is_action_pressed("ui_up"):
            rotation = Quaternion(-ROTATION_SPEED, 0, 0, 1, )
        if Input.is_action_pressed("ui_down"):
            rotation = Quaternion(ROTATION_SPEED, 0, 0, 1, )
        if Input.is_action_pressed("ui_right"):
            rotation = Quaternion(0, ROTATION_SPEED, 0, 1, )
        if Input.is_action_pressed("ui_left"):
            rotation = Quaternion(0, -ROTATION_SPEED, 0, 1, )
        # rotation = rotation.linear_interpolate(new_rotation, delta * movement_time)
    if rotation:
        var a = figureRoot.get_children()
        print_debug(a)
    pass
