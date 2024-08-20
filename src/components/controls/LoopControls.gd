extends Node
class_name LoopControls

@export var figureRoot: FigureRoot
@export var controlledNode: MeshIcosahedron
@export var ROTATION_SPEED: float
@onready var game_progress: GameProgress = %GameProgress
@onready var game_state_manager: GameStateManager = %GameStateManager
@onready var sfx_player: SfxPlayer = $"/root/MainScene/SfxPlayer"

enum ControlType {FREE_SPIN, FACE_LOCK}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    game_state_manager.game_state_changed.connect(_on_game_state)
    ROTATION_SPEED = G.settings.ROTATION_SPEED

func _on_game_state(old_state: GameStateManager.GameState, new_state: GameStateManager.GameState):
    var gs := GameStateManager.GameState
    if new_state == gs.GAME_END:
        # lock all input for short perion of time
        set_process_input(false)
        await get_tree().create_timer(1.0).timeout
        set_process_input(true)

func set_controlled_node(node: MeshIcosahedron):
    if controlledNode != null and controlledNode is MeshIcosahedron:
        controlledNode.set_controlled(false)
    node.set_controlled(true)
    controlledNode = node
    game_progress.add_one()

func update_controlled_node():
    var figures = figureRoot.get_node("Anchor").get_children() as Array[Icosahedron]
    var unchecked_mesh: MeshIcosahedron
    for figure in figures:
        if not figure.mesh_icosahedron.angle_good:
            unchecked_mesh = figure.mesh_icosahedron
            break
    if unchecked_mesh and controlledNode != unchecked_mesh:
        set_controlled_node(unchecked_mesh)

func pass_next_node(node: Collider):
    if controlledNode != null \
    and not controlledNode.angle_good \
    and node.mesh_icosahedron == controlledNode:
        controlledNode.angle_good = true
    update_controlled_node()

func _input(event: InputEvent) -> void:
    var is_inverted = G.settings.IS_CONTROL_INVERTED
    if game_state_manager.game_state == GameStateManager.GameState.GAME_END:
        handle_game_over_input(event, is_inverted)
        return
    if event.is_action_pressed('ui_pause'):
        get_tree().paused = !get_tree().paused
    if event.is_action_pressed('ui_accept'):
        if Utils.main_scene(self) == 'LoopScene':
            get_tree().paused = false
            get_tree().reload_current_scene()
            return
    if get_tree().paused and event.is_action_pressed('ui_cancel'):
        if Utils.main_scene(self) == 'LoopScene':
            get_tree().paused = false
            get_tree().reload_current_scene()
            return
        Utils.set_scene(self, 'LoopScene')
        return
    if event.is_action_pressed('ui_cancel'):
        if Utils.main_scene(self) == 'LoopScene':
            return
        Utils.set_scene(self, 'MenuScene')
        sfx_player.on_section_select.emit()
        return

func game_over_rot(scene: StringName, t: Quaternion):
    const GAME_OVER_ROT := 0.3
    const GAME_OVER_DELAY := 0.1
    var tw = create_tween()
    tw.tween_property(figureRoot.anchor, "quaternion", t, GAME_OVER_ROT)\
        .set_delay(GAME_OVER_DELAY)
    tw.tween_callback(func(): Utils.set_scene(self, scene))
    tw.play()
    sfx_player.on_action_select.emit()

func handle_game_over_input(event: InputEvent, is_inverted: bool):
    if event.is_action_pressed('ui_accept'):
        Utils.set_scene(self, 'LoopScene')
        sfx_player.on_action_select.emit()
    elif Op.xor(is_inverted, event.is_action_pressed('ui_left')):
        game_over_rot('MenuScene', Quats.menu_quat_left())
    elif Op.xor(is_inverted, event.is_action_pressed('ui_right')):
        game_over_rot('LoopScene', Quats.menu_quat_left().inverse())

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    if not controlledNode:
        update_controlled_node()
        return
    if game_state_manager.game_state == GameStateManager.GameState.GAME_END:
        return
    if G.settings.CONTROL_TYPE == "FACE_LOCK":
        FaceLock.handle_face_lock_input(controlledNode)
    else:
        handle_free_spin_input(delta)

func handle_free_spin_input(delta: float):
    var rotation: Quaternion
    var rs := ROTATION_SPEED / 10. * delta
    var is_inverted = G.settings.IS_CONTROL_INVERTED

    if Input.is_action_pressed("ui_up"):
        rotation = rotation * Quaternion(0, 0, -rs, 1, )
    if Input.is_action_pressed("ui_down"):
        rotation = rotation * Quaternion(0, 0, rs, 1, )
    if Op.xor(is_inverted, Input.is_action_pressed("ui_right")):
        rotation = rotation * Quaternion(0, rs, 0, 1, )
    if Op.xor(is_inverted, Input.is_action_pressed("ui_left")):
        rotation = rotation * Quaternion(0, -rs, 0, 1, )
    if controlledNode and rotation:
        var t = rotation.normalized() * controlledNode.quaternion
        controlledNode.transform.basis = Basis(t).orthonormalized()
