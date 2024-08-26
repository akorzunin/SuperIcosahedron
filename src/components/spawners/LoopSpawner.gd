extends Node3D
class_name LoopSpawner

@onready var game_state_manager: GameStateManager = %GameStateManager
@onready var loop_timer: LoopTimer = %LoopTimer
@onready var scale_timer: ScaleTimer = %ScaleTimer
@onready var game_progress: GameProgress = %GameProgress
@onready var pattern_gen: PatternGen = %PatternGen

@export var figureRoot: FigureRoot

const IcosahedronScene = preload('res://src/models/icosahedron/Icosahedron.tscn')
const MenuItemScene = preload('res://src/models/menu_item/MenuItem.tscn')

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
    elif new_state == gs.GAME_END:
        figureRoot.clean_all()
        spawn_game_over_scene()
        pass

func add_menu_items(node: Marker3D, layer: Dictionary):
    var items = layer.get("items")
    if not items:
        return
    #for loop over first level items
    for key in items.keys():
        var new_item = MenuItemScene.instantiate() \
            .init({
                pos = key,
                val = items[key]
            })
        node.add_child(new_item)

func get_game_over_state() -> Dictionary:
    var m := MenuStruct.game_over
    m.items[1].name = game_progress.get_score()
    return m

func spawn_game_over_scene():
    var anc := figureRoot.get_node("Anchor") as Anchor
    for ch in anc.get_children():
        ch.queue_free()
    var new_figure = IcosahedronScene.instantiate() \
                .with_type(-1)
    figureRoot.add_figure(new_figure)
    add_menu_items(anc, get_game_over_state())
    var tw = anc.create_tween()
    tw.tween_property(anc, "scale", Vector3(7.25, 7.25, 7.25), 0.2)
    tw.play()
    pass

class Figure:
    var type: FigureType
    func _init(_type: FigureType):
        self.type = _type

enum FigureType {ICOSAHEDRON, OCTAHEDRON}
enum SpawnMode {CENTER, SIDE, RANDOM, QUEUE}

func get_spawn_type():
    var s = PatternGen.SpawnMode
    match G.settings.SPAWN_MODE:
        s.TUTORIAL: # 0
            return 3
        s.DEBUG: # 1
            return 1
        s.QUEUE: # 2
            return pattern_gen.next_pattern()

func spawn_figure(figure: Figure) -> void:
    var new_figure
    match figure.type:
        FigureType.ICOSAHEDRON:
            new_figure = IcosahedronScene.instantiate() \
                .with_type(get_spawn_type())\
                .with_scale_timer(scale_timer)
        FigureType.OCTAHEDRON:
            pass

    figureRoot.add_figure(new_figure)


func _on_loop_timer():
    spawn_figure(Figure.new(FigureType.ICOSAHEDRON))
