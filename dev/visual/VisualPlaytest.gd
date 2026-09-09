extends Node

const ROTATION_LAB := preload("res://dev/labs/rotation/RotationLab.tscn")
const RUN_LAB := preload("res://dev/labs/run/RunLab.tscn")
const SEED := 12345
const SIZE := Vector2i(1280, 720)

var output := ""
var checks: Array[Dictionary] = []
var captures: Array[Dictionary] = []
var thumbnails: Array[Image] = []
var failed := false
var frame := 0

func _ready() -> void:
    for arg in OS.get_cmdline_user_args():
        if arg.begins_with("--output="):
            output = arg.trim_prefix("--output=")
    if output.is_empty() or DisplayServer.get_name() == "headless":
        push_error("Visual playtest needs a rendered display and --output=<directory>.")
        get_tree().quit(1)
        return
    if DirAccess.make_dir_recursive_absolute(output) != OK:
        push_error("Cannot create visual playtest output: " + output)
        get_tree().quit(1)
        return
    # Render at a fixed size even when a tiling window manager resizes the window.
    get_window().content_scale_mode = Window.CONTENT_SCALE_MODE_VIEWPORT
    get_window().content_scale_aspect = Window.CONTENT_SCALE_ASPECT_KEEP
    get_window().content_scale_size = SIZE
    get_window().size = SIZE
    G.settings = SettingsConfig.config_to_dict(SettingsConfig.set_default_config_values(ConfigFile.new()))
    G.settings.FULLSCREEN_ENABLED = false
    G.settings.FPS_COUNTER_ENABLED = false
    G.data = {}
    _run.call_deferred()

func _run() -> void:
    await _rotation_replay()
    await _restart_sequence()
    await _mounted_gameplay_sequence()
    await _collision_sequence()
    var report := {
        "automated_status": "failed" if failed else "passed",
        "visual_review": "required — inspect PNGs; state checks do not prove visual correctness",
        "seed": SEED,
        "fixed_fps": 60,
        "resolution": [SIZE.x, SIZE.y],
        "godot": Engine.get_version_info().string,
        "renderer": RenderingServer.get_current_rendering_method(),
        "project_renderer": ProjectSettings.get_setting("rendering/renderer/rendering_method"),
        "display": DisplayServer.get_name(),
        "checks": checks,
        "captures": captures,
    }
    var file := FileAccess.open(output.path_join("report.json"), FileAccess.WRITE)
    if file == null:
        push_error("Cannot write visual playtest report.")
        get_tree().quit(1)
        return
    file.store_string(JSON.stringify(report, "  ") + "\n")
    file.close()
    print("Visual playtest: %s. Inspect images in %s" % [report.automated_status, output])
    get_tree().quit(1 if failed else 0)

func _rotation_replay() -> void:
    seed(SEED)
    var lab := ROTATION_LAB.instantiate()
    add_child(lab)
    await _frames(3)
    var initial: Quaternion = lab.controller.target.quaternion
    await _capture("rotation", "01_initial", _rotation_state(lab))
    Input.action_press("ui_right")
    await _frames(15)
    await _capture("rotation", "02_right_mid", _rotation_state(lab))
    await _frames(15)
    Input.action_release("ui_right")
    var turned: Quaternion = lab.controller.target.quaternion
    _check(not turned.is_equal_approx(initial), "Holding right changes orientation")
    await _frames(2) # Let the lab's orientation label catch up after input stops.
    await _capture("rotation", "03_right_end", _rotation_state(lab))
    await _frames(15)
    _check(lab.controller.target.quaternion.is_equal_approx(turned), "Releasing right stops rotation")
    await _capture("rotation", "04_released", _rotation_state(lab))
    seed(SEED) # Reset side generation as well as orientation for comparable images.
    await _click(lab.get_node("UI/Panel/Controls/Reset"))
    await _frames(3)
    _check(lab.controller.target.quaternion.is_equal_approx(initial), "Reset button restores orientation")
    await _capture("rotation", "05_reset", _rotation_state(lab))
    await _frames(15)
    _check(lab.controller.target.quaternion.is_equal_approx(initial), "Reset remains stable")
    await _capture("rotation", "06_reset_settled", _rotation_state(lab))
    _save_contact_sheet("rotation")
    lab.queue_free()
    await _frames(3)

