extends Area3D
class_name MenuCollider

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    area_entered.connect(_on_area_entered)
    pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    pass

func _on_area_entered(node):
    pass
