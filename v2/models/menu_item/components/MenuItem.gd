extends Node3D
class_name MenuItem

@onready var label: Label = $Sprite3D/SubViewport/Label

var pos
var label_text


func init(props: Dictionary):
    pos = props.get("pos", 0)
    label_text = props.get("label", "placeholder")

    return self
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    self.add_to_group("menu_item")
    label.text = label_text
    var t = Quaternion(0, 0.504, 0.301, 0.808, ).normalized()
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
            transform.basis = Basis(Quaternion(0.342, 0, 0, 0.939, ).normalized())
    pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    pass
