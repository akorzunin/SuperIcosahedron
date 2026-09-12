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
    assert_eq(run.figures_passed, 0)
    _collect(run, "points", 1)

func test_easy_point_is_sometimes_open_and_sometimes_blocked() -> void:
    var rng := RandomNumberGenerator.new()
    rng.seed = 91
    for center in 20:
        var open_count := 0
        for i in 100:
            var figure := StageGenerator.create_modifier_figure(rng, true, center, i)
            if figure.sides[center].is_empty():
                open_count += 1
        assert_between(open_count, 1, 99, "No center guarantees AFK passage")

func test_seeded_distance_placement_and_dynamic_easy_zone() -> void:
    var a := RandomNumberGenerator.new()
    var b := RandomNumberGenerator.new()
    a.seed = 91
    b.seed = 91
    for i in 20:
        var progress := i
        var first := StageGenerator.create_modifier_figure(a, i > 0, i, progress)
        var second := StageGenerator.create_modifier_figure(b, i > 0, i, progress)
        var steps := FaceTopology.distances(i)
        var level: Dictionary = UpgradeCatalog.data.difficulty_levels[first.stage]
        var easy_open := 0
        var bases := 0
        var tiers := 0
        assert_null(first.sides[i].modifier, "An open center preserves the pending chain")
        for j in 20:
            var side := first.sides[j]
            assert_eq(side.kind, second.sides[j].kind)
            if side.is_empty() and steps[j] <= 1:
                easy_open += 1
            if side.modifier:
                var pickup := side.modifier
                assert_eq(pickup.id, second.sides[j].modifier.id)
                var entry: Dictionary = UpgradeCatalog.data.pickups.filter(func(item): return item.id == pickup.id)[0]
                assert_between(steps[j], int(entry.min_steps), int(entry.max_steps))
                assert_eq(pickup.pickup_value, int(entry.value_by_steps[steps[j]]))
                if pickup.pickup_kind == "base":
                    bases += 1
                if pickup.pickup_kind == "tier":
                    tiers += 1
                if i == 0:
                    assert_eq(pickup.pickup_kind, "base")
            else:
                assert_null(second.sides[j].modifier)
        assert_between(easy_open, int(level.easy_open_faces[0]), int(level.easy_open_faces[1]))
        assert_gte(bases, 1)
        if i > 0:
            assert_gte(tiers, 1)

func test_difficulty_counts_only_collected_tier_units() -> void:
    var run := RunState.new()
    _collect(run, "points", 1)
    for i in 10:
        _collect(run, "green", 2 + i)
    assert_eq(run.difficulty, 0)
    _collect(run, "tier", 12)
    _collect(run, "tier", 13)
    assert_eq(run.difficulty, 0)
    _collect(run, "tier", 14)
    assert_eq(run.difficulty, 1)
    _collect(run, "points", 15)
    assert_eq(run.difficulty, 1, "Committing a chain does not reset difficulty")
    for i in 5:
        _collect(run, "tier", 16 + i)
    assert_eq(run.difficulty, 2)
    assert_eq(run.tiers_collected, 8)
    run.reset()
    assert_eq(run.difficulty, 0)
    assert_eq(run.tiers_collected, 0)

func test_neutral_pass_keeps_chain_and_difficulty() -> void:
    var run := RunState.new()
    _collect(run, "points", 1)
    _collect(run, "tier", 2)
    var route := SideData.new().init(0, Vector3.RIGHT, SideData.Kind.POSITIVE)
    assert_eq(run.resolve_side(3, route), RunState.Outcome.PASSED)
    assert_eq(run.resolve_side(3, route), RunState.Outcome.IGNORED)
    assert_eq(run.modifier_system.tier, 2)
    assert_eq(run.tiers_collected, 1)
    assert_eq(run.difficulty, 0)
    assert_eq(run.score, 0)

func test_far_pickups_grant_stronger_base_and_tier_values() -> void:
    var run := RunState.new()
    run.modifier_system.collect(run, UpgradeCatalog.pickup("points", 4))
    assert_eq(run.modifier_system.tier, 4)
    run.modifier_system.collect(run, UpgradeCatalog.pickup("tier", 5))
    assert_eq(run.modifier_system.tier, 7)
    assert_eq(run.tiers_collected, 3)
    run.modifier_system.collect(run, UpgradeCatalog.pickup("points", 1))
    assert_eq(run.score, 8000)
    assert_eq(run.modifier_system.tier, 1)
