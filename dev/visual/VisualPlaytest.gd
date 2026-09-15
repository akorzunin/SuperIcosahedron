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
    G.settings = SettingsConfig.config_to_dict(
        SettingsConfig.set_default_config_values(ConfigFile.new())
    )
    G.settings.FULLSCREEN_ENABLED = false
    G.settings.FPS_COUNTER_ENABLED = false
    G.data = { }
    _run.call_deferred()


func _run() -> void:
    await _rotation_replay()
    await _restart_sequence()
    await _mounted_gameplay_sequence()
    await _collision_sequence()
    await _modifier_sequence()
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


func _library_sequence(main: Node) -> void:
    var discoveries: Array = G.discovered_modifiers.duplicate()
    G.discovered_modifiers = []
    var menu: MenuScene = main.scenes.MenuScene
    var spawner: MenuSpawner = menu.get_node("MenuSpawner")
    var controls: MenuControls = menu.get_node("MenuControls")
    controls.controlledNode = spawner.anchor
    await _frames(2)
    spawner.open_menu_section(spawner.anchor, MenuStruct.modifier_library_page(0))
    await _frames(3)
    await _capture("library", "empty", { })
    G.discovered_modifiers = UpgradeCatalog.data.pickups.map(
        func(entry):
            return entry.id,
    )
    var first_page := MenuStruct.modifier_library_page(0)
    menu.get_node("MenuState").state = first_page
    spawner.show_section(spawner.anchor, first_page)
    await _frames(3)
    await _capture("library", "first_page", { })
    spawner.show_section(spawner.anchor, MenuStruct.modifier_detail("forge"))
    await _frames(3)
    var preview: Icosahedron = spawner.anchor.get_node("Icosahedron")
    _check(
        preview.data.sides.any(
            func(side):
                return side.modifier and side.modifier.id == "forge",
        ),
        "Library preview uses the real Forge pickup visual",
    )
    await _capture("library", "forge_preview", { })
    var last_page := MenuStruct.modifier_library_page(1)
    menu.get_node("MenuState").state = last_page
    spawner.show_section(spawner.anchor, last_page)
    await _frames(3)
    await _capture("library", "last_page", { })
    _save_contact_sheet("library")
    G.discovered_modifiers = discoveries


func _modifier_sequence() -> void:
    var old_data := G.data
    G.data = { } # Direct lab starts must not inherit a previously selected menu difficulty.
    var old_mode: int = G.settings.SPAWN_MODE
    G.settings.SPAWN_MODE = PatternGen.SpawnMode.QUEUE
    var lab := RUN_LAB.instantiate()
    get_tree().root.add_child(lab)
    await _frames(3)
    lab.get_node("UI").hide()
    var gameplay: LoopScene = lab.get_node("Gameplay")
    gameplay.get_node("LoopTimer").stop()
    gameplay.get_node("ScaleTimer").stop()
    gameplay.figure_root.clean_all(true)
    await _frames(3)
    var pickups := [
        "points",
        "tier",
        "points",
        "echo",
        "inversion",
        "inversion",
        "all_in",
        "points",
    ]
    for step in pickups.size():
        var wanted: String = pickups[step]
        var wanted_value := 2 if wanted in ["echo", "inversion"] else 1
        # Search deterministic fixture seeds; all layouts still use production generation.
        for fixture_seed in range(100):
            gameplay.spawner.rng.seed = fixture_seed
            var candidate := StageGenerator.create_modifier_figure(
                gameplay.spawner.rng,
                gameplay.progress.run_state.modifier_system.pending,
                maxi(gameplay.spawner.easy_side, 0),
                gameplay.progress.run_state.tiers_collected,
            )
            if candidate.sides.any(
                func(side):
                    return (
                        side.modifier and side.modifier.id == wanted
                        and side.modifier.pickup_value == wanted_value
                    ),
            ):
                gameplay.spawner.rng.seed = fixture_seed
                break
        gameplay.spawner.spawn_icosahedron()
        await _frames(2)
        var figure := gameplay.figure_root.get_live_figures()[0]
        var side: SideData = figure.data.sides.filter(
            func(item):
                return (
                    item.modifier and item.modifier.id == wanted
                    and item.modifier.pickup_value == wanted_value
                ),
        )[0]
        _align_side(gameplay, figure, side)
        figure.scale = Vector3.ONE * 5.0
        await _frames(3)
        await _capture("modifiers", "%02d_choices" % (step * 2 + 1), _run_state(gameplay))
        await _grow_to_contact(figure)
        await _frames(70)
        await _capture("modifiers", "%02d_collected" % (step * 2 + 2), _run_state(gameplay))
        _check(gameplay.progress.figures_passed == step + 1, "Modifier physical passage %d" % step)
    _check(gameplay.progress.score == 750, "T2 commit plus inverted T2 all-in payout")
    _check(gameplay.progress.run_state.modifier_system.tier == 1, "Commit starts fresh T1 chain")
    _save_contact_sheet("modifiers")
    gameplay.progress.run_state.tiers_collected = 1 # Difficulty fixture starts one tier below its +2 pickup.
    await _difficulty_sequence(gameplay)
    await _forge_sequence(gameplay)
    await _automatic_level_sequence(gameplay)
    gameplay.restart()
    await _frames(3)
    _check(
        not gameplay.progress.run_state.modifier_system.pending,
        "Restart discards modifier chain",
    )
    lab.queue_free()
    await _frames(3)
    G.settings.SPAWN_MODE = old_mode
    G.data = old_data


