#!/usr/bin/env -S godot --headless -s
extends SceneTree

var local_confg := "res://src/components/settings/default_settings.cfg"
var user_config := "user://settings.cfg"

func copy_config(src: String, dest: String):
    print("reading local config")
    var dc := SettingsConfig.load_gs(src)
    print(dc)
    print("writig to user config")
    var config := SettingsConfig.dict_to_config(dc)
    config.save(dest)

func sync_config(name: String):
    if name == "local":
        copy_config(local_confg, user_config)
    elif name == "user":
        copy_config(user_config, local_confg)

func main(args: Dictionary):
    var _s = args.get("s")
    var _sync = args.get("sync")
    if _s or _sync:
        if _s:
            sync_config(_s)
        elif _sync:
            sync_config(_sync)
    else:
        print("""
sync config from local to user and vise versa
-s=local copy from local to user config

-s=name (name: user, local)
--sync=name
        """)

func _init():
    var arguments = {}
    for argument in OS.get_cmdline_args():
        # Parse valid command-line arguments into a dictionary
        if argument.find("=") > -1:
            var key_value = argument.split("=")
            arguments[key_value[0].lstrip("--")] = key_value[1]
    main(arguments)
    quit()
