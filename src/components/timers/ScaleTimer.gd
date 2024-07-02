extends Timer
class_name ScaleTimer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    autostart =  true
    # 10 ms
    wait_time = 10. / 1000.
    pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    pass
