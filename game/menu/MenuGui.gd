extends Node
class_name MenuGui

@onready var debug_stats_container: DebugStatsContainer = %DebugStatsContainer
@onready var common_controls: CommonControls = %CommonControls
@onready var section_title: Label = $SectionTitle
var modifier_description: Label
var modifier_card: PanelContainer


func _ready() -> void:
    modifier_card = PanelContainer.new()
    add_child(modifier_card)
    modifier_card.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_RIGHT)
    modifier_card.grow_vertical = Control.GROW_DIRECTION_BEGIN
    modifier_card.offset_left = -440
    modifier_card.offset_right = -24
    modifier_card.offset_top = -240
    modifier_card.offset_bottom = -24
    modifier_card.mouse_filter = Control.MOUSE_FILTER_IGNORE
    modifier_card.add_theme_stylebox_override(
        "panel",
        preload("res://game/ui/goal_card_style.tres"),
    )
    modifier_description = Label.new()
    modifier_description.mouse_filter = Control.MOUSE_FILTER_IGNORE
    modifier_description.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
    modifier_description.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
    modifier_description.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    modifier_description.add_theme_font_size_override("font_size", 18)
    modifier_description.theme = section_title.theme
    modifier_card.add_child(modifier_description)
    modifier_card.hide()

    common_controls.toggle_debug_stats.connect(_on_debug_stats_toggle)
    if G.settings.SHOW_DEBUG_STATS:
        debug_stats_container.show()
    else:
        debug_stats_container.hide()


func _on_debug_stats_toggle(v: bool):
    DebugStatsContainer.toggle(v, debug_stats_container)


func show_modifier_description(description: String) -> void:
    modifier_description.text = description
    modifier_card.visible = not description.is_empty()
