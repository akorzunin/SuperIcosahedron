extends Node

const theme = preload("res://src/themes/BaseTheme.gd").T
const tw = preload('res://src/components/colors/TwColors.gd').tw
# Default values for whole project
var D = {
    init_pos = Quaternion(0, 0.707, 0, 0.707).normalized(),
}
var data := {}