func _automatic_level_sequence(gameplay: LoopScene) -> void:
    gameplay.figure_root.clean_all(true)
    await _frames(3)
    var run := gameplay.progress.run_state
    run.reset()
    run.charges_completed = RunState.required_charges() - 1
    run.modifier_system.collect(run, UpgradeCatalog.pickup("points"))
    run.modifier_system.collect(run, UpgradeCatalog.pickup("tier"))
    gameplay.spawner.spawn_icosahedron()
    await _frames(2)
    var figure := gameplay.figure_root.get_live_figures()[0]
    var side: SideData = figure.data.sides.filter(
        func(item):
            return item.modifier and item.modifier.pickup_kind == "points",
    )[0]
    _align_side(gameplay, figure, side)
    figure.scale = Vector3.ONE * 5.0
    await _frames(3)
    await _capture("transition", "01_last_chain", _run_state(gameplay))
    await _grow_to_contact(figure)
    await _frames(3)
    gameplay.get_node("LoopTimer").stop()
    gameplay.get_node("ScaleTimer").stop()
    _check(
        run.difficulty == 1 and run.score == 0 and run.charges_completed == 0,
        "Final chain automatically starts a fresh level 2",
    )
    _check(
        gameplay.figure_root.get_live_figures().size() == 1,
        "Automatic transition replaces old shells",
    )
    await _capture("transition", "02_level_two", _run_state(gameplay))
    _save_contact_sheet("transition")


func _forge_sequence(gameplay: LoopScene) -> void:
    gameplay.figure_root.clean_all(true)
    await _frames(3)
    var run := gameplay.progress.run_state
    run.modifier_system.reset()
    run.difficulty = 1
    var before := run.score
    var ids := ["forge", "points", "points", "points"]
    for step in ids.size():
        var wanted: String = ids[step]
        for fixture_seed in range(1000):
            gameplay.spawner.rng.seed = fixture_seed
            var candidate := StageGenerator.create_modifier_figure(
                gameplay.spawner.rng,
                run.modifier_system.pending,
                maxi(gameplay.spawner.easy_side, 0),
                int(UpgradeCatalog.data.difficulty_levels[1].tiers_required),
            )
            if candidate.sides.any(
                func(side):
                    return (
                        side.modifier and side.modifier.id == wanted
                        and side.modifier.pickup_value == 1
                    ),
            ):
                gameplay.spawner.rng.seed = fixture_seed
                break
        gameplay.spawner.spawn_icosahedron()
        await _frames(2)
        var figure := gameplay.figure_root.get_live_figures()[0]
        var side: SideData = figure.data.sides.filter(
            func(item):
                return (
                    item.modifier and item.modifier.id == wanted and item.modifier.pickup_value == 1
                ),
        )[0]
        _align_side(gameplay, figure, side)
        figure.scale = Vector3.ONE * 5.0
        await _frames(3)
        await _capture("forge", "%02d_choices" % (step * 2), _run_state(gameplay))
        await _grow_to_contact(figure)
        await _frames(70)
        await _capture("forge", "%02d_collected" % (step * 2 + 1), _run_state(gameplay))
    _check(run.score == before + 400, "Forged Points pays ×4 on the following Points")
    _save_contact_sheet("forge")


