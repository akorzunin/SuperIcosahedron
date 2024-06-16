extends Node
class_name MenuStruct

const menu_items = {
    name = "root",
    items = {
        1: {
            name = "start",
            action = "menu_start_game",
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
        5: {
            name = "exit",
            action = "menu_exit_game",
        },
        6: {
            name = "credits",
        },
    }
}
