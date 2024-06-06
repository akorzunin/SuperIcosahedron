#!/usr/bin/env -S godot --headless -s
extends SceneTree

var q = Quaternion()
var right_q = Quaternion(0, -0.504, -0.301, -0.808, )
var right_q_norm = Quaternion(0, -0.504, -0.301, -0.808, ).normalized()

func _init():
    print_debug(q, q.is_normalized())
    print_debug("---")
    # cant inverse not normalized quats
    print_debug(right_q, right_q.normalized(), right_q.normalized().inverse())
    print_debug("---")
    prints(q.get_angle(), right_q_norm.get_angle(), q.angle_to(right_q_norm))
    print_debug("---")
    prints(right_q_norm.angle_to(right_q_norm.inverse()))
    quit()
