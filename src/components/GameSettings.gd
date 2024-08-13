@tool
extends Node
class_name GameSettings

var parent

func init():
    set_window_settings()
    # Engine.max_fps = 60

func _ready() -> void:
    if Engine.is_editor_hint():
        return
    parent = get_parent()
    # use gamesettings node from main scene inside other scenes
    if parent.name == 'Settings' and Utils.main_scene(self) == 'MainScene':
        return
    init()

func set_window_settings():
    var V = get_viewport()
    var P = Utils.Platform
    var R = Utils.RenderMethods

    match Utils.get_platform():
        P.PC:
            if G.settings.FULLSCREEN_ENABLED:
                DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
            else:
                DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
            if G.settings.VSYNC_ENABLED:
                Utils.set_vsync(DisplayServer.VSYNC_ADAPTIVE)
            else:
                Utils.set_vsync(DisplayServer.VSYNC_DISABLED)
        P.WEB:
            DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
        P.MOBILE:
            DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)

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

func update_from_dict(d: Dictionary):
    for section in d.keys():
        for key in d[section]:
            set(key, d[section][key])
    return self
