extends GutTest

const RUN_LAB := preload("res://dev/labs/run/RunLab.tscn")
const ROTATION_LAB := preload("res://dev/labs/rotation/RotationLab.tscn")
var lab: Node
var previous_settings: Dictionary
var previous_data: Dictionary

func before_each() -> void:
    previous_settings = G.settings
    previous_data = G.data
    G.settings = SettingsConfig.config_to_dict(SettingsConfig.set_default_config_values(ConfigFile.new()))
    G.data = {}
    for action in InputMap.get_actions():
        Input.action_release(action)

func after_each() -> void:
    for action in InputMap.get_actions():
        Input.action_release(action)
    if is_instance_valid(lab):
        lab.queue_free()
    await wait_process_frames(3)
    G.settings = previous_settings
    G.data = previous_data

func test_run_lab_starts_without_main_menu_and_restarts_with_one_figure() -> void:
    lab = RUN_LAB.instantiate()
    add_child(lab)
    await wait_process_frames(2)
    var gameplay: LoopScene = lab.get_node("Gameplay")
    assert_null(get_tree().root.get_node_or_null("MainScene"))
    assert_eq(gameplay.game_state_manager.game_state, GameStateManager.GameState.GAME_ACTIVE)
    assert_eq(gameplay.figure_root.get_live_figures().size(), 1)
    assert_true(gameplay.controls.figure_controller is FigureController)
    assert_eq(gameplay.controls.get_node("PlayerInput").controller, gameplay.controls.figure_controller)
    gameplay.progress.run_state.score = 42
    gameplay.restart()
    await wait_process_frames(2)
    assert_eq(gameplay.progress.score, 0)
    assert_eq(gameplay.figure_root.get_live_figures().size(), 1)
    gameplay.toggle_pause()
    assert_true(gameplay.get_node("ScaleTimer").paused)
    gameplay.restart()
    await wait_process_frames(2)
    assert_false(gameplay.get_node("ScaleTimer").paused)
    assert_eq(gameplay.figure_root.get_live_figures().size(), 1)

func test_collision_debug_toggles_do_not_take_keyboard_focus() -> void:
    lab = RUN_LAB.instantiate()
    add_child(lab)
    await wait_process_frames(2)
    for name in ["Collisions", "Observer"]:
        var button: CheckButton = lab.get_node("UI/Panel/Buttons/" + name)
        assert_eq(button.focus_mode, Control.FOCUS_NONE,
            name + " must not block PlayerInput after a mouse click.")

func test_accept_locks_current_figure_and_controls_the_next_one() -> void:
    lab = RUN_LAB.instantiate()
    add_child(lab)
    await wait_process_frames(2)
    var gameplay: LoopScene = lab.get_node("Gameplay")
    var first := gameplay.controls.controlledNode
    gameplay.spawner.spawn_icosahedron()
    await wait_process_frames(2)
    var figures := gameplay.figure_root.get_live_figures()
    var second := figures[1].mesh_icosahedron
    var accept := InputEventAction.new()
    accept.action = &"ui_accept"
    accept.pressed = true

    _align_for_commit(gameplay, first.icosahedron)
    watch_signals(gameplay.controls)
    watch_signals(gameplay.progress)
    gameplay.controls._input(accept)

    assert_signal_not_emitted(gameplay.controls, "sound_requested")
    assert_signal_not_emitted(gameplay.progress, "sound_requested")
    assert_true(first.angle_good)
    assert_true(first.visible, "Commit starts a fade instead of hiding immediately.")
    assert_eq(first.opacity, 1.0)
    assert_eq(gameplay.controls.controlledNode, second)
    assert_eq(gameplay.controls.figure_controller.target, second)
    assert_true(second.visible)
    assert_false(first.icosahedron.resolved)
    assert_eq(gameplay.progress.figures_passed, 0)
    for collider in first.get_node("SideColliders").get_children():
        assert_true(collider.get_collision_layer_value(1))
    await wait_seconds(MeshIcosahedron.FADE_TIME / 2.0)
    assert_gt(first.opacity, 0.0)
    assert_lt(first.opacity, 1.0)
    await wait_seconds(MeshIcosahedron.FADE_TIME)
    assert_false(first.visible)
    assert_false(first.icosahedron.resolved, "Fading must not bypass collision validation.")

