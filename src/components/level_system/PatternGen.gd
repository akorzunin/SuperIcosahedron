extends Node
class_name PatternGen

const MAX_LEVEL := 10
enum SpawnMode {TUTORIAL, DEBUG, QUEUE}

@export var level: int = 0:
    set(val):
        level = clamp(0, MAX_LEVEL, val)

var level_queue := LevelQueue.new()

func _ready():
    G.level_changed.connect(_on_level_changed)
    var l = G.data.get("level")
    if l:
        level = l
    add_patterns()

func _on_level_changed(new_level: int):
    var new_gs = LevelPatterns.levels[new_level].get("game_speed")
    if new_gs:
        G.settings.GAME_SPEED = new_gs
        G.reload_settings.emit()
    level = new_level

func next_pattern() -> int:
    if level_queue.length <= 0:
        add_patterns()
    return level_queue.next_item()

func add_patterns():
    var current_level: Dictionary = LevelPatterns.levels[level]
    if current_level.get("random"):
        var random_pattern: int = current_level.level_patterns.pick_random()
        queue_pattern(random_pattern)
        return

    for pattern in current_level.level_patterns:
        queue_pattern(pattern)

func queue_pattern(pattern: int):
    for type in LevelPatterns.patterns[pattern]:
        level_queue.add_item(type)
