extends InputEventAction
class_name InputEmit

func emit(props: Dictionary):
    action = props.action
    pressed = props.get("pressed", true)
    Input.parse_input_event(self)
    return self
