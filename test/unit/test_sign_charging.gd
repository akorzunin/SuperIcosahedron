extends GutTest


func take(run: RunState, id: String) -> void:
    run.modifier_system.collect(run, UpgradeCatalog.pickup(id))


func charged_run(strength: int = 2) -> RunState:
    var run := RunState.new()
    var effect := UpgradeCatalog.pickup("tier").duplicate() as ModifierData
    effect.pickup_value = strength
    run.modifier_system.collect(run, effect)
    return run


func test_positive_sign_keeps_bonus_without_banking_early() -> void:
    var run := charged_run()
    take(run, "red")
    take(run, "points")
    assert_eq(run.modifier_system.pending_points(), -500)
    take(run, "green")
    assert_eq(run.modifier_system.pending_points(), 500)
    assert_eq(run.score, 0)
    assert_true(run.modifier_system.pending)
    assert_eq(run.modifier_system.tier_remaining, 1)
    take(run, "points")
    assert_eq(run.score, 1000)
    assert_false(run.modifier_system.pending)
    assert_eq(run.charges_completed, 1)
    take(run, "points")
    assert_eq(run.score, 1100, "Bonus ends when the chain banks")


func test_unconverted_chain_banks_negative_total() -> void:
    var run := charged_run()
    take(run, "red")
    take(run, "points")
    take(run, "points")
    assert_eq(run.score, -1000)
    assert_false(run.modifier_system.pending)
    take(run, "green")
    assert_eq(run.score, -1000, "Conversion must happen before banking")


func test_repeated_signs_do_not_stack_bonus() -> void:
    var run := charged_run()
    for id in ["red", "red", "green", "red", "green", "points", "points"]:
        take(run, id)
    assert_eq(run.score, 1000)


func test_bonus_only_upgrades_subsequent_points() -> void:
    var run := charged_run(3)
    take(run, "points")
    take(run, "red")
    assert_eq(run.modifier_system.pending_points(), -250)
    take(run, "points")
    assert_eq(run.modifier_system.pending_points(), -750)
    take(run, "green")
    take(run, "points")
    assert_eq(run.score, 1250)


func test_discard_clears_sign_bonus() -> void:
    var run := charged_run()
    take(run, "red")
    run.modifier_system.discard_chain()
    take(run, "points")
    assert_eq(run.score, 100)
    assert_eq(run.modifier_system.points_multiplier, 1)
