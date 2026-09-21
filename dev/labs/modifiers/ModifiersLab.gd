extends Control

const RUN_FIELDS := [
    "score",
    "charges_completed",
    "tiers_collected",
    "controls_completed",
    "difficulty",
]
const MOD_FIELDS := [
    "pending",
    "tier",
    "sign_value",
    "points_multiplier",
    "echo_pending",
    "all_in",
    "chain_has_tier",
    "forge_slots",
    "forge_count",
    "forge_kind",
    "forge_value",
    "tier_streak_count",
]

var run_state := RunState.new()
var sequence: Array = []
var cursor := 0
var passage_id := 0
var history: ItemList
var library: VBoxContainer
var selected_modifier := 0
var played: Array = []
var played_starting: Dictionary = { }
var preview: SubViewportContainer
var strength: OptionButton
var description: Label
var state_view: Label
var log_view: TextEdit
var sequence_view: ItemList
var inputs: Dictionary = { }
var tutorial: CheckButton
var message := ""


func _ready() -> void:
    var background := ColorRect.new()
    background.color = Color("18202c")
    background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    background.mouse_filter = Control.MOUSE_FILTER_IGNORE
    add_child(background)
    var margin := MarginContainer.new()
    margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    for edge in ["left", "right", "top", "bottom"]:
        margin.add_theme_constant_override("margin_" + edge, 16)
    add_child(margin)
    var root := VBoxContainer.new()
    margin.add_child(root)
    _label(
        root,
        "MODIFIERS LAB — Space: pass hovered pickup · R: reset · Real RunState passage logic",
    )
    var columns := HBoxContainer.new()
    columns.size_flags_vertical = Control.SIZE_EXPAND_FILL
    root.add_child(columns)
    var left := _column(columns)
    _label(left, "Played passages")
    history = _list(left)
    _label(left, "Replay sequence (select + remove to edit)")
    sequence_view = _list(left)
    _button(left, "Remove selected step", _remove_step)
    _button(left, "Save played as preset + copy", save_played)
    var center := _column(columns)
    _label(center, "Modifier library")
    var preview_toggle := CheckButton.new()
    preview_toggle.name = "PreviewToggle"
    preview_toggle.text = "Show 3D preview (drag / click faces)"
    preview_toggle.button_pressed = false
    preview_toggle.focus_mode = Control.FOCUS_NONE
    center.add_child(preview_toggle)
    preview_toggle.toggled.connect(
        func(visible_preview):
            preview.visible = visible_preview,
    )
    preview = preload("res://dev/labs/modifiers/ModifierPreview.gd").new()
    center.add_child(preview)
    preview.hide()
    preview.modifier_selected.connect(_select_modifier)
    var library_scroll := ScrollContainer.new()
    library_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
    center.add_child(library_scroll)
    library = _column(library_scroll)
    for index in UpgradeCatalog.data.pickups.size():
        var button := Button.new()
        button.text = UpgradeCatalog.data.pickups[index].title
        button.focus_mode = Control.FOCUS_NONE
        button.mouse_entered.connect(_select_modifier.bind(index))
        button.pressed.connect(
            func():
                if selected_modifier != index:
                    _select_modifier(index)
                play_selected(),
        )
        library.add_child(button)
    strength = OptionButton.new()
    strength.focus_mode = Control.FOCUS_NONE
    center.add_child(strength)
    strength.item_selected.connect(
        func(_index):
            preview.select_modifier(selected_modifier, _selected_steps()),
    )
    description = _label(center, "")
    var pickup_actions := HBoxContainer.new()
    center.add_child(pickup_actions)
    _button(pickup_actions, "Play [Space]", play_selected)
    _button(
        pickup_actions,
        "Append to sequence",
        func():
            _append(_selection()),
    )
    var empty_actions := HBoxContainer.new()
    center.add_child(empty_actions)
    _button(
        empty_actions,
        "Empty passage",
        func():
            activate({ "id": "", "steps": -1 }),
    )
    _button(
        empty_actions,
        "Append empty passage",
        func():
            _append({ "id": "", "steps": -1 }),
    )
    var right := _column(columns)
    state_view = _label(right, "")
    _label(right, "Starting state — applied on Reset + replay")
    var scroll := ScrollContainer.new()
    scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
    right.add_child(scroll)
    var fields := VBoxContainer.new()
    fields.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    scroll.add_child(fields)
    for key in RUN_FIELDS + MOD_FIELDS:
        var value: Variant = (
            run_state.get(key)
            if key in RUN_FIELDS
            else run_state \
                    .modifier_system \
                    .get(key)
        )
        var row := HBoxContainer.new()
        fields.add_child(row)
        var label := _label(row, key)
        label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        if value is bool:
            var toggle := CheckButton.new()
            toggle.button_pressed = value
            row.add_child(toggle)
            inputs[key] = toggle
        elif value is String:
            var kind := OptionButton.new()
            for text in ["", "points", "tier"]:
                kind.add_item(text)
            row.add_child(kind)
            inputs[key] = kind
        else:
            var number := SpinBox.new()
            number.min_value = -1000000000 if key == "score" else 0
            number.max_value = 1000000000
            if key == "tier":
                number.min_value = 1
                number.max_value = UpgradeCatalog.data.points_by_tier.size()
            elif key == "sign_value":
                number.min_value = -1
                number.max_value = 1
                number.step = 2
            elif key == "points_multiplier":
                number.min_value = 1
            elif key in ["forge_slots", "forge_count"]:
                number.max_value = 3
            elif key == "tier_streak_count":
                number.max_value = 100
            number.value = value
            row.add_child(number)
            inputs[key] = number
    tutorial = CheckButton.new()
    tutorial.text = "Tutorial condition (passages include confirm)"
    tutorial.toggled.connect(
        func(_value):
            _refresh(),
    )
    root.add_child(tutorial)
    var buttons := HBoxContainer.new()
    root.add_child(buttons)
    var presets := OptionButton.new()
    presets.focus_mode = Control.FOCUS_NONE
    for title in [
        "Edge-case presets…",
        "Echo at max tier",
        "All-in → non-points",
        "Incomplete Forge",
        "Negative score",
        "Completion threshold",
    ]:
        presets.add_item(title)
    presets.item_selected.connect(load_preset)
    buttons.add_child(presets)
    _button(buttons, "Copy repro", copy_repro)
    _button(buttons, "Import clipboard", import_repro)
    _button(buttons, "Reset [R]", reset_fresh)
    _button(buttons, "Reset + replay", replay)
    _button(buttons, "Step sequence", step_sequence)
    _button(
        buttons,
        "Clear sequence",
        func():
            sequence.clear()
            cursor = 0
            _refresh(),
    )
    log_view = TextEdit.new()
    log_view.editable = false
    log_view.custom_minimum_size.y = 120
    root.add_child(log_view)
    run_state.modifier_system.pickup_collected.connect(
        func(text, _color):
            message = text,
    )
    _select_modifier(0)
    reset_state()


