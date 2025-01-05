extends Node
class_name IcoNode
@export var inital_transform := Quaternion(0, 0.707, 0, 0.707).normalized()
#@export var DEBUG_VISUAL := false
#@export var scaling_enabled := true
@export var show_face_numbers := false
@export var edges: Dictionary

@onready var ico_mesh := $IcoMesh


func with_face_numbers(_show: bool):
    show_face_numbers = _show
    return self

func with_edges(_edges: Dictionary):
    edges = _edges
    return self

func with_scale_timer(_scale_timer: ScaleTimer):
    #scale_timer = _scale_timer
    return self

func despawn():
    queue_free()
