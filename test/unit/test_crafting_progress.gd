extends GutTest


func test_only_completed_recipes_count_and_reset_clears_progress() -> void:
    var run := RunState.new()
    var system := run.modifier_system
    system.collect(run, UpgradeCatalog.pickup("points"))
    system.collect(run, UpgradeCatalog.pickup("forge"))
    system.collect(run, UpgradeCatalog.pickup("points"))
    assert_eq(run.crafts_completed, 0)
    system.collect(run, UpgradeCatalog.pickup("forge"))
    system.collect(run, UpgradeCatalog.pickup("tier"))
    assert_eq(run.crafts_completed, 0)
    system.collect(run, UpgradeCatalog.pickup("points"))
    assert_eq(run.crafts_completed, 1)
    system.collect(run, UpgradeCatalog.pickup("forge", 4))
    for i in 3:
        system.collect(run, UpgradeCatalog.pickup("tier"))
        assert_eq(run.crafts_completed, 2 if i == 2 else 1)
    system.discard_forge()
    assert_eq(run.crafts_completed, 2)
    run.reset()
    assert_eq(run.crafts_completed, 0)


func test_crafting_completion_uses_config_and_only_completes_level_two() -> void:
    var previous = UpgradeCatalog.data.crafts_required_for_level_3
    UpgradeCatalog.data.crafts_required_for_level_3 = 2
    var run := RunState.new()
    run.difficulty = 1
    for i in 3:
        run.modifier_system.collect(run, UpgradeCatalog.pickup("forge"))
        run.modifier_system.collect(run, UpgradeCatalog.pickup("points"))
        assert_eq(run.level_complete(false), i > 1)
        run.modifier_system.collect(run, UpgradeCatalog.pickup("points"))
        assert_eq(run.crafts_completed, mini(i + 1, 2))
        assert_eq(run.level_complete(false), i >= 1)
    run.difficulty = 2
    assert_false(run.level_complete(false))
    UpgradeCatalog.data.crafts_required_for_level_3 = previous
