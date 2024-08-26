extends RefCounted
class_name LevelPatterns

const patterns: Dictionary = {
    0: [19, 18],
    1: [17, 18],
    2: [19, 17],
    3: [17, 17, 17],
    4: [19, 19],
}

const levels: Dictionary = {
    0: {
        level_patterns = [0, 1, 2],
        random = false,
    },
    1: {
        level_patterns = [3, 4],
        random = true,
    }
}
