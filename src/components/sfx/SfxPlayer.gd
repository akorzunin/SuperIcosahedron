extends Node
class_name SfxPlayer

@onready var config: Config = %Config

@onready var section_changed: AudioStreamPlayer = $SectionChanged
signal on_section_chaged

@onready var section_select: AudioStreamPlayer = $SectionSelect
signal on_section_select

@onready var action_select: AudioStreamPlayer = $ActionSelect
signal on_action_select

signal toggle_sfx(state: bool)
signal toggle_music(state: bool)

func _init() -> void:
    if Utils.get_platform() == Utils.Platform.WEB:
        create_mute_callbac()

func _ready() -> void:
    on_section_chaged.connect(_play_section_chaged)
    on_section_select.connect(_play_section_select)
    on_action_select.connect(_play_action_select)
    toggle_sfx.connect(_on_toggle_sfx)
    toggle_music.connect(_on_toggle_music)
    if not G.settings.MUSIC_ENABLED:
        _on_toggle_music(false)
    if not G.settings.SFX_ENABLED:
        _on_toggle_sfx(false)

static func enable_bus(bus_name: String, state: bool):
    var bus_idx := AudioServer.get_bus_index(bus_name)
    AudioServer.set_bus_mute(bus_idx, not state)

func _on_toggle_sfx(state: bool):
    SfxPlayer.enable_bus("sfx", state)
    config.set_sfx_state(state)

func _on_toggle_music(state: bool):
    SfxPlayer.enable_bus("Music", state)
    config.set_music_state(state)

func _play_section_chaged():
    if section_changed.playing:
        section_changed.stop()
    section_changed.play()

func _play_section_select():
    section_select.play()

func _play_action_select():
    action_select.play()

var js_audio_callback: JavaScriptObject

func create_mute_callbac() -> void:
    js_audio_callback = JavaScriptBridge.create_callback(_set_audio_state)
    JavaScriptBridge.eval("""
var godotAudioBridge = {
    callback: null,
    setCallback: (cb) => this.callback = cb,
    setAudioState: (data) => this.callback(JSON.stringify(data)),
};
    """, true)
    var godot_bridge = JavaScriptBridge.get_interface("godotAudioBridge")
    godot_bridge.setCallback(js_audio_callback)

func _set_audio_state(data: Array) -> void:
    var json := JSON.new()
    var err := json.parse(data[0])
    if err != OK:
        push_error(error_string(err))
        return
    var args = json.data
    var state: bool
    var volume: float
    if args.get("state") != null:
        state = args.get("state")
        print('set state: ', state)
        _on_toggle_music(state)
        _on_toggle_sfx(state)
    if  args.get("volume") != null:
        volume = args.get("volume")
        print('set volume: ', volume)
