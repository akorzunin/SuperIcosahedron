@tool
extends RayCast3D
class_name EndRay

@onready var loop_controls: LoopControls = $'../../LoopControls'
@onready var gui: LoopGui = $'../../Gui'
@onready var game_state_manager: GameStateManager = %GameStateManager
@onready var sfx_player: SfxPlayer = $"/root/MainScene/SfxPlayer"

## vactor that points at EndGame marker
var pass_vec: Vector3
var MIN_END_DISTANCE := 0.05

func _ready():
    target_position = -global_position
    pass_vec = Vector3(0, -target_position.y, -target_position.z).normalized()
    pass

func _physics_process(delta):
    var node = get_collider() as Collider
    if not node or not node is Collider:
        return
    var v = node.get_cutplane_vector()
    var miss_angle := pass_vec.angle_to(v)
    var p = get_collision_point()
    var dist = global_position.distance_squared_to(p)
    var angle = check_angle(v)
    if angle == AngleType.ANGLE_GOOD:
        loop_controls.pass_next_node(node)
    if dist < MIN_END_DISTANCE:
        if angle == AngleType.ANGLE_WRONG:
            game_over()
        if angle == AngleType.ANGLE_OK:
            loop_controls.pass_next_node(node)

    gui.debug_stats_container.angle.label_text = str(miss_angle)
    pass

enum AngleType {ANGLE_WRONG, ANGLE_OK, ANGLE_GOOD}

func check_angle(v: Vector3) -> AngleType:
    var a = AngleType
    if pass_vec.angle_to(v) < 0.2:
        return a.ANGLE_GOOD
    if pass_vec.angle_to(v) < 0.5:
        return a.ANGLE_OK
    return a.ANGLE_WRONG

func game_over():
    var gs := GameStateManager.GameState
    if game_state_manager.game_state == gs.GAME_END:
        return
    game_state_manager.game_state_changed.emit(game_state_manager.game_state, gs.GAME_END)
    sfx_player.on_section_select.emit()
    if Utils.main_scene(self) == 'LoopScene':
        get_tree().paused = true
        return