func test_empty_dent_collision_advances_control_without_accept() -> void:
    lab = RUN_LAB.instantiate()
    add_child(lab)
    await wait_process_frames(2)
    var gameplay: LoopScene = lab.get_node("Gameplay")
    var first := gameplay.controls.controlledNode.icosahedron
    gameplay.spawner.spawn_icosahedron()
    var second := gameplay.figure_root.get_live_figures()[1].mesh_icosahedron

    watch_signals(gameplay.progress)
    await _collide_with_side(gameplay, first, true)

    assert_signal_emitted_with_parameters(gameplay.progress, "sound_requested", [&"on_node_passed"])
    assert_eq(gameplay.progress.figures_passed, 1)
    assert_eq(gameplay.controls.controlledNode, second)
    assert_eq(gameplay.controls.figure_controller.target, second)
    assert_false(is_instance_valid(first))

func test_incorrect_commit_is_rejected_without_losing_control() -> void:
    lab = RUN_LAB.instantiate()
    add_child(lab)
    await wait_process_frames(2)
    var gameplay: LoopScene = lab.get_node("Gameplay")
    var first := gameplay.controls.controlledNode.icosahedron
    _align_for_commit(gameplay, first, false)
    watch_signals(gameplay.controls)
    var accept := InputEventAction.new()
    accept.action = &"ui_accept"
    accept.pressed = true
    gameplay.controls._input(accept)
    assert_signal_emitted_with_parameters(gameplay.controls, "commit_rejected", [first])
    assert_eq(gameplay.controls.figure_controller.target, first.mesh_icosahedron)
    assert_false(first.mesh_icosahedron.angle_good)
    assert_null(first.mesh_icosahedron.fade_tween)
    assert_true(first.mesh_icosahedron.visible)
    assert_eq(gameplay.game_state_manager.game_state, GameStateManager.GameState.GAME_ACTIVE)
    assert_eq(gameplay.progress.figures_passed, 0)
    _align_for_commit(gameplay, first)
    gameplay.controls._input(accept)
    assert_true(first.mesh_icosahedron.angle_good, "Player can correct and retry.")

func test_committed_figure_pass_does_not_skip_next_figure() -> void:
    lab = RUN_LAB.instantiate()
    add_child(lab)
    await wait_process_frames(2)
    var gameplay: LoopScene = lab.get_node("Gameplay")
    var first := gameplay.controls.controlledNode.icosahedron
    _align_for_commit(gameplay, first)
    gameplay.controls.advance_control()
    gameplay.spawner.spawn_icosahedron()
    await wait_process_frames(2)
    var second := gameplay.controls.controlledNode
    assert_not_null(second)
    assert_ne(second, first.mesh_icosahedron)

    await _collide_with_side(gameplay, first, true)

    assert_eq(gameplay.progress.figures_passed, 1)
    assert_eq(gameplay.controls.controlledNode, second)
    assert_false(second.angle_good)

func _align_for_commit(gameplay: LoopScene, figure: Icosahedron, empty := true) -> void:
    var detector: EndDetector = gameplay.get_node("EndDetector")
    for side in figure.data.sides:
        if side.is_empty() == empty:
            var points := figure.mesh_icosahedron.get_side_points(side.id)
            var normal := (points[1] + points[2] + points[3]).normalized()
            var direction := (detector.global_position - figure.global_position).normalized()
            figure.mesh_icosahedron.global_basis = Basis(Quaternion(normal, direction))
            return

func _collide_with_side(gameplay: LoopScene, figure: Icosahedron, empty: bool) -> void:
    var detector: EndDetector = gameplay.get_node("EndDetector")
    for side in figure.data.sides:
        if side.is_empty() == empty:
            var direction := (detector.global_position - figure.global_position).normalized()
            _align_for_commit(gameplay, figure, empty)
            gameplay.get_node("LoopTimer").stop()
            gameplay.get_node("ScaleTimer").stop()
            for size in range(2, 25):
                if not is_instance_valid(figure) or figure.resolved:
                    break
                figure.scale = Vector3.ONE * size
                await wait_physics_frames(3)
            return

