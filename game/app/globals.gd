extends Node
class_name Globals

const theme = preload("res://game/game-assets/themes/TwTheme.gd").T
const tw = preload('res://game/game-assets/colors/TwColors.gd').tw
# Default values for whole project
var D = {
    init_pos = Quaternion(0, 0.707, 0, 0.707).normalized(),
}
var data := {}
## has to be empty
var settings := {}

const PROGRESS_PATH := "user://progress.cfg"
var unlocked_difficulty := 0
var discovered_modifiers: Array = []

func _ready() -> void:
    var saved := ConfigFile.new()
    if saved.load(PROGRESS_PATH) == OK:
        var discoveries: Variant = saved.get_value("progress", "discovered_modifiers", [])
        if discoveries is Array:
            discovered_modifiers = discoveries
        unlocked_difficulty = clampi(int(saved.get_value("progress", "unlocked_difficulty", 0)), 0, UpgradeCatalog.data.difficulty_levels.size())

func unlock_difficulty(level: int) -> void:
    level = clampi(level, 0, UpgradeCatalog.data.difficulty_levels.size())
    if level <= unlocked_difficulty:
        return
    unlocked_difficulty = level
    save_progress()

func discover_modifier(id: String) -> void:
    if discovered_modifiers.has(id) or not UpgradeCatalog.data.pickups.any(func(entry): return entry.id == id):
        return
    discovered_modifiers.append(id)
    save_progress()

func save_progress() -> void:
    var saved := ConfigFile.new()
    saved.set_value("progress", "discovered_modifiers", discovered_modifiers)
    saved.set_value("progress", "unlocked_difficulty", unlocked_difficulty)
    var error := saved.save(PROGRESS_PATH)
    if error != OK:
        push_warning("Could not save difficulty progress: %s" % error)

func reset_progress(path := PROGRESS_PATH) -> Error:
    var saved := ConfigFile.new()
    saved.set_value("progress", "unlocked_difficulty", 0)
    saved.set_value("progress", "discovered_modifiers", [])
    var error := saved.save(path)
    if error != OK:
        return error
    unlocked_difficulty = 0
    discovered_modifiers.clear()
    data.clear()
    return OK

# global signals
enum FontType {HEX, EMOJI}
@warning_ignore("unused_signal")
signal font_changed(new_font: FontType)

@warning_ignore("unused_signal")
signal level_changed(new_level: int)

@warning_ignore("unused_signal")
signal reload_settings()
