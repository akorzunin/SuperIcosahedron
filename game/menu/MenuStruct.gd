extends RefCounted
class_name MenuStruct


static var settings_items := {
    1: {
        name = "controls",
        items = {
            1: {
                name = "control\ntype",
                setting = "CONTROL_TYPE",
                options = {
                    1: {
                        name = "FreeSpin",
                        value = "FREE_SPIN",
                        action = "settings_set_control_free_spin",
                    },
                    2: {
                        name = "FaceLock",
                        value = "FACE_LOCK",
                        action = "settings_set_control_face_lock",
                    },
                },
            },
            2: {
                name = "invert\nx-axis",
                setting = "IS_CONTROL_INVERTED",
                options = {
                    1: {
                        name = "on",
                        value = true,
                        action = "settings_invert_x",
                    },
                    2: {
                        name = "off",
                        value = false,
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
                setting = "FPS_COUNTER_ENABLED",
                options = {
                    1: {
                        name = "on",
                        value = true,
                        action = "settings_fps_counter_on"
                    },
                    2: {
                        name = "off",
                        value = false,
                        action = "settings_fps_counter_off"
                    },
                },
            },
            2: {
                name = "display\ndebug\nstats",
                setting = "SHOW_DEBUG_STATS",
                options = {
                    1: {
                        name = "on",
                        value = true,
                        action = "settings_display_debug_stats_on"
                    },
                    2: {
                        name = "off",
                        value = false,
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
                setting = "FULLSCREEN_ENABLED",
                options = {
                    1: {
                        name = "fullscreen",
                        value = true,
                        action = "settings_fullscreen"
                    },
                    2: {
                        name = "bordered",
                        value = false,
                        action = "settings_bordered"
                    },
                },
            },
            2: {
                name = "v-sync",
                setting = "VSYNC_ENABLED",
                options = {
                    1: {
                        name = "on",
                        value = true,
                        action = "settings_vsync_on"
                    },
                    2: {
                        name = "off",
                        value = false,
                        action = "settings_vsync_off"
                    },
                },
            },
            3: {
                name = "3d scale",
                setting = "RENDER_SCALE_PERCENT",
                action = "settings_cycle_render_scale",
            },
        }
    },
    4: {
        name = "audio",
        items = {
            1: {
                name = "music",
                setting = "MUSIC_ENABLED",
                options = {
                    1: {
                        name = "on",
                        value = true,
                        action = "settings_music_on"
                    },
                    2: {
                        name = "off",
                        value = false,
                        action = "settings_music_off"
                    },
                },
            },
            2: {
                name = "sfx",
                setting = "SFX_ENABLED",
                options = {
                    1: {
                        name = "on",
                        value = true,
                        action = "settings_sfx_on"
                    },
                    2: {
                        name = "off",
                        value = false,
                        action = "settings_sfx_off"
                    },
                },
            }
        }
    },
    6: {
        name = "reset\nprogress",
        items = {
            1: {name = "erase all\nprogress", action = "settings_reset_progress"},
        },
    },
    7: {
        name = "restore\ndefaults",
        items = {
            1: {name = "reset all\nsettings", action = "settings_reset_defaults"},
        },
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
