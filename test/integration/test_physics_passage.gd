extends GutTest

const RUN_LAB := preload("res://dev/labs/run/RunLab.tscn")
var lab: Node
var gameplay: LoopScene
var previous_settings: Dictionary
var previous_data: Dictionary

func before_each() -> void:
    previous_settings = G.settings
    previous_data = G.data
    G.settings = SettingsConfig.config_to_dict(SettingsConfig.set_default_config_values(ConfigFile.new()))
    G.data = {}
    # These collision fixtures explicitly place individual shells independently.
    G.settings.SPAWN_MODE = PatternGen.SpawnMode.DEBUG
    lab = RUN_LAB.instantiate()
    add_child(lab)
    gameplay = lab.get_node("Gameplay")
    gameplay.get_node("LoopTimer").stop()
    gameplay.get_node("ScaleTimer").stop()
    await wait_physics_frames(3)

func after_each() -> void:
    lab.queue_free()
    await wait_physics_frames(3)
    G.settings = previous_settings
    G.data = previous_data

func test_solid_dent_contact_ends_game(side_id = use_parameters([
    0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19
])) -> void:
    var figure := _replace_figure((side_id + 1) % 20)
    assert_false(figure.data.sides[side_id].is_empty())
    _face_player(figure, side_id)
    assert_null(gameplay.get_node("EndDetector").get_passing_side(figure))
    await _grow_through_player(figure)
    assert_eq(gameplay.game_state_manager.game_state, GameStateManager.GameState.GAME_END)
    assert_eq(gameplay.progress.figures_passed, 0)
    assert_eq(gameplay.progress.score, 0)

func test_empty_dent_passes_and_hands_control_to_next_figure(side_id = use_parameters([
    0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19
])) -> void:
    gameplay.figure_root.clean_all(true)
    var data := StageGenerator.create_figure(side_id)
    var figure: Icosahedron = LoopSpawner.IcosahedronScene.instantiate().with_data(data)
    gameplay.progress.register_figure(data)
    gameplay.figure_root.add_figure(figure)
    gameplay.controls.update_controlled_node()
    _face_player(figure, side_id)
    gameplay.spawner.spawn_icosahedron()
    var next := gameplay.figure_root.get_live_figures()[1].mesh_icosahedron
    assert_eq(gameplay.get_node("EndDetector").get_passing_side(figure), data.sides[side_id])
    if side_id % 2 == 0:
        gameplay.controls.advance_control()
        assert_true(figure.mesh_icosahedron.angle_good)
    await _grow_through_player(figure)
    assert_eq(gameplay.game_state_manager.game_state, GameStateManager.GameState.GAME_ACTIVE)
    assert_eq(gameplay.progress.figures_passed, 1)
    assert_eq(gameplay.progress.score, 1)
    assert_eq(gameplay.controls.controlledNode, next)
    await wait_physics_frames(3)
    assert_eq(gameplay.progress.figures_passed, 1, "Passage must be scored only once.")

func test_touching_solid_edge_of_empty_dent_ends_game() -> void:
    # Explicit single opening: procedural choices can open both sides of an edge.
    var figure := _replace_figure(0)
    var empty := figure.data.sides.filter(func(side: SideData): return side.is_empty())[0] as SideData
    var points := figure.mesh_icosahedron.get_side_points(empty.id)
    var edge := ((points[1] + points[2]) / 2.0).normalized()
    var detector: EndDetector = gameplay.get_node("EndDetector")
    var direction := (detector.global_position - figure.global_position).normalized()
    figure.mesh_icosahedron.global_basis = Basis(Quaternion(edge, direction))
    await _grow_through_player(figure)
    assert_eq(gameplay.game_state_manager.game_state, GameStateManager.GameState.GAME_END)
    assert_eq(gameplay.progress.figures_passed, 0)

func test_adjacent_openings_allow_centered_border_commit_and_pass() -> void:
    var figure := _replace_figure(0)
    var neighbor := FaceTopology.neighbors(0)[0]
    figure.data.sides[neighbor].kind = SideData.Kind.POSITIVE
    figure.data.sides[neighbor].modifier = null
    figure.data.sides[neighbor].modifier_entity = 0
    figure.mesh_icosahedron.apply_side_data(figure.data.sides)
    var detector: EndDetector = gameplay.get_node("EndDetector")
    var edge_direction := (FaceTopology.normal(0) + FaceTopology.normal(neighbor)).normalized()
    var toward_player := (detector.global_position - figure.global_position).normalized()
    figure.mesh_icosahedron.global_basis = Basis(Quaternion(edge_direction, toward_player))
    assert_not_null(detector.get_passing_side(figure), "No invisible wall between adjacent openings")
    gameplay.controls.update_controlled_node()
    gameplay.controls.advance_control()
    assert_true(figure.mesh_icosahedron.angle_good)
    await _grow_through_player(figure)
    assert_eq(gameplay.progress.figures_passed, 1)
    assert_eq(gameplay.progress.collected_sides.size(), 1)
    assert_eq(gameplay.game_state_manager.game_state, GameStateManager.GameState.GAME_ACTIVE)

