@tool
extends SubViewport

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
    size = $Label.get_rect().size + Vector2(10., 10.)
    pass
