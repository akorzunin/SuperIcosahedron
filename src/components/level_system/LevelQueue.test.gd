#!/usr/bin/env -S godot --headless -s --quit
extends SceneTree

func test1():
    var q := LevelQueue.new()
    q.add_item(1)
    for i in 2:
        print_debug(q.next_item())
    q.free()

func test2():
    var q := LevelQueue.new()
    var n := 1_000
    print_debug("added: ", n, " items")
    for i in n:
        q.add_item(1)
    for i in n:
        q.next_item()

    q.free()

func test3():
    var q := LevelQueue.new()
    q.add_item(1)
    q.add_items([ 2, 3, 4])
    q.print_members()
    for i in q.length:
        print_debug("taking item: ", q.next_item())

    q.free()

func test4():
    var q := LevelQueue.new()
    q.add_item(1)
    q.add_item(2)
    q.add_item(3)
    q.add_item(4)
    q.print_members()
    for i in 2:
        print_debug("taking item: ", q.next_item())
    q.add_item(5)
    q.add_item(6)
    q.print_members()
    for i in q.length:
        print_debug("taking item: ", q.next_item())

    q.free()

func test5():
    var q := LevelQueue.new()
    q.add_item(1)
    q.add_item(2)
    q.add_item(3)
    q.print_members()
    q.free()

func main():
    var a := get_method_list()
    for m in a:
        if m.name.begins_with("test"):
            print_debug("running test: ", m.name)
            call(m.name)
            print_debug("test complete: ", m.name)

func _init():
    main()
    quit()
