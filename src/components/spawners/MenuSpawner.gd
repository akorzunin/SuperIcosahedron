extends Node3D
class_name MenuSpawner

@onready var discord_status: DummyDiscordStatus = $"/root/MainScene/DiscordStatus"

@onready var anchor: Marker3D = %Anchor
@onready var menu_scene: MenuSpawner = $'.'
@onready var gui: MenuGui = $'../Gui'
@onready var menu_controls: MenuControls = $'../MenuControls'
@onready var menu_state: MenuState = %MenuState


const IcosahedronScene = preload ('res://src/models/icosahedron/Icosahedron.tscn')
const MenuItemScene = preload('res://src/models/menu_item/MenuItem.tscn')

func add_menu_items(node: Marker3D, layer: Dictionary):
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
    if menu_controls.is_node_ready():
        menu_controls.change_selection(Quaternion(), true)

func clean_menu_items(node: Node3D):
    for i in node.get_children():
        if i.is_in_group("menu_item"):
            i.queue_free()
    pass

func open_menu_section(node, items):
    add_back_button(items)
    clean_menu_items(node)
    add_menu_items(node, items)
    pass

func open_options_section(node: Node3D, items: Dictionary):
    var options = items.options
    clean_menu_items(node)
    add_back_to_options(options)
    add_option_name(options, items.name)
    add_menu_items(node, {items = options})

func add_back_button(d: Dictionary) -> Dictionary:
    if not d.get("items"):
        return d
    if d.items.get(5):
        return d
    d.items[5] = {
        name = "back",
        action = "menu_back",
    }
    return d

func add_back_to_options(d: Dictionary) -> Dictionary:
    d[5] = {
        name = "back",
        action = "menu_back",
    }
    return d

func add_option_name(d: Dictionary, _name: String) -> Dictionary:
    d[6] = {
        name = _name,
        action = "menu_back",
    }
    return d

# Called when the node enters the scene tree for the first time.
func _ready():
    # only one node allowed at startup
    if anchor.get_node_or_null("Icosahedron"):
        return
    var new_figure = IcosahedronScene.instantiate() \
                .with_type(-1)
    anchor.add_child(new_figure)
    call_deferred('set_figures_count', anchor.get_child_count())
    add_menu_items(anchor, menu_state.state)
    discord_status.set_menu_state()

func set_figures_count(v: int):
    gui.debug_stats_container.figures_count.label_text = str(v)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
    pass
