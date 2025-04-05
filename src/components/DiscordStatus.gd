extends DummyDiscordStatus
class_name DiscordStatus

func _ready():
    DiscordRPC.app_id = ENV.DISCORD_APP_ID # Application ID
    DiscordRPC.details = init_state.details
    DiscordRPC.state = init_state.desc
    DiscordRPC.large_image = 'icon' # Image key from "Art Assets"
    DiscordRPC.refresh()

const init_state := {
    details = "Main menu",
    desc = "Chilling",
}

const loop_state := {
    details = "In Game",
    desc = "Level: %s",
}

func set_state(details: String, desc: String, with_time: bool = false):
    if with_time:
        DiscordRPC.start_timestamp = int(Time.get_unix_time_from_system()) # "02:46 elapsed"
    else:
        DiscordRPC.start_timestamp = 0
    DiscordRPC.details = details
    DiscordRPC.state = desc
    DiscordRPC.refresh()

func set_menu_state():
    set_state(init_state.details, init_state.desc)

func set_loop_state(level := 0):
    set_state(
        loop_state.details,
        loop_state.desc % level if level else "tutorial",
        true
    )

func _notification(what: int):
    if what == NOTIFICATION_WM_CLOSE_REQUEST:
        DiscordRPC.clear()
        get_tree().quit() # default behavior
