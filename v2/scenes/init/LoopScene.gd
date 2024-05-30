extends Node3D

@onready var settings = %Settings
const utils = preload("res://v2/components/Utils.gd")

@onready var DEBUG_VISUAL = true
# Called when the node enters the scene tree for the first time.
func _ready():
    if utils.is_main_scene(self):
        settings.DEBUG_VISUAL = DEBUG_VISUAL
    pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
    pass
