extends GutTest

const MAIN_SCENE := preload("res://game/app/Main.tscn")
const SETTINGS_FILE := "user://settings.cfg"

var _main_scene: Node
var _saved_settings_file: PackedByteArray
var _had_settings_file := false
var _previous_settings: Dictionary
var _previous_data: Dictionary

func before_each() -> void:
    _release_all_actions()
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

    await _tap_action(&"ui_accept")
    await wait_process_frames(10 * WAIT_MOD)
    assert_eq(main_scene.current_scene, loop_scene, "Second accept starts the selected level.")
    assert_eq(get_viewport().get_camera_3d(), loop_scene.get_node("Environment/Camera3D"),
        "Gameplay must not render through the close-up menu camera.")
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
        if selected != null and selected.get("action") == expected_action:
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
