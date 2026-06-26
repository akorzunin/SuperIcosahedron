extends Node
class_name LoopControls

@export var figureRoot: FigureRoot
@export var controlledNode: MeshIcosahedron
@onready var game_progress: GameProgress = %GameProgress
@onready var game_state_manager: GameStateManager = %GameStateManager
@onready var sfx_player: SfxPlayer = $"/root/MainScene/SfxPlayer"
@onready var loop_spawner: LoopSpawner = %LoopSpawner

enum ControlType {FREE_SPIN, FACE_LOCK}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    game_state_manager.game_state_changed.connect(_on_game_state)

func _on_game_state(old_state: GameStateManager.GameState, new_state: GameStateManager.GameState):
    var gs := GameStateManager.GameState
    if new_state == gs.GAME_END:
        # lock all input for short perion of time
        set_process_input(false)
        await get_tree().create_timer(1.0).timeout
        set_process_input(true)

func restart_run() -> void:
    figureRoot.clean_all(true)
    game_progress.reset()
    controlledNode = null
    game_state_manager.change_state(GameStateManager.GameState.GAME_ACTIVE)
    loop_spawner.spawn_icosahedron()

func set_controlled_node(node: MeshIcosahedron):
    if controlledNode != null and is_instance_valid(controlledNode) and controlledNode is MeshIcosahedron:
        controlledNode.set_controlled(false)
    node.set_controlled(true)
    controlledNode = node

func update_controlled_node():
    if controlledNode and not is_instance_valid(controlledNode):
        controlledNode = null
    var unchecked_mesh: MeshIcosahedron
    for figure in figureRoot.get_live_figures():
        if not figure.mesh_icosahedron.angle_good:
            unchecked_mesh = figure.mesh_icosahedron
            break
    if unchecked_mesh and controlledNode != unchecked_mesh:
        if game_state_manager.game_state != GameStateManager.GameState.GAME_END:
            sfx_player.on_node_passed.emit()
        set_controlled_node(unchecked_mesh)
    elif not unchecked_mesh:
        controlledNode = null

func pass_next_node(node: Collider):
    if controlledNode != null \
    and game_state_manager.game_state != GameStateManager.GameState.GAME_END \
    and not controlledNode.angle_good \
    and node.mesh_icosahedron == controlledNode:
        controlledNode.angle_good = true
        game_progress.log_tts(controlledNode.icosahedron.spwan_time, controlledNode.currnt_type)
    update_controlled_node()

func _input(event: InputEvent) -> void:
    var is_inverted = G.settings.IS_CONTROL_INVERTED
    if game_state_manager.game_state == GameStateManager.GameState.GAME_END:
        handle_game_over_input(event, is_inverted)
        G.reload_settings.emit()
        return
    if event.is_action_pressed('ui_pause') or event.is_action_pressed('ui_cancel'):
        game_state_manager.toggle_pause()
        sfx_player.on_section_select.emit()
        get_viewport().set_input_as_handled()
        return

func handle_game_over_input(event: InputEvent, is_inverted: bool):
    if event.is_action_pressed('ui_accept') or Op.xor(is_inverted, event.is_action_pressed('ui_right')):
        restart_run()
    elif event.is_action_pressed('ui_cancel') or Op.xor(is_inverted, event.is_action_pressed('ui_left')):
        sfx_player.on_action_select.emit()
        Utils.set_scene(self, 'MenuScene')

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    if game_state_manager.game_state != GameStateManager.GameState.GAME_ACTIVE:
        return
    if not controlledNode or not is_instance_valid(controlledNode):
        update_controlled_node()
        return
    var is_inverted = G.settings.IS_CONTROL_INVERTED
    if G.settings.CONTROL_TYPE == "FACE_LOCK":
        FaceLock.handle_face_lock_input(controlledNode, is_inverted)
    else:
        var rot_speed: float = G.settings.ROTATION_SPEED / 10. * delta
        FreeSpin.handle_free_spin_input(controlledNode, rot_speed, is_inverted)
