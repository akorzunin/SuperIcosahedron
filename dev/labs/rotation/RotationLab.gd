extends Node3D

const FIGURE := preload("res://game/gameplay/figure/Icosahedron.tscn")

@onready var controller: FigureController = $FigureController
@onready var controls: VBoxContainer = $UI/Panel/Controls
var figure: Icosahedron

func _ready() -> void:
    controls.get_node("Mode").item_selected.connect(func(index):
        reset_figure()
        controller.control_type = "FREE_SPIN" if index == 0 else "FACE_LOCK"
    )
    controls.get_node("Invert").toggled.connect(func(value): controller.inverted = value)
    controls.get_node("Speed").value_changed.connect(func(value): controller.rotation_speed = value)
    controls.get_node("Reset").pressed.connect(reset_figure)
    reset_figure()

func reset_figure() -> void:
    controller.target = null
    if is_instance_valid(figure):
        remove_child(figure)
        figure.queue_free()
    figure = FIGURE.instantiate()
    figure.scaling_enabled = false
    add_child(figure)
    controller.target = figure.mesh_icosahedron
    controller.target.set_controlled(true)
    get_viewport().gui_release_focus()

func _process(_delta: float) -> void:
    if is_instance_valid(controller.target):
        controls.get_node("Orientation").text = "Quaternion: %s" % controller.target.quaternion
