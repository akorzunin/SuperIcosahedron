extends Node
class_name LoopGui

@onready var game_state_manager: GameStateManager = %GameStateManager
@onready var loop_timer: LoopTimer = %LoopTimer
@onready var game_state_label: Label = $LoopUi/GameStatePanel/VBoxContainer/HFlowContainer/GameStateLabel
@onready var timer_rich_text_label: Label = $LoopUi/TimerPanel/CenterContainer/TimerRichTextLabel
@onready var debug_stats_container: DebugStatsContainer = %DebugStatsContainer
@onready var common_controls: CommonControls = %CommonControls
@onready var loop_ui: Control = $LoopUi

# Called when the node enters the scene tree for the first time.
func _ready():
    common_controls.toggle_debug_stats.connect(_on_debug_stats_toggle)
    if G.settings.SHOW_DEBUG_STATS:
        debug_stats_container.show()
    else:
        debug_stats_container.hide()

func _physics_process(delta: float) -> void:
    timer_rich_text_label.set_text(loop_timer.get_elapsed_time())
    pass

func _on_debug_stats_toggle(v: bool):
    DebugStatsContainer.toggle(v, debug_stats_container)

func show_stats_panel(state: bool):
    if state:
        loop_ui.show()
        return
    loop_ui.hide()
