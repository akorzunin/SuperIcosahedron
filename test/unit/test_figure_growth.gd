extends GutTest

var previous_settings: Dictionary


func before_each() -> void:
    previous_settings = G.settings
    G.settings = SettingsConfig.config_to_dict(
        SettingsConfig.set_default_config_values(ConfigFile.new())
    )


func after_each() -> void:
    G.settings = previous_settings


func test_growth_is_independent_of_frame_rate() -> void:
    var sf: float = 1. + (G.settings.SCALE_FACTOR / 1000.) \
            * (0.5 + (G.settings.GAME_SPEED / (10. + G.settings.GAME_SPEED)))
    var expected := Vector3.ONE * pow(sf, 1.0 / ScaleTimer.tick_dur)
    for fps in [30, 60, 180]:
        var figure := Icosahedron.new()
        var timer := ScaleTimer.new()
        figure.scale_timer = timer
        timer.start()
        for frame in range(fps):
            figure.call("_process", 1.0 / fps)
        assert_almost_eq(figure.scale, expected, Vector3.ONE * 0.0001)
        figure.free()
        timer.free()


func test_disabled_growth_does_not_change_scale() -> void:
    var figure := Icosahedron.new()
    figure.scaling_enabled = false
    figure.call("_grow", 1.0)
    assert_eq(figure.scale, Vector3.ONE)
    figure.free()


func test_growth_requires_running_unpaused_timer() -> void:
    var figure := Icosahedron.new()
    figure.call("_process", 1.0)
    assert_eq(figure.scale, Vector3.ONE, "Menu figures must not grow.")
    var timer := ScaleTimer.new()
    figure.scale_timer = timer
    figure.call("_process", 1.0)
    assert_eq(figure.scale, Vector3.ONE, "Stopped figures must not grow.")
    timer.start()
    timer.paused = true
    figure.call("_process", 1.0)
    assert_eq(figure.scale, Vector3.ONE, "Paused figures must not grow.")
    figure.free()
    timer.free()
