extends GutTest


func test_plain_points_score_immediately() -> void:
    var run := RunState.new()
    run.modifier_system.collect(run, UpgradeCatalog.pickup("points"))
    assert_eq(run.score, 100)
    assert_false(run.modifier_system.pending)
    assert_eq(run.modifier_system.pending_points(), 0)


func test_tier_charges_then_banks_upgraded_points() -> void:
    var run := RunState.new()
    var effect := UpgradeCatalog.pickup("tier").duplicate() as ModifierData
    effect.pickup_value = 2
    run.modifier_system.collect(run, effect)
    assert_eq(run.modifier_system.pending_points(), 0)
    run.modifier_system.collect(run, UpgradeCatalog.pickup("points"))
    assert_eq(run.score, 0)
    assert_eq(run.modifier_system.pending_points(), 250)
    run.modifier_system.collect(run, UpgradeCatalog.pickup("points"))
    assert_eq(run.score, 500)
    assert_false(run.modifier_system.pending)
    assert_eq(run.charges_completed, 1)


func test_replacement_preserves_points_and_replaces_strength() -> void:
    var run := RunState.new()
    var effect := UpgradeCatalog.pickup("tier").duplicate() as ModifierData
    effect.pickup_value = 2
    run.modifier_system.collect(run, effect)
    run.modifier_system.collect(run, UpgradeCatalog.pickup("points"))
    effect.pickup_value = 1
    run.modifier_system.collect(run, effect)
    assert_eq(run.modifier_system.pending_points(), 250)
    assert_eq(run.modifier_system.tier_remaining, 1)
    run.modifier_system.collect(run, UpgradeCatalog.pickup("points"))
    assert_eq(run.score, 500)
