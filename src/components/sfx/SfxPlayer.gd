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

func _on_toggle_sfx(state: bool):
    #R:TODO write utils func for that
    var i := AudioServer.get_bus_index("sfx")
    AudioServer.set_bus_mute(i, not state)
    config.set_sfx_state(state)

func _on_toggle_music(state: bool):
    #R:TODO write utils func for that
    var i := AudioServer.get_bus_index("Music")
    AudioServer.set_bus_mute(i, not state)
    config.set_music_state(state)

func _play_section_chaged():
    if section_changed.playing:
        section_changed.stop()
    section_changed.play()

func _play_section_select():
    section_select.play()

func _play_action_select():
    action_select.play()