func test_run_lab_resets_game_over_presentation() -> void:
    lab = RUN_LAB.instantiate()
    add_child(lab)
    await wait_process_frames(2)
    var gameplay: LoopScene = lab.get_node("Gameplay")
    gameplay.game_state_manager.change_state(GameStateManager.GameState.GAME_END)
    gameplay.restart()
    await wait_seconds(0.25)
    assert_true(gameplay.figure_root.anchor.transform.is_equal_approx(Transform3D.IDENTITY))
    assert_eq(gameplay.figure_root.get_live_figures().size(), 1)

func test_control_handoff_preserves_each_figures_color() -> void:
    lab = RUN_LAB.instantiate()
    add_child(lab)
    await wait_process_frames(2)
    var gameplay: LoopScene = lab.get_node("Gameplay")
    var first := gameplay.controls.controlledNode
    gameplay.spawner.spawn_icosahedron()
    var second := gameplay.figure_root.get_live_figures()[1].mesh_icosahedron
    var first_color: Color = first.get_dents()[0].material_override.get_shader_parameter("color")
    var second_color: Color = second.get_dents()[0].material_override.get_shader_parameter("color")
    _align_for_commit(gameplay, first.icosahedron)
    gameplay.controls.advance_control()
    assert_eq(first.get_dents()[0].material_override.get_shader_parameter("color"), first_color)
    assert_eq(second.get_dents()[0].material_override.get_shader_parameter("color"), second_color)

func test_commit_stops_in_flight_face_rotation() -> void:
    lab = RUN_LAB.instantiate()
    add_child(lab)
    await wait_process_frames(2)
    var gameplay: LoopScene = lab.get_node("Gameplay")
    var mesh := gameplay.controls.controlledNode
    gameplay.controls.figure_controller.step_face(Vector2.RIGHT)
    _align_for_commit(gameplay, mesh.icosahedron)
    gameplay.controls.advance_control()
    var committed := mesh.quaternion
    await wait_seconds(FaceLock.ROTATION_TIME + 0.05)
    assert_true(mesh.quaternion.is_equal_approx(committed))
    assert_false(mesh.is_rotating)

func test_shared_rotation_spawn_commit_preserves_existing_layouts() -> void:
    lab = RUN_LAB.instantiate()
    add_child(lab)
    await wait_process_frames(2)
    var gameplay: LoopScene = lab.get_node("Gameplay")
    gameplay.get_node("LoopTimer").stop()
    gameplay.get_node("ScaleTimer").stop()
    var first := gameplay.controls.controlledNode.icosahedron
    gameplay.spawner.spawn_icosahedron()
    var second := gameplay.figure_root.get_live_figures()[1]
    gameplay.controls.figure_controller.rotate_continuous(Vector2.RIGHT, 0.1)
    gameplay.controls.sync_orientation()
    assert_true(first.mesh_icosahedron.basis.is_equal_approx(second.mesh_icosahedron.basis))
    gameplay.spawner.spawn_icosahedron()
    var third := gameplay.figure_root.get_live_figures()[2]
    assert_true(first.mesh_icosahedron.basis.is_equal_approx(third.mesh_icosahedron.basis),
        "New figures inherit accumulated steering")
    lab.collision_debug.set_enabled(true)
    await wait_process_frames(2)
    _align_for_commit(gameplay, first)
    var passed: SideData = gameplay.get_node("EndDetector").get_passing_side(first)
    gameplay.controls.advance_control()
    var frozen := first.mesh_icosahedron.basis
    gameplay.controls.figure_controller.step_face(Vector2.RIGHT)
    await wait_seconds(FaceLock.ROTATION_TIME + 0.05)
    gameplay.controls.sync_orientation()
    assert_true(first.mesh_icosahedron.basis.is_equal_approx(frozen), "Committed shell stays safe")
    assert_true(second.mesh_icosahedron.basis.is_equal_approx(third.mesh_icosahedron.basis),
        "FaceLock tween propagates to upcoming shells")
    var layouts := []
    for figure in [second, third]:
        layouts.append([figure.data.easy_side,
            figure.data.sides.map(func(side): return [side.kind, side.modifier])])
    await _collide_with_side(gameplay, first, true)
    assert_eq(gameplay.spawner.easy_side, passed.id)
    for i in 2:
        var figure: Icosahedron = [second, third][i]
        assert_eq(figure.data.easy_side, layouts[i][0])
        assert_eq(figure.data.sides.map(func(side): return [side.kind, side.modifier]), layouts[i][1])
    gameplay.spawner.spawn_icosahedron()
    assert_eq(gameplay.figure_root.get_live_figures()[-1].data.easy_side, passed.id)
    await wait_process_frames(2)
    for area in second.get_node("MeshIcosahedron/SideColliders").get_children():
        var wire: MeshInstance3D = lab.collision_debug.shapes[area.get_child(0)]
        assert_eq(wire.material_override.albedo_color, Color.LIME_GREEN if area.side.is_empty() else Color.RED)
    gameplay.restart()
    await wait_process_frames(2)
    assert_eq(gameplay.progress.run_state.tiers_collected, 0)
    assert_eq(gameplay.figure_root.get_live_figures().size(), 1)

