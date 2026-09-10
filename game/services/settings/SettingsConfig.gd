extends RefCounted
class_name SettingsConfig

const config_path = "user://settings.cfg"

static func load_gs(file: String) -> Dictionary:
    var cfg = load_config(file)
    var d = config_to_dict(cfg)
    return d

## Load data from a file.
static func load_config(file := config_path) -> ConfigFile:
    var config = ConfigFile.new()
    var err = config.load(file)
    if err != Error.OK and err != Error.ERR_FILE_NOT_FOUND and err != Error.ERR_FILE_CANT_OPEN:
        push_warning("Cannot read user settings; restoring defaults: " + file)
    update_keys(config, file)
    return config

## Persist preferences only; old saved gameplay values must not shadow CMS tuning.
static func update_keys(config: ConfigFile, file: String):
    var defaults: Dictionary = DafaultConfig.settings
    var changed := not FileAccess.file_exists(file)
    if config.has_section("game_settings"):
        config.erase_section("game_settings")
        changed = true
    for key in defaults.user_settings:
        if not config.has_section_key("user_settings", key):
            config.set_value("user_settings", key, defaults.user_settings[key])
            changed = true
    if changed:
        var err := config.save(file)
        if err != OK:
            push_warning("Cannot save user settings: " + file)
    # Runtime compatibility: consumers still read G.settings and game_settings.
    for key in defaults.game_settings:
        config.set_value("game_settings", key, defaults.game_settings[key])

static func set_default_config_values(config: ConfigFile) -> ConfigFile:
    var settings: Dictionary = DafaultConfig.settings
    for section in settings.keys():
        if settings[section] is Dictionary:
            for key in settings[section].keys():
                config.set_value(section, key, settings[section][key])
    return config

static func config_to_kv(config: ConfigFile) -> Dictionary:
    var d = {}
    for section in config.get_sections():
        for key in config.get_section_keys(section):
            d[key] = config.get_value(section, key)
    return d

static func config_to_dict(config: ConfigFile) -> Dictionary:
    var d = {}
    for section in config.get_sections():
        d[section] = {}
        for key in config.get_section_keys(section):
            d[section][key] = config.get_value(section, key)
            d[key] = config.get_value(section, key)
    return d

static func dict_to_config(d: Dictionary) -> ConfigFile:
    var config = ConfigFile.new()
    for section in d.keys():
        if section != "game_settings" and d[section] is Dictionary:
            for key in d[section].keys():
                config.set_value(section, key, d[section][key])
    return config

static func write_key(_config_path: String, section: String, key: String, value: Variant) -> Error:
    var c = ConfigFile.new()
    var err := c.load(_config_path)
    if err != OK:
        return err
    c.set_value(section, key, value)
    err = c.save(_config_path)
    if err != OK:
        return err
    return OK
