extends Node
class_name MenuActions

@onready var config: Config = $"/root/MainScene/Config"
@onready var sfx_player: SfxPlayer = $"/root/MainScene/SfxPlayer"
@onready var menu_spawner := $"../MenuSpawner"
@onready var menu_selector: MenuSelector = %MenuSelector
@onready var menu_controls: MenuControls = $'../MenuControls'
@onready var menu_state: MenuState = %MenuState
@onready var common_controls: CommonControls = %CommonControls

func menu_start_game():
    if Utils.main_scene(self) == 'MenuScene':
        get_tree().quit()
        return
    Utils.set_scene(self, 'LoopScene')

func settings_fps_counter_on():
    config.set_fps_counter_state.emit(true)

func settings_fps_counter_off():
    config.set_fps_counter_state.emit(false)

func settings_display_debug_stats_on():
    config._on_debug_stats_state(true)
    common_controls.toggle_debug_stats.emit(true)

func settings_display_debug_stats_off():
    config._on_debug_stats_state(false)
    common_controls.toggle_debug_stats.emit(false)

func settings_fullscreen():
    var state := DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN
    config.set_fullscreen_state(state)
    # TODO: logic of this func a bit confusing
    Utils.change_window_mode(DisplayServer.WINDOW_MODE_MAXIMIZED)

func settings_bordered():
    var state := DisplayServer.WINDOW_MODE_MAXIMIZED
    config.set_fullscreen_state(state)
    DisplayServer.window_set_mode(state)

func settings_vsync_on():
    var state := DisplayServer.VSYNC_ADAPTIVE
    config.set_vsync_state(state)
    Utils.set_vsync(state)

func settings_vsync_off():
    var state := DisplayServer.VSYNC_DISABLED
    config.set_vsync_state(state)
    Utils.set_vsync(state)

func settings_music_on():
    sfx_player.toggle_music.emit(true)

func settings_music_off():
    sfx_player.toggle_music.emit(false)

func settings_sfx_on():
    sfx_player.toggle_sfx.emit(true)

func settings_sfx_off():
    sfx_player.toggle_sfx.emit(false)

func menu_show_achivemets():
    pass

func menu_show_credits():
    pass

func menu_exit_game():
    get_tree().quit()

func menu_back():
    var selected = menu_selector.get_selected_item()
    menu_spawner.open_menu_section(menu_controls.controlledNode, menu_state.back())
    return

func menu_easter_egg():
    menu_state.toggle_easter_egg_state()
    menu_spawner.open_menu_section(menu_controls.controlledNode, menu_state.state)


func menu_open_controls_editor():
    push_warning("not implemented")
