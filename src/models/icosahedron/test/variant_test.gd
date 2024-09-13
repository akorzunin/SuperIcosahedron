extends Node3D

const IcosahedronScene = preload('res://src/models/icosahedron/Icosahedron.tscn')
var controlledNode

@onready var pattern_gen: PatternGen = $PatternGen

@export var ROTATION_SPEED: float = 12

@export_category("variant settings")
@export var show_face_numbers: bool = true
#@export_range(0, 19) var variant_type: int = 0
@export_enum("zero:0", "mid_left:17", "mid:18", "mid_right:19") var variant_type: int = 0
@export_enum("queue:0", "random:1", "custom:2",) var spawn_type: int = 0
@export var use_default := false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    get_next()

func get_next():
    remove_current()
    var next_type: int
    match spawn_type:
        0: next_type = pattern_gen.next_pattern()
        1: next_type = randi_range(0, 19)
        2: next_type = variant_type
    print_debug("Spawinig next figure with type: ", next_type)
    spawn_next(next_type)

func remove_current():
    for i in get_children():
        if i is Icosahedron:
            i.queue_free()

# TODO mb generalize and move to another module to reuse
func spawn_next(_type: int):
    var new_figure
    if use_default:
        new_figure = IcosahedronScene.instantiate()
    else:
        new_figure = IcosahedronScene.instantiate()\
            .with_type(_type)\
            .with_face_numbers(show_face_numbers)
    add_child(new_figure)
    controlledNode = new_figure.mesh_icosahedron

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    if not controlledNode:
        return
    if Input.is_action_just_pressed('ui_accept'):
        controlledNode.transform.basis = Basis(Quaternion()).orthonormalized()
    if Input.is_action_just_pressed('ui_focus_next'):
        get_next()
    var rs := ROTATION_SPEED / 10. * delta
    FreeSpin.handle_free_spin_input(controlledNode, rs)
