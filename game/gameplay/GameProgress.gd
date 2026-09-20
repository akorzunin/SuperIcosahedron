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
var modifier_hud: Label
var pickup_message: Label
var score_background: Panel
var score_label: Label
var pending_label: Label
var goal_card: PanelContainer
var bank_tween: Tween
var displayed_score := 0
var pickup_message_time := 0.0
var figures_passed: int:
    get:
        return run_state.figures_passed
var score: int:
    get:
        return run_state.score
var time_passed := 0.
var time_passed_formated: String:
    get:
        return loop_timer.get_elapsed_time()
var max_reached_level := 0


func _update_level():
    if (G.settings.SPAWN_MODE == PatternGen.SpawnMode.TUTORIAL and run_state.level_complete(true)):
        G.unlock_difficulty(1)
        (get_parent() as LoopScene).enter_next_level.call_deferred()
    elif G.settings.SPAWN_MODE == PatternGen.SpawnMode.QUEUE and run_state.level_complete(false):
        G.unlock_difficulty(run_state.difficulty + 2)
        (get_parent() as LoopScene).enter_next_level.call_deferred()


func reset():
    run_state.reset()
    pickup_message_time = 0.0
    if is_instance_valid(pickup_message):
        pickup_message.hide()
        pickup_message.text = ""
    time_passed = 0
    displayed_score = 0
    if bank_tween:
        bank_tween.kill()
    if is_instance_valid(pending_label):
        pending_label.position.y = 88
        pending_label.modulate.a = 1.0


func _ready() -> void:
    var layer := CanvasLayer.new()
    add_child(layer)
    score_background = Panel.new()
    layer.add_child(score_background)
    score_background.set_anchors_and_offsets_preset(Control.PRESET_TOP_RIGHT)
    score_background.offset_left = -384
    score_background.offset_right = -12
    score_background.offset_top = 12
    score_background.offset_bottom = 136
    score_background.mouse_filter = Control.MOUSE_FILTER_IGNORE
    var score_style := StyleBoxFlat.new()
    score_style.bg_color = Color(0.035, 0.055, 0.09, 0.94)
    score_style.set_corner_radius_all(16)
    score_background.add_theme_stylebox_override("panel", score_style)
    score_label = Label.new()
    layer.add_child(score_label)
    score_label.set_anchors_and_offsets_preset(Control.PRESET_TOP_RIGHT)
    score_label.offset_left = -360
    score_label.offset_right = -24
    score_label.offset_top = 20
    score_label.add_theme_font_size_override("font_size", 48)
    score_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
    score_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
    pending_label = Label.new()
    layer.add_child(pending_label)
    pending_label.set_anchors_and_offsets_preset(Control.PRESET_TOP_RIGHT)
    pending_label.offset_left = -360
    pending_label.offset_right = -24
    pending_label.offset_top = 88
    pending_label.add_theme_font_size_override("font_size", 24)
    pending_label.add_theme_color_override("font_color", Color("7de6cf"))
    pending_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
    pending_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
    goal_card = PanelContainer.new()
    layer.add_child(goal_card)
    goal_card.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_RIGHT)
    goal_card.grow_vertical = Control.GROW_DIRECTION_BEGIN
    goal_card.offset_left = -440
    goal_card.offset_right = -24
    goal_card.offset_top = -240
    goal_card.offset_bottom = -24
    goal_card.mouse_filter = Control.MOUSE_FILTER_IGNORE
    goal_card.add_theme_stylebox_override("panel", preload("res://game/ui/goal_card_style.tres"))
    modifier_hud = Label.new()
    modifier_hud.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    modifier_hud.mouse_filter = Control.MOUSE_FILTER_IGNORE
    modifier_hud.add_theme_color_override("font_color", Color.WHITE)
    modifier_hud.add_theme_color_override("font_shadow_color", Color.BLACK)
    modifier_hud.add_theme_constant_override("shadow_offset_x", 2)
    modifier_hud.add_theme_constant_override("shadow_offset_y", 2)
    modifier_hud.add_theme_font_size_override("font_size", 20)
    goal_card.add_child(modifier_hud)
    pickup_message = modifier_hud.duplicate() as Label
    layer.add_child(pickup_message)
    pickup_message.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
    pickup_message.offset_left = 24
    pickup_message.offset_right = -24
    pickup_message.offset_top = -320
    pickup_message.offset_bottom = -256
    pickup_message.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    pickup_message.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    pickup_message.hide()
    run_state.modifier_system.pickup_collected.connect(_on_pickup_collected)
    game_state_manager.game_state_changed.connect(_on_game_state)
    G.level_changed.connect(_on_level_changed)


func _on_pickup_collected(message: String, color: Color) -> void:
    pickup_message.text = message
    pickup_message.add_theme_color_override("font_color", color)
    pickup_message_time = 2.0
    pickup_message.visible = modifier_hud.visible


func start():
    gui.show_stats_panel(true)


func end():
    time_passed = loop_timer.get_raw_elapsed_time()
    gui.show_stats_panel(false)
    pickup_message_time = 0.0
    pickup_message.hide()


