extends PanelContainer
class_name DebugStatsContainer

@onready var figures_count: Label = $VBoxContainer/FiguresCount
@onready var angle: Label = $VBoxContainer/Angle

var width_percent := 20

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    var screenSize = get_viewport_rect().size
    custom_minimum_size.x = int(screenSize.x * (width_percent / 100.))

static func toggle(val: bool, node: DebugStatsContainer):
    if val:
        node.show()
    else:
        node.hide()
