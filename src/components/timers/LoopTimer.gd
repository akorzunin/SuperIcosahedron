extends Timer
class_name LoopTimer

@onready var game_state_manager: GameStateManager = %GameStateManager
var time_start: int
var pause_start: int
var paused_time: int

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    game_state_manager.game_state_changed.connect(_on_game_state_changed)
    G.reload_settings.connect(_on_reload_settings)

func _on_reload_settings():
    await timeout
    stop()
    start(100. / (G.settings.SPAWN_SPEED * G.settings.GAME_SPEED))

func _on_game_state_changed(old_state: GameStateManager.GameState, new_state: GameStateManager.GameState) -> void:
    var gs = GameStateManager.GameState
    if new_state == gs.GAME_ACTIVE:
        paused = false
        if old_state == gs.GAME_PAUSED and time_start != 0:
            paused_time += Time.get_ticks_msec() - pause_start
        else:
            time_start = Time.get_ticks_msec()
            pause_start = 0
            paused_time = 0
        start(100. / (G.settings.SPAWN_SPEED * G.settings.GAME_SPEED))
    if new_state in [gs.GAME_END, gs.GAME_MENU]:
        stop()
    if new_state == gs.GAME_PAUSED:
        pause_start = Time.get_ticks_msec()
        paused = true

func get_raw_elapsed_time() -> int:
    var time_now := Time.get_ticks_msec()
    if is_stopped() or time_start > time_now:
        return 0
    if paused:
        time_now = pause_start
    return maxi(0, time_now - time_start - paused_time)

func get_elapsed_time() -> String:
    var raw_time := get_raw_elapsed_time()
    if not raw_time:
        return "000:000"
    return format_time(raw_time)

static func format_time(time: int) -> String:
    var ms := time % 1000
    var sec := float(time) / 1000
    return "%d:%03d" % [sec, ms]
