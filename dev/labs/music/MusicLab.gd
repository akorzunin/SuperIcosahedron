extends Control

const ROLES := ["Drums", "Bass", "Flute", "Melody"]
const LENGTH := 117.6
const BUS := "MusicLab"
const SILENCE_DB := -60.0
const PATTERNS := [[0.0, 2.0], [0.0, 2.5], [0.5, 3.5]]

var player: AudioStreamPlayer
var mix: AudioStreamSynchronized
var filter: AudioEffectLowPassFilter
var gains := [0.7, 0.7, 0.7, 0.7]
var muted := [false, false, false, false]
var soloed := [false, false, false, false]
var applied := [0.7, 0.7, 0.7, 0.7]
var target := [0.7, 0.7, 0.7, 0.7]
var sliders: Array[HSlider] = []
var fades := [0.15, 0.15, 0.15, 0.15]
var fade_inputs: Array[SpinBox] = []
var mutes: Array[CheckButton] = []
var solos: Array[CheckButton] = []
var pending_beat := -1.0
var bpm := 100.0
var offset_ms := 0.0
var quantize := 4.0
var pattern_index := 1
var seconds := 0.0
var loop_count := 0
var previous_position := 0.0
var judged: Dictionary = { }
var event_remaining := 0.0
var saved_mix: Dictionary = { }
var status: Label
var transport: Label
var feedback: Label
var meter: Label
var lane: ProgressBar
var pause_button: Button
var owns_bus := false


func _ready() -> void:
    _setup_audio()
    _setup_ui()


func _setup_audio() -> void:
    # One lab instance owns this bus; use instance-specific buses if parallel labs are needed.
    if AudioServer.get_bus_index(BUS) < 0:
        AudioServer.add_bus()
        AudioServer.set_bus_name(AudioServer.bus_count - 1, BUS)
        owns_bus = true
    var bus := AudioServer.get_bus_index(BUS)
    AudioServer.set_bus_volume_db(bus, -9.0)
    filter = AudioEffectLowPassFilter.new()
    filter.cutoff_hz = 20000.0
    AudioServer.add_bus_effect(bus, filter)
    mix = AudioStreamSynchronized.new()
    mix.stream_count = ROLES.size()
    for index in ROLES.size():
        var stream := load("res://dev/labs/music/assets/%s.ogg" % ROLES[index].to_lower()).duplicate() as AudioStreamOggVorbis
        stream.loop = true
        mix.set_sync_stream(index, stream)
        mix.set_sync_stream_volume(index, linear_to_db(gains[index]))
    player = AudioStreamPlayer.new()
    player.stream = mix
    player.bus = BUS
    add_child(player)


