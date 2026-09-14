extends CanvasLayer
class_name ModifierLibrary

const PAGE_SIZE := 4
var page := 0
var entries: Array = []
var cards: VBoxContainer
var page_label: Label
var previous: Button
var next: Button
var close_button: Button

func _ready() -> void:
    layer = 10
    var background := PanelContainer.new()
    background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    add_child(background)
    var margin := MarginContainer.new()
    for side in ["left", "right", "top", "bottom"]:
        margin.add_theme_constant_override("margin_" + side, 24)
    background.add_child(margin)
    var column := VBoxContainer.new()
    column.add_theme_constant_override("separation", 16)
    margin.add_child(column)
    var title := Label.new()
    title.text = "MODIFIERS LIBRARY"
    title.add_theme_font_size_override("font_size", 28)
    column.add_child(title)
    var scroll := ScrollContainer.new()
    scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
    column.add_child(scroll)
    cards = VBoxContainer.new()
    cards.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    cards.add_theme_constant_override("separation", 20)
    scroll.add_child(cards)
    var navigation := HBoxContainer.new()
    column.add_child(navigation)
    previous = Button.new()
    previous.text = "Previous"
    previous.pressed.connect(func(): show_page(page - 1))
    navigation.add_child(previous)
    page_label = Label.new()
    page_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    page_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    navigation.add_child(page_label)
    next = Button.new()
    next.text = "Next"
    next.pressed.connect(func(): show_page(page + 1))
    navigation.add_child(next)
    close_button = Button.new()
    close_button.text = "Back"
    close_button.pressed.connect(queue_free)
    column.add_child(close_button)
    entries = UpgradeCatalog.data.pickups.filter(func(entry): return G.discovered_modifiers.has(entry.id))
    show_page(0)
    close_button.grab_focus()

func show_page(index: int) -> void:
    var pages := maxi(1, ceili(float(entries.size()) / PAGE_SIZE))
    page = clampi(index, 0, pages - 1)
    for child in cards.get_children():
        cards.remove_child(child)
        child.queue_free()
    if entries.is_empty():
        var empty := Label.new()
        empty.text = "No modifiers discovered yet. Collect modifiers during a run to open them here."
        empty.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
        cards.add_child(empty)
    for entry in entries.slice(page * PAGE_SIZE, (page + 1) * PAGE_SIZE):
        var label := Label.new()
        label.text = "%s\n%s" % [entry.title, entry.get("description", "")]
        label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
        label.add_theme_color_override("font_color", Color(entry.color))
        cards.add_child(label)
    page_label.text = "%d / %d · %d discovered" % [page + 1, pages, entries.size()]
    previous.disabled = page == 0
    next.disabled = page == pages - 1
    if (previous.disabled and previous.has_focus()) or (next.disabled and next.has_focus()):
        close_button.grab_focus()

func _input(event: InputEvent) -> void:
    if event.is_action_pressed("ui_cancel"):
        get_viewport().set_input_as_handled()
        queue_free()
