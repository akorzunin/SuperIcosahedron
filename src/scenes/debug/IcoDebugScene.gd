extends Node3D
class_name IcoDebugScene

const IcosahedronScene: PackedScene = preload("res://src/models/icosahedron/Icosahedron.tscn")
const DEBUG_GUI_FONT_SIZE := 22
const DEBUG_GUI_TITLE_FONT_SIZE := 28
const INITIAL_VARIANT := 0.0
const INITIAL_STAGE := 0.0
const INITIAL_SPAWN_SCALE := 1.0
const INITIAL_SCALE_FACTOR := 1.0
const INITIAL_GAME_SPEED := 10.0
const INITIAL_ROTATION_SPEED := 12.0
const INITIAL_CONTROL_TYPE := "FREE_SPIN"

@onready var spawn_root: Node3D = $SpawnRoot
@onready var game_state_manager: GameStateManager = %GameStateManager
@onready var scale_timer: ScaleTimer = %ScaleTimer

var current_ico: Icosahedron
var is_playing := false

var variant_spin: SpinBox
var stage_spin: SpinBox
var scale_spin: SpinBox
var rotation_speed_spin: SpinBox
var game_speed_spin: SpinBox
var scale_factor_spin: SpinBox
var face_numbers_check: CheckBox
var debug_visual_check: CheckBox
var scaling_check: CheckBox
var default_rotation_check: CheckBox
var control_type_option: OptionButton
var status_label: Label
var play_button: Button

func _ready() -> void:
    _ensure_game_settings()
    _build_settings_panel()
    spawn_node()

func _ensure_game_settings() -> void:
    if not G.settings is Dictionary:
        G.settings = {}
    var defaults := {
        "SCALE_FACTOR": INITIAL_SCALE_FACTOR,
        "GAME_SPEED": INITIAL_GAME_SPEED,
        "ROTATION_SPEED": INITIAL_ROTATION_SPEED,
        "IS_CONTROL_INVERTED": false,
        "CONTROL_TYPE": INITIAL_CONTROL_TYPE,
    }
    for key in defaults.keys():
        if not G.settings.has(key):
            G.settings[key] = defaults[key]

func _build_settings_panel() -> void:
    var layer := CanvasLayer.new()
    layer.name = "DebugGui"
    add_child(layer)

    var panel := PanelContainer.new()
    panel.name = "SettingsPanel"
    panel.set_anchors_preset(Control.PRESET_TOP_LEFT)
    panel.offset_left = 16.0
    panel.offset_top = 16.0
    panel.offset_right = 620.0
    panel.offset_bottom = 720.0
    layer.add_child(panel)

    var box := VBoxContainer.new()
    box.add_theme_constant_override("separation", 8)
    panel.add_child(box)

    var title := Label.new()
    title.text = "Icosahedron Debug"
    title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    title.add_theme_font_size_override("font_size", DEBUG_GUI_TITLE_FONT_SIZE)
    box.add_child(title)

    variant_spin = _add_spin(box, "Variant (-1 default, 0-19)", -1.0, 19.0, 1.0, INITIAL_VARIANT)
    stage_spin = _add_spin(box, "Stage data", 0.0, 200.0, 1.0, INITIAL_STAGE)
    scale_spin = _add_spin(box, "Spawn scale", 0.1, 20.0, 0.1, INITIAL_SPAWN_SCALE)
    rotation_speed_spin = _add_spin(box, "Rotation speed", 0.0, 100.0, 1.0, float(G.settings.ROTATION_SPEED))
    game_speed_spin = _add_spin(box, "Game speed", 0.0, 100.0, 1.0, float(G.settings.GAME_SPEED))
    scale_factor_spin = _add_spin(box, "Scale factor", 0.0, 100.0, 0.1, float(G.settings.SCALE_FACTOR))

    face_numbers_check = _add_check(box, "Show face numbers", false)
    debug_visual_check = _add_check(box, "Debug visual", false)
    scaling_check = _add_check(box, "Scaling enabled", true)
    default_rotation_check = _add_check(box, "Use game initial rotation", true)

    var control_row := HBoxContainer.new()
    var control_label := Label.new()
    control_label.text = "Control"
    control_label.custom_minimum_size.x = 140.0
    control_row.add_child(control_label)
    control_type_option = OptionButton.new()
    control_type_option.focus_mode = Control.FOCUS_NONE
    control_type_option.add_item("Free spin")
    control_type_option.set_item_metadata(0, "FREE_SPIN")
    control_type_option.add_item("Face lock")
    control_type_option.set_item_metadata(1, "FACE_LOCK")
    control_type_option.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    control_row.add_child(control_type_option)
    box.add_child(control_row)

    var buttons := HBoxContainer.new()
    var spawn_button := Button.new()
    spawn_button.text = "Spawn node"
    spawn_button.focus_mode = Control.FOCUS_NONE
    spawn_button.pressed.connect(spawn_node)
    buttons.add_child(spawn_button)

    play_button = Button.new()
    play_button.text = "Play node"
    play_button.focus_mode = Control.FOCUS_NONE
    play_button.pressed.connect(play_node)
    buttons.add_child(play_button)

    var reset_button := Button.new()
    reset_button.text = "Reset"
    reset_button.focus_mode = Control.FOCUS_NONE
    reset_button.pressed.connect(reset_all)
    buttons.add_child(reset_button)
    box.add_child(buttons)

    var stop_button := Button.new()
    stop_button.text = "Stop / preview"
    stop_button.focus_mode = Control.FOCUS_NONE
    stop_button.pressed.connect(stop_node)
    box.add_child(stop_button)

    status_label = Label.new()
    status_label.text = "Ready"
    status_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    box.add_child(status_label)

    _apply_gui_font_size(panel)
    title.add_theme_font_size_override("font_size", DEBUG_GUI_TITLE_FONT_SIZE)

