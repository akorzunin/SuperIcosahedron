extends Node
class_name MenuGui

@onready var debug_stats_container: DebugStatsContainer = %DebugStatsContainer
@onready var common_controls: CommonControls = %CommonControls
@onready var section_title: Label = $SectionTitle
var modifier_description: Label

func _ready() -> void:
    modifier_description = Label.new()
    modifier_description.set_anchors_preset(Control.PRESET_TOP_WIDE)
    modifier_description.offset_top = 68
    modifier_description.offset_bottom = 124
    modifier_description.mouse_filter = Control.MOUSE_FILTER_IGNORE
    modifier_description.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    modifier_description.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
    modifier_description.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    modifier_description.add_theme_font_size_override("font_size", 18)
    modifier_description.theme = section_title.theme
    add_child(modifier_description)
    modifier_description.hide()

    common_controls.toggle_debug_stats.connect(_on_debug_stats_toggle)
    if G.settings.SHOW_DEBUG_STATS:
        debug_stats_container.show()
    else:
        debug_stats_container.hide()

func _on_debug_stats_toggle(v: bool):
    DebugStatsContainer.toggle(v, debug_stats_container)

func show_modifier_description(description: String) -> void:
    modifier_description.text = description
    modifier_description.visible = not description.is_empty()
