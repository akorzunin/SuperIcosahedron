extends Node
class_name LoopControls

@export var figureRoot: FigureRoot
@export var controlledNode: MeshIcosahedron
@onready var game_progress: GameProgress = %GameProgress
@onready var game_state_manager: GameStateManager = %GameStateManager
@onready var figure_controller: FigureController = $FigureController

signal menu_requested
signal restart_requested
signal sound_requested(event: StringName)
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
    restart_requested.emit()

func set_controlled_node(node: MeshIcosahedron):
    if controlledNode != null and is_instance_valid(controlledNode) and controlledNode is MeshIcosahedron:
        controlledNode.set_controlled(false)
    node.set_controlled(true)
    controlledNode = node
    figure_controller.target = node

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
            sound_requested.emit(&"on_node_passed")
        set_controlled_node(unchecked_mesh)
    elif not unchecked_mesh:
        if controlledNode and is_instance_valid(controlledNode):
            controlledNode.set_controlled(false)
        controlledNode = null
        figure_controller.target = null

func advance_control() -> void:
    if game_state_manager.game_state != GameStateManager.GameState.GAME_ACTIVE:
        return
    if not controlledNode or not is_instance_valid(controlledNode) or controlledNode.angle_good:
        return
    controlledNode.angle_good = true
    # Hide only the visuals: committing does not bypass collision validation.
    controlledNode.hide()
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
        sound_requested.emit(&"on_section_select")
        get_viewport().set_input_as_handled()
        return
    if game_state_manager.game_state == GameStateManager.GameState.GAME_ACTIVE \
    and event.is_action_pressed('ui_accept'):
        advance_control()
        get_viewport().set_input_as_handled()

func handle_game_over_input(event: InputEvent, is_inverted: bool):
    var restart_action := 'ui_left' if is_inverted else 'ui_right'
    var menu_action := 'ui_right' if is_inverted else 'ui_left'
    if event.is_action_pressed('ui_accept') or event.is_action_pressed(restart_action):
        restart_run()
    elif event.is_action_pressed('ui_cancel') or event.is_action_pressed(menu_action):
        sound_requested.emit(&"on_action_select")
        menu_requested.emit()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    figure_controller.enabled = game_state_manager.game_state == GameStateManager.GameState.GAME_ACTIVE
    if not controlledNode or not is_instance_valid(controlledNode):
        update_controlled_node()
    figure_controller.target = controlledNode
    figure_controller.control_type = G.settings.CONTROL_TYPE
    figure_controller.rotation_speed = G.settings.ROTATION_SPEED
    figure_controller.inverted = G.settings.IS_CONTROL_INVERTED
