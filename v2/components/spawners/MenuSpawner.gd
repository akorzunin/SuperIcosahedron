extends Node3D
class_name MenuSpawner

@onready var settings: Settings = %Settings
const IcosahedronScene = preload ('res://v2/models/icosahedron/Icosahedron.tscn')
@onready var anchor: Marker3D = %Anchor

func menu_action():
    print_debug("aboba")

const menu_items = {
    name = "root",
    items = {
        1: {
            name = "start",
            action = "menu_action",
        },
        2: {
            name = "settings",
            items = {
                1: {
                    name = "video",
                    items = {
                        1: {
                            name = "window_mode",
                            options = {
                                1: {
                                    name = "fullscreen",
                                    action = "settings_fullscreen"
                                },
                                2: {
                                    name = "bordered",
                                    action = "settings_bordered"
                                },
                            },
                        },
                        2: {
                            name = "v-sync",
                            options = {
                                1: {
                                    name = "on",
                                    action = "settings_vsync_on"
                                },
                                2: {
                                    name = "off",
                                    action = "settings_vsync_off"
                                },
                            },
                        }
                    }
                },
                2: {
                    name = "audio",
                    items = {
                        1: {
                            name = "music",
                            options = {
                                1: {
                                    name = "on",
                                    action = "settings_music_on"
                                },
                                2: {
                                    name = "off",
                                    action = "settings_music_off"
                                },
                            },
                        },
                        2: {
                            name = "sfx",
                            options = {
                                1: {
                                    name = "on",
                                    action = "settings_sfx_on"
                                },
                                2: {
                                    name = "off",
                                    action = "settings_sfx_off"
                                },
                            },
                        }
                    }
                },
                3: {
                    name = "controls",
                    action = "menu_open_controls_editor"
                },
            }
        },
        3: {
            name = "achivemets",
        },
        4: {
            name = "credits",
        },
    }
}
# Called when the node enters the scene tree for the first time.
func _ready():
    # only one node allowed at startup
    if anchor.get_node_or_null("Icosahedron"):
        return
    var new_figure = IcosahedronScene.instantiate() \
                .init(
                    settings,
                    {type=0},
                    {quat=G.D.init_pos}
                )
    #new_figure.hide()
    anchor.add_child(new_figure)
    pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
    pass
