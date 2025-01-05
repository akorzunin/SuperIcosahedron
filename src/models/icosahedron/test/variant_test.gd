extends Node3D

#const IcosahedronScene = preload('res://src/models/icosahedron/Icosahedron.tscn')
const ICO_NODE = preload("res://src/components/ico_node/IcoNode.tscn")

var controlledNode: IcoMesh

@onready var pattern_gen: PatternGen = $PatternGen

@export var ROTATION_SPEED: float = 12

@export_category("variant settings")
@export var show_face_numbers: bool = true
#@export_range(0, 19) var variant_type: int = 0
@export_enum("zero:0", "mid_left:17", "mid:18", "mid_right:19") var variant_type: int = 19
@export_enum("queue:0", "random:1", "custom:2",) var spawn_type: int = 0
@export var use_default := false
@export var cutplane_1: ShaderMaterial
@export var outline_1: ShaderMaterial

@export var aboba: Dictionary[String, ShaderMaterial]


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    get_next()
    G.ico_node_spawn.connect(func(nt: int):
        remove_current()
        spawn_next(nt)
    )

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
        new_figure = ICO_NODE.instantiate()

    else:
        new_figure = ICO_NODE.instantiate()\
            .with_edges({17: {}, 19: {}})\
            .with_face_numbers(show_face_numbers)
    add_child(new_figure)
    controlledNode = new_figure.ico_mesh
    cutplane_1 = controlledNode.material_override.next_pass
    outline_1 = cutplane_1.next_pass
    var count = 0
    for k in controlledNode.applied_shaders_dict:
        match count:
            0: aboba[k] = controlledNode.material_override
            1: aboba[k] = controlledNode.material_override.next_pass
            2: aboba[k] = controlledNode.material_override.next_pass.next_pass
            3: aboba[k] = controlledNode.material_override.next_pass.next_pass.next_pass
            4: aboba[k] = controlledNode.material_override.next_pass.next_pass.next_pass.next_pass
        count += 1


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
