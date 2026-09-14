extends GutTest

class QuitActions extends MenuActions:
    var confirmed := false

    func menu_confirm_exit():
        confirmed = true

const MAIN_SCENE := preload("res://game/app/Main.tscn")
const SETTINGS_FILE := "user://settings.cfg"

var _main_scene: Node
var _saved_settings_file: PackedByteArray
var _had_settings_file := false
var _previous_settings: Dictionary
var _previous_data: Dictionary
var _previous_unlocked: int
var _saved_progress: PackedByteArray
var _had_progress := false

func before_each() -> void:
    _release_all_actions()
    _previous_unlocked = G.unlocked_difficulty
    G.unlocked_difficulty = 0
    _had_progress = FileAccess.file_exists(G.PROGRESS_PATH)
    if _had_progress:
        _saved_progress = FileAccess.get_file_as_bytes(G.PROGRESS_PATH)
    _previous_settings = G.settings
    _previous_data = G.data
    G.settings = {}
    G.data = {}
    _had_settings_file = FileAccess.file_exists(SETTINGS_FILE)
    if _had_settings_file:
        _saved_settings_file = FileAccess.get_file_as_bytes(SETTINGS_FILE)
        DirAccess.remove_absolute(ProjectSettings.globalize_path(SETTINGS_FILE))

func after_each() -> void:
    _release_all_actions()
    if is_instance_valid(_main_scene):
        _main_scene.queue_free()
    _main_scene = null
    await wait_process_frames(3)
    if _had_settings_file:
        var file := FileAccess.open(SETTINGS_FILE, FileAccess.WRITE)
        file.store_buffer(_saved_settings_file)
        file.close()
    elif FileAccess.file_exists(SETTINGS_FILE):
        DirAccess.remove_absolute(ProjectSettings.globalize_path(SETTINGS_FILE))
    G.unlocked_difficulty = _previous_unlocked
    if _had_progress:
        var progress_file := FileAccess.open(G.PROGRESS_PATH, FileAccess.WRITE)
        progress_file.store_buffer(_saved_progress)
        progress_file.close()
    elif FileAccess.file_exists(G.PROGRESS_PATH):
        DirAccess.remove_absolute(ProjectSettings.globalize_path(G.PROGRESS_PATH))
    G.settings = _previous_settings
    G.data = _previous_data

func test_main_menu_accept_starts_active_game_and_solid_side_ends_game() -> void:
    const WAIT_MOD := 1
    # const WAIT_MOD := 100
    var main_scene := await _load_main_scene()
    var menu_scene: Node = main_scene.scenes.MenuScene
    var loop_scene: Node = main_scene.scenes.LoopScene
    var game_state_manager: GameStateManager = loop_scene.get_node("GameStateManager")

    assert_eq(main_scene.current_scene, menu_scene, "Game boots into the main menu.")
    assert_eq(get_viewport().get_camera_3d(), menu_scene.get_node("Environment/Camera3D"))
    assert_eq(game_state_manager.game_state, GameStateManager.GameState.GAME_MENU)

    await _tap_action(&"ui_accept")
    await wait_process_frames(10 * WAIT_MOD)
    assert_eq(main_scene.current_scene, menu_scene, "First accept opens level select from Start.")
    await _wait_for_selected_menu_item(menu_scene, "menu_start_game")

    await _tap_action(&"ui_accept")
    await wait_process_frames(10 * WAIT_MOD)
    assert_eq(main_scene.current_scene, loop_scene, "Second accept starts the selected level.")
    assert_eq(get_viewport().get_camera_3d(), loop_scene.get_node("Environment/Camera3D"),
        "Gameplay must not render through the close-up menu camera.")
    assert_eq(game_state_manager.game_state, GameStateManager.GameState.GAME_PAUSED,
        "The first level pauses for tutorial instructions.")
    assert_true(game_state_manager.tutorial_waiting)
    await _tap_action(&"ui_accept")
    await wait_process_frames(2 * WAIT_MOD)
    assert_false(game_state_manager.tutorial_waiting, "Accept dismisses tutorial instructions.")
    assert_eq(game_state_manager.game_state, GameStateManager.GameState.GAME_ACTIVE)

    assert_true(_resolve_first_solid_side(loop_scene), "A spawned figure has a solid side that can end the run.")
    await wait_process_frames(2 * WAIT_MOD)
    assert_eq(game_state_manager.game_state, GameStateManager.GameState.GAME_END)
    assert_eq(get_viewport().get_camera_3d(), loop_scene.get_node("Environment/Camera3D"))

    main_scene.change_scene("MenuScene")
    assert_eq(get_viewport().get_camera_3d(), menu_scene.get_node("Environment/Camera3D"),
        "Returning to menu restores its close-up camera.")
    main_scene.change_scene("LoopScene")
    assert_eq(get_viewport().get_camera_3d(), loop_scene.get_node("Environment/Camera3D"))

