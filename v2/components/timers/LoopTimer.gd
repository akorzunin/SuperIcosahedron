extends Timer
class_name LoopTimer

@onready var game_state_manager: GameStateManager = %GameStateManager
var time_start: int
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    game_state_manager.game_state_changed.connect(_on_game_state_changed)
    pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    pass

func _on_game_state_changed(old_state: GameStateManager.GameState, new_state: GameStateManager.GameState) -> void:
    var gs = GameStateManager.GameState
    if new_state == gs.GAME_ACTIVE:
        start()
        time_start = Time.get_ticks_msec()
    if new_state in [gs.GAME_END, gs.GAME_MENU]:
        stop()
    if new_state == gs.GAME_PAUSED:
        paused = true
    if old_state == gs.GAME_PAUSED:
        paused = false

func get_elapsed_time() -> String:
    var time_now := Time.get_ticks_msec()
    if is_stopped() or time_start > time_now:
        return "000:000"
    return format_time(time_now - time_start)

func format_time(time: int) -> String:
    var ms := time % 1000
    var sec := float(time) / 1000
    return "%d:%03d" % [sec, ms]
