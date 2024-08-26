extends Node
class_name Globals

const theme = preload("res://src/themes/TwTheme.gd").T
const tw = preload('res://src/components/colors/TwColors.gd').tw
# Default values for whole project
var D = {
    init_pos = Quaternion(0, 0.707, 0, 0.707).normalized(),
}
var data := {}
var settings := {
    SCALE_FACTOR = DafaultConfig.settings.game_settings.SCALE_FACTOR,
    ROTATION_SPEED = DafaultConfig.settings.game_settings.ROTATION_SPEED,
}

# global signals
enum FontType {HEX, EMOJI}
@warning_ignore("unused_signal")
signal font_changed(new_font: FontType)
