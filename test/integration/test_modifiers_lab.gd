extends GutTest

const LAB := preload("res://dev/labs/modifiers/ModifiersLab.tscn")
var lab: Control


func before_each() -> void:
    lab = LAB.instantiate()
    add_child_autofree(lab)


func test_replay_banks_real_chain_and_reset_keeps_sequence() -> void:
    lab.sequence = [
        { "id": "points", "steps": -1 },
        { "id": "tier", "steps": -1 },
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
    for id in ["points", "tier", "points"]:
        lab.activate({ "id": id, "steps": -1 })
    assert_true(lab.run_state.level_complete(false))
    assert_false(lab.run_state.ended)
    lab.activate({ "id": "all_in", "steps": -1 })
    lab.activate({ "id": "", "steps": -1 })
    assert_false(lab.run_state.modifier_system.pending)
    assert_string_contains(lab.log_view.text, "All-in lost")
    assert_eq(lab.run_state.figures_passed, 5)


func test_preview_uses_production_faces_and_tracks_strength() -> void:
    assert_true(lab.preview.figure is Icosahedron)
    assert_eq(lab.preview.face_indices.size(), UpgradeCatalog.data.pickups.size())
    lab.preview.modifier_selected.emit(1)
    assert_eq(lab.library.selected, 1)
    lab.strength.select(lab.strength.item_count - 1)
    lab.strength.item_selected.emit(lab.strength.selected)
    var face: SideData = lab.preview.figure.data.sides[2]
    assert_eq(face.modifier.pickup_value, 5)
    lab.play_selected()
    assert_eq(lab.run_state.modifier_system.tier, face.modifier.pickup_value)


func test_hiding_preview_preserves_selection_and_passage_controls() -> void:
    lab.preview.modifier_selected.emit(1)
    var toggle := lab.find_child("PreviewToggle", true, false) as CheckButton
    assert_true(lab.preview.visible)
    toggle.button_pressed = false
    assert_false(lab.preview.visible)
    assert_eq(toggle.focus_mode, Control.FOCUS_NONE)
    lab.play_selected()
    assert_true(lab.run_state.modifier_system.pending)
    assert_eq(lab.library.selected, 1)
    lab.reset_state()
    assert_false(lab.preview.visible)
    toggle.button_pressed = true
    assert_true(lab.preview.visible)
    assert_eq(lab.library.selected, 1)


func test_space_uses_passage_path() -> void:
    lab.library.select(1)
    lab.library.item_selected.emit(1)
    var event := InputEventKey.new()
    event.physical_keycode = KEY_SPACE
    event.pressed = true
    lab.get_viewport().push_input(event)
    assert_eq(lab.run_state.figures_passed, 1)
    assert_true(lab.run_state.modifier_system.pending)
