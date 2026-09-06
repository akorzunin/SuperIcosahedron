extends Node
class_name PlayerInput

@export var controller: FigureController

func _process(delta: float) -> void:
    if not controller or not controller.enabled:
        return
    # Lab widgets and menu fields must not also rotate the figure.
    if get_viewport().gui_get_focus_owner() != null:
        return
    if controller.control_type == "FACE_LOCK":
        var direction := Vector2.ZERO
        if Input.is_action_just_pressed("ui_up"):
            direction = Vector2.UP
        elif Input.is_action_just_pressed("ui_down"):
            direction = Vector2.DOWN
        elif Input.is_action_just_pressed("ui_left"):
            direction = Vector2.LEFT
        elif Input.is_action_just_pressed("ui_right"):
            direction = Vector2.RIGHT
        controller.step_face(direction)
    else:
        controller.rotate_continuous(Vector2(
            Input.get_axis("ui_left", "ui_right"),
            Input.get_axis("ui_up", "ui_down")
        ), delta)
