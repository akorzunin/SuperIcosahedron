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

func test_solid_dent_contact_ends_game() -> void:
    var figure := gameplay.figure_root.get_live_figures()[0]
    var solid := figure.data.sides.filter(func(side: SideData): return not side.is_empty())[0] as SideData
    _face_player(figure, solid.id)
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
    await _grow_through_player(figure)
    assert_eq(gameplay.game_state_manager.game_state, GameStateManager.GameState.GAME_ACTIVE)
    assert_eq(gameplay.progress.figures_passed, 1)
    assert_eq(gameplay.progress.score, 1)
    assert_eq(gameplay.controls.controlledNode, next)
    await wait_physics_frames(3)
    assert_eq(gameplay.progress.figures_passed, 1, "Passage must be scored only once.")

func test_touching_solid_edge_of_empty_dent_ends_game() -> void:
    var figure := gameplay.figure_root.get_live_figures()[0]
    var empty := figure.data.sides.filter(func(side: SideData): return side.is_empty())[0] as SideData
    var points := figure.mesh_icosahedron.get_side_points(empty.id)
    var edge := ((points[1] + points[2]) / 2.0).normalized()
    var detector: EndDetector = gameplay.get_node("EndDetector")
    var direction := (detector.global_position - figure.global_position).normalized()
    figure.mesh_icosahedron.global_basis = Basis(Quaternion(edge, direction))
    await _grow_through_player(figure)
    assert_eq(gameplay.game_state_manager.game_state, GameStateManager.GameState.GAME_END)
    assert_eq(gameplay.progress.figures_passed, 0)

func test_no_collision_before_visible_dent_reaches_player() -> void:
    var figure := gameplay.figure_root.get_live_figures()[0]
    var solid := figure.data.sides.filter(func(side: SideData): return not side.is_empty())[0] as SideData
    _face_player(figure, solid.id)
    var detector: EndDetector = gameplay.get_node("EndDetector")
    var direction := (detector.global_position - figure.global_position).normalized()
    var shape: BoxShape3D = detector.get_node("CollisionShape3D").shape
    var support := direction.abs().dot(shape.size / 2.0)
    var face_distance := figure.mesh_icosahedron.get_side_points(solid.id)[1].dot(solid.normal)
    var safe_scale := (figure.global_position.distance_to(detector.global_position) - support - 0.5) / face_distance
    figure.scale = Vector3.ONE * safe_scale
    await wait_physics_frames(5)
    assert_eq(gameplay.game_state_manager.game_state, GameStateManager.GameState.GAME_ACTIVE,
        "The bounding box must not end the run before the visible dent arrives.")
    if is_instance_valid(figure):
        assert_false(figure.resolved)

func _face_player(figure: Icosahedron, side_id: int) -> void:
    var detector: EndDetector = gameplay.get_node("EndDetector")
    # Align the rendered face, independently of the collision-side selection code.
    var dent := figure.mesh_icosahedron.get_dents()[side_id]
    var arrays := dent.mesh.surface_get_arrays(0)
    var vertices: PackedVector3Array = arrays[Mesh.ARRAY_VERTEX]
    var center := (vertices[0] + vertices[1] + vertices[2]) / 3.0
    var normal := (dent.basis * center).normalized()
    var direction := (detector.global_position - figure.global_position).normalized()
    figure.mesh_icosahedron.global_basis = Basis(Quaternion(normal, direction))

func _grow_through_player(figure: Icosahedron) -> void:
    for size in range(2, 25):
        if not is_instance_valid(figure) or figure.resolved:
            break
        figure.scale = Vector3.ONE * size
        await wait_physics_frames(3)