func _restart_sequence() -> void:
    seed(SEED)
    var lab := RUN_LAB.instantiate()
    add_child(lab)
    var gameplay: LoopScene = lab.gameplay
    await _frames(3)
    _check_active_run(gameplay, "Initial run")
    await _capture("run", "01_initial", _run_state(gameplay))
    Input.action_press("ui_right")
    await _frames(12)
    Input.action_release("ui_right")
    await _capture("run", "02_playing", _run_state(gameplay))
    # Presentation-only fixture: force failure and a nonzero score. Add a separate
    # collision/input replay when testing passage correctness, not this restart smoke test.
    gameplay.progress.run_state.score = 42
    gameplay.game_state_manager.change_state(GameStateManager.GameState.GAME_END)
    await _frames(6)
    await _capture("run", "03_game_over_mid", _run_state(gameplay))
    await _frames(12)
    _check(gameplay.game_state_manager.game_state == GameStateManager.GameState.GAME_END, "Game-over state reached")
    _check(not gameplay.figure_root.anchor.transform.is_equal_approx(Transform3D.IDENTITY), "Game-over presentation changes anchor")
    await _capture("run", "04_game_over", _run_state(gameplay))
    seed(SEED)
    await _click(lab.get_node("UI/Panel/Buttons/Restart"))
    await _frames(3)
    _check_active_run(gameplay, "Restart")
    await _capture("run", "05_restart", _run_state(gameplay))
    var restarted_figure: Icosahedron = gameplay.figure_root.get_live_figures()[0]
    var restarted_scale := restarted_figure.scale.x
    await _frames(24)
    _check_active_run(gameplay, "Settled restart")
    _check(is_instance_valid(restarted_figure) and restarted_figure.scale.x > restarted_scale, "Restarted figure continues growing")
    await _capture("run", "06_restart_settled", _run_state(gameplay))
    _save_contact_sheet("run")
    lab.queue_free()
    await _frames(3)

func _mounted_gameplay_sequence() -> void:
    seed(SEED)
    var main := preload("res://game/app/Main.tscn").instantiate()
    # Keep the replay's render settings; Config uses the in-memory settings above.
    main.get_node("GameSettings").free()
    # Audio is outside visual coverage; avoid real-time playback in a fixed-FPS replay.
    for player in main.get_node("SfxPlayer").get_children():
        player.stream = null
    get_tree().root.add_child(main)
    await _frames(30)
    await _capture("mounted", "01_menu", {})
    await _tap_accept()
    await _frames(30)
    await _tap_accept()
    await _frames(30)
    var gameplay: LoopScene = main.scenes.LoopScene
    _check(main.current_scene == gameplay, "Menu input starts mounted gameplay")
    _check(get_viewport().get_camera_3d() == gameplay.get_node("Environment/Camera3D"),
        "Mounted gameplay uses gameplay camera")
    gameplay.get_node("LoopTimer").stop()
    gameplay.get_node("ScaleTimer").stop()
    var figure := gameplay.figure_root.get_live_figures()[0]
    var empty := figure.data.sides.filter(func(side: SideData): return side.is_empty())[0] as SideData
    _align_side(gameplay, figure, empty)
    figure.scale = Vector3.ONE * 5.0
    await _frames(3)
    await _capture("mounted", "02_approaching_hole", _run_state(gameplay))
    gameplay.spawner.spawn_icosahedron()
    await _grow_to_contact(figure)
    _check(gameplay.progress.figures_passed == 1, "Mounted physical passage scores once")
    await _capture("mounted", "03_passed", _run_state(gameplay))
    figure = gameplay.figure_root.get_live_figures()[0]
    var solid := figure.data.sides.filter(func(side: SideData): return not side.is_empty())[0] as SideData
    _align_side(gameplay, figure, solid)
    figure.scale = Vector3.ONE * 5.0
    await _frames(3)
    await _capture("mounted", "04_approaching_solid", _run_state(gameplay))
    await _grow_to_contact(figure)
    await _frames(20)
    _check(gameplay.game_state_manager.game_state == GameStateManager.GameState.GAME_END,
        "Mounted solid contact ends run")
    await _capture("mounted", "05_game_over", _run_state(gameplay))
    main.change_scene("MenuScene")
    await _frames(3)
    _check(get_viewport().get_camera_3d() == main.scenes.MenuScene.get_node("Environment/Camera3D"),
        "Returning to menu restores menu camera")
    await _capture("mounted", "06_menu_return", {})
    _save_contact_sheet("mounted")
    await _transition_sequence(main)
    main.queue_free()
    await _frames(3)

