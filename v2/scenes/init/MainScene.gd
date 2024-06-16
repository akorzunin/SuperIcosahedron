extends Node3D

const LOOP_SCENE = preload('res://v2/scenes/LoopScene.tscn')
const MENU_SCENE = preload('res://v2/scenes/MenuScene.tscn')

@export var start_fullscreen := false
var current_scene

# Called when the node enters the scene tree for the first time.
func _ready():
    set_window_settings()
    change_scene('MenuScene')
    pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
    pass

func set_window_settings():
    var V = get_viewport()
    var P = Utils.Platform
    var R = Utils.RenderMethods

    DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
    V.use_debanding = true

    if Utils.get_platform() == P.PC and start_fullscreen:
        DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)

    if Utils.get_render_method() == R.FORWARD_PLUS:
        V.msaa_3d = Viewport.MSAA_8X
        V.use_taa = true

    if Utils.get_render_method() == R.MOBILE:
        V.screen_space_aa = Viewport.SCREEN_SPACE_AA_FXAA

    if Utils.get_render_method() == R.GL_COMPATIBILITY:
        V.screen_space_aa = Viewport.SCREEN_SPACE_AA_FXAA
        V.msaa_3d = Viewport.MSAA_8X

    pass

func change_scene(scene_name: String):
    if current_scene:
        current_scene.deinit()
    match scene_name:
        'MenuScene':
            current_scene = MENU_SCENE.instantiate().init()
        'LoopScene':
            current_scene = LOOP_SCENE.instantiate().init()
    get_tree().root.add_child.call_deferred(current_scene)
