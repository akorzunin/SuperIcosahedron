extends Marker3D
class_name LoopSpawner

@onready var game_state_manager: GameStateManager = %GameStateManager
@onready var loop_timer: LoopTimer = %LoopTimer
@onready var scale_timer: ScaleTimer = %ScaleTimer

@export var figureRoot: FigureRoot
const IcosahedronScene = preload('res://src/models/icosahedron/Icosahedron.tscn')
# Called when the node enters the scene tree for the first time.
func _ready():
    game_state_manager.game_state_changed.connect(_on_game_state_changed)
    loop_timer.timeout.connect(_on_loop_timer)

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
enum SpawnMode {CENTER, SIDE, RANDOM, QUEUE}

func get_spawn_type():
    var s = SpawnMode
    match G.settings.SPAWN_MODE:
        s.CENTER: # 0
            return 3
        s.SIDE: # 1
            return 1
        s.RANDOM: # 2
            return randi_range(1, 8)
        s.QUEUE: # 3
            pass

func spawn_figure(figure: Figure) -> void:
    var new_figure
    match figure.type:
        FigureType.ICOSAHEDRON:
            new_figure = IcosahedronScene.instantiate() \
                .init(
                    {type = get_spawn_type()},
                    {
                        quat = G.D.init_pos,
                        scale_timer = scale_timer,
                    },
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
