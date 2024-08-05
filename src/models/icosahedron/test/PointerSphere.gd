@tool
extends MeshInstance3D
class_name PointerSphere

signal pointer_changed
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    set_notify_transform(true)
    pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:

    pass

func _notification(what: int) -> void:
    match what:
        NOTIFICATION_TRANSFORM_CHANGED:
            pointer_changed.emit()
