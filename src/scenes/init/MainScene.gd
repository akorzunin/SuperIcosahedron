extends Node

const LOOP_SCENE = preload('res://src/scenes/LoopScene.tscn')
const MENU_SCENE = preload('res://src/scenes/MenuScene.tscn')

@export var start_fullscreen := false
var current_scene
var discord_status: DummyDiscordStatus
# Called when the node enters the scene tree for the first time.
func _ready():
    if OS.has_feature('web') or OS.has_feature('mobile'):
        discord_status = DummyDiscordStatus.new()
    else:
        var DiscordStatus = load('res://src/components/DiscordStatus.gd')
        discord_status = DiscordStatus.new()
    discord_status.name = 'DiscordStatus'
    add_child(discord_status)
    change_scene('MenuScene')


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
    pass

func init_scene(scene: PackedScene) -> Node3D:
    return scene.instantiate().init({})

func release_inputs():
    for a in InputMap.get_actions():
        Input.action_release(a)

func change_scene(scene_name: String):
    release_inputs()
    if current_scene:
        current_scene.deinit()
    match scene_name:
        'MenuScene':
            current_scene = init_scene(MENU_SCENE)
        'LoopScene':
            current_scene = init_scene(LOOP_SCENE)
    get_tree().root.add_child.call_deferred(current_scene)
