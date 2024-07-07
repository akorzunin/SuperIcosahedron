extends Node
class_name LoopGui

@onready var game_state_manager: GameStateManager = %GameStateManager
@onready var game_state_label: Label = $GameStatePanel/VBoxContainer/HFlowContainer/GameStateLabel
@onready var loop_timer: LoopTimer = %LoopTimer
@onready var timer_rich_text_label: RichTextLabel = $TimerPanel/CenterContainer/TimerRichTextLabel
@onready var debug_stats_container: DebugStatsContainer = %DebugStatsContainer
@onready var common_controls: CommonControls = %CommonControls

# Called when the node enters the scene tree for the first time.
func _ready():
    game_state_manager.game_state_changed.connect(_on_game_state_changed)
    common_controls.toggle_debug_stats.connect(_on_toggle)
    if G.settings.SHOW_DEBUG_STATS:
        debug_stats_container.show()
    else:
        debug_stats_container.hide()

func _physics_process(delta: float) -> void:
    timer_rich_text_label.set_text(loop_timer.get_elapsed_time())
    pass


func _on_game_state_changed(old_state: GameStateManager.GameState, new_state: GameStateManager.GameState):
    game_state_label.set_text(GameStateManager.GameStateNames[new_state])

# R:TODO rename
func _on_toggle(v: bool):
    if v:
        debug_stats_container.show()
    else:
        debug_stats_container.hide()
