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