func test_no_collision_before_visible_dent_reaches_player() -> void:
    var figure := gameplay.figure_root.get_live_figures()[0]
    var solid := figure.data.sides.filter(func(side: SideData): return not side.is_empty())[0] as SideData
    _face_player(figure, solid.id)
    var detector: EndDetector = gameplay.get_node("EndDetector")
    var direction := (detector.global_position - figure.global_position).normalized()
    var shape: ConvexPolygonShape3D = detector.get_node("CollisionShape3D").shape
    var support := 0.0
    for point in shape.points:
        support = maxf(support, absf(direction.dot(detector.global_basis * point)))
    var face_distance := figure.mesh_icosahedron.get_side_points(solid.id)[1].dot(solid.normal)
    var safe_scale := (figure.global_position.distance_to(detector.global_position) - support - 0.5) / face_distance
    figure.scale = Vector3.ONE * safe_scale
    await wait_physics_frames(5)
    assert_eq(gameplay.game_state_manager.game_state, GameStateManager.GameState.GAME_ACTIVE,
        "The bounding box must not end the run before the visible dent arrives.")
    if is_instance_valid(figure):
        assert_false(figure.resolved)

func test_same_tick_pass_is_not_lost_to_next_figures_failure() -> void:
    var first := gameplay.figure_root.get_live_figures()[0]
    var empty := first.data.sides.filter(func(side: SideData): return side.is_empty())[0] as SideData
    _face_player(first, empty.id)
    gameplay.spawner.spawn_icosahedron()
    var second := gameplay.figure_root.get_live_figures()[1]
    var solid := second.data.sides.filter(func(side: SideData): return not side.is_empty())[0] as SideData
    _face_player(second, solid.id)
    # Both shells enter the detector in one physics update.
    first.scale = Vector3.ONE * 18.0
    second.scale = Vector3.ONE * 18.0
    await wait_physics_frames(5)
    assert_eq(gameplay.progress.figures_passed, 1, "Resolve contacts in figure order, not all solids first.")
    assert_eq(gameplay.game_state_manager.game_state, GameStateManager.GameState.GAME_END)

func test_sustained_overlapping_passes_do_not_auto_fail() -> void:
    var spawned := 1
    for tick in range(400):
        if gameplay.game_state_manager.game_state != GameStateManager.GameState.GAME_ACTIVE:
            break
        if tick % 8 == 0 and spawned < 24:
            gameplay.spawner.spawn_icosahedron()
            spawned += 1
        gameplay.controls.update_controlled_node()
        var target := gameplay.controls.controlledNode
        if is_instance_valid(target):
            var figure := target.icosahedron
            var empty := figure.data.sides.filter(func(side: SideData): return side.is_empty())[0] as SideData
            _face_player(figure, empty.id)
            # Alternate early commits and natural passage; keep several shells alive.
            if spawned % 2 == 0:
                gameplay.controls.advance_control()
        for figure in gameplay.figure_root.get_live_figures():
            figure.scale *= 1.08
        await wait_physics_frames(1)
        if gameplay.progress.figures_passed == 24:
            break
    assert_eq(gameplay.game_state_manager.game_state, GameStateManager.GameState.GAME_ACTIVE)
    assert_eq(gameplay.progress.figures_passed, 24)
    assert_eq(gameplay.progress.collected_sides.size(), 24,
        "Each physical passage collects exactly once; modifier chains determine score.")

