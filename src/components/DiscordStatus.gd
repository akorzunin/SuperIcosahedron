extends Node
class_name DiscordStatus

func _ready():
    DiscordRPC.app_id = ENV.DISCORD_APP_ID # Application ID
    DiscordRPC.details = "Main menu"
    DiscordRPC.state = "Checkpoint 23/23"
    DiscordRPC.large_image = 'icon' # Image key from "Art Assets"
    DiscordRPC.large_image_text = "Try it now!"
    DiscordRPC.small_image = 'icon' # Image key from "Art Assets"
    DiscordRPC.small_image_text = "Fighting the end boss! D:"

    DiscordRPC.start_timestamp = int(Time.get_unix_time_from_system()) # "02:46 elapsed"
    # DiscordRPC.end_timestamp = int(Time.get_unix_time_from_system()) + 3600 # +1 hour in unix time / "01:00:00 remaining"

    DiscordRPC.refresh() # Always refresh after changing the values!
