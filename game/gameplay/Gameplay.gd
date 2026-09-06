extends Node3D
class_name LoopScene

signal menu_requested
signal sound_requested(event: StringName)
signal status_changed(details: String, state: String)
signal level_changed(level: int)

@onready var game_state_manager: GameStateManager = %GameStateManager
@onready var controls: LoopControls = %LoopControls
@onready var progress: GameProgress = %GameProgress
@onready var spawner: LoopSpawner = %LoopSpawner
@onready var figure_root: FigureRoot = $FigureRoot
var start_inactive := false

func init(props: Dictionary):
    start_inactive = props.get("start_inactive", false)
    return self

func _ready() -> void:
    controls.restart_requested.connect(restart)
    controls.menu_requested.connect(func(): menu_requested.emit())
    controls.sound_requested.connect(func(event): sound_requested.emit(event))
    progress.sound_requested.connect(func(event): sound_requested.emit(event))
    progress.status_changed.connect(func(details, state): status_changed.emit(details, state))
    progress.level_changed.connect(func(level): level_changed.emit(level))
    if not start_inactive:
        restart()

func restart() -> void:
    controls.controlledNode = null
    controls.figure_controller.target = null
    game_state_manager.change_state(GameStateManager.GameState.GAME_MENU)
    figure_root.clean_all(true)
    spawner.reset()
    %PatternGen.reset(int(G.data.get("level", 0)))
    progress.reset()
    game_state_manager.change_state(GameStateManager.GameState.GAME_ACTIVE)
    spawner.spawn_icosahedron()

func toggle_pause() -> void:
    game_state_manager.toggle_pause()
