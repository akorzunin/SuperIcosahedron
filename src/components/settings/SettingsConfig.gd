extends RefCounted
class_name SettingsConfig

var score_data = {}
var config = ConfigFile.new()
const config_path = "user://settings.cfg"

# Load data from a file.
func load_config() -> ConfigFile:
    var err = config.load(config_path)
    if err == Error.ERR_FILE_CANT_OPEN:
        push_error("Cant open config file")
    if err != Error.OK:
        push_warning("config file not found creating default one")
        var default_config = get_default_config()
        default_config.save(config_path)
        return default_config
    return config

func get_default_config():
    var _config = ConfigFile.new()
    _config.set_value("aboba", "123", 123123)
    return _config

var S = {
    game_settings = {
        gameplay = {
            despawner_mode = {
                type = GameSettings.DespawneMode,
                value = GameSettings.DespawneMode.NORMAL,
                default_value = GameSettings.DespawneMode.NORMAL,
            }
        }
    },
    user_settings = {
        ui = {
            fps_counter = {
                type = "bool",
                value = true,
                default_value = true,
            }
        }
    }
}