func test_end_game_rotates_before_activating_option(inverted = use_parameters([false, true])) -> void:
    lab = RUN_LAB.instantiate()
    add_child(lab)
    await wait_process_frames(2)
    var gameplay: LoopScene = lab.get_node("Gameplay")
    var controls := gameplay.controls
    gameplay.game_state_manager.change_state(GameStateManager.GameState.GAME_END)
    await wait_seconds(1.05)
    var anchor := gameplay.figure_root.anchor
    var initial := anchor.quaternion
    watch_signals(controls)
    var event := InputEventAction.new()
    event.action = &"ui_left" if inverted else &"ui_right"
    event.pressed = true
    controls.handle_game_over_input(event, inverted)
    assert_eq(gameplay.game_state_manager.game_state, GameStateManager.GameState.GAME_END)
    assert_signal_not_emitted(controls, "restart_requested")
    await wait_seconds(LoopControls.OPTION_ROTATION_TIME / 2.0)
    assert_false(anchor.quaternion.is_equal_approx(initial))
    assert_eq(gameplay.game_state_manager.game_state, GameStateManager.GameState.GAME_END)
    await wait_seconds(LoopControls.OPTION_ROTATION_TIME)
    assert_signal_emit_count(controls, "restart_requested", 1)
    assert_eq(gameplay.game_state_manager.game_state, GameStateManager.GameState.GAME_ACTIVE)
    assert_true(anchor.transform.is_equal_approx(Transform3D.IDENTITY))

    gameplay.game_state_manager.change_state(GameStateManager.GameState.GAME_END)
    await wait_seconds(1.05)
    event.action = &"ui_right" if inverted else &"ui_left"
    controls.handle_game_over_input(event, inverted)
    assert_signal_not_emitted(controls, "menu_requested")
    await wait_seconds(LoopControls.OPTION_ROTATION_TIME + 0.05)
    assert_signal_emit_count(controls, "menu_requested", 1)

func test_restart_cancels_pending_end_game_selection() -> void:
    lab = RUN_LAB.instantiate()
    add_child(lab)
    await wait_process_frames(2)
    var gameplay: LoopScene = lab.get_node("Gameplay")
    gameplay.game_state_manager.change_state(GameStateManager.GameState.GAME_END)
    await wait_seconds(1.05)
    var event := InputEventAction.new()
    event.action = &"ui_left"
    event.pressed = true
    watch_signals(gameplay.controls)
    gameplay.controls.handle_game_over_input(event, false)
    gameplay.restart()
    await wait_seconds(LoopControls.OPTION_ROTATION_TIME + 0.05)
    assert_signal_not_emitted(gameplay.controls, "menu_requested")
    assert_true(gameplay.figure_root.anchor.transform.is_equal_approx(Transform3D.IDENTITY))

func test_rotation_lab_uses_production_controller_and_resets_target() -> void:
    G.settings = {} # Rotation must not depend on app settings initialization.
    lab = ROTATION_LAB.instantiate()
    add_child(lab)
    var controller: FigureController = lab.get_node("FigureController")
    var input: PlayerInput = lab.get_node("PlayerInput")
    assert_eq(input.controller, controller)
    var initial := controller.target.quaternion
    Input.action_press("ui_right")
    await wait_process_frames(3)
    Input.action_release("ui_right")
    assert_false(controller.target.quaternion.is_equal_approx(initial))
    lab.reset_figure()
    assert_true(controller.target.quaternion.is_equal_approx(initial))
    controller.step_face(Vector2.LEFT)
    await wait_seconds(FaceLock.ROTATION_TIME + 0.05)
    assert_false(controller.target.quaternion.is_equal_approx(initial))
    assert_false(controller.target.is_rotating)