func _setup_ui() -> void:
    theme = Theme.new()
    theme.default_font = preload("res://game/game-assets/fonts/barlow/Barlow-SemiBold.ttf")
    theme.default_font_size = 18
    var background := ColorRect.new()
    background.color = Color("101522")
    background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    add_child(background)
    var scroll := ScrollContainer.new()
    scroll.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    scroll.offset_left = 24
    scroll.offset_top = 20
    scroll.offset_right = -24
    scroll.offset_bottom = -20
    add_child(scroll)
    var column := VBoxContainer.new()
    column.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    column.add_theme_constant_override("separation", 10)
    scroll.add_child(column)
    _label(column, "MUSIC LAB / Glitch Stairs — Fupi — CC0").add_theme_font_size_override(
        "font_size",
        26,
    )
    _label(
        column,
        "Four synchronized stems • 100 BPM inferred • Space = optional pass • no gameplay changes",
    )
    var row := _row(column)
    _button(row, "Play / restart", restart)
    pause_button = _button(row, "Pause", toggle_pause)
    _button(
        row,
        "Jump to middle",
        func():
            restart(57.6),
    )
    _button(row, "Stop", stop)
    transport = _label(column, "Stopped — press Play (audio starts only on request)")
    row = _row(column)
    _number(
        row,
        "BPM (grid only)",
        40,
        240,
        bpm,
        1,
        func(value):
            bpm = value
            _reset_timing(),
    )
    _number(
        row,
        "Beat offset ms (+ = later)",
        -1000,
        1000,
        0,
        5,
        func(value):
            offset_ms = value
            _reset_timing(),
    )
    row = _row(column)
    _label(row, "Apply mix changes:")
    var boundary := OptionButton.new()
    for text in ["Immediately", "Next beat", "Next bar (4 beats)", "End of sequence (8 bars)"]:
        boundary.add_item(text)
    boundary.select(2)
    boundary.focus_mode = Control.FOCUS_NONE
    boundary.item_selected.connect(
        func(index):
            quantize = [0.0, 1.0, 4.0, 32.0][index]
            pending_beat = -1.0
            request_mix(),
    )
    row.add_child(boundary)
    _label(
        column,
        "STEMS                         Gain                                   Fade (seconds) / Mute / Solo",
    )
    for index in ROLES.size():
        row = _row(column)
        _label(row, ROLES[index]).custom_minimum_size.x = 110
        var slider := HSlider.new()
        slider.min_value = 0
        slider.max_value = 1
        slider.step = 0.01
        slider.value = gains[index]
        slider.custom_minimum_size.x = 310
        slider.focus_mode = Control.FOCUS_NONE
        slider.value_changed.connect(
            func(value):
                gains[index] = value
                request_mix(),
        )
        row.add_child(slider)
        sliders.append(slider)
        var fade := SpinBox.new()
        fade.min_value = 0.0
        fade.max_value = 2.0
        fade.step = 0.01
        fade.value = fades[index]
        fade.tooltip_text = "Fade seconds (0 = instant); full-range gain ramp"
        fade.value_changed.connect(
            func(value):
                fades[index] = value,
        )
        row.add_child(fade)
        fade_inputs.append(fade)
        var mute := _toggle(
            row,
            "Mute",
            func(value):
                muted[index] = value
                request_mix(),
        )
        var solo := _toggle(
            row,
            "Solo",
            func(value):
                soloed[index] = value
                request_mix(),
        )
        mutes.append(mute)
        solos.append(solo)
    row = _row(column)
    _button(
        row,
        "Sparse",
        func():
            set_arrangement([true, true, false, false]),
    )
    _button(
        row,
        "Full / combo",
        func():
            set_arrangement([true, true, true, true]),
    )
    _button(row, "Random combination", randomize_mix)
    _button(row, "Store A", store_mix)
    _button(row, "Recall A", recall_mix)
    status = _label(column, "Mix ready • -9 dB bus headroom")
    row = _row(column)
    _button(
        row,
        "Pickup: filter sweep",
        func():
            trigger_event(0.45),
    )
    _button(
        row,
        "Combo break: sparse + filter",
        func():
            set_arrangement([true, true, false, false])
            trigger_event(1.0),
    )
    meter = _label(row, "Peak: silent")
    row = _row(column)
    _label(row, "Node targets / each bar:")
    var patterns := OptionButton.new()
    for text in ["1, 3", "1, 3 &", "1 &, 4 &"]:
        patterns.add_item(text)
    patterns.select(pattern_index)
    patterns.focus_mode = Control.FOCUS_NONE
    patterns.item_selected.connect(
        func(index):
            pattern_index = index
            judged.clear(),
    )
    row.add_child(patterns)
    _button(row, "Pass (Space)", press_pass)
    lane = ProgressBar.new()
    lane.custom_minimum_size.y = 24
    lane.max_value = 4
    lane.show_percentage = false
    column.add_child(lane)
    feedback = _label(
        column,
        "Approach bar fills toward next target • Perfect ±60 ms / Good ±130 ms",
    )
    _label(
        column,
        "BPM changes the test grid, NOT audio speed. Offset calibrates grid/input. Stem entries follow the original arrangement.",
    )


func _row(parent: Node) -> HBoxContainer:
    var row := HBoxContainer.new()
    row.add_theme_constant_override("separation", 12)
    parent.add_child(row)
    return row


func _label(parent: Node, text: String) -> Label:
    var label := Label.new()
    label.text = text
    parent.add_child(label)
    return label