func _column(parent: Node) -> VBoxContainer:
    var column := VBoxContainer.new()
    column.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    parent.add_child(column)
    return column


func _label(parent: Node, text: String) -> Label:
    var label := Label.new()
    label.text = text
    label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    parent.add_child(label)
    return label


func _list(parent: Node) -> ItemList:
    var list := ItemList.new()
    list.size_flags_vertical = Control.SIZE_EXPAND_FILL
    list.custom_minimum_size = Vector2(240, 100)
    list.focus_mode = Control.FOCUS_NONE
    parent.add_child(list)
    return list


func _button(parent: Node, text: String, action: Callable) -> void:
    var button := Button.new()
    button.text = text
    button.focus_mode = Control.FOCUS_NONE
    button.pressed.connect(action)
    parent.add_child(button)


func _select_modifier(index: int) -> void:
    selected_modifier = index
    var entry: Dictionary = UpgradeCatalog.data.pickups[index]
    description.text = entry.description
    strength.clear()
    strength.add_item("Default strength: %d" % entry.value, -1)
    for steps in range(int(entry.min_steps), int(entry.max_steps) + 1):
        strength.add_item("%d steps — strength %d" % [steps, entry.value_by_steps[steps]], steps)
    preview.select_modifier(index, -1)


func _selected_steps() -> int:
    return -1 if strength.selected == 0 else strength.get_selected_id()


func _selection() -> Dictionary:
    return { "id": UpgradeCatalog.data.pickups[selected_modifier].id, "steps": _selected_steps() }


func _input(event: InputEvent) -> void:
    if (
        event is InputEventKey and event.pressed and not event.echo
        and event.physical_keycode in [KEY_SPACE, KEY_R]
    ):
        var focus := get_viewport().gui_get_focus_owner()
        if focus is LineEdit or focus is TextEdit:
            return
        if event.physical_keycode == KEY_R:
            reset_fresh()
        else:
            play_selected()
        get_viewport().set_input_as_handled()


