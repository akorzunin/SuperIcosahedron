extends Area3D
class_name MenuCollider


@onready var menu_item: MenuItem = $'..'

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	area_entered.connect(_on_area_entered)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    pass

func _on_area_entered(node):
    pass

func menu_selected():
    return {
        pos = menu_item.pos,
        label = menu_item.label_text,
        action = menu_item.action,
        items = menu_item.items,
    }
