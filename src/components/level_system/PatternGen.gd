extends Node
class_name PatternGen

var level_queue := LevelQueue.new()

const MAX_LEVEL := 10

enum SpawnMode {TUTORIAL, DEBUG, QUEUE}

@export var level := 0:
    set(val):
        level = clamp(0, MAX_LEVEL, val)


func _ready():
    add_patterns()

func upgrade_level():
    level += 1

func downgrade_level():
    level -= 1

func next_pattern() -> int:
    if level_queue.length <= 0:
        add_patterns()
    return level_queue.next_item()


func add_patterns():
    var current_level: Dictionary = LevelPatterns.levels[level]
    if current_level.get("random"):
        var p: int = current_level.level_patterns.pick_random()
        for i in LevelPatterns.patterns[p]:
            level_queue.add_item(i)
    else:
        for pattern in current_level.level_patterns:
            for type in LevelPatterns.patterns[pattern]:
                level_queue.add_item(type)

func update_patterns_based_on_level():
    # Clear the queue to avoid mixing patterns from different levels
    level_queue.items_queue.clear()
    # Add patterns corresponding to the current level
    add_patterns()
