extends GutTest

var discoveries: Array
var pickups: Array


func before_each() -> void:
    discoveries = G.discovered_modifiers.duplicate()
    G.discovered_modifiers = []
    pickups = UpgradeCatalog.data.pickups.duplicate(true)
    for entry in UpgradeCatalog.data.pickups:
        entry.enabled = true


func after_each() -> void:
    G.discovered_modifiers = discoveries
    UpgradeCatalog.data.pickups = pickups


func test_disabled_pickups_are_hidden_and_not_generated() -> void:
    UpgradeCatalog.data.pickups = pickups.duplicate(true)
    assert_eq(
        UpgradeCatalog.enabled_pickups().map(
            func(entry):
                return entry.id,
        ),
        ["forge", "points", "tier"],
    )
    G.discovered_modifiers = ["echo", "inversion"]
    var section := MenuStruct.modifier_library_page(0)
    assert_eq(section.modifier_page_count, 1)
    assert_false(section.items.has(4))
    assert_false(section.items.has(7))
    for steps in 6:
        for difficulty in 4:
            for has_chain in [false, true]:
                for entry in UpgradeCatalog.eligible(steps, has_chain, difficulty):
                    assert_true(entry.kind in ["points", "tier", "forge"])
    for entry in UpgradeCatalog.data.pickups:
        entry.enabled = true
    assert_true(
        UpgradeCatalog.eligible(3, true, 2).any(
            func(entry):
                return entry.id == "echo",
        )
    )


func test_empty_library_uses_menu_items() -> void:
    var section := MenuStruct.modifier_library_page(0)
    assert_eq(section.modifier_page, 0)
    assert_eq(section.modifier_page_count, 2)
    assert_eq(section.items[1].name, "unknown")
    assert_eq(section.items[1].modifier_id, "")
    assert_eq(section.items[5].action, "menu_back")
    assert_true(section.items.has(7))


func test_library_pages_use_four_3d_menu_items() -> void:
    G.discovered_modifiers = UpgradeCatalog.data.pickups.map(
        func(entry):
            return entry.id,
    )
    var first := MenuStruct.modifier_library_page(0)
    var last := MenuStruct.modifier_library_page(99)
    assert_eq(first.modifier_page_count, 2)
    assert_eq(first.items[1].modifier_id, "forge")
    assert_eq(first.items[4].modifier_id, "red")
    assert_eq(first.items[7].action, "menu_modifier_library_next")
    assert_eq(last.modifier_page, 1)
    assert_eq(last.items[1].modifier_id, "tier")
    assert_eq(last.items[4].modifier_id, "inversion")
    assert_eq(last.items[6].action, "menu_modifier_library_previous")
    assert_false(last.items.has(7))


func test_discovery_keeps_fixed_slots_without_submenus() -> void:
    G.discovered_modifiers = ["inversion"]
    var first := MenuStruct.modifier_library_page(0)
    var last := MenuStruct.modifier_library_page(1)
    assert_eq(first.items[1].name, "unknown")
    assert_eq(last.items[4].modifier_id, "inversion")
    assert_eq(last.items[4].modifier_description, UpgradeCatalog.data.pickups[7].description)
    assert_false(last.items[4].has("items"))
    assert_eq(last.items[1].name, "unknown")
