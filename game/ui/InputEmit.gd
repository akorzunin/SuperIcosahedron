extends InputEventAction
class_name InputEmit

var scene

func emit(props: Dictionary):
    scene = props.get("scene")
    action = props.action
    pressed = props.get("pressed", true)
    Input.parse_input_event(self)
    return self