func _button(parent: Node, text: String, action: Callable) -> Button:
    var button := Button.new()
    button.text = text
    button.focus_mode = Control.FOCUS_NONE
    button.pressed.connect(action)
    parent.add_child(button)
    return button


func _toggle(parent: Node, text: String, action: Callable) -> CheckButton:
    var button := CheckButton.new()
    button.text = text
    button.focus_mode = Control.FOCUS_NONE
    button.toggled.connect(action)
    parent.add_child(button)
    return button


func _number(
    parent: Node,
    text: String,
    minimum: float,
    maximum: float,
    value: float,
    step: float,
    action: Callable,
) -> void:
    _label(parent, text)
    var input := SpinBox.new()
    input.min_value = minimum
    input.max_value = maximum
    input.step = step
    input.value = value
    input.value_changed.connect(action)
    parent.add_child(input)


func restart(from_seconds: float = 0.0) -> void:
    player.stop()
    player.stream_paused = false
    player.play(from_seconds)
    seconds = from_seconds
    previous_position = from_seconds
    loop_count = 0
    _reset_timing()
    pause_button.text = "Pause"


func stop() -> void:
    player.stop()
    player.stream_paused = false
    seconds = 0.0
    loop_count = 0
    previous_position = 0.0
    _reset_timing()
    pause_button.text = "Pause"
    transport.text = "Stopped"
    lane.value = 0.0
    feedback.text = "Stopped — press Play to test node timing"


func toggle_pause() -> void:
    if not player.playing:
        return
    player.stream_paused = not player.stream_paused
    pause_button.text = "Resume" if player.stream_paused else "Pause"


func _reset_timing() -> void:
    judged.clear()
    pending_beat = -1.0
    event_remaining = 0.0
    filter.cutoff_hz = 20000.0
    target = effective_gains()


func beat_position() -> float:
    return (seconds - offset_ms / 1000.0) * bpm / 60.0


static func next_boundary(beat: float, interval: float) -> float:
    return (floor(beat / interval) + 1.0) * interval if interval > 0.0 else beat


static func nearest_target(beat: float, pattern: Array) -> float:
    var best := INF
    for bar in range(maxi(0, int(floor(beat / 4.0)) - 1), maxi(0, int(floor(beat / 4.0))) + 2):
        for offset in pattern:
            var candidate: float = bar * 4.0 + offset
            if absf(candidate - beat) < absf(best - beat):
                best = candidate
    return best


static func upcoming_target(beat: float, pattern: Array) -> float:
    var best := INF
    var bar := maxi(0, int(floor(beat / 4.0)))
    for current_bar in [bar, bar + 1]:
        for offset in pattern:
            var candidate: float = current_bar * 4.0 + offset
            if candidate >= beat:
                best = minf(best, candidate)
    return best


func effective_gains() -> Array:
    var values: Array = []
    var any_solo := soloed.has(true)
    for index in ROLES.size():
        values.append(gains[index] if not muted[index] and (not any_solo or soloed[index]) else 0.0)
    return values


func request_mix() -> void:
    if not player.playing or player.stream_paused or quantize == 0.0:
        target = effective_gains()
        pending_beat = -1.0
    elif pending_beat < 0.0:
        pending_beat = next_boundary(beat_position(), quantize)


func set_arrangement(enabled: Array) -> void:
    for index in ROLES.size():
        muted[index] = not enabled[index]
        soloed[index] = false
    _sync_controls()
    request_mix()


func randomize_mix() -> void:
    var enabled := [true, randf() > 0.5, randf() > 0.5, randf() > 0.5]
    set_arrangement(enabled)


func store_mix() -> void:
    saved_mix = {
        "gains": gains.duplicate(),
        "fades": fades.duplicate(),
        "muted": muted.duplicate(),
        "soloed": soloed.duplicate(),
    }


func recall_mix() -> void:
    if saved_mix.is_empty():
        return
    gains = saved_mix.gains.duplicate()
    fades = saved_mix.fades.duplicate()
    muted = saved_mix.muted.duplicate()
    soloed = saved_mix.soloed.duplicate()
    _sync_controls()
    request_mix()


