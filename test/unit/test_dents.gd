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

func test_burst_preserves_colliders_and_outlives_figure() -> void:
    var root := Node3D.new()
    add_child_autofree(root)
    var anchor := Node3D.new()
    root.add_child(anchor)
    var figure: Icosahedron = FIGURE_SCENE.instantiate().with_data(StageGenerator.create_figure(4))
    anchor.add_child(figure)
    await wait_process_frames(1)
    figure.mesh_icosahedron.fade_out()
    var burst := root.get_node("DentBurst")
    assert_eq(burst.get_child_count(), 19)
    assert_eq(figure.mesh_icosahedron.get_node("SideColliders").get_child_count(), 20)
    assert_false(figure.resolved)
    figure.mesh_icosahedron.burst_dents()
    assert_eq(root.get_child_count(), 2, "Repeated resolution must not duplicate fragments.")
    var first: Node3D = burst.get_child(0)
    var start := first.position
    var start_basis := first.basis
    await wait_seconds(0.15)
    assert_gt(first.position.length(), start.length(), "Dent flies outward.")
    assert_eq(first.basis, start_basis, "Dents translate without tumbling.")
    figure.despawn()
    await wait_process_frames(2)
    assert_true(is_instance_valid(burst), "Fragments survive shell cleanup.")
    await wait_seconds(0.65)
    assert_true(is_instance_valid(burst), "Burst stays visible longer than the old effect.")
    var material := (first as MeshInstance3D).material_override as ShaderMaterial
    var fragment_opacity: float = material.get_shader_parameter("opacity")
    assert_gt(fragment_opacity, 0.0, "Fragments remain visible during their fade.")
    assert_lt(fragment_opacity, 0.7, "Fragments fade before cleanup, even after shell removal.")
    await wait_seconds(0.5)
    assert_false(is_instance_valid(burst), "Fragments clean themselves up.")

func test_figure_is_built_from_twenty_dents_with_one_hole() -> void:
    var figure: Icosahedron = FIGURE_SCENE.instantiate().with_data(StageGenerator.create_figure(4))
    add_child_autofree(figure)
    await wait_process_frames(1)
    var dents := figure.mesh_icosahedron.get_dents()
    var hidden_dents := dents.filter(func(dent: Dent): return not dent.visible)

    assert_eq(dents.size(), 20)
    assert_eq(hidden_dents.size(), 1)
    assert_eq(hidden_dents[0].side_id, 4)

func test_control_cues_follow_open_dent_and_clear_on_handoff() -> void:
    var figure: Icosahedron = FIGURE_SCENE.instantiate().with_data(StageGenerator.create_figure(4))
    add_child_autofree(figure)
    await wait_process_frames(1)
    var shell := figure.mesh_icosahedron
    var marker := shell.get_node("OpenDentMarker") as MeshInstance3D
    assert_false(marker.visible)
    shell.set_controlled(true)
    assert_true(marker.visible)
    var points := shell.get_side_points(4)
    assert_almost_eq(marker.position, (points[1] + points[2] + points[3]) / 3.0 * 1.03, Vector3.ONE * 0.001)
    for dent in shell.get_dents():
        assert_true(dent.material_override.get_shader_parameter("controlled"))
    shell.apply_side_data(StageGenerator.create_figure(7).sides)
    points = shell.get_side_points(7)
    assert_almost_eq(marker.position, (points[1] + points[2] + points[3]) / 3.0 * 1.03, Vector3.ONE * 0.001)
    assert_false(shell.get_dents()[7].visible, "Marker must not fill the hole.")
    shell.set_controlled(false)
    assert_false(marker.visible)
    for dent in shell.get_dents():
        assert_false(dent.material_override.get_shader_parameter("controlled"))