func _transition_sequence(main: Node) -> void:
    main.change_scene("LoopScene")
    var gameplay: LoopScene = main.scenes.LoopScene
    gameplay.get_node("LoopTimer").stop()
    gameplay.get_node("ScaleTimer").stop()
    await _frames(3)
    var figure := gameplay.figure_root.get_live_figures()[0]
    var empty := figure.data.sides.filter(func(side: SideData): return side.is_empty())[0] as SideData
    _align_side(gameplay, figure, empty)
    figure.scale = Vector3.ONE * 7.0
    gameplay.spawner.spawn_icosahedron()
    await _frames(3)
    await _capture("fade", "01_before_commit", _run_state(gameplay))
    await _tap_accept()
    await _frames(2)
    await _capture("fade", "02_early", _run_state(gameplay))
    await _frames(4)
    await _capture("fade", "03_mid", _run_state(gameplay))
    _check(figure.mesh_icosahedron.opacity > 0.0 and figure.mesh_icosahedron.opacity < 1.0,
        "Commit visibly fades over time")
    await _frames(5)
    await _capture("fade", "04_late", _run_state(gameplay))
    await _frames(8)
    _check(not figure.mesh_icosahedron.visible and not figure.resolved,
        "Faded shell still awaits collision validation")
    await _capture("fade", "05_hidden", _run_state(gameplay))
    await _grow_to_contact(figure)
    _check(gameplay.progress.figures_passed == 1, "Committed shell scores at physical passage")
    await _capture("fade", "06_passed", _run_state(gameplay))
    _save_contact_sheet("fade")

    gameplay.game_state_manager.change_state(GameStateManager.GameState.GAME_END)
    await _frames(65)
    await _capture("options", "01_score", _run_state(gameplay))
    await _tap_accept(&"ui_right")
    await _frames(7)
    _check(gameplay.game_state_manager.game_state == GameStateManager.GameState.GAME_END,
        "Restart waits for rotation")
    await _capture("options", "02_restart_turn", _run_state(gameplay))
    await _frames(15)
    _check_active_run(gameplay, "Animated restart")
    await _capture("options", "03_restarted", _run_state(gameplay))
    gameplay.game_state_manager.change_state(GameStateManager.GameState.GAME_END)
    await _frames(65)
    await _capture("options", "04_score", _run_state(gameplay))
    await _tap_accept(&"ui_left")
    await _frames(7)
    _check(main.current_scene == gameplay, "Exit waits for rotation")
    await _capture("options", "05_exit_turn", _run_state(gameplay))
    await _frames(15)
    _check(main.current_scene == main.scenes.MenuScene, "Animated exit returns to menu")
    await _capture("options", "06_menu", {})
    _save_contact_sheet("options")

