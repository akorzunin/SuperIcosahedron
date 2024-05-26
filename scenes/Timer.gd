extends Timer

enum SpawnSpeeds {SPEED_0 = -1, SPEED_1 = 1, SPEED_2 = 3, SPEED_3 = 20}
@export var spawn_speed: SpawnSpeeds

@onready var signals: Signals = $"/root/Main/Signals"
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    signals.new_game_mode.connect(_on_signals_new_game_mode)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    pass

func _on_signals_new_game_mode(game_mode: GameStateManager.GameMode):
    if game_mode in [
        GameStateManager.GameMode.START,
        GameStateManager.GameMode.RESUME,
    ]:
        if 0:
            start(1 % spawn_speed)
    elif game_mode in [
        GameStateManager.GameMode.PAUSE,
        GameStateManager.GameMode.END,
    ]:
        stop()
