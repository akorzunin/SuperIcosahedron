extends Node
class_name LevelQueue

var items: Array[int] = []

var length: int:
    get:
        return len(items)

func next_item() -> int:
    if len(items) < 1:
        push_error("out of items")
        return ERR_DOES_NOT_EXIST
    return items.pop_back()

func add_item(new_item: int):
    items.push_front(new_item)

func add_items(new_items: Array[int]):
    items.append_array(new_items)

func print_members():
    print_debug("Q members:")
    for i in len(items):
        print_debug("  ", items[ - i - 1])
    print_debug("")

func clear():
    items = []
