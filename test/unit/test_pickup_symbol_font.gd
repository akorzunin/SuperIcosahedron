extends GutTest


func test_pickup_symbols_do_not_require_system_font_fallback() -> void:
    var font = load("res://game/game-assets/fonts/noto-sans-symbols/NotoSansSymbols2-Regular.ttf").duplicate()
    font.allow_system_fallback = false
    assert_true(font.has_char("◆".unicode_at(0)), "Pickup diamond must be bundled")
    assert_true(font.has_char("□".unicode_at(0)), "Forge slot must be bundled")
