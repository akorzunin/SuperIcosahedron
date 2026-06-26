extends Node
class_name GameProgress

@onready var discord_status: DummyDiscordStatus = $"/root/MainScene/DiscordStatus"

@onready var game_state_manager: GameStateManager = %GameStateManager
@onready var loop_timer: LoopTimer = %LoopTimer
@onready var debug_stats_container: DebugStatsContainer = %DebugStatsContainer
@onready var gui: LoopGui = $'../Gui'
@onready var pattern_gen: PatternGen = %PatternGen
@onready var loop_controls: LoopControls = %LoopControls

var figures_passed := 0
var score := 0
var time_passed := 0.
var time_passed_formated: String:
    get:
        return loop_timer.get_elapsed_time()
var max_reached_level := 0
var modifier_system := ModifierSystem.new()
var collected_sides: Array[SideData] = []


func add_one():
    figures_passed += 1
    if LevelPatterns.is_level_up(figures_passed, pattern_gen.level):
        G.level_changed.emit(pattern_gen.level + 1)

func reset():
    figures_passed = 0
    score = 0
    time_passed = 0
    collected_sides.clear()
    modifier_system.reset()

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
        discord_status.set_state("Game over", "Enjoying results")
        end()
    elif new_state == gs.GAME_ACTIVE:
        discord_status.set_loop_state(pattern_gen.level)
        start()

func _on_level_changed(new_level: int):
    discord_status.set_loop_state(new_level)

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
    for side in figure.sides:
        if side.modifier:
            side.modifier_entity = modifier_system.register_modifier(side.modifier)

func resolve_side(figure: Icosahedron, side: SideData) -> void:
    if game_state_manager.game_state != GameStateManager.GameState.GAME_ACTIVE:
        return
    if not figure or figure.resolved or not side or side.collected:
        return
    figure.resolved = true
    figure.mesh_icosahedron.angle_good = true
    if side.kind == SideData.Kind.SOLID:
        _game_over()
        return
    side.collected = true
    collected_sides.append(side)
    modifier_system.apply_to(self, side.modifier_entity)
    add_one()
    log_tts(figure.spwan_time, side.id)
    figure.despawn()
    loop_controls.update_controlled_node()

func _game_over() -> void:
    var gs := GameStateManager.GameState
    if game_state_manager.game_state == gs.GAME_END:
        return
    game_state_manager.change_state(gs.GAME_END)
    var sfx_player: SfxPlayer = get_node_or_null("/root/MainScene/SfxPlayer")
    if sfx_player:
        sfx_player.on_section_select.emit()

func log_tts(spawn_time: float, type: int):
    var time_ms := int((Time.get_unix_time_from_system() - spawn_time) * 1000.)
    debug_stats_container.time_to_solve.label_text = "ms: %s, type: %s" % [time_ms, type]
    print_debug("time: ", time_ms, " type: ", type)
