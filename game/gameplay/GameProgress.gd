extends Node
class_name GameProgress

signal status_changed(details: String, state: String)
signal level_changed(level: int)
signal sound_requested(event: StringName)

@onready var game_state_manager: GameStateManager = %GameStateManager
@onready var loop_timer: LoopTimer = %LoopTimer
@onready var debug_stats_container: DebugStatsContainer = %DebugStatsContainer
@onready var gui: LoopGui = $'../Gui'
@onready var pattern_gen: PatternGen = %PatternGen
@onready var loop_controls: LoopControls = %LoopControls

var run_state := RunState.new()
var figures_passed: int:
    get: return run_state.figures_passed
var score: int:
    get: return run_state.score
var time_passed := 0.
var time_passed_formated: String:
    get:
        return loop_timer.get_elapsed_time()
var max_reached_level := 0
var collected_sides: Array[SideData]:
    get: return run_state.collected_sides


func _update_level():
    if LevelPatterns.is_level_up(figures_passed, pattern_gen.level):
        G.level_changed.emit(pattern_gen.level + 1)

func reset():
    run_state.reset()
    time_passed = 0

func _ready() -> void:
    game_state_manager.game_state_changed.connect(_on_game_state)
    G.level_changed.connect(_on_level_changed)

func start():
    gui.show_stats_panel(true)

func end():
    time_passed = loop_timer.get_raw_elapsed_time()
    gui.show_stats_panel(false)

func _on_game_state(old_state: GameStateManager.GameState, new_state: GameStateManager.GameState):
    var gs := GameStateManager.GameState
    if new_state == gs.GAME_END:
        status_changed.emit("Game over", "Enjoying results")
        end()
    elif new_state == gs.GAME_ACTIVE:
        level_changed.emit(pattern_gen.level)
        start()

func _on_level_changed(new_level: int):
    level_changed.emit(new_level)

func _physics_process(delta: float) -> void:
    debug_stats_container.nodes_passed.label_text = str(figures_passed)
    debug_stats_container.time_passed.label_text = loop_timer.get_elapsed_time()
    debug_stats_container.current_level.label_text = str(pattern_gen.level)
    gui.game_state_label.set_text(str(figures_passed))

func get_score():
    return "score\nnodes: %s\nscore: %s\ntime: %s" % [
        figures_passed,
        score,
        time_passed_formated
    ]

func register_figure(figure: FigureData) -> void:
    run_state.register_figure(figure)

func resolve_side(figure: Icosahedron, side: SideData) -> void:
    if game_state_manager.game_state != GameStateManager.GameState.GAME_ACTIVE:
        return
    if not figure or figure.resolved or not side or side.collected:
        return
    var outcome := run_state.resolve_side(figure.get_instance_id(), side)
    if outcome == RunState.Outcome.IGNORED:
        return
    figure.resolved = true
    figure.mesh_icosahedron.angle_good = true
    if outcome == RunState.Outcome.GAME_OVER:
        _game_over()
        return
    _update_level()
    log_tts(figure.spwan_time, side.id)
    figure.despawn()
    loop_controls.update_controlled_node()

func _game_over() -> void:
    var gs := GameStateManager.GameState
    if game_state_manager.game_state == gs.GAME_END:
        return
    game_state_manager.change_state(gs.GAME_END)
    sound_requested.emit(&"on_section_select")

func log_tts(spawn_time: float, type: int):
    var time_ms := int((Time.get_unix_time_from_system() - spawn_time) * 1000.)
    debug_stats_container.time_to_solve.label_text = "ms: %s, type: %s" % [time_ms, type]
    print_debug("time: ", time_ms, " type: ", type)
