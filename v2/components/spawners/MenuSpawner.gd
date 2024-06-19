extends Node3D
class_name MenuSpawner

@onready var settings: Settings = %Settings
@onready var anchor: Marker3D = %Anchor
@onready var menu_scene: MenuSpawner = $'.'

const IcosahedronScene = preload ('res://v2/models/icosahedron/Icosahedron.tscn')
const MenuItemScene = preload('res://v2/models/menu_item/MenuItem.tscn')

func menu_action():
    print_debug("aboba")


func add_menu_items(node: Node3D, layer : Dictionary):
    var items = layer.get("items")
    if not items:
        return
#for loop over first level items
    for key in items.keys():
        var new_item = MenuItemScene.instantiate() \
            .init({
                pos = key,
                val = items[key]
            })
        node.add_child(new_item)

func clean_menu_items(node: Node3D):
    for i in node.get_children():
        if i.is_in_group("menu_item"):
            i.queue_free()
    pass

func open_menu_section(node, items):
    clean_menu_items(node)
    add_menu_items(node, items)
    pass

# Called when the node enters the scene tree for the first time.
func _ready():
    # only one node allowed at startup
    if anchor.get_node_or_null("Icosahedron"):
        return
    var new_figure = IcosahedronScene.instantiate() \
                .init(
                    settings,
                    {type=0},
                    {quat=G.D.init_pos}
                )
    #new_figure.hide()
    anchor.add_child(new_figure)
    add_menu_items(anchor, MenuStruct.menu_items)
    pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
    pass
