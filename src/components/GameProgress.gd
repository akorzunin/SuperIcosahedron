extends Node
class_name GameProgress

@onready var game_state_manager: GameStateManager = %GameStateManager
@onready var loop_timer: LoopTimer = %LoopTimer
@onready var debug_stats_container: DebugStatsContainer = %DebugStatsContainer
@onready var gui: LoopGui = $'../Gui'
@onready var pattern_gen: PatternGen = %PatternGen

var figures_passed := 0
var time_passed := 0.
var time_passed_formated: String:
    get:
        return loop_timer.get_elapsed_time()
var max_reached_level := 0

static func is_level_up(nodes: int, level: int) -> bool:
    match level:
        0: return nodes > 10
        #1: return nodes > 20
        _: return false

func add_one():
    figures_passed += 1
    if is_level_up(figures_passed, pattern_gen.level):
        G.level_changed.emit(pattern_gen.level + 1)

func reset():
    figures_passed = 0
    time_passed = 0

func _ready() -> void:
    game_state_manager.game_state_changed.connect(_on_game_state)

func start():
    gui.show_stats_panel(true)

func end():
    time_passed = loop_timer.get_raw_elapsed_time()
    gui.show_stats_panel(false)

func _on_game_state(old_state: GameStateManager.GameState, new_state: GameStateManager.GameState):
    var gs := GameStateManager.GameState
    if new_state == gs.GAME_END:
        end()
    elif new_state == gs.GAME_ACTIVE:
        start()

func _physics_process(delta: float) -> void:
    debug_stats_container.nodes_passed.label_text = str(figures_passed)
    debug_stats_container.time_passed.label_text = loop_timer.get_elapsed_time()
    debug_stats_container.current_level.label_text = str(pattern_gen.level)
    gui.game_state_label.set_text(str(figures_passed))

func get_score():
    return "score\nnodes: %s\ntime: %s" % [
        figures_passed,
        time_passed_formated
    ]