func test_off_center_hole_clearance(sample = use_parameters([
    [0, 0.35, true], [7, 0.35, true], [14, 0.35, true],
    [0, 0.95, true], [7, 0.95, true], [14, 0.95, true],
    [0, 0.99, false], [7, 0.99, false], [14, 0.99, false]
])) -> void:
    var figure := _replace_figure(sample[0])
    var dent := figure.mesh_icosahedron.get_dents()[sample[0]]
    var vertices: PackedVector3Array = dent.mesh.surface_get_arrays(0)[Mesh.ARRAY_VERTEX]
    var center := (vertices[0] + vertices[1] + vertices[2]) / 3.0
    var edge := (vertices[1] + vertices[2]) / 2.0
    var aim := (dent.basis * center.lerp(edge, sample[1])).normalized()
    var detector: EndDetector = gameplay.get_node("EndDetector")
    var direction := (detector.global_position - figure.global_position).normalized()
    figure.mesh_icosahedron.global_basis = Basis(Quaternion(aim, direction))
    var predicted: bool = gameplay.get_node("EndDetector").get_passing_side(figure) != null
    assert_eq(predicted, sample[2], "Commit prediction matches full-window clearance.")
    if predicted:
        gameplay.controls.advance_control()
        assert_true(figure.mesh_icosahedron.angle_good)
    # Fine growth steps exercise grazing contacts, not just integer-scale jumps.
    for tick in range(260):
        if not is_instance_valid(figure) or figure.resolved:
            break
        figure.scale *= 1.02
        await wait_physics_frames(1)
    assert_eq(gameplay.progress.figures_passed, 1 if sample[2] else 0)
    assert_eq(gameplay.game_state_manager.game_state,
        GameStateManager.GameState.GAME_ACTIVE if sample[2] else GameStateManager.GameState.GAME_END)

func test_window_is_small_and_parallel_to_gameplay_camera() -> void:
    var camera: Camera3D = gameplay.get_node("Environment/Camera3D")
    var detector: EndDetector = gameplay.get_node("EndDetector")
    var window: ConvexPolygonShape3D = detector.get_node("CollisionShape3D").shape
    assert_true(detector.global_basis.is_equal_approx(camera.global_basis))
    assert_almost_eq(camera.to_local(detector.global_position), Vector3(0, 0, -1), Vector3.ONE * 0.0001)
    assert_eq(window.points.size(), 64)
    for point in window.points:
        assert_almost_eq(Vector2(point.x, point.y).length(), EndDetector.WINDOW_RADIUS, 0.0001)
        assert_almost_eq(absf(point.z), EndDetector.WINDOW_DEPTH / 2.0, 0.0001)
    var target := detector.global_transform
    lab.collision_debug.set_observer(true)
    assert_true(detector.global_transform.is_equal_approx(target), "Observer must not move the hit window.")

func test_natural_growth_resolves_committed_hidden_hole_once() -> void:
    var figure := gameplay.figure_root.get_live_figures()[0]
    var empty := figure.data.sides.filter(func(side: SideData): return side.is_empty())[0] as SideData
    _face_player(figure, empty.id)
    gameplay.spawner.spawn_icosahedron()
    gameplay.controls.advance_control()
    await wait_seconds(MeshIcosahedron.FADE_TIME + 0.1)
    assert_false(figure.mesh_icosahedron.visible)
    assert_false(figure.resolved, "Commit/fade is not passage.")
    for tick in range(2000):
        if not is_instance_valid(figure) or figure.resolved:
            break
        figure._on_scale_tick()
        await wait_physics_frames(1)
    assert_eq(gameplay.progress.figures_passed, 1)
    assert_eq(gameplay.game_state_manager.game_state, GameStateManager.GameState.GAME_ACTIVE)
    await wait_physics_frames(5)
    assert_eq(gameplay.progress.figures_passed, 1)

func _replace_figure(stage: int) -> Icosahedron:
    gameplay.figure_root.clean_all(true)
    var data := StageGenerator.create_figure(stage)
    var figure: Icosahedron = LoopSpawner.IcosahedronScene.instantiate().with_data(data)
    gameplay.progress.register_figure(data)
    gameplay.figure_root.add_figure(figure)
    gameplay.controls.update_controlled_node()
    return figure

func _face_player(figure: Icosahedron, side_id: int) -> void:
    var detector: EndDetector = gameplay.get_node("EndDetector")
    # Align the rendered face, independently of the collision-side selection code.
    var dent := figure.mesh_icosahedron.get_dents()[side_id]
    var arrays := dent.mesh.surface_get_arrays(0)
    var vertices: PackedVector3Array = arrays[Mesh.ARRAY_VERTEX]
    var center := (vertices[0] + vertices[1] + vertices[2]) / 3.0
    var normal := (dent.basis * center).normalized()
    var direction := (detector.global_position - figure.global_position).normalized()
    var mesh_scale := figure.mesh_icosahedron.global_basis.get_scale()
    figure.mesh_icosahedron.global_basis = Basis(Quaternion(normal, direction)).scaled(mesh_scale)

func _grow_through_player(figure: Icosahedron) -> void:
    for size in range(2, 25):
        if not is_instance_valid(figure) or figure.resolved:
            break
        figure.scale = Vector3.ONE * size
        await wait_physics_frames(3)
