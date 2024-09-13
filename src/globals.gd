extends Node
class_name Globals

const theme = preload("res://src/themes/TwTheme.gd").T
const tw = preload('res://src/components/colors/TwColors.gd').tw
# Default values for whole project
var D = {
    init_pos = Quaternion(0, 0.707, 0, 0.707).normalized(),
}
var data := {}
## has to be empty
var settings := {}

# global signals
enum FontType {HEX, EMOJI}
@warning_ignore("unused_signal")
signal font_changed(new_font: FontType)

@warning_ignore("unused_signal")
signal level_changed(new_level: int)

@warning_ignore("unused_signal")
signal reload_settings()