func _difficulty_sequence(gameplay: LoopScene) -> void:
    # Continue the actual base/tier/base replay: one tier unit collected so far.
    # Find a seeded hard TIER +2 layout, then collect it through physical passage.
    for fixture_seed in range(100):
        gameplay.spawner.rng.seed = fixture_seed
        var candidate := StageGenerator.create_modifier_figure(
            gameplay.spawner.rng,
            true,
            gameplay.spawner.easy_side,
            gameplay.progress.run_state.tiers_collected,
        )
        if candidate.sides.any(
            func(side):
                return (
                    side.modifier and side.modifier.id == "tier" and side.modifier.pickup_value == 2
                ),
        ):
            gameplay.spawner.rng.seed = fixture_seed
            break
    gameplay.spawner.spawn_icosahedron()
    await _frames(3)
    var figure := gameplay.figure_root.get_live_figures()[0]
    _align_side(gameplay, figure, figure.data.sides[figure.data.easy_side])
    figure.scale = Vector3.ONE * 5.0
    gameplay.controls.sync_orientation()
    await _frames(3)
    await _capture("difficulty", "01_easy_zone", _run_state(gameplay))
    gameplay.spawner.spawn_icosahedron()
    var next := gameplay.figure_root.get_live_figures()[1]
    var next_center := next.data.easy_side
    var next_layout := next.data.sides.map(
        func(side):
            return [side.kind, side.modifier],
    )
    next.scale = Vector3.ONE * 2.5
    gameplay.controls.figure_controller.rotate_continuous(Vector2.RIGHT, 0.15)
    await _frames(3)
    _check(figure.mesh_icosahedron.basis.is_equal_approx(next.mesh_icosahedron.basis), "Live figures share steering")
    await _capture("difficulty", "02_shared_rotation", _run_state(gameplay))
    var hard: SideData = figure.data.sides.filter(
        func(side):
            return side.modifier and side.modifier.id == "tier" and side.modifier.pickup_value == 2,
    )[0]
    _align_side(gameplay, figure, hard)
    gameplay.controls.sync_orientation()
    await _frames(3)
    await _capture("difficulty", "03_hard_pickup", _run_state(gameplay))
    var previous_charges := gameplay.progress.run_state.charges_completed
    gameplay.controls.advance_control()
    var frozen := figure.mesh_icosahedron.basis
    gameplay.controls.figure_controller.rotate_continuous(Vector2.LEFT, 0.15)
    await _frames(3)
    _check(
        figure.mesh_icosahedron.basis.is_equal_approx(frozen),
        "Committed shell ignores later shared steering",
    )
    await _grow_to_contact(figure)
    await _frames(70)
    _check(
        gameplay.progress.run_state.tiers_collected == 3,
        "Hard +2 pickup adds two build tier units",
    )
    _check(
        gameplay.progress.run_state.difficulty == 0,
        "Tier collection never changes the selected level",
    )
    _check(
        gameplay.progress.run_state.charges_completed == previous_charges,
        "Unfinished charge grants no mastery",
    )
    _check(gameplay.spawner.easy_side == hard.id, "Future spawns use passed face as easy point")
    _check(
        next.data.easy_side == next_center and next.data.sides.map(
            func(side):
                return [side.kind, side.modifier],
        ) == next_layout,
        "Already spawned dent layouts stay unchanged after passage",
    )
    await _capture("difficulty", "04_unchanged", _run_state(gameplay))
    next.despawn()
    await _frames(3)
    gameplay.progress.run_state.difficulty = 1 # Explicit level selection for the two-route fixture.
    for fixture_seed in range(100):
        gameplay.spawner.rng.seed = fixture_seed
        var candidate := StageGenerator.create_modifier_figure(
            gameplay.spawner.rng,
            true,
            gameplay.spawner.easy_side,
            gameplay.progress.run_state.tiers_collected,
        )
        var steps := FaceTopology.distances(candidate.easy_side)
        if candidate.sides.filter(
            func(side):
                return side.is_empty() and steps[side.id] <= 1,
        ).size() == 2:
            gameplay.spawner.rng.seed = fixture_seed
            break
    gameplay.spawner.spawn_icosahedron()
    await _frames(3)
    figure = gameplay.figure_root.get_live_figures()[0]
    var center := figure.data.easy_side
    _align_side(gameplay, figure, figure.data.sides[center])
    figure.scale = Vector3.ONE * 5.0
    await _frames(3)
    await _capture("difficulty", "05_two_easy_routes", _run_state(gameplay))
    var neighbor: int = FaceTopology.neighbors(center).filter(
        func(id):
            return figure.data.sides[id].is_empty(),
    )[0]
    var edge := (FaceTopology.normal(center) + FaceTopology.normal(neighbor)).normalized()
    var detector: EndDetector = gameplay.get_node("EndDetector")
    var toward_player := (detector.global_position - figure.global_position).normalized()
    figure.mesh_icosahedron.global_basis = Basis(Quaternion(edge, toward_player)).scaled(
        Vector3.ONE * 5.0
    )
    await _frames(3)
    _check(detector.get_passing_side(figure) != null, "Adjacent open/open border has clearance")
    await _capture("difficulty", "06_open_border", _run_state(gameplay))
    for stage in [2, 3]:
        gameplay.figure_root.clean_all(true)
        gameplay.progress.run_state.difficulty = stage # Render-only palette fixture, not an unlocked lesson.
        gameplay.spawner.spawn_icosahedron()
        figure = gameplay.figure_root.get_live_figures()[0]
        _align_side(gameplay, figure, figure.data.sides[figure.data.easy_side])
        figure.scale = Vector3.ONE * 5.0
        await _frames(3)
        await _capture(
            "difficulty",
            "%02d_palette_level_%d" % [stage + 5, stage + 1],
            _run_state(gameplay),
        )
    _save_contact_sheet("difficulty")


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
    _check(
        gameplay.game_state_manager.game_state == GameStateManager.GameState.GAME_END,
        "Game-over state reached",
    )
    _check(
        not gameplay.figure_root.anchor.transform.is_equal_approx(Transform3D.IDENTITY),
        "Game-over presentation changes anchor",
    )
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
    _check(
        is_instance_valid(restarted_figure) and restarted_figure.scale.x > restarted_scale,
        "Restarted figure continues growing",
    )
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
    await _capture("mounted", "01_menu", { })
    await _tap_accept()
    await _frames(30)
    await _tap_accept()
    await _frames(30)
    var gameplay: LoopScene = main.scenes.LoopScene
    _check(main.current_scene == gameplay, "Menu input starts mounted gameplay")
    _check(
        get_viewport().get_camera_3d() == gameplay.get_node("Environment/Camera3D"),
        "Mounted gameplay uses gameplay camera",
    )
    gameplay.get_node("LoopTimer").stop()
    gameplay.get_node("ScaleTimer").stop()
    var figure := gameplay.figure_root.get_live_figures()[0]
    var empty := figure.data.sides.filter(
        func(side: SideData):
            return side.is_empty(),
    )[0] as SideData
    _align_side(gameplay, figure, empty)
    figure.scale = Vector3.ONE * 5.0
    await _frames(3)
    await _capture("mounted", "02_approaching_hole", _run_state(gameplay))
    gameplay.spawner.spawn_icosahedron()
    await _grow_to_contact(figure)
    _check(gameplay.progress.figures_passed == 1, "Mounted physical passage scores once")
    await _capture("mounted", "03_passed", _run_state(gameplay))
    figure = gameplay.figure_root.get_live_figures()[0]
    var solid := figure.data.sides.filter(
        func(side: SideData):
            return not side.is_empty(),
    )[0] as SideData
    _align_side(gameplay, figure, solid)
    figure.scale = Vector3.ONE * 5.0
    await _frames(3)
    await _capture("mounted", "04_approaching_solid", _run_state(gameplay))
    await _grow_to_contact(figure)
    await _frames(20)
    _check(
        gameplay.game_state_manager.game_state == GameStateManager.GameState.GAME_END,
        "Mounted solid contact ends run",
    )
    await _capture("mounted", "05_game_over", _run_state(gameplay))
    main.change_scene("MenuScene")
    await _frames(3)
    _check(
        get_viewport().get_camera_3d() == main.scenes.MenuScene.get_node("Environment/Camera3D"),
        "Returning to menu restores menu camera",
    )
    await _capture("mounted", "06_menu_return", { })
    _save_contact_sheet("mounted")
    await _transition_sequence(main)
    await _video_scale_sequence(main)
    await _menu_ui_sequence(main)
    await _library_sequence(main)
    main.queue_free()
    await _frames(3)