func play_selected() -> void:
    activate(_selection())


func snapshot() -> Dictionary:
    var result := { }
    for key in RUN_FIELDS + ["figures_passed"]:
        result[key] = run_state.get(key)
    for key in MOD_FIELDS:
        result[key] = run_state.modifier_system.get(key)
    result["pending_points"] = (
        run_state.modifier_system.pending_points()
        if run_state \
                .modifier_system \
                .pending
        else 0
    )
    result["level_complete"] = run_state.level_complete(tutorial.button_pressed)
    return result


func activate(action: Dictionary) -> void:
    var before := snapshot()
    message = "Empty passage: no pickup; chain unchanged unless All-in is armed."
    var side := SideData.new()
    if not action.id.is_empty():
        side.modifier = UpgradeCatalog.pickup(action.id, int(action.steps))
        side.modifier_entity = run_state.modifier_system.register_modifier(side.modifier)
    passage_id += 1
    if tutorial.button_pressed:
        run_state.tutorial_commits[passage_id] = true
    run_state.resolve_side(passage_id, side)
    # Synthetic shells have no lifetime; release their ECS and passage records immediately.
    var figure := FigureData.new()
    figure.sides.append(side)
    run_state.unregister_figure(passage_id, figure)
    var after := snapshot()
    var changes: Array[String] = []
    for key in after:
        if before[key] != after[key]:
            changes.append("%s: %s → %s" % [key, before[key], after[key]])
    if before.charges_completed == after.charges_completed:
        if before.charges_completed >= RunState.required_charges():
            message += "\nCharge counter already at requirement."
        else:
            message += "\nNo completed charge: a pending chain containing TIER must be banked by POINTS (Forge may store instead)."
    played.append(action.duplicate(true))
    history.add_item("%d. %s" % [history.item_count + 1, _action_name(action)])
    log_view.text += "%s\n%s\n%s\n\n" % [_action_name(action), message, "\n".join(changes)]
    log_view.set_caret_line(log_view.get_line_count() - 1)
    _refresh()


func _action_name(action: Dictionary) -> String:
    return (
        "Empty passage"
        if action.id.is_empty()
        else UpgradeCatalog \
                .pickup(action.id, int(action.steps)) \
                .title \
                .replace("\n", " · ")
    )


func reset_fresh() -> void:
    var fresh := RunState.new()
    for key in inputs:
        _set_input(key, fresh.get(key) if key in RUN_FIELDS else fresh.modifier_system.get(key))
    reset_state()


func reset_state() -> void:
    run_state.reset()
    for key in inputs:
        var value: Variant = _input_value(key)
        if key in RUN_FIELDS:
            run_state.set(key, value)
        else:
            run_state.modifier_system.set(key, value)
    played.clear()
    played_starting.clear()
    for key in inputs:
        played_starting[key] = _input_value(key)
    cursor = 0
    passage_id = 0
    history.clear()
    log_view.text = "Reset to chosen starting state. Completion is observed, never navigates away.\n"
    _refresh()


func _append(action: Dictionary) -> void:
    sequence.append(action)
    _refresh()


func _remove_step() -> void:
    var selected := sequence_view.get_selected_items()
    if not selected.is_empty():
        sequence.remove_at(selected[0])
        cursor = 0
        _refresh()


func step_sequence() -> void:
    if cursor < sequence.size():
        var action: Dictionary = sequence[cursor]
        cursor += 1
        activate(action)


func load_preset(index: int) -> void:
    if index == 0:
        return
    var fresh := RunState.new()
    for key in inputs:
        _set_input(key, fresh.get(key) if key in RUN_FIELDS else fresh.modifier_system.get(key))
    tutorial.button_pressed = false
    var ids: Array = []
    match index:
        1:
            _set_input("pending", true)
            _set_input("tier", UpgradeCatalog.data.points_by_tier.size())
            ids = ["echo", "tier", "points"]
        2:
            ids = ["points", "all_in", "tier", "points"]
        3:
            ids = ["forge", "points", "", "echo"]
        4:
            ids = ["points", "tier", "red", "points"]
        5:
            _set_input("charges_completed", RunState.required_charges() - 1)
            ids = ["points", "tier", "points"]
    sequence.clear()
    for id in ids:
        sequence.append({ "id": id, "steps": -1 })
    reset_state()


