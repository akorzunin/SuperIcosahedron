extends Timer
class_name MainTimer


@onready var game_state_manager: GameStateManager = %GameStateManager
@onready var settings = %Settings

@export var spawn_speed: Settings.SpawnSpeeds

func _ready() -> void:
    spawn_speed = settings.spawn_speed
    game_state_manager.game_state_changed.connect(_on_game_state_changed)
    pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    pass

func _on_game_state_changed(old_state: GameStateManager.GameState, new_state: GameStateManager.GameState):
    var gm = GameStateManager.GameMode
    if new_state in [gm.START, gm.RESUME]:
        start(1 % spawn_speed)
    if new_state in [gm.PAUSE, gm.END]:
        stop()
