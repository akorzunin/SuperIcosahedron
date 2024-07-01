@tool
extends SubViewport

# Called when the node enters the scene tree for the first time.
func _ready():
    #canvas_item_default_texture_filter = Viewport.DEFAULT_CANVAS_ITEM_TEXTURE_FILTER_NEAREST
    pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
    size = $Label.get_rect().size + Vector2(10., 10.)
    pass