func _apply_gui_font_size(node: Node) -> void:
    if node is Control:
        (node as Control).add_theme_font_size_override("font_size", DEBUG_GUI_FONT_SIZE)
    for child in node.get_children():
        _apply_gui_font_size(child)

func _add_spin(parent: Node, label_text: String, min_value: float, max_value: float, step: float, value: float) -> SpinBox:
    var row := HBoxContainer.new()
    var label := Label.new()
    label.text = label_text
    label.custom_minimum_size.x = 190.0
    row.add_child(label)

    var spin := SpinBox.new()
    spin.focus_mode = Control.FOCUS_NONE
    spin.min_value = min_value
    spin.max_value = max_value
    spin.step = step
    spin.value = value
    spin.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    row.add_child(spin)
    parent.add_child(row)
    return spin

func _add_check(parent: Node, text: String, pressed: bool) -> CheckBox:
    var check := CheckBox.new()
    check.focus_mode = Control.FOCUS_NONE
    check.text = text
    check.button_pressed = pressed
    parent.add_child(check)
    return check

func reset_all() -> void:
    stop_node(false)
    if current_ico and is_instance_valid(current_ico):
        current_ico.queue_free()
        current_ico = null

    variant_spin.value = INITIAL_VARIANT
    stage_spin.value = INITIAL_STAGE
    scale_spin.value = INITIAL_SPAWN_SCALE
    rotation_speed_spin.value = INITIAL_ROTATION_SPEED
    game_speed_spin.value = INITIAL_GAME_SPEED
    scale_factor_spin.value = INITIAL_SCALE_FACTOR
    face_numbers_check.button_pressed = false
    debug_visual_check.button_pressed = false
    scaling_check.button_pressed = true
    default_rotation_check.button_pressed = true
    control_type_option.select(0)
    G.settings.IS_CONTROL_INVERTED = false

    spawn_node()
    status_label.text = "Reset to initial state."

func spawn_node() -> void:
    stop_node(false)
    if current_ico and is_instance_valid(current_ico):
        current_ico.queue_free()
        current_ico = null

    _apply_runtime_settings()
    var variant := int(variant_spin.value)
    var figure_data := StageGenerator.create_figure(int(stage_spin.value)) if variant >= 0 else FigureData.new()
    var ico := IcosahedronScene.instantiate() as Icosahedron
    ico.with_type(variant)
    ico.with_face_numbers(face_numbers_check.button_pressed)
    ico.with_data(figure_data)
    ico.with_scale_timer(scale_timer)
    ico.DEBUG_VISUAL = debug_visual_check.button_pressed
    ico.scaling_enabled = false
    ico.scale = Vector3.ONE * float(scale_spin.value)
    if not default_rotation_check.button_pressed:
        ico.inital_transform = Quaternion.IDENTITY

    spawn_root.add_child(ico)
    current_ico = ico
    status_label.text = "Spawned variant %s. Press Play node to run it with game controls/scaling." % variant

func play_node() -> void:
    get_viewport().gui_release_focus()
    if not current_ico or not is_instance_valid(current_ico):
        spawn_node()
    _apply_runtime_settings()
    is_playing = true
    current_ico.scaling_enabled = scaling_check.button_pressed
    if current_ico.mesh_icosahedron:
        current_ico.mesh_icosahedron.set_controlled(true)
    game_state_manager.change_state(GameStateManager.GameState.GAME_ACTIVE)
    if scale_timer.is_stopped():
        scale_timer.start(ScaleTimer.tick_dur)
    status_label.text = "Playing. Use normal game controls to rotate the node."

func stop_node(update_status := true) -> void:
    is_playing = false
    game_state_manager.change_state(GameStateManager.GameState.GAME_PAUSED)
    scale_timer.stop()
    if current_ico and is_instance_valid(current_ico):
        current_ico.scaling_enabled = false
        if current_ico.mesh_icosahedron:
            current_ico.mesh_icosahedron.set_controlled(false)
    if update_status and status_label:
        status_label.text = "Preview stopped."

func _apply_runtime_settings() -> void:
    G.settings.ROTATION_SPEED = float(rotation_speed_spin.value)
    G.settings.GAME_SPEED = float(game_speed_spin.value)
    G.settings.SCALE_FACTOR = float(scale_factor_spin.value)
    G.settings.CONTROL_TYPE = str(control_type_option.get_selected_metadata())

func _process(delta: float) -> void:
    if not is_playing:
        return
    if not current_ico or not is_instance_valid(current_ico) or not current_ico.mesh_icosahedron:
        return
    if G.settings.CONTROL_TYPE == "FACE_LOCK":
        FaceLock.handle_face_lock_input(current_ico.mesh_icosahedron, false)
    else:
        var rot_speed := float(G.settings.ROTATION_SPEED) / 10.0 * delta
        FreeSpin.handle_free_spin_input(current_ico.mesh_icosahedron, rot_speed, false)
