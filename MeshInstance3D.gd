extends MeshInstance3D

# var SCALE_FACTOR = 1
var SCALE_FACTOR := 1.001
var SCALING_ENABLED = false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    if SCALING_ENABLED:
        scale_object_local(Vector3(SCALE_FACTOR, SCALE_FACTOR, SCALE_FACTOR, ))
    if Input.is_action_just_pressed('ui_accept'):
        SCALING_ENABLED = ! SCALING_ENABLED
