class_name MeshIcosahedron
extends MeshInstance3D

@export var SCALE_FACTOR := 1.001
@export var scaling_enabled = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    var main = get_node("/root/Main")
    main.game_state_changed.connect(_change_scaling)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    if scaling_enabled:
        scale_object_local(Vector3(SCALE_FACTOR, SCALE_FACTOR, SCALE_FACTOR, ))

func _change_scaling(gs: Global.GameState):
    if gs == Global.GameState.GAME_ACTIVE:
        scaling_enabled = true
    else:
        scaling_enabled = false
