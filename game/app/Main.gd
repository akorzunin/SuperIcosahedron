extends Node

const LOOP_SCENE = preload('res://game/gameplay/Gameplay.tscn')
const MENU_SCENE = preload('res://game/menu/Menu.tscn')

@export var start_fullscreen := false
var scenes := {}
var current_scene: Node
var discord_status: DummyDiscordStatus
var app_state := AppState.new()

func _ready():
    app_state.name = "AppState"
    add_child(app_state)
    if OS.has_feature('web') or OS.has_feature('mobile') or OS.has_feature('editor'):
        discord_status = DummyDiscordStatus.new()
    else:
        discord_status = load('res://game/services/discord/DiscordStatus.gd').new()
    discord_status.name = 'DiscordStatus'
    add_child(discord_status)
    _mount_scenes()
    change_scene('MenuScene')

func _process(delta):
    pass

func init_scene(scene: PackedScene, props := {}) -> Node3D:
    return scene.instantiate().init(props)

func _mount_scenes() -> void:
    scenes.MenuScene = init_scene(MENU_SCENE)
    scenes.LoopScene = init_scene(LOOP_SCENE, { start_inactive = true })
    scenes.LoopScene.menu_requested.connect(func(): change_scene('MenuScene'))
    scenes.LoopScene.sound_requested.connect(func(event): $SfxPlayer.emit_signal(event))
    scenes.LoopScene.status_changed.connect(discord_status.set_state)
    scenes.LoopScene.level_changed.connect(discord_status.set_loop_state)
    add_child(scenes.MenuScene)
    add_child(scenes.LoopScene)
    _set_scene_active(scenes.MenuScene, false)
    _set_scene_active(scenes.LoopScene, false)

func _set_scene_active(scene: Node, active: bool) -> void:
    scene.visible = active
    _set_canvas_layers_visible(scene, active)
    scene.process_mode = Node.PROCESS_MODE_INHERIT if active else Node.PROCESS_MODE_DISABLED

func _set_canvas_layers_visible(node: Node, visible: bool) -> void:
    if node is CanvasLayer:
        node.visible = visible
    for child in node.get_children():
        _set_canvas_layers_visible(child, visible)

func release_inputs():
    for a in InputMap.get_actions():
        Input.action_release(a)

func change_scene(scene_name: String):
    release_inputs()
    var next_scene: Node = scenes.get(scene_name)
    if not next_scene:
        return
    if current_scene:
        _set_scene_active(current_scene, false)
    current_scene = next_scene
    _set_scene_active(current_scene, true)
    if scene_name == 'LoopScene':
        app_state.set_state(AppState.State.PLAYING)
        current_scene.restart()
    else:
        app_state.set_state(AppState.State.MENU)
        var loop: Node = scenes.get('LoopScene')
        var gsm: GameStateManager = loop.get_node_or_null("GameStateManager") as GameStateManager if loop else null
        if gsm:
            gsm.change_state(GameStateManager.GameState.GAME_MENU)
