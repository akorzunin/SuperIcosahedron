extends Node
class_name MenuActions

@onready var config: Config = $'../Config'
@onready var sfx_player: SfxPlayer = $"/root/MainScene/SfxPlayer"
@onready var menu_spawner := $"../MenuSpawner"
@onready var menu_selector: MenuSelector = %MenuSelector
@onready var menu_controls: MenuControls = $'../MenuControls'
@onready var menu_state: MenuState = %MenuState

func settings_fps_counter_on():
    config.set_fps_counter_state.emit(true)

func settings_fps_counter_off():
    config.set_fps_counter_state.emit(false)

func settings_sfx_on():
    sfx_player.toggle_sfx.emit(true)

func settings_sfx_off():
    sfx_player.toggle_sfx.emit(false)

func menu_back():
    var selected = menu_selector.get_selected_item()
    menu_spawner.open_menu_section(menu_controls.controlledNode, menu_state.back())
    return

func menu_start_game():
    if Utils.main_scene(self) == 'MenuScene':
        get_tree().quit()
        return
    Utils.set_scene(self, 'LoopScene')

func menu_open_controls_editor():
    push_warning("not implemented")

func menu_exit_game():
    get_tree().quit()
