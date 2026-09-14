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
        4: {
            name = "modifiers\nlibrary",
            action = "menu_modifier_library",
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
        4: {
            name = "📚",
            action = "menu_modifier_library",
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

const MODIFIER_PAGE_SIZE := 4

static func modifier_library_page(page: int) -> Dictionary:
    var discovered: Array = UpgradeCatalog.data.pickups.filter(func(entry): return G.discovered_modifiers.has(entry.id))
    var page_count := maxi(1, ceili(float(discovered.size()) / MODIFIER_PAGE_SIZE))
    page = clampi(page, 0, page_count - 1)
    var section := {
        name = "modifiers · %d/%d" % [page + 1, page_count],
        items = {},
        modifier_page = page,
        modifier_page_count = page_count,
    }
    var first := page * MODIFIER_PAGE_SIZE
    for index in mini(MODIFIER_PAGE_SIZE, discovered.size() - first):
        var entry: Dictionary = discovered[first + index]
        section.items[index + 1] = {
            name = entry.title,
            action = "menu_show_modifier",
            modifier_id = entry.id,
            modifier_color = Color(entry.color),
        }
    if discovered.is_empty():
        section.items[1] = {name = "no modifiers\ndiscovered"}
    section.items[5] = {name = "back", action = "menu_back"}
    if page > 0:
        section.items[6] = {name = "previous\npage", action = "menu_modifier_library_previous"}
    if page < page_count - 1:
        section.items[7] = {name = "next\npage", action = "menu_modifier_library_next"}
    if not discovered.is_empty():
        section.preview_modifier_id = discovered[first].id
    return section

static func modifier_detail(id: String) -> Dictionary:
    for entry in UpgradeCatalog.data.pickups:
        if entry.id != id:
            continue
        return {
            name = entry.title,
            items = {
                1: {name = "collect during\na run"},
                5: {name = "back", action = "menu_back"},
            },
            modifier_id = id,
            modifier_description = entry.get("description", ""),
            preview_modifier_id = id,
        }
    return modifier_library_page(0)

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
