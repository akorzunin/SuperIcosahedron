extends Node
class_name LoopGui

@onready var game_state_manager: GameStateManager = %GameStateManager
@onready var game_state_label: Label = $LoopUi/GameStatePanel/VBoxContainer/HFlowContainer/GameStateLabel
@onready var debug_stats_container: DebugStatsContainer = %DebugStatsContainer
@onready var common_controls: CommonControls = %CommonControls
@onready var loop_ui: Control = $LoopUi
@onready var tutorial_hint: Label = $LoopUi/TutorialHint
@onready var pause_menu: Control = $PauseMenu
@onready var controls: LoopControls = %LoopControls


# Called when the node enters the scene tree for the first time.
func _ready():
    common_controls.toggle_debug_stats.connect(_on_debug_stats_toggle)
    $PauseMenu/Options/Resume.pressed.connect(close_pause_menu)
    $PauseMenu/Options/ReturnToMenu.pressed.connect(
        func():
            controls.menu_requested.emit(),
    )
    game_state_manager.game_state_changed.connect(
        func(_old, state):
            if state != GameStateManager.GameState.GAME_PAUSED:
                hide_pause_menu(),
    )
    tutorial_hint.z_index = 1
    var button_style := StyleBoxFlat.new()
    button_style.bg_color = Color("182b40")
    button_style.set_corner_radius_all(12)
    button_style.content_margin_left = 24
    button_style.content_margin_right = 24
    var focus_style := button_style.duplicate() as StyleBoxFlat
    focus_style.border_color = Color("7de6cf")
    focus_style.set_border_width_all(2)
    for button in [$PauseMenu/Options/Resume, $PauseMenu/Options/ReturnToMenu]:
        button.add_theme_stylebox_override("normal", button_style)
        button.add_theme_stylebox_override("hover", focus_style)
        button.add_theme_stylebox_override("focus", focus_style)
        button.add_theme_font_size_override("font_size", 24)
    tutorial_hint.text = tutorial_instructions(Utils.get_platform() == Utils.Platform.MOBILE)
    tutorial_hint.visible = game_state_manager.tutorial_waiting
    if G.settings.SHOW_DEBUG_STATS:
        debug_stats_container.show()
    else:
        debug_stats_container.hide()


func _physics_process(delta: float) -> void:
    tutorial_hint.visible = game_state_manager.tutorial_waiting


func open_pause_menu() -> void:
    game_state_manager.change_state(GameStateManager.GameState.GAME_PAUSED)
    pause_menu.show()
    $ControlsContainer.hide()
    $PauseMenu/Options/Resume.grab_focus()


func hide_pause_menu() -> void:
    var focus := get_viewport().gui_get_focus_owner()
    if focus and pause_menu.is_ancestor_of(focus):
        focus.release_focus()
    pause_menu.hide()
    $ControlsContainer.show()


func close_pause_menu() -> void:
    hide_pause_menu()
    # Resuming the tutorial returns to its instructions, not straight into play.
    if not game_state_manager.tutorial_waiting:
        game_state_manager.change_state(GameStateManager.GameState.GAME_ACTIVE)


static func tutorial_instructions(mobile: bool) -> String:
    if mobile:
        return "TUTORIAL — PAUSED\n\nUse the four direction buttons to rotate the figure.\nAlign the open gap and pass safely to make progress.\nThe central buttons optionally lock your alignment.\n\nTap a central button to start playing."
    return "TUTORIAL — PAUSED\n\nUse W, A, S, D or the arrow keys to rotate the figure.\nAlign the open gap and pass safely to make progress.\nSpace or Enter optionally locks your alignment near passage.\n\nPress Space or Enter to start playing."


func _on_debug_stats_toggle(v: bool):
    DebugStatsContainer.toggle(v, debug_stats_container)


func show_stats_panel(state: bool):
    if state:
        loop_ui.show()
        return
    loop_ui.hide()
