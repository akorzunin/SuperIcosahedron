extends GutTest

const LAB := preload("res://dev/labs/modifiers/ModifiersLab.tscn")
var lab: Control


func before_each() -> void:
    lab = LAB.instantiate()
    add_child_autofree(lab)


func test_replay_banks_real_chain_and_reset_keeps_sequence() -> void:
    lab.sequence = [
        { "id": "tier", "steps": -1 },
        { "id": "points", "steps": -1 },
        { "id": "points", "steps": -1 },
    ]
    lab.step_sequence()
    lab.step_sequence()
    assert_eq(lab.run_state.score, 0)
    assert_eq(lab.run_state.charges_completed, 0)
    assert_eq(lab.run_state.tiers_collected, 2)
    lab.step_sequence()
    var score: int = lab.run_state.score
    assert_gt(score, 0)
    assert_eq(lab.run_state.charges_completed, 1)
    lab.replay()
    assert_eq(lab.run_state.score, score)
    lab.reset_state()
    assert_eq(lab.history.item_count, 0)
    assert_eq(lab.sequence.size(), 3)
    assert_eq(lab.run_state.score, 0)


func test_empty_passage_loses_all_in_and_completion_stays_inspectable() -> void:
    lab.inputs.charges_completed.value = RunState.required_charges() - 1
    lab.reset_state()
    for id in ["tier", "points", "points"]:
        lab.activate({ "id": id, "steps": -1 })
    assert_true(lab.run_state.level_complete(false))
    assert_false(lab.run_state.ended)
    lab.activate({ "id": "tier", "steps": -1 })
    lab.activate({ "id": "all_in", "steps": -1 })
    lab.activate({ "id": "", "steps": -1 })
    assert_false(lab.run_state.modifier_system.pending)
    assert_string_contains(lab.log_view.text, "All-in lost")
    assert_eq(lab.run_state.figures_passed, 6)


func test_preview_uses_production_faces_and_tracks_strength() -> void:
    assert_true(lab.preview.figure is Icosahedron)
    assert_eq(lab.preview.face_indices.size(), UpgradeCatalog.data.pickups.size())
    lab.preview.modifier_selected.emit(1)
    assert_eq(lab.selected_modifier, 1)
    lab.strength.select(lab.strength.item_count - 1)
    lab.strength.item_selected.emit(lab.strength.selected)
    var face: SideData = lab.preview.figure.data.sides[2]
    assert_eq(face.modifier.pickup_value, 5)
    lab.play_selected()
    assert_eq(
        lab.run_state.score,
        int(UpgradeCatalog.data.points_by_tier[face.modifier.pickup_value - 1]),
    )


func test_hiding_preview_preserves_selection_and_passage_controls() -> void:
    lab.preview.modifier_selected.emit(1)
    var toggle := lab.find_child("PreviewToggle", true, false) as CheckButton
    assert_false(lab.preview.visible)
    toggle.button_pressed = true
    assert_true(lab.preview.visible)
    toggle.button_pressed = false
    assert_false(lab.preview.visible)
    assert_eq(toggle.focus_mode, Control.FOCUS_NONE)
    lab.play_selected()
    assert_false(lab.run_state.modifier_system.pending)
    assert_gt(lab.run_state.score, 0)
    assert_eq(lab.selected_modifier, 1)
    lab.reset_state()
    assert_false(lab.preview.visible)
    toggle.button_pressed = true
    assert_true(lab.preview.visible)
    assert_eq(lab.selected_modifier, 1)


func test_hover_selects_and_click_plays() -> void:
    var button: Button = lab.library.get_child(1)
    button.mouse_entered.emit()
    assert_eq(lab.selected_modifier, 1)
    assert_eq(lab.run_state.figures_passed, 0)
    button.pressed.emit()
    assert_eq(lab.run_state.figures_passed, 1)
    assert_eq(lab.played[0].id, UpgradeCatalog.data.pickups[1].id)


func test_r_clears_preset_points_and_pending_chain() -> void:
    lab.load_preset(1)
    lab.inputs.score.value = 123
    lab.reset_state()
    var event := InputEventKey.new()
    event.physical_keycode = KEY_R
    event.pressed = true
    lab.get_viewport().push_input(event)
    assert_eq(lab.run_state.score, 0)
    assert_false(lab.run_state.modifier_system.pending)
    assert_eq(lab.history.item_count, 0)
    assert_eq(lab.sequence.size(), 3)


func test_save_played_replaces_sequence_and_preserves_actual_start() -> void:
    lab.activate({ "id": "points", "steps": -1 })
    lab.activate({ "id": "", "steps": -1 })
    lab.inputs.score.value = 999
    lab.save_played()
    assert_eq(lab.sequence, lab.played)
    assert_eq(int(lab.inputs.score.value), 0)
    lab.reset_fresh()
    assert_true(lab.played.is_empty())
    assert_eq(lab.sequence.size(), 2)


func test_space_uses_passage_path() -> void:
    lab.library.get_child(1).mouse_entered.emit()
    var event := InputEventKey.new()
    event.physical_keycode = KEY_SPACE
    event.pressed = true
    lab.get_viewport().push_input(event)
    assert_eq(lab.run_state.figures_passed, 1)
    assert_false(lab.run_state.modifier_system.pending)
    assert_gt(lab.run_state.score, 0)
