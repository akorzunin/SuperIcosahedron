extends Node
class_name FigureController

@export var target: MeshIcosahedron
@export_enum("FREE_SPIN", "FACE_LOCK") var control_type := "FREE_SPIN"
@export var rotation_speed := 12.0
@export var inverted := false
@export var enabled := true

func rotate_continuous(direction: Vector2, delta: float) -> void:
    if not enabled or not is_instance_valid(target):
        return
    if inverted:
        direction.x = -direction.x
    FreeSpin.rotate(target, direction, rotation_speed / 10.0 * delta)

func step_face(direction: Vector2) -> void:
    if not enabled or not is_instance_valid(target):
        return
    if inverted:
        direction.x = -direction.x
    FaceLock.step(target, direction)
