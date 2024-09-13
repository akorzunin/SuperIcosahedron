extends RefCounted
class_name MenuStruct


static var settings_items := {
    1: {
        name = "controls",
        items = {
            1: {
                name = "control\ntype",
                options = {
                    1: {
                        name = "FreeSpin",
                        action = "settings_set_control_free_spin",
                    },
                    2: {
                        name = "FaceLock",
                        action = "settings_set_control_face_lock",
                    },
                },
            },
            2: {
                name = "invert\nx-axis",
                options = {
                    1: {
                        name = "on",
                        action = "settings_invert_x",
                    },
                    2: {
                        name = "off",
                        action = "settings_not_invert_x",
                    },
                },
            },
        }

    },
    2: {
        name = "ui",
        items = {
            1: {
                name = "fps\ncounter",
                options = {
                    1: {
                        name = "on",
                        action = "settings_fps_counter_on"
                    },
                    2: {
                        name = "off",
                        action = "settings_fps_counter_off"
                    },
                },
            },
            2: {
                name = "display\ndebug\nstats",
                options = {
                    1: {
                        name = "on",
                        action = "settings_display_debug_stats_on"
                    },
                    2: {
                        name = "off",
                        action = "settings_display_debug_stats_off"
                    },
                },
            },
        }
    },
    3: {
        name = "video",
        items = {
            1: {
                name = "window mode",
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
    4: {
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
}

static var menu_items := {
    name = "root",
    items = {
        1: {
            name = "start",
            action = "menu_level_select",
        },
        2: {
            name = "settings",
            items = settings_items,
        },
        3: {
            name = "achivemets",
            action = "menu_show_achivemets"
        },
        5: {
            name = "exit",
            action = "menu_exit_game",
        },
        6: {
            name = "credits",
            action = "menu_show_credits",
        },
        7: {
            name = "???",
            action = "menu_easter_egg",
        },
    }
}

static var menu_items_emoji := {
    name = "root",
    items = {
        1: {
            'name': "🎮",
            'action': "menu_level_select",
        },
        2: {
            'name': "⚙️",
            'items': settings_items,
        },
        3: {
            'name': "🏆",
            'action': "menu_show_achievements",
        },
        5: {
            'name': "🚪",
            'action': "menu_exit_game",
        },
        6: {
            'name': "📜",
            'action': "menu_show_credits",
        },
        7: {
            'name': "o(`>w<')o",
            'action': "menu_easter_egg",
        },
    }
}

static var game_over := {
    name = "game_over",
    items = {
        1: {
            name = "score",
        },
        2: {
            name = "restart",
        },
        5: {
            name = "exit",
        },
        6: {
            name = "game over",
        },
    }
}
