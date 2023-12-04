extends Marker3D

signal spawn_figure(figure: Figure)
@onready var main: Main = $"/root/Main"
@onready var signals: Signals = $"/root/Main/Signals"

const Icosahedron = preload('res://scenes/figures/icosahedron/Icosahedron.tscn')
class Figure:
    var type: String = "new"
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    signals.new_game_mode.connect(_on_signals_start_game)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    pass


func _on_spawn_figure(figure: Figure) -> void:
    if figure.type == "new":
        var new_figure := Icosahedron.instantiate()
        main.add_child(new_figure)


func _on_signals_start_game(game_mode: GameStateManager.GameMode) -> void:
    if game_mode == GameStateManager.GameMode.START:
        _on_spawn_figure(Figure.new())
