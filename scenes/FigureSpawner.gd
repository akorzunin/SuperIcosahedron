extends Marker3D
class_name FigureSpawner

signal spawn_figure(figure: Figure)
@export var figureRoot: FigureRoot
@onready var signals: Signals = $"/root/Main/Signals"
#@onready var icosahedron_node: IcosahedronNode = $"/root/Main/Icosahedron"

const IcosahedronScene = preload('res://scenes/figures/icosahedron/Icosahedron.tscn')
class Figure:
    var type: String
    func _init(_type: String = 'new'):
        self.type = _type

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    signals.new_game_mode.connect(_on_signals_start_game)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    var aaa = get_tree().get_nodes_in_group("figures")
    if not aaa:
        return
    var a = Quaternion(transform.basis)
    var t = Quaternion(transform.basis)
    #var t = a * Quaternion(_main.transform.basis)
    if Input.is_action_pressed("ui_up"):
        t = t * Quaternion(-G.ROTATION_SPEED, 0, 0, 1, )
    if Input.is_action_pressed("ui_down"):
        t = t * Quaternion(G.ROTATION_SPEED, 0, 0, 1, )
    if Input.is_action_pressed("ui_right"):
        t = t * Quaternion(0, G.ROTATION_SPEED, 0, 1, )
    if Input.is_action_pressed("ui_left"):
        t = t * Quaternion(0, -G.ROTATION_SPEED, 0, 1, )
    var tb = Basis(t).orthonormalized()
    aaa[0].transform.basis = tb
    #if aaa and len(aaa) >= 5:

    pass


func _on_spawn_figure(figure: Figure) -> void:
    if figure.type == "new":

        #Node3D()
        #var new_figure = IcosahedronNode.new()
        var new_figure := IcosahedronScene.instantiate()
        var id = str(randf())
        new_figure.name = "MainIcosahedron" + id
        new_figure.set_meta("id", id)
        add_child(new_figure)


func _on_signals_start_game(game_mode: GameStateManager.GameMode) -> void:
    if game_mode == GameStateManager.GameMode.START:
        _on_spawn_figure(Figure.new('new'))


func _on_timer_timeout() -> void:
    _on_spawn_figure(Figure.new('new'))