func test_tutorial_unlocks_difficulty_and_selected_level_starts_fresh() -> void:
    var main := await _load_main_scene()
    var loop: LoopScene = main.scenes.LoopScene
    G.data.selected_difficulty = 0
    main.change_scene("LoopScene")
    assert_eq(G.settings.SPAWN_MODE, PatternGen.SpawnMode.TUTORIAL)
    loop.game_state_manager.change_state(GameStateManager.GameState.GAME_ACTIVE)
    loop.progress.run_state.controls_completed = 3
    loop.progress._update_level()
    await wait_process_frames(3)
    assert_eq(G.unlocked_difficulty, 1)
    assert_eq(G.settings.SPAWN_MODE, PatternGen.SpawnMode.QUEUE)
    assert_eq(loop.progress.score, 0)
    assert_eq(loop.progress.run_state.difficulty, 0)
    G.unlock_difficulty(3)
    G.unlock_difficulty(1)
    var saved := ConfigFile.new()
    assert_eq(saved.load(G.PROGRESS_PATH), OK)
    assert_eq(saved.get_value("progress", "unlocked_difficulty"), 3)
    var entries: Dictionary = LevelPatterns.get_menu_levels(G.unlocked_difficulty)
    assert_eq(entries[1].level, 1)
    assert_eq(entries.size(), 3)
    assert_eq(entries[6].level, 0)
    G.data.selected_difficulty = 3
    loop.restart()
    assert_eq(loop.progress.run_state.tiers_collected, 0)
    assert_eq(loop.progress.score, 0)
    assert_false(loop.progress.run_state.modifier_system.pending)
    var figure: Icosahedron = loop.figure_root.get_live_figures()[0]
    assert_eq(figure.data.stage, 1)
    var material: ShaderMaterial = figure.mesh_icosahedron._materials[0]
    var rgb: Array = TwColors.tw.blue._500
    assert_eq(material.get_shader_parameter("color"), Color(rgb[0], rgb[1], rgb[2]))
    loop.progress.run_state.tiers_collected = 16
    assert_eq(figure.data.stage, 1, "Existing figure retains its generated difficulty")
    assert_eq(material.get_shader_parameter("color"), Color(rgb[0], rgb[1], rgb[2]))
    G.unlock_difficulty(4)
    G.data.selected_difficulty = 4
    G.data.level = 4
    loop.restart()
    assert_eq(loop.progress.run_state.difficulty, 1, "Unimplemented lessons stay locked even with legacy saves")
    assert_eq(loop.get_node("PatternGen").level, 0)

