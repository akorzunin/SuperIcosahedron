#!/usr/bin/env -S godot -s
extends SceneTree

class FooData:
    var name: String
    var type: String

    func _init(name, type):
        self.name = name
        self.type = type

class Foo:
    var a
    func _init(a: FooData):
        self.a = a

func _init():
    print("Hello!")
    var i := Foo.new(FooData.new("pepe", "meme"))
    print(i.a.name)
    quit()
