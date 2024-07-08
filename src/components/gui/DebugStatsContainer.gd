extends PanelContainer
class_name DebugStatsContainer

@onready var figures_count: Label = $VBoxContainer/FiguresCount
@onready var angle: Label = $VBoxContainer/Angle


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
#R:TODO set as width %
    custom_minimum_size.x = 200
    pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    pass

static func toggle(val: bool, node: DebugStatsContainer):
    if val:
        node.show()
    else:
        node.hide()
