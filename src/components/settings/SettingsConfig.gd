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
    return config

static func set_default_config_values(config: ConfigFile) -> ConfigFile:
    var default_config = ConfigFile.new()
    var settings: Dictionary = load("res://src/components/settings/DefaultConfig.gd").settings
    for section in settings.keys():
        if settings[section] is Dictionary:
            for key in settings[section].keys():
                config.set_value(section, key, settings[section][key])
    return config

static func config_to_dict(config: ConfigFile):
    var d = {}
    for section in config.get_sections():
        d[section] = {}
        for key in config.get_section_keys(section):
            d[section][key] = config.get_value(section, key)
            d[key] = config.get_value(section, key)
    return d