func test_charging_completion_automatically_starts_fresh_level_using_config() -> void:
    var main := await _load_main_scene()
    var loop: LoopScene = main.scenes.LoopScene
    G.unlock_difficulty(1)
    G.data.selected_difficulty = 1
    main.change_scene("LoopScene")
    var run := loop.progress.run_state
    var previous_required: int = RunState.required_charges()
    UpgradeCatalog.data.chains_required_for_level_2 = 2
    for i in 2:
        run.modifier_system.collect(run, UpgradeCatalog.pickup("points"))
        run.modifier_system.collect(run, UpgradeCatalog.pickup("tier", 3))
        run.modifier_system.collect(run, UpgradeCatalog.pickup("points"))
        loop.progress._update_level()
        assert_eq(G.unlocked_difficulty, 2 if i == 1 else 1)
        if i == 0:
            await wait_process_frames(2)
            assert_eq(run.difficulty, 0, "Below the configured threshold stays in level 1")
    loop.progress._update_level() # Duplicate scheduling must not skip another level.
    assert_eq(run.difficulty, 0, "Transition waits until passage handling finishes")
    assert_gt(run.score, 0)
    await wait_process_frames(3)
    UpgradeCatalog.data.chains_required_for_level_2 = previous_required
    assert_eq(run.difficulty, 1)
    assert_eq(run.score, 0)
    assert_false(run.modifier_system.pending)
    assert_eq(run.charges_completed, 0)
    assert_eq(loop.figure_root.get_live_figures().size(), 1)
    assert_eq(loop.figure_root.get_live_figures()[0].data.stage, 1)
    assert_eq(G.unlocked_difficulty, 2)
    var saved := ConfigFile.new()
    assert_eq(saved.load(G.PROGRESS_PATH), OK)
    assert_eq(saved.get_value("progress", "unlocked_difficulty"), 2)
    run.charges_completed = RunState.required_charges()
    loop.progress._update_level()
    assert_eq(G.unlocked_difficulty, 2, "Crafting advancement remains locked")

func test_main_menu_setting_input_is_saved_to_ini_file() -> void:
    var main_scene := await _load_main_scene()
    var menu_scene: Node = main_scene.scenes.MenuScene
    assert_eq(main_scene.current_scene, menu_scene, "Setting starts from main menu.")

    _open_invert_x_options(menu_scene)

    var selected: Variant = await _wait_for_selected_menu_item(menu_scene, "settings_not_invert_x")
    assert_not_null(selected, "The opened setting option has a selected menu item.")
    assert_eq(selected.get("action"), "settings_not_invert_x",
        "The current false value is selected when the option opens.")
    var current_item: MenuItem
    for item in menu_scene.get_tree().get_nodes_in_group("menu_item"):
        if item.items.get("is_current", false):
            current_item = item
            break
    assert_not_null(current_item, "The current setting option is marked.")
    assert_eq(current_item.label_3d.modulate, MenuItem.CURRENT_OPTION_COLOR)

    await wait_process_frames(50)
    await _tap_action(&"ui_right")
    selected = await _wait_for_selected_menu_item(menu_scene, "settings_invert_x")
    assert_eq(selected.get("action"), "settings_invert_x")
    await _tap_action(&"ui_accept")
    await wait_process_frames(2)

    assert_true(G.settings.IS_CONTROL_INVERTED, "Accepting the menu option updates runtime settings.")
    var highlighted_action := ""
    for item in menu_scene.get_tree().get_nodes_in_group("menu_item"):
        if item.label_3d.modulate == MenuItem.CURRENT_OPTION_COLOR:
            highlighted_action = item.action
            break
    assert_eq(highlighted_action, "settings_invert_x",
        "The highlighted option follows the saved value.")

    var cfg := ConfigFile.new()
    assert_eq(cfg.load(SETTINGS_FILE), OK, "Settings ini file exists after the menu setting change.")
    assert_true(
        cfg.get_value("user_settings", "IS_CONTROL_INVERTED"),
        "Accepting the menu option serializes IS_CONTROL_INVERTED to user://settings.cfg."
    )

