#!/usr/bin/env -S godot -s
extends SceneTree

func format_time(time: int) -> String:
    var ms := time % 1000
    var sec := time / 1000
    return "%03d:%03d" % [sec, ms]

func _init():
    print("start")
    #var a := create_timer(1.0)
    var a = create_timer(2.3)
    var time_start = Time.get_ticks_msec()
    print_debug(time_start)
    await a.timeout
    var time_now = Time.get_ticks_msec() - time_start
    print_debug(time_now)
    print_debug(format_time(time_now))

    print("end")
    quit()
