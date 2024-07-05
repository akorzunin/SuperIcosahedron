extends Area3D
class_name MenuSelector

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	area_entered.connect(_on_area_entered)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    pass

func _on_area_entered(node):
# TODO add on select effect (mb shader or animation trigger)
    pass

func get_selected_item():
    var arr = get_overlapping_areas()
    if not len(arr):
        return
    for i in arr:
        if i.has_method("menu_selected"):
            return i.menu_selected()
    pass
