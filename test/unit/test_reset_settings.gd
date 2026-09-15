extends GutTest

const TEMP := "user://gut_reset_settings.cfg"
var previous_settings: Dictionary
var previous_data: Dictionary
var previous_unlock: int


func before_each() -> void:
    previous_settings = G.settings.duplicate(true)
    previous_data = G.data.duplicate(true)
    previous_unlock = G.unlocked_difficulty


func after_each() -> void:
    G.settings = previous_settings
    G.data = previous_data
    G.unlocked_difficulty = previous_unlock
    if FileAccess.file_exists(TEMP):
        DirAccess.remove_absolute(TEMP)


func test_reset_defaults_preserves_progress() -> void:
    var config := Config.new()
    config.config = TEMP
    add_child_autofree(config)
    SettingsConfig.load_gs(TEMP)
    config.set_music_state(false)
    config.set_render_scale(20)
    G.unlocked_difficulty = 3
    G.data = { level = 2 }
    assert_eq(config.reset_user_settings(), OK)
    assert_eq(G.settings.user_settings, DafaultConfig.settings.user_settings)
    assert_eq(SettingsConfig.load_gs(TEMP), G.settings)
    assert_eq(G.unlocked_difficulty, 3)
    assert_eq(G.data, { level = 2 })
    var saved := ConfigFile.new()
    saved.load(TEMP)
    assert_false(saved.has_section("game_settings"))


func test_reset_progress_preserves_settings() -> void:
    G.unlocked_difficulty = 3
    G.data = { level = 2, selected_difficulty = 2 }
    assert_eq(G.reset_progress(TEMP), OK)
    assert_eq(G.unlocked_difficulty, 0)
    assert_eq(G.data, { })
    assert_eq(G.settings, previous_settings)
    var saved := ConfigFile.new()
    assert_eq(saved.load(TEMP), OK)
    assert_eq(saved.get_value("progress", "unlocked_difficulty"), 0)


func test_confirmation_has_one_action_and_automatic_back() -> void:
    var spawner := MenuSpawner.new()
    autofree(spawner)
    for index in [6, 7]:
        var section: Dictionary = MenuStruct.settings_items[index].duplicate(true)
        assert_false(section.has("options"), "No redundant option title button")
        spawner.add_back_button(section)
        assert_eq(section.items.size(), 2)
        assert_true(section.items[1].action.begins_with("settings_reset_"))
        assert_eq(section.items[5].action, "menu_back")
