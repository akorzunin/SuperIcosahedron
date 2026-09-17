extends GutTest


func take(run: RunState, id: String, steps: int = -1) -> void:
    run.modifier_system.collect(run, UpgradeCatalog.pickup(id, steps))


func test_points_craft_charges_active_chain_with_multiplied_points() -> void:
    for slots in [2, 3]:
        var run := RunState.new()
        take(run, "points")
        take(run, "tier")
        take(run, "forge", 2 if slots == 2 else 4)
        for i in slots - 1:
            take(run, "points")
            assert_eq(run.score, 100)
            assert_eq(run.modifier_system.tier_remaining, 2)
        take(run, "points")
        assert_eq(run.score, 100)
        assert_eq(run.charges_completed, 0)
        assert_eq(run.modifier_system.pending_points(), 250 * (1 << slots))
        assert_eq(run.modifier_system.forge_slots, 0)
        take(run, "points")
        assert_eq(run.score, 350 + 250 * (1 << slots))
        assert_eq(run.charges_completed, 1)
        assert_eq(run.modifier_system.points_multiplier, 1)


func test_tier_ingredients_save_echo_until_activation() -> void:
    var run := RunState.new()
    take(run, "tier")
    take(run, "forge")
    take(run, "tier", 2)
    take(run, "echo")
    assert_true(run.modifier_system.echo_pending)
    assert_eq(run.modifier_system.tier, 1)
    take(run, "tier", 5)
    assert_eq(run.tiers_collected, 10, "Initial 2 plus first ingredient +1 ×4, then Echo ×2")
    assert_eq(run.modifier_system.tier_remaining, 8)
    assert_false(run.modifier_system.echo_pending)


func test_nonmatching_activations_and_repeated_forge_keep_recipe() -> void:
    var run := RunState.new()
    take(run, "points")
    take(run, "forge")
    take(run, "points", 3)
    take(run, "echo")
    take(run, "tier")
    assert_false(run.modifier_system.echo_pending)
    assert_eq(run.modifier_system.tier_remaining, 4)
    take(run, "forge", 5)
    assert_eq(run.modifier_system.forge_slots, 2)
    assert_eq(run.modifier_system.forge_count, 1)
    take(run, "points", 1)
    assert_eq(run.score, 100)
    assert_eq(run.modifier_system.pending_points(), 4000, "First ingredient T3 upgraded to T4 ×4")


func test_forge_without_chain_neutral_pass_death_and_reset() -> void:
    var run := RunState.new()
    take(run, "forge")
    take(run, "points")
    run.modifier_system.apply_to(run, 0)
    assert_eq(run.modifier_system.forge_count, 1)
    assert_false(run.modifier_system.pending)
    assert_string_contains(run.modifier_system.summary(), "[POINTS] [ _ ]")
    var wall := SideData.new().init(0, Vector3.RIGHT, SideData.Kind.SOLID)
    run.resolve_side(1, wall)
    assert_eq(run.modifier_system.forge_slots, 0)
    run.reset()
    take(run, "forge")
    take(run, "points")
    run.reset()
    assert_eq(run.modifier_system.forge_slots, 0)
    assert_eq(run.modifier_system.forge_count, 0)


func test_all_in_banks_next_shell_without_consuming_recipe() -> void:
    var run := RunState.new()
    take(run, "tier")
    take(run, "forge")
    take(run, "all_in")
    take(run, "points")
    assert_false(run.modifier_system.all_in)
    assert_eq(run.score, 500)
    assert_eq(run.modifier_system.forge_count, 0)
    take(run, "points")
    assert_eq(run.score, 500)
    assert_eq(run.modifier_system.forge_count, 1)
    take(run, "tier")
    take(run, "all_in")
    take(run, "forge")
    assert_false(run.modifier_system.pending, "Forge is not Points; All-in loses its chain")


func test_forge_only_spawns_from_level_two() -> void:
    var rng := RandomNumberGenerator.new()
    rng.seed = 74
    var found := [0, 0]
    for level in 2:
        for i in 150:
            var figure := StageGenerator.create_modifier_figure(
                rng,
                true,
                i % 20,
                int(UpgradeCatalog.data.difficulty_levels[level].tiers_required),
            )
            for side in figure.sides:
                if side.modifier and side.modifier.pickup_kind == "forge":
                    found[level] += 1
                    assert_between(side.modifier.pickup_value, 1, 2)
    assert_eq(found[0], 0)
    assert_gt(found[1], 0)
