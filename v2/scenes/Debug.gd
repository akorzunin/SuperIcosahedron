extends Node

@export var spawner: LoopSpawner
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    spawner._on_spawn_figure(spawner.Figure.new())
    pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    pass
