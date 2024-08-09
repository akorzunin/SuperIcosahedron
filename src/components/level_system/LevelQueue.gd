extends Node
class_name LevelQueue

var items: Array[Dictionary] = []

var length: int:
    get:
        return len(items)

func next_item() -> Dictionary:
    if len(items) < 1:
        push_error("out of items")
        return {}
    return items.pop_back()

func add_item(new_item: Dictionary):
    items.push_front(new_item)

func add_items(new_items: Array[Dictionary]):
    items.append_array(new_items)

func print_members():
    print_debug("Q members:")
    for i in len(items):
        print_debug(items[ - i - 1])

func clear():
    items = []




# https://docs.godotengine.org/en/latest/tutorials/scripting/gdscript/gdscript_advanced.html#custom-iterators

# func should_continue():
#     return (current < end)

# func _iter_init(arg):
#     current = start
#     return should_continue()

# func _iter_next(arg):
#     current += increment
#     return should_continue()

# func _iter_get(arg):
#     return current
