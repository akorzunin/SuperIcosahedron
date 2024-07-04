"""Some pre build checks"""


def check_main_scene():
    main_scene = "res://src/scenes/MainScene.tscn"
    with open("project.godot") as f:
        for line in f.readlines():
            if line.startswith("run/main_scene="):
                # check scene name
                scene_name = line.split("=")[-1].strip("\n").strip('"')
                if scene_name != main_scene:
                    raise SystemExit(f"Incorrect main scene: {scene_name}")
                break
        else:
            raise SystemExit("main_scene field not found")
        print("main_scene: OK")


if __name__ == "__main__":
    check_main_scene()
