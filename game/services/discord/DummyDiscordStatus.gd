extends Node
class_name DummyDiscordStatus

## Use this module if platform cant have DiscordRPC namespace

func _ready():
    pass

func set_state(details: String, desc: String, with_time: bool = false):
    pass

func set_menu_state():
    pass

func set_loop_state(level := 0):
    pass

func _notification(what: int):
    pass