func _menu_ui_sequence(main: Node) -> void:
    var previous_data: Dictionary = G.data.duplicate(true)
    var previous_spawn_mode: int = G.settings.SPAWN_MODE
    var menu: Node = main.scenes.MenuScene
    var controls: MenuControls = menu.get_node("MenuControls")
    var spawner: MenuSpawner = menu.get_node("MenuSpawner")
    var state: MenuState = menu.get_node("MenuState")
    while not state.history.is_empty():
        spawner.go_back()
        await _frames(30)
    spawner.open_menu_section(controls.controlledNode, MenuStruct.menu_items.items[2])
    await _frames(30)
    await _capture("menu_ui", "01_settings_heading", { })
    spawner.open_menu_section(controls.controlledNode, MenuStruct.settings_items[1])
    await _frames(30)
    spawner.open_options_section(controls.controlledNode, MenuStruct.settings_items[1].items[2])
    await _frames(30)
    await _capture("menu_ui", "02_option_heading", { })
    await _tap_accept(&"ui_cancel")
    await _frames(30)
    _check(state.state.name == "controls", "Esc returns exactly one submenu level")
    await _capture("menu_ui", "03_parent_heading", { })
    await _tap_accept(&"ui_cancel")
    await _frames(30)
    await _tap_accept(&"ui_cancel")
    await _frames(30)
    await _tap_accept(&"ui_cancel")
    await _frames(30)
    _check(state.state.name == "Quit game?", "Root Esc asks before quitting")
    await _capture("menu_ui", "04_quit_confirmation", { })
    await _tap_accept(&"ui_left")
    await _frames(30)
    await _tap_accept()
    await _frames(30)
    G.data.selected_difficulty = 0
    main.change_scene("LoopScene")
    var gameplay: LoopScene = main.scenes.LoopScene
    var gui: LoopGui = gameplay.get_node("Gui")
    await _tap_accept(&"ui_cancel")
    _check(gui.pause_menu.visible, "Tutorial Esc opens pause menu")
    await _capture("menu_ui", "05_tutorial_pause", { })
    await _click(gui.get_node("PauseMenu/Options/Resume"))
    _check(gameplay.game_state_manager.tutorial_waiting, "Resume preserves tutorial instructions")
    await _tap_accept()
    await _tap_accept(&"ui_cancel")
    _check(gui.pause_menu.visible, "Gameplay Esc opens pause menu")
    await _capture("menu_ui", "06_gameplay_pause", { })
    await _click(gui.get_node("PauseMenu/Options/ReturnToMenu"))
    _check(main.current_scene == menu, "Pause menu can return to main menu")
    _save_contact_sheet("menu_ui")
    G.data = previous_data
    G.settings.SPAWN_MODE = previous_spawn_mode


