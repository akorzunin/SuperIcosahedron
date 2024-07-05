extends Node

const LOOP_SCENE = preload('res://src/scenes/LoopScene.tscn')
const MENU_SCENE = preload('res://src/scenes/MenuScene.tscn')

@onready var game_settings: GameSettings = %GameSettings

@export var start_fullscreen := false
var current_scene

# Called when the node enters the scene tree for the first time.
func _ready():
    change_scene('MenuScene')


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
    pass

func init_scene(scene: PackedScene) -> Node3D:
    return scene.instantiate().init({
        game_settings = game_settings
    })

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
