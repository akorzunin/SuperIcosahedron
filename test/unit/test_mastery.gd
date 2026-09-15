extends GutTest


func test_control_requirement_uses_config() -> void:
    var previous = UpgradeCatalog.data.controls_required_for_level_1
    UpgradeCatalog.data.controls_required_for_level_1 = 2
    assert_eq(RunState.required_controls(), 2)
    var run := RunState.new()
    for id in 4:
        var figure := StageGenerator.create_figure(0)
        run.register_figure(figure)
        run.tutorial_commits[id] = true
        run.resolve_side(id, figure.sides[0])
    assert_eq(run.controls_completed, 2, "Control progress caps at the configured requirement")
    UpgradeCatalog.data.controls_required_for_level_1 = previous


func test_points_do_not_earn_mastery_and_each_chain_counts_once() -> void:
    var run := RunState.new()
    var points := UpgradeCatalog.pickup("points")
    var tier := UpgradeCatalog.pickup("tier", 3)
    for i in 8:
        run.modifier_system.collect(run, points)
    assert_eq(run.charges_completed, 0)
    for i in 4:
        run.modifier_system.collect(run, tier)
        run.modifier_system.collect(run, tier)
        run.modifier_system.collect(run, points)
        assert_eq(run.charges_completed, mini(i + 1, 3))
    assert_eq(run.difficulty, 0)
    run.reset()
    assert_eq(run.charges_completed, 0)


func test_discard_loses_attempt_not_completed_marks() -> void:
    var run := RunState.new()
    var points := UpgradeCatalog.pickup("points")
    var tier := UpgradeCatalog.pickup("tier", 3)
    run.modifier_system.collect(run, points)
    run.modifier_system.collect(run, tier)
    run.modifier_system.collect(run, points)
    run.modifier_system.collect(run, tier)
    run.modifier_system.discard_chain()
    run.modifier_system.collect(run, points)
    assert_eq(run.charges_completed, 1)


func test_controls_require_confirmed_safe_passages() -> void:
    var run := RunState.new()
    var figure := StageGenerator.create_figure(0)
    run.register_figure(figure)
    run.resolve_side(1, figure.sides[0])
    assert_eq(run.controls_completed, 0)
    figure = StageGenerator.create_figure(0)
    run.register_figure(figure)
    run.tutorial_commits[2] = true
    run.resolve_side(2, figure.sides[0])
    run.resolve_side(2, figure.sides[0])
    assert_eq(run.controls_completed, 1)
    run.reset()
    assert_eq(run.controls_completed, 0)
