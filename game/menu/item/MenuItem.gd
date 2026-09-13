extends Node3D
class_name MenuItem

@onready var label_3d: Label3D = $Label3D

const HEX_FONT := preload("res://game/game-assets/fonts/plastic-bag/Plastic Bag.otf")
const EMOJI_FONT := preload("res://game/game-assets/fonts/noto-color-emoji/NotoColorEmoji-Regular.ttf")
const CURRENT_OPTION_COLOR := Color(1.0, 0.8, 0.2, 1.0)

var pos: int
var label_text: String
var action: String
var items: Dictionary


func init(props: Dictionary):
    pos = props.get("pos", 0)
    items = props.val
    label_text = items.get("name", "placeholder")
    action = items.get("action", "placeholder_action")

    return self
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    G.font_changed.connect(_on_font_changed)
    self.add_to_group("menu_item")
    label_3d.text = label_text
    _update_render_scale_label()
    label_3d.font = HEX_FONT
    if items.get("is_current", false):
        label_3d.modulate = CURRENT_OPTION_COLOR
    var t = Quats.menu_quat_left()
    var y = Quats.menu_quat_down().inverse()
    match pos:
        1:
            pass
        2:
            transform.basis = Basis(t)
        3:
            transform.basis = Basis(t * t)
        4:
            transform.basis = Basis(t * t * t)
        5:
            transform.basis = Basis(t * t * t * t)
        6:
            transform.basis = Basis(y)
        7:
            transform.basis = Basis(Quats.easter_egg_quat)

func _update_render_scale_label() -> void:
    if action == "settings_cycle_render_scale":
        label_3d.text = "3d scale\n%d%%" % G.settings.get("RENDER_SCALE_PERCENT", 100)

func _process(_delta: float) -> void:
    _update_render_scale_label()
    var setting: String = items.get("setting", "")
    if setting.is_empty() or not G.settings.has(setting):
        return
    label_3d.modulate = CURRENT_OPTION_COLOR if \
        items.get("value", null) == G.settings[setting] else Color.WHITE

func _on_font_changed(new_font: G.FontType):
    match new_font:
        G.FontType.HEX:
            label_3d.font = HEX_FONT
        G.FontType.EMOJI:
            label_3d.font = EMOJI_FONT
        _:
            return
