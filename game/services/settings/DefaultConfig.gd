extends RefCounted
class_name DafaultConfig

const GAMEPLAY_PATH := "res://game/gameplay/config/gameplay.json"

static var settings: Dictionary:
    get:
        return {"game_settings": load_game_settings(), "user_settings": USER_SETTINGS.duplicate()}

const USER_SETTINGS = {
    FPS_COUNTER_ENABLED=true,
    SHOW_DEBUG_STATS=false,
    MUSIC_ENABLED=true,
    SFX_ENABLED=true,
    FULLSCREEN_ENABLED=true,
    VSYNC_ENABLED=true,
    CONTROL_TYPE="FREE_SPIN",
    IS_CONTROL_INVERTED=false,
}

static func valid_gameplay_data(data: Variant) -> bool:
    if not data is Dictionary or data.get("schema_version") != 1:
        return false
    var values: Variant = data.get("game_settings")
    if not values is Dictionary:
        return false
    for key in ["SPAWN_MODE", "DESPAWNER_MODE", "SCALE_FACTOR", "SPAWN_SPEED",
            "GAME_SPEED", "ROTATION_SPEED", "MAX_LEVEL"]:
        var value: Variant = values.get(key)
        if not (value is float or value is int) or not is_finite(float(value)):
            return false
        if value < 0:
            return false
    for key in ["SPAWN_MODE", "MAX_LEVEL"]:
        if values[key] != floor(values[key]):
            return false
    return values.SPAWN_MODE <= 2 and values.MAX_LEVEL <= 10 and \
        values.GAME_SPEED > 0 and values.SPAWN_SPEED > 0 and values.SCALE_FACTOR > 0

static func load_game_settings() -> Dictionary:
    var data: Variant = JSON.parse_string(FileAccess.get_file_as_string(GAMEPLAY_PATH))
    assert(valid_gameplay_data(data), "Invalid gameplay catalog: " + GAMEPLAY_PATH)
    var values: Dictionary = data.game_settings
    # JSON numbers are floats; these settings are used as enum/index values.
    values.SPAWN_MODE = int(values.SPAWN_MODE)
    values.MAX_LEVEL = int(values.MAX_LEVEL)
    return values