func _video_scale_sequence(main: Node) -> void:
    var config: Config = main.get_node("Config")
    var previous_path := config.config
    var previous_percent: int = G.settings.get("RENDER_SCALE_PERCENT", 100)
    var previous_scale := get_viewport().scaling_3d_scale
    config.config = "user://visual_render_scale.cfg"
    SettingsConfig.load_gs(config.config)
    config.set_render_scale(100)
    var menu: Node = main.scenes.MenuScene
    var controls: MenuControls = menu.get_node("MenuControls")
    var spawner: MenuSpawner = menu.get_node("MenuSpawner")
    controls.check_controlled_node()
    spawner.open_menu_section(controls.controlledNode, MenuStruct.settings_items[3].duplicate(true))
    await _frames(30)
    var turn := Quats.menu_quat_left()
    controls.change_selection((turn * turn).inverse(), true)
    await _frames(30)
    var checkpoint := 0
    for percent in [100, 90, 70, 50, 10, 100]:
        if checkpoint > 0:
            for _step in range(10):
                if G.settings.RENDER_SCALE_PERCENT == percent:
                    break
                await _tap_accept()
        await _frames(3)
        _check(
            is_equal_approx(get_viewport().scaling_3d_scale, percent / 100.0),
            "Video scale applies %d%%" % percent,
        )
        checkpoint += 1
        await _capture("video_scale", "%02d_%d" % [checkpoint, percent], { "percent": percent })
    _save_contact_sheet("video_scale")
    config.set_render_scale(previous_percent)
    get_viewport().scaling_3d_scale = previous_scale
    DirAccess.remove_absolute(ProjectSettings.globalize_path(config.config))
    config.config = previous_path


