extends Label

@onready var settings = %Settings
@export var enabled := true
var counter := 0.

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    enabled = settings.gs.FPS_COUNTER_ENABLED

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    if not enabled:
        return
    counter += delta
    # Hide FPS label until it's initially updated by the engine (this can take up to 1 second).
    visible = counter >= 1.0
    text = "%d FPS (%.2f mspf)" % [Engine.get_frames_per_second(), 1000.0 / Engine.get_frames_per_second()]
    # Color FPS counter depending on framerate.
    # The Gradient resource is stored as metadata within the FPSLabel node (accessible in the inspector).
    modulate = get_meta("gradient").sample(remap(Engine.get_frames_per_second(), 0, 180, 0.0, 1.0))