func _input_value(key: String) -> Variant:
    var input: Control = inputs[key]
    if input is CheckButton:
        return input.button_pressed
    if input is OptionButton:
        return input.get_item_text(input.selected)
    return int(input.value)


func _set_input(key: String, value: Variant) -> void:
    var input: Control = inputs[key]
    if input is CheckButton:
        input.button_pressed = value
    elif input is OptionButton:
        input.select(["", "points", "tier"].find(value))
    else:
        input.value = value


func save_played() -> void:
    sequence = played.duplicate(true)
    for key in played_starting:
        _set_input(key, played_starting[key])
    cursor = sequence.size()
    copy_repro()
    _refresh()


func copy_repro() -> void:
    var state := { }
    for key in inputs:
        state[key] = _input_value(key)
    DisplayServer.clipboard_set(
        JSON.stringify(
            {
                "version": 1,
                "starting": state,
                "sequence": sequence,
                "tutorial": tutorial.button_pressed,
                "required_charges": RunState.required_charges(),
                "required_controls": RunState.required_controls(),
            },
            "  ",
        )
    )
    log_view.text += "Reproduction copied (chosen starting state, sequence, production conditions).\n"


func import_repro() -> void:
    var data: Variant = JSON.parse_string(DisplayServer.clipboard_get())
    if not _valid_repro(data):
        log_view.text += "Import rejected: invalid reproduction or incompatible production conditions. State unchanged.\n"
        return
    for key in inputs:
        _set_input(key, data.starting[key])
    sequence = data.sequence.duplicate(true)
    tutorial.button_pressed = data.tutorial
    reset_state()


func _valid_repro(data: Variant) -> bool:
    if not data is Dictionary or data.get("version") != 1:
        return false
    if (
        not data.get("starting") is Dictionary
        or not data.get("sequence") is Array or not data.get("tutorial") is bool
    ):
        return false
    if (
        data.get("required_charges") != RunState.required_charges()
        or data.get("required_controls") != RunState.required_controls()
    ):
        return false
    for key in inputs:
        var value: Variant = data.starting.get(key)
        var input: Control = inputs[key]
        if input is CheckButton:
            if not value is bool:
                return false
        elif input is OptionButton:
            if not value in ["", "points", "tier"]:
                return false
        else:
            if not (value is float or value is int):
                return false
            if (
                not is_finite(value) or value != floor(value)
                or value < input.min_value or value > input.max_value
            ):
                return false
            if key == "sign_value" and value not in [-1, 1]:
                return false
    for action in data.sequence:
        if not action is Dictionary or not action.get("id") is String:
            return false
        var steps: Variant = action.get("steps")
        if not (steps is float or steps is int):
            return false
        if steps != floor(steps) or steps < -1 or steps > 5:
            return false
        if action.id != "" and not UpgradeCatalog.data.pickups.any(
                func(entry):
                    return entry.id == action.id,
            ):
            return false
    return true


func replay() -> void:
    reset_state()
    for action in sequence:
        step_sequence()


func _refresh() -> void:
    var state := snapshot()
    state_view.text = "Banked: %d    Pending: %d\nTier: %d · Sign: %d · Multiplier: ×%d\nEcho: %s · All-in: %s · Chain has tier: %s\nForge: %d/%d %s (level %d)\nTier streak: %d · next reward uses configured increment\nTiers collected: %d (not completed charges)\nCharges: %d/%d · %s\nControls: %d/%d · %s\nLevel %d completion: %s (navigation intercepted)" % [
        state.score,
        state.pending_points,
        state.tier,
        state.sign_value,
        state.points_multiplier,
        state.echo_pending,
        state.all_in,
        state.chain_has_tier,
        state.forge_count,
        state.forge_slots,
        state.forge_kind,
        state.forge_value,
        state.tier_streak_count,
        state.tiers_collected,
        state.charges_completed,
        RunState.required_charges(),
        "satisfied" if state.charges_completed >= RunState.required_charges() else "not satisfied",
        state.controls_completed,
        RunState.required_controls(),
        "satisfied" if state.controls_completed >= RunState.required_controls() else "not satisfied",
        state.difficulty + 1,
        state.level_complete,
    ]
    sequence_view.clear()
    for i in sequence.size():
        sequence_view.add_item(
            "%s %d. %s" % ["→" if i == cursor else "", i + 1, _action_name(sequence[i])]
        )
