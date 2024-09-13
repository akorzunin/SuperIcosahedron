#!/usr/bin/env -S godot --headless -s --quit
extends SceneTree

var G ={
    settings ={
        SPAWN_MODE=2,
        DESPAWNER_MODE=16633,
        ROTATION_SPEED=12,
        MAX_LEVEL=0,

        SPAWN_SPEED=10,
        SCALE_FACTOR=10,
        GAME_SPEED=10,
    }
}

func gs_calc(x: int):
    return  0.5 +  (x / (10. + x))

func get_loop():
    return 100. / (G.settings.SPAWN_SPEED * G.settings.GAME_SPEED)

func get_scale():
    # return 1. + ((G.settings.SCALE_FACTOR / 10.) * gs_calc(G.settings.GAME_SPEED)) / 100.
    # return 1. + (
    #     (G.settings.SCALE_FACTOR / 10.)
    #     * (0.5 +  (G.settings.GAME_SPEED / (10. + G.settings.GAME_SPEED)))
    # ) / 100.
    return 1. + (G.settings.SCALE_FACTOR  / 1000. ) * (0.5 +  (G.settings.GAME_SPEED / (10. + G.settings.GAME_SPEED)))

func main():
    print_debug(gs_calc(20))

    print_debug("base loop: ", 1, " > ", get_loop())
    print_debug("base scale: ", 1.01, " > ", get_scale())
    G.settings.GAME_SPEED = 5
    print_debug("\nL2: gs=", G.settings.GAME_SPEED)
    print_debug("loop: ", get_loop())
    print_debug("scale: ", get_scale())
    G.settings.GAME_SPEED = 20
    print_debug("\nL3: gs=", G.settings.GAME_SPEED)
    print_debug("loop: ", get_loop())
    print_debug("scale: ", get_scale())
    pass

func _init():
    main()
    quit()