func test_video_render_scale_cycles_and_persists() -> void:
    var previous_scale := get_viewport().scaling_3d_scale
    var main_scene := await _load_main_scene()
    var menu_scene: Node = main_scene.scenes.MenuScene
    var actions: MenuActions = menu_scene.get_node("MenuActions")
    var item: MenuItem = autofree(MenuItem.new().init({
        pos = 3, val = MenuStruct.settings_items[3].items[3]
    }))
    assert_eq(item.action, "settings_cycle_render_scale")
    assert_eq(G.settings.RENDER_SCALE_PERCENT, 100)
    for percent in range(90, 0, -10):
        actions.call(item.action)
        assert_eq(G.settings.RENDER_SCALE_PERCENT, percent)
        assert_almost_eq(get_viewport().scaling_3d_scale, percent / 100.0, 0.001)
        assert_eq(SettingsConfig.load_gs(SETTINGS_FILE).RENDER_SCALE_PERCENT, percent)
    main_scene.change_scene("LoopScene")
    assert_almost_eq(get_viewport().scaling_3d_scale, 0.1, 0.001)
    main_scene.change_scene("MenuScene")
    actions.call(item.action)
    assert_eq(G.settings.RENDER_SCALE_PERCENT, 100, "10% wraps back to 100%.")
    assert_almost_eq(get_viewport().scaling_3d_scale, 1.0, 0.001)
    get_viewport().scaling_3d_scale = previous_scale

func test_submenu_history_titles_and_escape_confirmation() -> void:
    var main := await _load_main_scene()
    var menu: Node = main.scenes.MenuScene
    var controls: MenuControls = menu.get_node("MenuControls")
    var spawner: MenuSpawner = menu.get_node("MenuSpawner")
    var state: MenuState = menu.get_node("MenuState")
    controls.check_controlled_node()
    var rotation := Quats.menu_quat_left().inverse()
    controls.controlledNode.quaternion = rotation
    spawner.open_menu_section(controls.controlledNode, MenuStruct.menu_items.items[2])
    spawner.open_menu_section(controls.controlledNode, MenuStruct.settings_items[1])
    spawner.open_options_section(controls.controlledNode, MenuStruct.settings_items[1].items[2])
    assert_eq(menu.get_node("Gui/SectionTitle").text, "invert x-axis")
    assert_eq(state.history.size(), 3)
    assert_false(spawner.anchor.get_children().any(func(item):
        return item is MenuItem and not item.is_queued_for_deletion() and item.pos == 6
    ), "Option titles no longer occupy a selectable face.")
    spawner.go_back()
    assert_eq(state.state.name, "controls")
    spawner.go_back()
    assert_eq(state.state.name, "settings")
    spawner.go_back()
    assert_true(controls.target.quat.is_equal_approx(rotation))
    assert_eq(menu.get_node("Gui/SectionTitle").text, "")
    await _wait_for_selected_menu_item(menu, "placeholder_action")
    assert_true(state.history.is_empty())
    assert_gte(controls.target.progress, 1.0)
    await _tap_action(&"ui_cancel")
    assert_eq(state.state.name, "Quit game?")
    await _wait_for_selected_menu_item(menu, "menu_confirm_exit")
    assert_eq(state.state.items.size(), 1, "Quit is the only item besides the generated Back button.")
    assert_eq(state.state.items[1].name, "quit")
    var real_actions := controls.actions
    var quit_actions: QuitActions = autofree(QuitActions.new())
    controls.actions = quit_actions
    await _tap_action(&"ui_cancel")
    assert_true(quit_actions.confirmed, "The next Esc confirms quitting.")
    controls.actions = real_actions
    real_actions.menu_back()
    assert_true(state.history.is_empty(), "Back still cancels quitting.")