func _on_game_state(old_state: GameStateManager.GameState, new_state: GameStateManager.GameState):
    var gs := GameStateManager.GameState
    if new_state == gs.GAME_END:
        status_changed.emit("Game over", "Enjoying results")
        end()
    elif new_state == gs.GAME_ACTIVE:
        level_changed.emit(
            run_state.difficulty + 1 if G.settings.SPAWN_MODE == PatternGen.SpawnMode.QUEUE else pattern_gen.level
        )
        start()


func _on_level_changed(new_level: int):
    level_changed.emit(new_level)


func _physics_process(delta: float) -> void:
    debug_stats_container.nodes_passed.label_text = str(figures_passed)
    debug_stats_container.time_passed.label_text = loop_timer.get_elapsed_time()
    debug_stats_container.current_level.label_text = (
        str(run_state.difficulty + 1)
        if G \
                .settings \
                .SPAWN_MODE
        == PatternGen.SpawnMode.QUEUE
        else str(pattern_gen.level)
    )
    gui.game_state_label.set_text(str(figures_passed))
    var tutorial: bool = G.settings.SPAWN_MODE == PatternGen.SpawnMode.TUTORIAL
    modifier_hud.visible = (tutorial or G.settings.SPAWN_MODE == PatternGen.SpawnMode.QUEUE) and \
            game_state_manager.game_state in [
                GameStateManager.GameState.GAME_ACTIVE,
                GameStateManager.GameState.GAME_PAUSED,
            ]
    goal_card.visible = modifier_hud.visible
    score_background.visible = modifier_hud.visible
    score_label.visible = modifier_hud.visible
    pending_label.visible = modifier_hud.visible
    _update_score_hud()
    pickup_message_time = maxf(0.0, pickup_message_time - delta)
    pickup_message.visible = modifier_hud.visible and pickup_message_time > 0.0
    var objective := "Completed chains: %d/%d · Tier → Points until banked · Then level 2" % [
        run_state.charges_completed,
        RunState.required_charges(),
    ]
    if run_state.difficulty == 1:
        objective = "Completed crafts: %d/%d · Forge → matching ingredients · Then level 3" % [
            run_state.crafts_completed,
            RunState.required_crafts(),
        ]
    elif run_state.difficulty > 1:
        objective = "Mastered charging and crafting · Keep building your score"
    modifier_hud.text = "GOAL  ·  LEVEL %d\n\n%s\n\n%s" % [
        run_state.difficulty + 1,
        objective,
        run_state.modifier_system.summary(),
    ]
    if tutorial:
        modifier_hud.text = "Controls: align an opening and pass safely: %d/%d" % [
            run_state.controls_completed,
            RunState.required_controls(),
        ]


func _update_score_hud() -> void:
    if score != displayed_score:
        var banked := score - displayed_score
        displayed_score = score
        if bank_tween:
            bank_tween.kill()
        pending_label.position.y = 88
        pending_label.modulate.a = 1.0
        pending_label.text = "%+d" % banked
        bank_tween = create_tween().set_parallel(true)
        bank_tween \
                .tween_property(pending_label, "position:y", 32.0, 0.45) \
                .set_trans(Tween.TRANS_CUBIC) \
                .set_ease(Tween.EASE_IN)
        bank_tween.tween_property(pending_label, "modulate:a", 0.0, 0.45)
        bank_tween.chain().tween_callback(
            func():
                score_label.text = "%d" % displayed_score,
        )
    if not bank_tween or not bank_tween.is_running():
        score_label.text = "%d" % score
        pending_label.position.y = 88
        pending_label.modulate.a = 1.0
        pending_label.text = (
            "%+d pending" % run_state.modifier_system.pending_points()
            if run_state \
                    .modifier_system \
                    .pending
            else ""
        )


func get_score():
    return "score\nnodes: %s\nscore: %s\ntime: %s" % [figures_passed, score, time_passed_formated]


func register_figure(figure: FigureData) -> void:
    run_state.register_figure(figure)


func resolve_side(figure: Icosahedron, side: SideData) -> void:
    if game_state_manager.game_state != GameStateManager.GameState.GAME_ACTIVE:
        return
    if (
        not is_instance_valid(figure) or figure.resolved or figure.despawning \
                or figure.is_queued_for_deletion()
        or not side or side.collected
    ):
        return
    if figure.get_parent() != loop_controls.figureRoot.anchor or not figure.data.sides.has(side):
        return
    var outcome := run_state.resolve_side(
        figure.get_instance_id(),
        side,
        G.settings.SPAWN_MODE == PatternGen.SpawnMode.TUTORIAL,
    )
    if outcome == RunState.Outcome.IGNORED:
        return
    if outcome == RunState.Outcome.PASSED and side.modifier:
        G.discover_modifier(side.modifier.id)
    loop_controls.sync_orientation()
    figure.resolved = true
    figure.mesh_icosahedron.angle_good = true
    figure.mesh_icosahedron.burst_dents()
    if outcome == RunState.Outcome.GAME_OVER:
        _game_over()
        return
    if figure.data.easy_side >= 0:
        loop_controls.loop_spawner.recenter_after_pass(side.id)
        level_changed.emit(run_state.difficulty + 1)
    sound_requested.emit(&"on_node_passed")
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
