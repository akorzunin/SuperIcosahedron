extends Node3D
class_name Icosahedron

@onready var cut_plane: CutPlane = $CutPlane
@onready var mesh_icosahedron: MeshIcosahedron = $MeshIcosahedron

@export var inital_transform := Quaternion(0, 0.707, 0, 0.707).normalized()
@export var DEBUG_VISUAL := false
@export var scaling_enabled := true
@export var show_face_numbers := false
@export var shader_type: int

var scale_timer: ScaleTimer

func with_type(type: int):
    shader_type = type
    return self

func with_face_numbers(_show: bool):
    show_face_numbers = _show
    return self

func with_scale_timer(_scale_timer: ScaleTimer):
    scale_timer = _scale_timer
    return self

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    transform.basis = Basis(inital_transform).orthonormalized()
    if not DEBUG_VISUAL:
        cut_plane.hide()
    if scale_timer:
        scale_timer.timeout.connect(_on_scale_tick)

func _on_scale_tick() -> void:
    if scaling_enabled:
        var sf: float = 1. + (G.settings.SCALE_FACTOR  / 1000. ) \
            * (0.5 +  (G.settings.GAME_SPEED / (10. + G.settings.GAME_SPEED)))
        scale_object_local(Vector3(sf, sf, sf))

func despawn():
    scaling_enabled = false
    var tw = create_tween()
    tw.tween_callback(func():).set_delay(.8)
    tw.finished.connect(func(): queue_free())
    tw.play()
