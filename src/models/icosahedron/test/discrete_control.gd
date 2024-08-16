@tool
extends Node3D

@onready var m: MeshInstance3D = $MeshInstance3D

@export var init_quat: Quaternion

@export_category("CONST")
@export var a := 0.301
@export var b := 0.504
@export var c := 0.808

@export var a1 := 0.488
@export var b1 := 0.873

const alt_q := Quaternion(-0.515479, 0.282345, 0.400652, 0.702881)

@export_category("controls")

@export var reset := false:
    set(val):
        m.quaternion = init_quat

func t(q: Quaternion, m: MeshInstance3D):
    var tw := m.create_tween()
    var rot := q * m.quaternion
    tw.tween_property(m, 'quaternion', rot.normalized(), 0.3)
    tw.play()

@export var left := false:
    set(val):
        print_debug("left")
        var q := Quaternion(a, b, 0, c).normalized()
        t(q, m)


@export var alt_left := false:
    set(val):
        print_debug("left")
        var q := alt_q * Quaternion(0, 0, a1, b1).normalized().inverse()
        t(q, m)

@export var right := false:
    set(val):
        print_debug("right")
        var q := Quaternion(a, b, 0, c).normalized().inverse()
        t(q, m)

@export var alt_right := false:
    set(val):
        print_debug("right")
        var q := (alt_q * Quaternion(0, 0, a1, b1).normalized().inverse()).inverse()
        t(q, m)

@export var up := false:
    set(val):
        print_debug("up")
        var q := Quaternion(0, 0, a1, b1).normalized().inverse()
        t(q, m)

@export var down := false:
    set(val):
        print_debug("down")
        var q := Quaternion(0, 0, a1, b1).normalized()
        t(q, m)

@export var quat: Quaternion:
    set(val):
        m.quaternion = val
    get:
        return m.quaternion


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    init_quat = m.quaternion
    pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    pass
