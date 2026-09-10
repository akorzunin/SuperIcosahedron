extends GutTest

const TEMP := "user://gut_gameplay_settings.cfg"

func after_each() -> void:
    if FileAccess.file_exists(TEMP):
        DirAccess.remove_absolute(TEMP)

func test_json_is_the_runtime_source_of_gameplay_defaults() -> void:
    var source: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(DafaultConfig.GAMEPLAY_PATH))
    var runtime := SettingsConfig.config_to_dict(SettingsConfig.set_default_config_values(ConfigFile.new()))
    assert_true(DafaultConfig.valid_gameplay_data(source))
    for key in source.game_settings:
        assert_eq(float(runtime[key]), float(source.game_settings[key]), key)
        assert_eq(runtime[key], runtime.game_settings[key])
    assert_typeof(runtime.SPAWN_MODE, TYPE_INT)
    assert_typeof(runtime.MAX_LEVEL, TYPE_INT)

func test_legacy_gameplay_overrides_are_removed_but_preferences_survive() -> void:
    var old := ConfigFile.new()
    old.set_value("game_settings", "GAME_SPEED", 0)
    old.set_value("game_settings", "SPAWN_MODE", 1)
    old.set_value("user_settings", "MUSIC_ENABLED", false)
    old.set_value("user_settings", "IS_CONTROL_INVERTED", true)
    assert_eq(old.save(TEMP), OK)
    var runtime := SettingsConfig.load_gs(TEMP)
    var expected := DafaultConfig.load_game_settings()
    assert_eq(runtime.GAME_SPEED, expected.GAME_SPEED)
    assert_eq(runtime.SPAWN_MODE, expected.SPAWN_MODE)
    assert_false(runtime.MUSIC_ENABLED)
    assert_true(runtime.IS_CONTROL_INVERTED)
    var saved := ConfigFile.new()
    assert_eq(saved.load(TEMP), OK)
    assert_false(saved.has_section("game_settings"))
    assert_false(saved.get_value("user_settings", "MUSIC_ENABLED"))
    assert_true(saved.has_section_key("user_settings", "SFX_ENABLED"))
    assert_eq(SettingsConfig.load_gs(TEMP), runtime, "Loading migrated preferences is idempotent")

func test_new_and_exported_user_configs_do_not_persist_gameplay() -> void:
    var runtime := SettingsConfig.load_gs(TEMP)
    assert_true(runtime.has("GAME_SPEED"))
    var saved := ConfigFile.new()
    assert_eq(saved.load(TEMP), OK)
    assert_false(saved.has_section("game_settings"))
    assert_true(saved.has_section("user_settings"))
    var exported := SettingsConfig.dict_to_config(runtime)
    assert_false(exported.has_section("game_settings"))
    assert_eq(exported.get_value("user_settings", "CONTROL_TYPE"), runtime.CONTROL_TYPE)

func test_invalid_gameplay_values_are_rejected() -> void:
    var source: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(DafaultConfig.GAMEPLAY_PATH))
    for key in source.game_settings:
        var invalid := source.duplicate(true)
        invalid.game_settings.erase(key)
        assert_false(DafaultConfig.valid_gameplay_data(invalid), "Missing " + key)
        invalid.game_settings[key] = "10"
        assert_false(DafaultConfig.valid_gameplay_data(invalid), "String " + key)
        invalid.game_settings[key] = -1
        assert_false(DafaultConfig.valid_gameplay_data(invalid), "Negative " + key)
    for key in ["GAME_SPEED", "SPAWN_SPEED", "SCALE_FACTOR"]:
        var invalid := source.duplicate(true)
        invalid.game_settings[key] = 0
        assert_false(DafaultConfig.valid_gameplay_data(invalid), "Zero " + key)
    for pair in [["SPAWN_MODE", 3], ["MAX_LEVEL", 11], ["SPAWN_MODE", 1.5], ["GAME_SPEED", INF]]:
        var invalid := source.duplicate(true)
        invalid.game_settings[pair[0]] = pair[1]
        assert_false(DafaultConfig.valid_gameplay_data(invalid))
    source.game_settings.GAME_SPEED = 12.5
    assert_true(DafaultConfig.valid_gameplay_data(source), "Fractional speeds are supported")
    source.schema_version = 2
    assert_false(DafaultConfig.valid_gameplay_data(source))
    assert_false(DafaultConfig.valid_gameplay_data(null))
