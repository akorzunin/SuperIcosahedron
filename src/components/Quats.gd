extends Node
class_name Quats

static func menu_quat_left():
    return Quaternion(0, 0.504, 0.301, 0.808, ).normalized()

static func menu_quat_down():
    return Quaternion(-0.342, 0, 0, 0.939, ).normalized()

static var easter_egg_quat := Quaternion(0.937, -0.142, -0.276, 0.161).normalized()
