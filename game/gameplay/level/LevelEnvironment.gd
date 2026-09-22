extends Node3D
class_name LevelEnvironment

const PATH := "res://game/gameplay/config/levels.json"
const TRANSITION_SECONDS := 1.2
var transition: Tween
var levels: Array = []
@onready var world: WorldEnvironment = $WorldEnvironment
@onready var backdrop: MeshInstance3D = $SkyMeshIcosahedron
@onready var light: DirectionalLight3D = $DirectionalLight3D


func _ready() -> void:
    var config: Variant = JSON.parse_string(FileAccess.get_file_as_string(PATH))
    assert(config is Dictionary and config.get("schema_version") == 1)
    levels = config.levels
    assert(not levels.is_empty())
    for level in levels:
        var settings: Dictionary = level.environment
        assert(settings.theme in ["day", "night"])
        assert(TwColors.tw.has(settings.accent))
        assert(TwColors.tw[settings.accent].has("_%s" % int(settings.shade)))
    # Tween only this scene's resources, never the menu or another gameplay instance.
    world.environment = world.environment.duplicate(true)
    backdrop.material_override = backdrop.material_override.duplicate()


static func colors(settings: Dictionary) -> Dictionary:
    var rgb: Array = TwColors.tw[settings.accent]["_%s" % int(settings.shade)]
    var accent := Color(rgb[0], rgb[1], rgb[2])
    var night: bool = settings.theme == "night"
    return {
        "background": Color(0.015, 0.025, 0.065).lerp(accent, 0.12) if night else accent,
        "light": Color(0.65, 0.72, 1.0).lerp(accent, 0.2) if night else Color.WHITE,
        "energy": 0.65 if night else 1.0,
    }


func apply_level(level: int) -> void:
    var palette := colors(levels[clampi(level, 0, levels.size() - 1)].environment)
    if transition:
        transition.kill()
    transition = create_tween().set_parallel(true)
    transition.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
    var sky: ShaderMaterial = world.environment.sky.sky_material
    var color: Color = palette.background
    transition.tween_property(
        sky,
        "shader_parameter/bg_color",
        Vector3(color.r, color.g, color.b),
        TRANSITION_SECONDS,
    )
    transition.tween_property(
        backdrop.material_override,
        "shader_parameter/bg_color",
        color,
        TRANSITION_SECONDS,
    )
    transition.tween_property(light, "light_color", palette.light, TRANSITION_SECONDS)
    transition.tween_property(light, "light_energy", palette.energy, TRANSITION_SECONDS)
