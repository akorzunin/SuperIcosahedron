extends Node3D
class_name MenuItem

@onready var label_3d: Label3D = $Label3D

var pos: int
var label_text: String
var action: String
var items: Dictionary


func init(props: Dictionary):
    pos = props.get("pos", 0)
    items = props.val
    label_text = items.get("name", "placeholder")
    action = items.get("action", "placeholder_action")

    return self
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    self.add_to_group("menu_item")
    label_3d.text = label_text
    var t = Quats.menu_quat_left()
    var y = Quats.menu_quat_down().inverse()
    match pos:
        1:
            pass
        2:
            transform.basis = Basis(t)
        3:
            transform.basis = Basis(t * t)
        4:
            transform.basis = Basis(t * t * t)
        5:
            transform.basis = Basis(t * t * t * t)
        6:
            transform.basis = Basis(y)
        7:
            transform.basis = Basis(Quats.easter_egg_quat)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    pass
