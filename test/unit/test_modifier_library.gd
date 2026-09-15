extends GutTest

var discoveries: Array


func before_each() -> void:
    discoveries = G.discovered_modifiers.duplicate()
    G.discovered_modifiers = []


func after_each() -> void:
    G.discovered_modifiers = discoveries


func test_empty_library_uses_menu_items() -> void:
    var section := MenuStruct.modifier_library_page(0)
    assert_eq(section.modifier_page, 0)
    assert_eq(section.modifier_page_count, 1)
    assert_eq(section.items[1].name, "no modifiers\ndiscovered")
    assert_eq(section.items[5].action, "menu_back")
    assert_false(section.items.has(7))


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


func test_modifier_detail_requests_actual_3d_preview() -> void:
    var detail := MenuStruct.modifier_detail("inversion")
    assert_eq(detail.preview_modifier_id, "inversion")
    assert_eq(detail.modifier_description, UpgradeCatalog.data.pickups[7].description)
    assert_eq(detail.items[5].action, "menu_back")
