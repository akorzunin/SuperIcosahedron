extends Node
class_name GameSettings

enum SettingsPreset {DEFAULT, DEBUG, CUSTOM}
@export var preset: SettingsPreset:
    set(value):
        preset = value
        parse_preset()
        notify_property_list_changed()

enum DespawneMode {NORMAL = 16633, IMMEDIATE = 0, BEFORE_END = 10000}
@export var DESPAWNER_MODE := DespawneMode.NORMAL

enum SpawnMode {QUEUE, RANDOM, CENTER, SIDE}
@export var SPAWN_MODE := SpawnMode.RANDOM

enum RoatationSpeed {NORMAL = 12, SLOW = 5, FAST = 15}
@export var ROTATION_SPEED := RoatationSpeed.FAST

@export_category("window settings")
@export var WINDOW_MODE := DisplayServer.WindowMode.WINDOW_MODE_WINDOWED

@onready var parent: Node = $'..'

func init():
    set_window_settings()

func _ready() -> void:
    # use gamesettings node from main scene inside other scenes
    if parent.name == 'Settings' and Utils.main_scene(self) == 'MainScene':
        return
    init()

func parse_preset() -> void:
    var sp = SettingsPreset
    match preset:
        sp.DEFAULT:
            DESPAWNER_MODE = DespawneMode.NORMAL
            SPAWN_MODE = SpawnMode.RANDOM
        sp.DEBUG:
            DESPAWNER_MODE = DespawneMode.BEFORE_END
        sp.CUSTOM:
            pass

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
