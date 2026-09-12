extends GutTest

func test_long_run_releases_retired_figure_objects() -> void:
    var run := RunState.new()
    var baseline := Performance.get_monitor(Performance.OBJECT_COUNT)
    for id in range(1000):
        var figure := StageGenerator.create_figure(0)
        run.register_figure(figure)
        var side := figure.sides.filter(func(s: SideData): return s.is_empty())[0] as SideData
        run.resolve_side(id, side)
        run.unregister_figure(id, figure)
    var growth := Performance.get_monitor(Performance.OBJECT_COUNT) - baseline
    assert_eq(run.figures_passed, 1000)
    assert_eq(run.modifier_system.world.components.size(), 0)
    assert_eq(run._resolved_figures.size(), 0)
    assert_lt(growth, 100.0,
        "Retired figures must not retain sides or modifiers across a long run.")

func test_old_figure_cleanup_does_not_remove_new_run_modifiers() -> void:
    var run := RunState.new()
    var old_figure := StageGenerator.create_figure(0)
    run.register_figure(old_figure)
    run.reset()
    var new_figure := StageGenerator.create_figure(0)
    run.register_figure(new_figure)
    var count := run.modifier_system.world.components.size()
    run.unregister_figure(1, old_figure)
    assert_eq(run.modifier_system.world.components.size(), count)
    run.unregister_figure(2, new_figure)
    assert_eq(run.modifier_system.world.components.size(), 0)

func test_collectible_resolves_once_per_figure() -> void:
    var run := RunState.new()
    var side := SideData.new()
    assert_eq(run.resolve_side(1, side), RunState.Outcome.PASSED)
    assert_eq(run.resolve_side(1, SideData.new()), RunState.Outcome.IGNORED)
    assert_eq(run.figures_passed, 1)

func test_solid_side_ends_run_and_prevents_further_collection() -> void:
    var run := RunState.new()
    var solid := SideData.new()
    solid.kind = SideData.Kind.SOLID
    assert_eq(run.resolve_side(1, solid), RunState.Outcome.GAME_OVER)
    assert_eq(run.resolve_side(2, SideData.new()), RunState.Outcome.IGNORED)
    assert_true(run.ended)
    assert_eq(run.figures_passed, 0)

func test_registered_modifier_changes_score() -> void:
    var run := RunState.new()
    var figure := FigureData.new()
    var side := SideData.new()
    side.modifier = ModifierData.new()
    side.modifier.score_value = 7
    figure.sides.append(side)
    run.register_figure(figure)
    run.resolve_side(1, side)
    assert_eq(run.score, 7)

func test_reset_accepts_fresh_figure_data_and_clears_run_state() -> void:
    var run := RunState.new()
    run.resolve_side(1, SideData.new())
    run.reset()
    assert_eq(run.figures_passed, 0)
    assert_eq(run.score, 0)
    assert_false(run.ended)
    assert_eq(run.resolve_side(1, SideData.new()), RunState.Outcome.PASSED)
