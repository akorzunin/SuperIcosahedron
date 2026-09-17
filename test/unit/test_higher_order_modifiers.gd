extends GutTest


func test_echo_arms_without_chain_and_doubles_points_once() -> void:
    var run := RunState.new()
    for id in ["echo", "echo", "green"]:
        run.modifier_system.collect(run, UpgradeCatalog.pickup(id))
    assert_string_contains(run.modifier_system.summary(), "ECHO READY")
    run.modifier_system.collect(run, UpgradeCatalog.pickup("points"))
    assert_eq(run.score, 200)
    assert_false(run.modifier_system.echo_pending)
    run.modifier_system.collect(run, UpgradeCatalog.pickup("points"))
    assert_eq(run.score, 300)


func test_echo_points_double_reward_not_charge_consumption() -> void:
    var run := RunState.new()
    for id in ["tier", "echo", "points"]:
        run.modifier_system.collect(run, UpgradeCatalog.pickup(id))
    assert_eq(run.modifier_system.pending_points(), 500)
    assert_eq(run.modifier_system.tier_remaining, 1)
    assert_false(run.modifier_system.echo_pending)


func test_all_in_banks_early_and_bypasses_forge_storage() -> void:
    var run := RunState.new()
    run.modifier_system.collect(run, UpgradeCatalog.pickup("tier", 5))
    for id in ["points", "forge", "all_in", "points"]:
        run.modifier_system.collect(run, UpgradeCatalog.pickup(id))
    assert_eq(run.score, 1000)
    assert_false(run.modifier_system.pending)
    assert_false(run.modifier_system.all_in)
    assert_eq(run.modifier_system.forge_count, 0)
    assert_eq(run.modifier_system.forge_slots, 2)
    assert_eq(run.charges_completed, 1)


func test_inversion_doubles_existing_pot_and_survives_next_points() -> void:
    var run := RunState.new()
    for id in ["tier", "points", "inversion"]:
        run.modifier_system.collect(run, UpgradeCatalog.pickup(id))
    assert_eq(run.modifier_system.pending_points(), -500)
    assert_string_contains(run.modifier_system.summary(), "CONVERT BEFORE BANKING")
    run.modifier_system.collect(run, UpgradeCatalog.pickup("inversion"))
    assert_eq(run.modifier_system.pending_points(), 1000)
    assert_eq(run.tiers_collected, 2, "INVERSION no longer grants a phantom tier")
    run.modifier_system.collect(run, UpgradeCatalog.pickup("points"))
    assert_eq(run.score, 1250)


func test_inversion_risk_can_be_converted_or_banked_negative() -> void:
    for convert in [false, true]:
        var run := RunState.new()
        for id in ["tier", "points", "inversion"]:
            run.modifier_system.collect(run, UpgradeCatalog.pickup(id))
        if convert:
            run.modifier_system.collect(run, UpgradeCatalog.pickup("green"))
        run.modifier_system.collect(run, UpgradeCatalog.pickup("points"))
        assert_eq(run.score, 750 if convert else -750)


func test_special_names_and_strengths() -> void:
    for id in ["echo", "all_in", "inversion"]:
        var pickup := UpgradeCatalog.pickup(id)
        assert_eq(pickup.title, id.to_upper().replace("_", "-"))
        assert_eq(pickup.pickup_value, 2)
        for steps in 6:
            assert_eq(UpgradeCatalog.pickup(id, steps).pickup_value, 2)
