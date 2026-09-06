extends GutTest

func test_collectible_resolves_once_per_figure() -> void:
    var run := RunState.new()
    var side := SideData.new()
    assert_eq(run.resolve_side(1, side), RunState.Outcome.PASSED)
    assert_eq(run.resolve_side(1, SideData.new()), RunState.Outcome.IGNORED)
    assert_eq(run.figures_passed, 1)
    assert_eq(run.collected_sides.size(), 1)

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
    assert_eq(run.collected_sides.size(), 0)
    assert_false(run.ended)
    assert_eq(run.resolve_side(1, SideData.new()), RunState.Outcome.PASSED)
