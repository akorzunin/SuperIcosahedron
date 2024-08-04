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
    if err == Error.ERR_FILE_CANT_OPEN:
        push_error("Cant open config file")
    if err != Error.OK:
        push_warning("config file not found creating default one")
        set_default_config_values(config)
        config.save(file)
        return config
    update_keys(config, file)
    return config

## If key exist in default config then we need to write in in user config
static func update_keys(config: ConfigFile, file: String):
    var given_d := config_to_kv(config)
    var default_d: Dictionary = load("res://src/components/settings/DefaultConfig.gd").settings
    for section in default_d.keys():
        for key in default_d[section]:
            if not given_d.has(key):
                SettingsConfig.write_key(file, section, key, default_d[section][key])
                config.set_value(section, key, default_d[section][key])

static func set_default_config_values(config: ConfigFile) -> ConfigFile:
    var default_config = ConfigFile.new()
    var settings: Dictionary = load("res://src/components/settings/DefaultConfig.gd").settings
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
        if d[section] is Dictionary:
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
