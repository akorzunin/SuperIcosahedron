extends Node
class_name PatternGen

var level_queue: LevelQueue

var patterns_struct: Dictionary = {}

const MAX_LEVEL := 10

var level := 0:
    set(val):
        level = clamp(0, MAX_LEVEL, val)


func _ready():
    add_pattern()

func upgrade_level():
    level += 1

func downgrade_level():
    level -= 1

func next_pattern():
    return
