extends GutTest

func _collect(run: RunState, id: String, figure_id: int) -> void:
    var figure := FigureData.new()
    var side := SideData.new().init(0, Vector3.RIGHT, SideData.Kind.POSITIVE, UpgradeCatalog.pickup(id))
    figure.sides.append(side)
    run.register_figure(figure)
    assert_eq(run.resolve_side(figure_id, side), RunState.Outcome.PASSED)
    assert_eq(run.resolve_side(figure_id, side), RunState.Outcome.IGNORED)

func test_commit_applies_previous_chain_then_resets() -> void:
    var run := RunState.new()
    _collect(run, "points", 1)
    _collect(run, "tier", 2)
    _collect(run, "red", 3)
    assert_eq(run.score, 0)
    _collect(run, "points", 4)
    assert_eq(run.score, -250)
    assert_true(run.modifier_system.pending)
    assert_eq(run.modifier_system.tier, 1)
    assert_eq(run.modifier_system.sign_value, 1)
    _collect(run, "points", 5)
    assert_eq(run.score, -150)

func test_orphans_repeated_signs_cap_death_and_restart() -> void:
    var run := RunState.new()
    _collect(run, "tier", 1)
    _collect(run, "red", 2)
    assert_false(run.modifier_system.pending)
    _collect(run, "points", 3)
    for i in 10:
        _collect(run, "tier", 4 + i)
    assert_eq(run.modifier_system.tier, UpgradeCatalog.data.points_by_tier.size())
    _collect(run, "red", 14)
    _collect(run, "red", 15)
    _collect(run, "green", 16)
    assert_eq(run.modifier_system.sign_value, 1)
    var wall := SideData.new().init(0, Vector3.RIGHT, SideData.Kind.SOLID)
    assert_eq(run.resolve_side(17, wall), RunState.Outcome.GAME_OVER)
    assert_false(run.modifier_system.pending)
    assert_eq(run.score, 0)
    run.reset()
    assert_eq(run.modifier_system.last_activation, "")
    assert_eq(run.modifier_system.tier, 1)
    assert_eq(run.collected_sides.size(), 0)
    _collect(run, "points", 1)

func test_seeded_choices_always_offer_a_base() -> void:
    var a := RandomNumberGenerator.new()
    var b := RandomNumberGenerator.new()
    a.seed = 91
    b.seed = 91
    for i in 20:
        var first := StageGenerator.create_modifier_figure(a, i > 0)
        var second := StageGenerator.create_modifier_figure(b, i > 0)
        var choices := 0
        var bases := 0
        for j in 20:
            var side := first.sides[j]
            assert_eq(side.kind, second.sides[j].kind)
            if side.is_empty():
                choices += 1
                assert_eq(side.modifier.id, second.sides[j].modifier.id)
                if side.modifier.pickup_kind == "base":
                    bases += 1
                if i == 0:
                    assert_eq(side.modifier.pickup_kind, "base")
            else:
                assert_null(side.modifier)
        assert_eq(choices, int(UpgradeCatalog.data.choices_per_figure))
        assert_gte(bases, 1)
        var openings := first.sides.filter(func(side): return side.is_empty())
        for x in openings.size():
            for y in range(x + 1, openings.size()):
                assert_lt(openings[x].normal.dot(openings[y].normal), 0.74,
                    "Openings must retain solid borders for single-sector clearance")
