extends GutTest


func test_mobile_explains_direction_and_central_buttons():
    var text := LoopGui.tutorial_instructions(true)
    assert_string_contains(text, "four direction buttons")
    assert_string_contains(text, "central buttons")
    assert_string_contains(text, "open gap")


func test_keyboard_explains_both_rotation_and_pass_shortcuts():
    var text := LoopGui.tutorial_instructions(false)
    assert_string_contains(text, "W, A, S, D")
    assert_string_contains(text, "arrow keys")
    assert_string_contains(text, "Space or Enter")
    assert_string_contains(text, "open gap")
