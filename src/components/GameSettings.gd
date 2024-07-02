@tool
extends Node
class_name GameSettings

@onready var parent: Node

@export_category("pssetable")
@export_group("preset")
enum SettingsPreset {DEFAULT, DEBUG, CUSTOM}
@export var preset: SettingsPreset:
    set(value):
        preset = value
        parse_preset()
        notify_property_list_changed()


@export_subgroup("gameplay")
enum DespawneMode {NORMAL = 16633, IMMEDIATE = 0, BEFORE_END = 10000}
@export var DESPAWNER_MODE := DespawneMode.NORMAL:
    set(value):
        DESPAWNER_MODE = value
        upd_preset()

enum SpawnMode {QUEUE, RANDOM, CENTER, SIDE}
@export var SPAWN_MODE := SpawnMode.RANDOM:
    set(value):
        SPAWN_MODE = value
        upd_preset()

enum RoatationSpeed {NORMAL = 12, SLOW = 5, FAST = 15}
@export var ROTATION_SPEED := RoatationSpeed.FAST:
    set(value):
        ROTATION_SPEED = value
        upd_preset()

@export_category("non presettable")
@export_group("window")
@export var WINDOW_MODE := DisplayServer.WindowMode.WINDOW_MODE_WINDOWED

var setting_preset = false

func upd_preset(p = SettingsPreset.CUSTOM):
    if setting_preset:
        return
    preset = p

func init():
    set_window_settings()

func _ready() -> void:
    if Engine.is_editor_hint():
        return
    parent = get_parent()
    # use gamesettings node from main scene inside other scenes
    if parent.name == 'Settings' and Utils.main_scene(self) == 'MainScene':
        return
    init()


func parse_preset() -> void:
    var sp = SettingsPreset
    setting_preset = true
    match preset:
        sp.DEFAULT:
            DESPAWNER_MODE = DespawneMode.NORMAL
            SPAWN_MODE = SpawnMode.RANDOM
            ROTATION_SPEED = RoatationSpeed.NORMAL
        sp.DEBUG:
            DESPAWNER_MODE = DespawneMode.BEFORE_END
            SPAWN_MODE = SpawnMode.SIDE
            ROTATION_SPEED = RoatationSpeed.SLOW
        sp.CUSTOM:
            pass
    setting_preset = false

func set_window_settings():
    var V = get_viewport()
    var P = Utils.Platform
    var R = Utils.RenderMethods

    match Utils.get_platform():
        P.PC:
            DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
        P.WEB:
            DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
        P.MOBILE:
            DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)

    if OS.has_feature('editor'):
        DisplayServer.window_set_mode(WINDOW_MODE)


    V.use_debanding = true

    if Utils.get_render_method() == R.FORWARD_PLUS:
        V.msaa_3d = Viewport.MSAA_8X
        V.use_taa = true

    if Utils.get_render_method() == R.MOBILE:
        V.screen_space_aa = Viewport.SCREEN_SPACE_AA_FXAA

    if Utils.get_render_method() == R.GL_COMPATIBILITY:
        V.screen_space_aa = Viewport.SCREEN_SPACE_AA_FXAA
        V.msaa_3d = Viewport.MSAA_8X

    pass
