extends Marker3D
class_name LoopSpawner

@onready var settings: Settings = %Settings
@onready var game_state_manager: GameStateManager = %GameStateManager
@onready var loop_timer: LoopTimer = %LoopTimer

@export var figureRoot: FigureRoot
const IcosahedronScene = preload('res://v2/models/icosahedron/Icosahedron.tscn')
# Called when the node enters the scene tree for the first time.
func _ready():
    game_state_manager.game_state_changed.connect(_on_game_state_changed)
    loop_timer.timeout.connect(_on_loop_timer)
    pass  # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
    pass

func _on_game_state_changed(old_state: GameStateManager.GameState, new_state: GameStateManager.GameState) -> void:
    var gs = GameStateManager.GameState
    if old_state == gs.GAME_MENU and new_state in [gs.GAME_ACTIVE, gs.GAME_PAUSED]:
        spawn_figure(Figure.new(FigureType.ICOSAHEDRON))

class Figure:
    var type: FigureType
    func _init(_type: FigureType):
        self.type = _type

enum FigureType {ICOSAHEDRON, OCTAHEDRON}



func spawn_figure(figure: Figure) -> void:
    var new_figure
    match figure.type:
        FigureType.ICOSAHEDRON:
            new_figure = IcosahedronScene.instantiate() \
                .init(
                    settings,
                    #{ type = 0 },
                    {type = randi_range(0, 5)},
                    {quat = Quaternion(0, 0.707, 0, 0.707)}
                )
        FigureType.OCTAHEDRON:
            #new_figure = OctahedronScene.instantiate() \
                #.init(
                    #settings,
                #)
            pass

    figureRoot.add_figure(new_figure)

func _on_loop_timer():
    spawn_figure(Figure.new(FigureType.ICOSAHEDRON))
