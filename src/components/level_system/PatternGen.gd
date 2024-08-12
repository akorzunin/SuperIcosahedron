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

func next_pattern() -> Dictionary:
    return level_queue.next_item()

func initialize_patterns():
    # Example initialization of patterns_struct
    patterns_struct = {
        1: [ {name = "Easy Pattern", difficulty = 1}],
        2: [ {name = "Medium Pattern", difficulty = 2}, {name = "Another Medium Pattern", difficulty = 2}],
        # Add more levels and patterns as needed
    }

func add_pattern():
    var current_level_patterns = patterns_struct[level]
    if current_level_patterns != null:
        for pattern in current_level_patterns:
            level_queue.add_item(pattern)

func update_patterns_based_on_level():
    # Clear the queue to avoid mixing patterns from different levels
    level_queue.items_queue.clear()
    # Add patterns corresponding to the current level
    add_pattern()
