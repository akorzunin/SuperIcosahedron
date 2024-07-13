extends Node
class_name SfxPlayer

@onready var section_changed: AudioStreamPlayer = $SectionChanged
signal on_section_chaged

@onready var section_select: AudioStreamPlayer = $SectionSelect
signal on_section_select

@onready var action_select: AudioStreamPlayer = $ActionSelect
signal on_action_select


func _ready() -> void:
    on_section_chaged.connect(_play_section_chaged)
    on_section_select.connect(_play_section_select)
    on_action_select.connect(_play_action_select)

func _play_section_chaged():
    if section_changed.playing:
        section_changed.stop()
    section_changed.play()

func _play_section_select():
    section_select.play()

func _play_action_select():
    action_select.play()
