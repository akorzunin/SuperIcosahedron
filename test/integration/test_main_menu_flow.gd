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
    assert_eq(game_state_manager.game_state, GameStateManager.GameState.GAME_MENU)

    await _tap_action(&"ui_accept")
    await wait_process_frames(10 * WAIT_MOD)
    assert_eq(main_scene.current_scene, menu_scene, "First accept opens level select from Start.")

    await _tap_action(&"ui_accept")
    await wait_process_frames(10 * WAIT_MOD)
    assert_eq(main_scene.current_scene, loop_scene, "Second accept starts the selected level.")
    assert_eq(game_state_manager.game_state, GameStateManager.GameState.GAME_ACTIVE)

    assert_true(_resolve_first_solid_side(loop_scene), "A spawned figure has a solid side that can end the run.")
    await wait_process_frames(2 * WAIT_MOD)
    assert_eq(game_state_manager.game_state, GameStateManager.GameState.GAME_END)

func test_main_menu_setting_input_is_saved_to_ini_file() -> void:
    var main_scene := await _load_main_scene()
    var menu_scene: Node = main_scene.scenes.MenuScene
    assert_eq(main_scene.current_scene, menu_scene, "Setting starts from main menu.")

    _open_invert_x_options(menu_scene)

    var selected: Variant = await _wait_for_selected_menu_item(menu_scene, "settings_invert_x")
    assert_not_null(selected, "The opened setting option has a selected menu item.")
    assert_eq(selected.get("action"), "settings_invert_x")

    await _tap_action(&"ui_accept")
    await wait_process_frames(2)

    assert_true(G.settings.IS_CONTROL_INVERTED, "Accepting the menu option updates runtime settings.")

    var cfg := ConfigFile.new()
    assert_eq(cfg.load(SETTINGS_FILE), OK, "Settings ini file exists after the menu setting change.")
    assert_true(
        cfg.get_value("user_settings", "IS_CONTROL_INVERTED"),
        "Accepting the menu option serializes IS_CONTROL_INVERTED to user://settings.cfg."
    )

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
