extends Label
class_name DebugLabel

var key := name
@export var label_text: String = "":
    set(val):
        label_text = val
        if not val:
            text = key
            return
        text = key + ": " + val
enum LabelType {
    NONE,
    VERSION,
    OS_NAME,
    FIGURES_COUNT,
    ANGLE,
    WINDOW_MODE,
}
@export var type := LabelType.NONE
@export var regular_update := false
@onready var timer: Timer = %DebugStatsTimer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    if regular_update:
        timer.timeout.connect(_on_update)
    key = name
    _on_update()

func _on_update():
    match type:
        LabelType.VERSION:
            label_text = get_version()
        LabelType.OS_NAME:
            label_text = OS.get_name() + " " + OS.get_model_name()
        LabelType.FIGURES_COUNT:
            label_text = str(0)
        LabelType.ANGLE:
            label_text = str(0.0)
        LabelType.WINDOW_MODE:
            label_text = str(DisplayServer.window_get_mode())
        _:
            label_text = label_text

func get_version():
    var version_file = load("res://src/version.gd") # can be null
    if not version_file:
        version_file = {}
    var v = version_file.get("VERSION")
    var c = version_file.get("COMMIT")
    if not v:
        v = ''
    if not c:
        c = ''
    return "%s commit: %s" % [v, c]
