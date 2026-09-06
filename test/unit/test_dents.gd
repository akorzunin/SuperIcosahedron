extends GutTest

const FIGURE_SCENE := preload("res://game/gameplay/figure/Icosahedron.tscn")

func test_generated_figure_has_one_scoring_empty_dent() -> void:
    var figure := StageGenerator.create_figure(7)
    var empty_sides := figure.sides.filter(func(side: SideData): return side.is_empty())

    assert_eq(figure.sides.size(), 20)
    assert_eq(empty_sides.size(), 1)
    assert_eq(empty_sides[0].id, 7)
    assert_eq(empty_sides[0].score_delta, 1)

    var run := RunState.new()
    run.register_figure(figure)
    assert_eq(run.resolve_side(1, empty_sides[0]), RunState.Outcome.PASSED)
    assert_eq(run.score, 1)

func test_dent_visibility_matches_its_side() -> void:
    var dent := Dent.new().init(0, null)
    var empty_side := SideData.new().init(0, Vector3.UP, SideData.Kind.POSITIVE)
    var solid_side := SideData.new().init(0, Vector3.UP, SideData.Kind.SOLID)

    dent.apply_data(empty_side)
    assert_true(dent.is_empty())
    assert_false(dent.visible)

    dent.apply_data(solid_side)
    assert_false(dent.is_empty())
    assert_true(dent.visible)
    dent.free()

func test_figure_is_built_from_twenty_dents_with_one_hole() -> void:
    var figure: Icosahedron = FIGURE_SCENE.instantiate().with_data(StageGenerator.create_figure(4))
    add_child_autofree(figure)
    await wait_process_frames(1)
    var dents := figure.mesh_icosahedron.get_dents()
    var hidden_dents := dents.filter(func(dent: Dent): return not dent.visible)

    assert_eq(dents.size(), 20)
    assert_eq(hidden_dents.size(), 1)
    assert_eq(hidden_dents[0].side_id, 4)
