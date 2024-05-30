extends Marker3D
class_name FigureSpawner

signal spawn_figure(figure: Figure)
@export var figureRoot: FigureRoot
@onready var signals: Signals = $"/root/Main/Signals"
#@onready var icosahedron_node: IcosahedronNode = $"/root/Main/Icosahedron"

const IcosahedronScene = preload('res://v2/models/icosahedron/Icosahedron.tscn')
class Figure:
    var type: String
    func _init(_type: String = 'new'):
        self.type = _type

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    #signals.new_game_mode.connect(_on_signals_start_game)
    pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    pass


func _on_spawn_figure(figure: Figure) -> void:
    if figure.type == "new":

        #Node3D()
        #var new_figure = IcosahedronNode.new()
        var new_figure := IcosahedronScene.instantiate()
        print_debug(typeof(new_figure))
        figureRoot.add_child(new_figure)


#func _on_signals_start_game(game_mode: GameStateManager.GameMode) -> void:
    #if game_mode == GameStateManager.GameMode.START:
        #_on_spawn_figure(Figure.new('new'))


func _on_timer_timeout() -> void:
    _on_spawn_figure(Figure.new('new'))