func _collision_sequence() -> void:
    seed(SEED)
    var lab := RUN_LAB.instantiate()
    add_child(lab)
    var gameplay: LoopScene = lab.gameplay
    gameplay.get_node("LoopTimer").stop()
    gameplay.get_node("ScaleTimer").stop()
    var figure := gameplay.figure_root.get_live_figures()[0]
    var empty := figure.data.sides.filter(func(side: SideData): return side.is_empty())[0] as SideData
    _align_side(gameplay, figure, empty)
    figure.scale = Vector3.ONE * 7.0
    await _frames(3)
    await _click(lab.get_node("UI/Panel/Buttons/Collisions"))
    await _frames(3)
    _check(lab.collision_debug.enabled, "Collision overlay enabled by UI")
    _check(lab.collision_debug.shapes.size() == 21, "Overlay includes 20 sides and player ring")
    await _check_debug_steering(figure, "Colliders")
    var detector: EndDetector = gameplay.get_node("EndDetector")
    var camera: Camera3D = gameplay.get_node("Environment/Camera3D")
    _check(detector.global_basis.is_equal_approx(camera.global_basis), "Window is parallel to camera plane")
    var solid_start := figure.data.sides.filter(func(side: SideData): return not side.is_empty())[0] as SideData
    _align_side(gameplay, figure, solid_start)
    var rejected: Array[Icosahedron] = []
    gameplay.controls.commit_rejected.connect(func(value): rejected.append(value))
    await _tap_accept()
    _check(rejected == [figure], "Incorrect Space emits rejection signal")
    _check(not figure.mesh_icosahedron.angle_good and figure.mesh_icosahedron.visible,
        "Rejected figure stays visible and unlocked")
    _check(gameplay.controls.controlledNode == figure.mesh_icosahedron and gameplay.progress.score == 0,
        "Rejected commit keeps control and does not score")
    await _capture("collision", "01_player_view", _run_state(gameplay))
    _align_side(gameplay, figure, empty)
    await _click(lab.get_node("UI/Panel/Buttons/Observer"))
    await _frames(3)
    _check(lab.collision_debug.observer, "Observer camera enabled by UI")
    await _check_debug_steering(figure, "Observer")
    await _capture("collision", "02_observer", _run_state(gameplay))
    _align_side(gameplay, figure, empty)
    gameplay.spawner.spawn_icosahedron()
    await _tap_accept()
    await _frames(25)
    _check(not figure.mesh_icosahedron.visible and not figure.resolved, "Debug: hidden shell still unresolved")
    var shape: CollisionShape3D = figure.get_node("MeshIcosahedron/SideColliders").get_child(0).get_child(0)
    _check(lab.collision_debug.shapes[shape].is_visible_in_tree(), "Hidden shell retains debug wireframe")
    await _capture("collision", "03_hidden_collider", _run_state(gameplay))
    await _grow_to_contact(figure)
    _check(gameplay.progress.figures_passed == 1, "Debug: real hole contact scores")
    await _capture("collision", "04_passed", _run_state(gameplay))
    figure = gameplay.figure_root.get_live_figures()[0]
    var solid := figure.data.sides.filter(func(side: SideData): return not side.is_empty())[0] as SideData
    _align_side(gameplay, figure, solid)
    figure.scale = Vector3.ONE * 10.0
    await _frames(3)
    await _capture("collision", "05_solid_approach", _run_state(gameplay))
    await _grow_to_contact(figure)
    await _frames(20)
    _check(gameplay.game_state_manager.game_state == GameStateManager.GameState.GAME_END,
        "Debug: real solid contact fails")
    await _click(lab.get_node("UI/Panel/Buttons/Collisions"))
    await _click(lab.get_node("UI/Panel/Buttons/Observer"))
    await _frames(3)
    _check(not lab.collision_debug.visible, "Collision overlay can be hidden")
    _check(gameplay.get_node("Environment/Camera3D").transform.is_equal_approx(lab.collision_debug.camera_transform),
        "Observer restores gameplay camera")
    await _capture("collision", "06_game_over", _run_state(gameplay))
    _save_contact_sheet("collision")
    lab.queue_free()
    await _frames(3)

func _check_debug_steering(figure: Icosahedron, label: String) -> void:
    _check(get_viewport().gui_get_focus_owner() == null, label + ": click leaves gameplay keyboard focus")
    var initial := figure.mesh_icosahedron.quaternion
    Input.action_press("ui_right")
    await _frames(15)
    Input.action_release("ui_right")
    var turned := figure.mesh_icosahedron.quaternion
    _check(not turned.is_equal_approx(initial), label + ": steering works after click")
    await _frames(15)
    _check(figure.mesh_icosahedron.quaternion.is_equal_approx(turned), label + ": release stops steering")

func _tap_accept(action: StringName = &"ui_accept") -> void:
    var event := InputEventAction.new()
    event.action = action
    event.pressed = true
    Input.parse_input_event(event)
    await _frames(1)
    event = event.duplicate()
    event.pressed = false
    Input.parse_input_event(event)
    await _frames(1)

func _align_side(gameplay: LoopScene, figure: Icosahedron, side: SideData) -> void:
    var detector: EndDetector = gameplay.get_node("EndDetector")
    var direction := (detector.global_position - figure.global_position).normalized()
    var mesh_scale := figure.mesh_icosahedron.global_basis.get_scale()
    var points := figure.mesh_icosahedron.get_side_points(side.id)
    var normal := (points[1] + points[2] + points[3]).normalized()
    figure.mesh_icosahedron.global_basis = Basis(Quaternion(normal, direction)).scaled(mesh_scale)

func _grow_to_contact(figure: Icosahedron) -> void:
    # Controlled scale steps isolate camera/passage presentation from wall-clock growth.
    for size in range(6, 25):
        if not is_instance_valid(figure) or figure.resolved:
            break
        figure.scale = Vector3.ONE * size
        await _frames(3)

