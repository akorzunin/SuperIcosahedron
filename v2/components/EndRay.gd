@tool
extends RayCast3D
class_name EndRay

## vactor that points at EndGame marker
var pass_vec: Vector3

func _ready():
    target_position = -global_position
    pass_vec = Vector3(0, -target_position.y, -target_position.z).normalized()
    pass

func _physics_process(delta):
    var node = get_collider()
    if not node:
        return
    if not node.has_method("get_cutplane_vector"):
        return
    var v = node.get_cutplane_vector()
    var miss_angle := pass_vec.angle_to(v)
    var p = get_collision_point()
    var d = global_position.distance_squared_to(p)
    var a = check_angle(v)
    if a == AngleType.ANGLE_GOOD:
        $'../../LoopControls'.angle_good()
        pass
    if d < 0.05 and not a:
        game_over()
    $'../../Gui/GameStatePanel/VBoxContainer/HFlowContainer/GameStateLabel'.set_text("%f" % miss_angle)
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
    if Utils.main_scene(self) == 'LoopScene':
        get_tree().paused = true
        return
    Utils.set_scene(self, 'MenuScene')