func _transition_sequence(main: Node) -> void:
    main.change_scene("LoopScene")
    var gameplay: LoopScene = main.scenes.LoopScene
    gameplay.get_node("LoopTimer").stop()
    gameplay.get_node("ScaleTimer").stop()
    await _frames(3)
    var figure := gameplay.figure_root.get_live_figures()[0]
    var empty := figure.data.sides.filter(
        func(side: SideData):
            return side.is_empty(),
    )[0] as SideData
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
    _check(
        figure.mesh_icosahedron.opacity > 0.0 and figure.mesh_icosahedron.opacity < 1.0,
        "Commit visibly fades over time",
    )
    await _frames(5)
    await _capture("fade", "04_late", _run_state(gameplay))
    await _frames(8)
    _check(
        not figure.mesh_icosahedron.visible and not figure.resolved,
        "Faded shell still awaits collision validation",
    )
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
    _check(
        gameplay.game_state_manager.game_state == GameStateManager.GameState.GAME_END,
        "Restart waits for rotation",
    )
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
    _check(main.current_scene == gameplay, "Selecting Menu does not autoclick")
    await _tap_accept()
    _check(main.current_scene == main.scenes.MenuScene, "Confirming Menu returns to menu")
    await _capture("options", "06_menu", { })
    _save_contact_sheet("options")


func _collision_sequence() -> void:
    seed(SEED)
    var lab := RUN_LAB.instantiate()
    add_child(lab)
    var gameplay: LoopScene = lab.gameplay
    gameplay.get_node("LoopTimer").stop()
    gameplay.get_node("ScaleTimer").stop()
    var figure := gameplay.figure_root.get_live_figures()[0]
    var empty := figure.data.sides.filter(
        func(side: SideData):
            return side.is_empty(),
    )[0] as SideData
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
    var solid_start := figure.data.sides.filter(
        func(side: SideData):
            return not side.is_empty(),
    )[0] as SideData
    _align_side(gameplay, figure, solid_start)
    var rejected: Array[Icosahedron] = []
    gameplay.controls.commit_rejected.connect(
        func(value):
            rejected.append(value),
    )
    await _tap_accept()
    _check(rejected == [figure], "Incorrect Space emits rejection signal")
    _check(
        not figure.mesh_icosahedron.angle_good and figure.mesh_icosahedron.visible,
        "Rejected figure stays visible and unlocked",
    )
    _check(
        gameplay.controls.controlledNode == figure.mesh_icosahedron and gameplay.progress.score == 0,
        "Rejected commit keeps control and does not score",
    )
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
    _check(
        not figure.mesh_icosahedron.visible and not figure.resolved,
        "Debug: hidden shell still unresolved",
    )
    var shape: CollisionShape3D = figure \
            .get_node("MeshIcosahedron/SideColliders") \
            .get_child(0) \
            .get_child(0)
    _check(
        lab.collision_debug.shapes[shape].is_visible_in_tree(),
        "Hidden shell retains debug wireframe",
    )
    await _capture("collision", "03_hidden_collider", _run_state(gameplay))
    await _grow_to_contact(figure)
    _check(gameplay.progress.figures_passed == 1, "Debug: real hole contact scores")
    await _capture("collision", "04_passed", _run_state(gameplay))
    figure = gameplay.figure_root.get_live_figures()[0]
    var solid := figure.data.sides.filter(
        func(side: SideData):
            return not side.is_empty(),
    )[0] as SideData
    _align_side(gameplay, figure, solid)
    figure.scale = Vector3.ONE * 10.0
    await _frames(3)
    await _capture("collision", "05_solid_approach", _run_state(gameplay))
    await _grow_to_contact(figure)
    await _frames(20)
    _check(
        gameplay.game_state_manager.game_state == GameStateManager.GameState.GAME_END,
        "Debug: real solid contact fails",
    )
    await _click(lab.get_node("UI/Panel/Buttons/Collisions"))
    await _click(lab.get_node("UI/Panel/Buttons/Observer"))
    await _frames(3)
    _check(not lab.collision_debug.visible, "Collision overlay can be hidden")
    _check(
        gameplay.get_node("Environment/Camera3D").transform.is_equal_approx(
            lab.collision_debug.camera_transform
        ),
        "Observer restores gameplay camera",
    )
    await _capture("collision", "06_game_over", _run_state(gameplay))
    _save_contact_sheet("collision")
    lab.queue_free()
    await _frames(3)


