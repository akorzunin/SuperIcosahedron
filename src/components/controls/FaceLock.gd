extends RefCounted
class_name FaceLock

## time to transfrom from one face to another in seconds
const ROTATION_TIME := 0.1

## magic numbers
const a := 0.301
const b := 0.504
const c := 0.808


## alt vaersion of magic numbers
const a1 := 0.488
const b1 := 0.873

## quat represents rotation to up-left face
const left_q := Quaternion(-a, b, 0, c)
## quat represents rotation to mid-down face
const down_q := Quaternion(0, 0, -a1, b1)
## quat represents rotation to down-left face
const alt_q := Quaternion(0.515479, 0.282345, -0.400652, 0.702881)

static func face_lock_transform(q: Quaternion, m: MeshIcosahedron):
    var tw := m.create_tween()
    var rot := q * m.quaternion
    tw.tween_property(m, 'quaternion', rot.normalized(), ROTATION_TIME)
    tw.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
    tw.tween_callback(func(): m.is_rotating = false)
    m.is_rotating = true
    tw.play()


static func handle_face_lock_input(controlledNode: MeshIcosahedron):
    if controlledNode.is_rotating:
        return
    var q: Quaternion
    if Input.is_action_just_pressed("ui_up"):
        if not controlledNode.is_alt:
            return
        q = down_q.normalized().inverse()
        controlledNode.is_alt = false
    if Input.is_action_just_pressed("ui_down"):
        if controlledNode.is_alt:
            return
        q = down_q.normalized()
        controlledNode.is_alt = true
    if Input.is_action_just_pressed('ui_left'):
        # R:TODO refactor later
        if not G.settings.IS_CONTROL_INVERTED:
            if not controlledNode.is_alt:
                q = left_q.normalized()
            else:
                q = alt_q * down_q.normalized().inverse()
        else:
            if not controlledNode.is_alt:
                q = left_q.normalized().inverse()
            else:
                q = (alt_q * down_q.normalized().inverse()).inverse()
    if Input.is_action_just_pressed('ui_right'):
        if not G.settings.IS_CONTROL_INVERTED:
            if not controlledNode.is_alt:
                q = left_q.normalized().inverse()
            else:
                q = (alt_q * down_q.normalized().inverse()).inverse()
        else:
            if not controlledNode.is_alt:
                q = left_q.normalized()
            else:
                q = alt_q * down_q.normalized().inverse()

    if not q:
        return
    face_lock_transform(q, controlledNode)
    return
