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

    gameplay.controls._input(accept)

    assert_true(first.angle_good)
    assert_false(first.visible)
    assert_eq(gameplay.controls.controlledNode, second)
    assert_eq(gameplay.controls.figure_controller.target, second)
    assert_true(second.visible)
    assert_false(first.icosahedron.resolved)
    assert_eq(gameplay.progress.figures_passed, 0)
    for collider in first.get_node("SideColliders").get_children():
        assert_true(collider.get_collision_layer_value(1))

func test_empty_dent_collision_advances_control_without_accept() -> void:
    lab = RUN_LAB.instantiate()
    add_child(lab)
    await wait_process_frames(2)
    var gameplay: LoopScene = lab.get_node("Gameplay")
    var first := gameplay.controls.controlledNode.icosahedron
    gameplay.spawner.spawn_icosahedron()
    var second := gameplay.figure_root.get_live_figures()[1].mesh_icosahedron

    await _collide_with_side(gameplay, first, true)

    assert_eq(gameplay.progress.figures_passed, 1)
    assert_eq(gameplay.controls.controlledNode, second)
    assert_eq(gameplay.controls.figure_controller.target, second)
    assert_false(is_instance_valid(first))

func test_committed_figure_still_fails_on_solid_dent_collision() -> void:
    lab = RUN_LAB.instantiate()
    add_child(lab)
    await wait_process_frames(2)
    var gameplay: LoopScene = lab.get_node("Gameplay")
    var first := gameplay.controls.controlledNode.icosahedron
    gameplay.controls.advance_control()
    assert_null(gameplay.controls.figure_controller.target)

    await _collide_with_side(gameplay, first, false)

    assert_eq(gameplay.game_state_manager.game_state, GameStateManager.GameState.GAME_END)
    assert_eq(gameplay.progress.figures_passed, 0)

func test_committed_figure_pass_does_not_skip_next_figure() -> void:
    lab = RUN_LAB.instantiate()
    add_child(lab)
    await wait_process_frames(2)
    var gameplay: LoopScene = lab.get_node("Gameplay")
    var first := gameplay.controls.controlledNode.icosahedron
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

func _collide_with_side(gameplay: LoopScene, figure: Icosahedron, empty: bool) -> void:
    var detector: EndDetector = gameplay.get_node("EndDetector")
    for side in figure.data.sides:
        if side.is_empty() == empty:
            var direction := (detector.global_position - figure.global_position).normalized()
            figure.mesh_icosahedron.global_basis = Basis(Quaternion(side.normal.normalized(), direction))
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