func _check_debug_steering(figure: Icosahedron, label: String) -> void:
    _check(
        get_viewport().gui_get_focus_owner() == null,
        label + ": click leaves gameplay keyboard focus",
    )
    var initial := figure.mesh_icosahedron.quaternion
    Input.action_press("ui_right")
    await _frames(15)
    Input.action_release("ui_right")
    var turned := figure.mesh_icosahedron.quaternion
    _check(not turned.is_equal_approx(initial), label + ": steering works after click")
    await _frames(15)
    _check(figure.mesh_icosahedron.quaternion.is_equal_approx(turned), label
        + ": release stops steering")


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
    _check(
        gameplay.game_state_manager.game_state == GameStateManager.GameState.GAME_ACTIVE,
        label + ": active",
    )
    _check(gameplay.progress.score == 0, label + ": score reset")
    _check(gameplay.progress.figures_passed == 0, label + ": progress reset")
    _check(gameplay.figure_root.get_live_figures().size() == 1, label + ": exactly one figure")
    _check(gameplay.figure_root.anchor.transform.is_equal_approx(Transform3D.IDENTITY), label
        + ": anchor reset")
    _check(
        is_instance_valid(gameplay.controls.figure_controller.target),
        label + ": control target exists",
    )
    _check(not gameplay.get_node("ScaleTimer").paused, label + ": scaling unpaused")


func _rotation_state(lab: Node) -> Dictionary:
    return { "orientation": _quaternion(lab.controller.target.quaternion) }


func _run_state(gameplay: LoopScene) -> Dictionary:
    var figures: Array[Dictionary] = []
    for figure in gameplay.figure_root.get_live_figures():
        figures.append(
            {
                "orientation": _quaternion(figure.mesh_icosahedron.quaternion),
                "scale": [figure.scale.x, figure.scale.y, figure.scale.z],
                "opacity": figure.mesh_icosahedron.opacity,
                "committed": figure.mesh_icosahedron.angle_good,
                "easy_side": figure.data.easy_side,
                "layout_difficulty": figure.data.stage,
                "open_faces": figure.data.sides.filter(
                    func(side):
                        return side.is_empty(),
                ).map(
                    func(side):
                        return side.id,
                ),
                "visible": figure.mesh_icosahedron.is_visible_in_tree(),
                "controlled": figure.mesh_icosahedron == gameplay.controls.figure_controller.target,
            }
        )
    var anchor_scale := gameplay.figure_root.anchor.scale
    return {
        "game_state": GameStateManager.GameStateNames[gameplay.game_state_manager.game_state],
        "score": gameplay.progress.score,
        "difficulty": gameplay.progress.run_state.difficulty,
        "tiers_collected": gameplay.progress.run_state.tiers_collected,
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
    captures.append({ "file": filename, "frame": frame, "state": state })
    image.convert(Image.FORMAT_RGBA8)
    image.resize(SIZE.x / 2, SIZE.y / 2, Image.INTERPOLATE_LANCZOS)
    thumbnails.append(image)


func _save_contact_sheet(scenario: String) -> void:
    # Six sparse checkpoints catch gross transitions, not single-frame glitches;
    # increase capture density or record video when investigating animation artifacts.
    var sheet := Image.create_empty(SIZE.x, SIZE.y / 2 * 3, false, Image.FORMAT_RGBA8)
    for i in range(thumbnails.size()):
        sheet.blit_rect(
            thumbnails[i],
            Rect2i(Vector2i.ZERO, thumbnails[i].get_size()),
            Vector2i((i % 2) * (SIZE.x / 2), (i / 2) * (SIZE.y / 2)),
        )
    _check(
        sheet.save_png(output.path_join(scenario + "_contact_sheet.png")) == OK,
        "Save " + scenario + " contact sheet",
    )
    thumbnails.clear()


func _check(condition: bool, description: String) -> void:
    checks.append({ "check": description, "passed": condition })
    if not condition:
        failed = true
        push_error("Visual playtest check failed: " + description)
