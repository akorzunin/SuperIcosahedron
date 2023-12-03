class_name MeshIcosahedron
extends MeshInstance3D

@export var SCALE_FACTOR := 1.009
@export var scaling_enabled = true
@onready var main: Main = get_node("/root/Main")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    #main.signals.game_state_changed.connect(_change_scaling)
    pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    if scaling_enabled:
        scale_object_local(Vector3(SCALE_FACTOR, SCALE_FACTOR, SCALE_FACTOR, ))

#func _change_scaling(gs: G.GameState):
    #if gs == G.GameState.GAME_ACTIVE:
        #scaling_enabled = true
    #else:
        #scaling_enabled = false