func test_menu_ignores_repeats_transition_input_and_touch_release() -> void:
    var main := await _load_main_scene()
    var menu: Node = main.scenes.MenuScene
    var controls: MenuControls = menu.get_node("MenuControls")
    var state: MenuState = menu.get_node("MenuState")
    var repeat := InputEventKey.new()
    repeat.keycode = KEY_ENTER
    repeat.pressed = true
    repeat.echo = true
    controls._input(repeat)
    assert_true(state.history.is_empty(), "Key repeat cannot open a submenu.")
    await _tap_action(&"ui_accept")
    assert_eq(state.history.size(), 1)
    await _tap_action(&"ui_accept")
    assert_eq(main.current_scene, menu, "Accept during transition cannot start a run.")
    await _wait_for_selected_menu_item(menu, "menu_start_game")
    var release := InputEventScreenTouch.new()
    release.pressed = false
    controls._unhandled_input(release)
    assert_eq(main.current_scene, menu, "Touch release cannot activate a selection.")
    InputEmit.new().emit({action = "ui_cancel"})
    await wait_process_frames(2)
    assert_true(state.history.is_empty(), "Platform Back works without a scene argument.")

func test_pause_menu_preserves_tutorial_and_resumes_gameplay() -> void:
    var main := await _load_main_scene()
    G.data.selected_difficulty = 0
    main.change_scene("LoopScene")
    var loop: LoopScene = main.scenes.LoopScene
    var gui: LoopGui = loop.get_node("Gui")
    await _tap_action(&"ui_cancel")
    assert_true(gui.pause_menu.visible)
    assert_true(loop.game_state_manager.tutorial_waiting)
    await _tap_action(&"ui_cancel")
    assert_false(gui.pause_menu.visible)
    assert_true(loop.game_state_manager.tutorial_waiting)
    await _tap_action(&"ui_accept")
    assert_eq(loop.game_state_manager.game_state, GameStateManager.GameState.GAME_ACTIVE)
    await _tap_action(&"ui_cancel")
    assert_true(gui.pause_menu.visible)
    gui.get_node("PauseMenu/Options/Resume").pressed.emit()
    assert_eq(loop.game_state_manager.game_state, GameStateManager.GameState.GAME_ACTIVE)
    await _tap_action(&"ui_cancel")
    gui.get_node("PauseMenu/Options/ReturnToMenu").pressed.emit()
    assert_eq(main.current_scene, main.scenes.MenuScene)
    assert_false(gui.pause_menu.visible)

func _load_main_scene() -> Node:
    _main_scene = MAIN_SCENE.instantiate()
    get_tree().root.add_child(_main_scene)
    await wait_process_frames(5)
    return _main_scene

func _tap_action(action: StringName) -> void:
    _send_action(action, true)
    await wait_process_frames(1)
    _send_action(action, false)
    await wait_process_frames(1)

func _send_action(action: StringName, pressed: bool) -> void:
    var event := InputEventAction.new()
    event.action = action
    event.pressed = pressed
    Input.parse_input_event(event)

func _wait_for_selected_menu_item(menu_scene: Node, expected_action: String, max_frames := 60) -> Variant:
    var menu_selector: MenuSelector = menu_scene.get_node("MenuSelector")
    for _i in max_frames:
        await get_tree().physics_frame
        await get_tree().process_frame
        var selected: Variant = menu_selector.get_selected_item()
        if selected != null and selected.get("action") == expected_action \
        and menu_scene.get_node("MenuControls").target.progress >= 1:
            return selected
    return menu_selector.get_selected_item()

func _release_all_actions() -> void:
    for action in InputMap.get_actions():
        Input.action_release(action)

func _open_invert_x_options(menu_scene: Node) -> void:
    var menu_controls: MenuControls = menu_scene.get_node("MenuControls")
    var menu_spawner: MenuSpawner = menu_scene.get_node("MenuSpawner")

    menu_controls.check_controlled_node()
    menu_spawner.open_options_section(
        menu_controls.controlledNode,
        MenuStruct.settings_items[1].items[2]
    )

func _resolve_first_solid_side(loop_scene: Node) -> bool:
    var game_progress: GameProgress = loop_scene.get_node("GameProgress")
    var figure_root: FigureRoot = loop_scene.get_node("FigureRoot")

    for figure in figure_root.get_live_figures():
        for side in figure.data.sides:
            if side.kind == SideData.Kind.SOLID:
                game_progress.resolve_side(figure, side)
                return true
    return false
