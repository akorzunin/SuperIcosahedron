extends RefCounted
class_name LevelPatterns

const patterns: Dictionary = {
    0: [19, 18],
    1: [17, 18],
    2: [19, 17],
    # level 1
    3: [17, 19, 14], # 1 motion
    4: [2, 3], # 2 simple motions
    5: [13, 7], # 2 motions
    # level 2
    6: [15, 1, 2],
    7: [12, 8],
    8: [6, 16],
}

const levels: Dictionary = {
    0: {
        level_patterns = [0, 1, 2],
        random = false,
    },
    1: {
        level_patterns = [3, 4, 5],
        random = true,
        # game_speed = 20,
    },
    2: {
        level_patterns = [6, 7, 8],
        random = true,
        # game_speed = 10,
    }
}

static func is_level_up(nodes: int, level: int) -> bool:
    match level:
        0: return nodes > 10
        1: return nodes > 20
        _: return false

const tutorial_item := {
    name = "tutorial",
    action = "menu_start_game",
    level = 0,
}

static func get_menu_levels(max_level: int):
    if max_level == 0:
        return {1: tutorial_item }
    var menu_entries = {}
    for i in range(max_level, 0, -1):
        menu_entries[max_level - i + 1] = {
            name = "level %s" % i,
            action = "menu_start_game",
            level = i,
        }
    menu_entries[6] = tutorial_item

    return menu_entries
