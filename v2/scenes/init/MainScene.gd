extends Node3D

const LOOP_SCENE = preload('res://v2/scenes/LoopScene.tscn')
const MENU_SCENE = preload('res://v2/scenes/MenuScene.tscn')

var current_scene

# Called when the node enters the scene tree for the first time.
func _ready():
    change_scene('MenuScene')
    pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
    pass

func change_scene(scene_name: String):
    current_scene.deinit()
    match scene_name:
        'MenuScene':
            current_scene = MENU_SCENE.instantiate().init()
        'LoopScene':
            current_scene = LOOP_SCENE.instantiate().init()
    get_tree().root.add_child.call_deferred(current_scene)
