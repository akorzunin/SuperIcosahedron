extends Marker3D

signal spawn_figure(figure: Figure)
@onready var main: Main = $'..'
const ICOSAHEDRON = preload('res://icosahedron/Icosahedron.tscn')
class Figure:
    var type: String = "new"
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    pass


func _on_spawn_figure(figure: Figure) -> void:
    if figure.type == "new":
        var new_figure := ICOSAHEDRON.instantiate()
        main.add_child(new_figure)


func _on_signals_start_game() -> void:
    spawn_figure.emit(Figure.new())
    pass # Replace with function body.