func _sync_controls() -> void:
    for index in ROLES.size():
        sliders[index].set_value_no_signal(gains[index])
        fade_inputs[index].set_value_no_signal(fades[index])
        mutes[index].set_pressed_no_signal(muted[index])
        solos[index].set_pressed_no_signal(soloed[index])


func trigger_event(duration: float) -> void:
    if player.playing and not player.stream_paused:
        # Retrigger one bounded envelope, rather than stacking effects on rapid pickups.
        event_remaining = duration


func press_pass() -> void:
    if not player.playing or player.stream_paused:
        return
    var beat := beat_position()
    var node := nearest_target(beat, PATTERNS[pattern_index])
    var error_ms := (beat - node) * 60000.0 / bpm
    if absf(error_ms) > 130.0:
        feedback.text = "Outside node window — no award"
    elif judged.has(node):
        feedback.text = "Node already judged — no repeat award"
    else:
        judged[node] = true
        feedback.text = "%s / %+.0f ms" % [
            "Perfect" if absf(error_ms) <= 60.0 else "Good",
            error_ms,
        ]


func _input(event: InputEvent) -> void:
    if (
        event is InputEventKey and event.pressed and not event.echo
        and event.physical_keycode == KEY_SPACE
    ):
        press_pass()
        get_viewport().set_input_as_handled()


func _process(delta: float) -> void:
    if player.playing and not player.stream_paused:
        var position := player.get_playback_position()
        if position < previous_position - LENGTH / 2.0:
            loop_count += 1
        previous_position = position
        var audible := position + AudioServer.get_time_since_last_mix() - AudioServer.get_output_latency()
        seconds = maxf(seconds, loop_count * LENGTH + audible)
        advance_mix(delta, beat_position())
        var beat := beat_position()
        transport.text = "Bar %d / Beat %.2f   •   %.2f s   •   %.0f BPM" % [
            int(floor(beat / 4.0)) + 1,
            fposmod(beat, 4.0) + 1.0,
            seconds,
            bpm,
        ]
        var next := upcoming_target(beat, PATTERNS[pattern_index])
        lane.value = clampf(4.0 - (next - beat), 0.0, 4.0)
        # Only recent targets can be judged again; bound memory during long lab sessions.
        for node in judged.keys():
            if node < beat - 4.0:
                judged.erase(node)
    elif not player.playing:
        advance_mix(delta, beat_position())
    status.text = (
        "Mix pending at beat %.1f • %.2f s remaining"
        % [pending_beat + 1.0, maxf(0.0, (pending_beat - beat_position()) * 60.0 / bpm)]
        if pending_beat >= 0
        else "Mix applied • Store/Recall A is session-only • -9 dB bus headroom"
    )
    var bus := AudioServer.get_bus_index(BUS)
    var peak := maxf(
        AudioServer.get_bus_peak_volume_left_db(bus, 0),
        AudioServer.get_bus_peak_volume_right_db(bus, 0),
    )
    meter.text = "Peak %.1f dB%s" % [peak, " / CLIPPING" if peak >= 0.0 else ""]


func advance_mix(delta: float, beat: float) -> void:
    if pending_beat >= 0.0 and beat >= pending_beat:
        target = effective_gains()
        pending_beat = -1.0
    for index in ROLES.size():
        applied[index] = (
            target[index]
            if fades[index] == 0.0
            else move_toward(applied[index], target[index], delta / fades[index])
        )
        mix.set_sync_stream_volume(
            index,
            linear_to_db(applied[index]) if applied[index] > 0.001 else SILENCE_DB,
        )
    event_remaining = maxf(0.0, event_remaining - delta)
    filter.cutoff_hz = lerpf(20000.0, 800.0, minf(event_remaining / 0.45, 1.0))


func _exit_tree() -> void:
    player.stop()
    var bus := AudioServer.get_bus_index(BUS)
    if owns_bus and bus >= 0:
        AudioServer.remove_bus(bus)
