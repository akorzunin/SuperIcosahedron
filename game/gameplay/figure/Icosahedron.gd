extends Node3D
class_name Icosahedron

@onready var cut_plane: CutPlane = get_node_or_null("CutPlane")
@onready var mesh_icosahedron: MeshIcosahedron = $MeshIcosahedron

@export var inital_transform := Quaternion(0, 0.707, 0, 0.707).normalized()
@export var DEBUG_VISUAL := false
@export var scaling_enabled := true
@export var show_face_numbers := false
@export var shader_type: int
@export var spwan_time: float

var scale_timer: ScaleTimer
var data: FigureData
var resolved := false
var despawning := false

func with_type(type: int):
    shader_type = type
    return self

func with_face_numbers(_show: bool):
    show_face_numbers = _show
    return self

func with_scale_timer(_scale_timer: ScaleTimer):
    scale_timer = _scale_timer
    return self

func with_data(_data: FigureData):
    data = _data
    return self

func init(_data: FigureData):
    data = _data
    return self

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    transform.basis = Basis(inital_transform).orthonormalized()
    if not DEBUG_VISUAL and cut_plane:
        cut_plane.hide()
    if scale_timer:
        scale_timer.timeout.connect(_on_scale_tick)
    spwan_time = Time.get_unix_time_from_system()
    if not data:
        data = StageGenerator.create_figure(shader_type if shader_type >= 0 else 0)

func _on_scale_tick() -> void:
    if scaling_enabled:
        var sf: float = 1. + (G.settings.SCALE_FACTOR  / 1000. ) \
            * (0.5 +  (G.settings.GAME_SPEED / (10. + G.settings.GAME_SPEED)))
        scale_object_local(Vector3(sf, sf, sf))

func _build_side_colliders() -> void:
    var root := Node3D.new()
    root.name = "SideColliders"
    mesh_icosahedron.add_child(root)
    for side in data.sides:
        var area := SideCollider.new().init(self, side)
        var shape := CollisionShape3D.new()
        var convex := ConvexPolygonShape3D.new()
        convex.points = mesh_icosahedron.get_side_points(side.id)
        shape.shape = convex
        area.add_child(shape)
        root.add_child(area)

func despawn():
    if despawning or is_queued_for_deletion():
        return
    despawning = true
    scaling_enabled = false
    _disable_collisions(self)
    queue_free()

func _disable_collisions(node: Node) -> void:
    if node is Area3D:
        node.set_deferred("monitoring", false)
        node.set_deferred("monitorable", false)
    elif node is CollisionShape3D:
        node.set_deferred("disabled", true)
    for child in node.get_children():
        _disable_collisions(child)