func _check_active_run(gameplay: LoopScene, label: String) -> void:
    _check(gameplay.game_state_manager.game_state == GameStateManager.GameState.GAME_ACTIVE, label + ": active")
    _check(gameplay.progress.score == 0, label + ": score reset")
    _check(gameplay.progress.figures_passed == 0, label + ": progress reset")
    _check(gameplay.figure_root.get_live_figures().size() == 1, label + ": exactly one figure")
    _check(gameplay.figure_root.anchor.transform.is_equal_approx(Transform3D.IDENTITY), label + ": anchor reset")
    _check(is_instance_valid(gameplay.controls.figure_controller.target), label + ": control target exists")
    _check(not gameplay.get_node("ScaleTimer").paused, label + ": scaling unpaused")

func _rotation_state(lab: Node) -> Dictionary:
    return {"orientation": _quaternion(lab.controller.target.quaternion)}

func _run_state(gameplay: LoopScene) -> Dictionary:
    var figures: Array[Dictionary] = []
    for figure in gameplay.figure_root.get_live_figures():
        figures.append({
            "orientation": _quaternion(figure.mesh_icosahedron.quaternion),
            "scale": [figure.scale.x, figure.scale.y, figure.scale.z],
            "opacity": figure.mesh_icosahedron.opacity,
            "committed": figure.mesh_icosahedron.angle_good,
            "visible": figure.mesh_icosahedron.is_visible_in_tree(),
            "controlled": figure.mesh_icosahedron == gameplay.controls.figure_controller.target,
        })
    var anchor_scale := gameplay.figure_root.anchor.scale
    return {
        "game_state": GameStateManager.GameStateNames[gameplay.game_state_manager.game_state],
        "score": gameplay.progress.score,
        "figures_passed": gameplay.progress.figures_passed,
        "anchor_scale": [anchor_scale.x, anchor_scale.y, anchor_scale.z],
        "anchor_orientation": _quaternion(gameplay.figure_root.anchor.quaternion),
        "figures": figures,
    }

func _quaternion(value: Quaternion) -> Array:
    return [value.x, value.y, value.z, value.w]

func _frames(count: int) -> void:
    for i in range(count):
        # Resume after rendering, so input changes affect the next complete frame.
        await RenderingServer.frame_post_draw
        frame += 1

func _click(button: Button) -> void:
    var position := button.get_global_rect().get_center()
    var motion := InputEventMouseMotion.new()
    motion.position = position
    get_viewport().push_input(motion, true)
    var event := InputEventMouseButton.new()
    event.position = position
    event.button_index = MOUSE_BUTTON_LEFT
    event.pressed = true
    get_viewport().push_input(event, true)
    await _frames(1)
    event = event.duplicate()
    event.pressed = false
    get_viewport().push_input(event, true)
    await _frames(1)
    # Keep hover styling/cursor away from the subject in the captured frame.
    motion = InputEventMouseMotion.new()
    motion.position = Vector2(SIZE) - Vector2(2, 2)
    get_viewport().push_input(motion, true)

func _capture(scenario: String, checkpoint: String, state: Dictionary) -> void:
    var image := get_viewport().get_texture().get_image()
    if image == null or image.is_empty():
        _check(false, "Rendered image available: " + checkpoint)
        return
    var filename := scenario + "_" + checkpoint + ".png"
    _check(image.get_size() == SIZE, "Capture resolution: " + filename)
    _check(image.save_png(output.path_join(filename)) == OK, "Save " + filename)
    captures.append({"file": filename, "frame": frame, "state": state})
    image.convert(Image.FORMAT_RGBA8)
    image.resize(SIZE.x / 2, SIZE.y / 2, Image.INTERPOLATE_LANCZOS)
    thumbnails.append(image)

func _save_contact_sheet(scenario: String) -> void:
    # Six sparse checkpoints catch gross transitions, not single-frame glitches;
    # increase capture density or record video when investigating animation artifacts.
    var sheet := Image.create_empty(SIZE.x, SIZE.y / 2 * 3, false, Image.FORMAT_RGBA8)
    for i in range(thumbnails.size()):
        sheet.blit_rect(thumbnails[i], Rect2i(Vector2i.ZERO, thumbnails[i].get_size()),
            Vector2i((i % 2) * (SIZE.x / 2), (i / 2) * (SIZE.y / 2)))
    _check(sheet.save_png(output.path_join(scenario + "_contact_sheet.png")) == OK, "Save " + scenario + " contact sheet")
    thumbnails.clear()

func _check(condition: bool, description: String) -> void:
    checks.append({"check": description, "passed": condition})
    if not condition:
        failed = true
        push_error("Visual playtest check failed: " + description)
