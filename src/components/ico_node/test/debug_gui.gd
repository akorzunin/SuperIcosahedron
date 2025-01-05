extends Control
@onready var spawn_button = $VBoxContainer/SpawnButton
@onready var node_type: LineEdit = $VBoxContainer/NodeType


func _ready():
    spawn_button.pressed.connect(func ():
        var nt := int(node_type.text)
        print_debug("Spawning Node: ", nt)
        G.ico_node_spawn.emit(nt)
    )
    node_type.text_submitted.connect(func (s: String):
        var nt := int(node_type.text)
        print_debug("Spawning Node: ", nt)
        G.ico_node_spawn.emit(nt)
    )
