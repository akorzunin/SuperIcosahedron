extends GutTest


func test_day_preserves_original_sky_color() -> void:
    var palette := LevelEnvironment.colors({ "theme": "day", "accent": "sky", "shade": 200 })
    assert_eq(palette.background, Color(0.729, 0.902, 0.992))
    assert_eq(palette.energy, 1.0)


func test_night_is_dark_but_keeps_lighting() -> void:
    var palette := LevelEnvironment.colors({ "theme": "night", "accent": "violet", "shade": 400 })
    assert_lt(palette.background.v, 0.2)
    assert_gt(palette.energy, 0.5)


func test_smooth_despawn_keeps_visual_until_animation_finishes() -> void:
    var figure: Icosahedron = preload("res://game/gameplay/figure/Icosahedron.tscn").instantiate()
    add_child_autofree(figure)
    figure.despawn(0.1)
    assert_true(figure.despawning)
    assert_false(figure.scaling_enabled)
    assert_false(figure.is_queued_for_deletion())
    await wait_seconds(0.2)
    assert_false(is_instance_valid(figure))
