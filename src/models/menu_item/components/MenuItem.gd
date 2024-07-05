extends Node3D
class_name MenuItem

@onready var label: Label = $Sprite3D/SubViewport/Label

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
	label.text = label_text
	var t = Quats.menu_quat_left()
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
			transform.basis = Basis(Quats.menu_quat_down().inverse())

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    pass
