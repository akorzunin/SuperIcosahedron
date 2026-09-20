extends Node3D
class_name MenuSpawner

@onready var discord_status: DummyDiscordStatus = $"/root/MainScene/DiscordStatus"

@onready var anchor: Marker3D = %Anchor
@onready var menu_scene: MenuSpawner = $'.'
@onready var gui: MenuGui = $'../Gui'
@onready var menu_controls: MenuControls = $'../MenuControls'
@onready var menu_state: MenuState = %MenuState

const IcosahedronScene = preload('res://game/gameplay/figure/Icosahedron.tscn')
const MenuItemScene = preload('res://game/menu/item/MenuItem.tscn')


func add_menu_items(node: Marker3D, layer: Dictionary):
    var items = layer.get("items")
    if not items:
        return
    #for loop over first level items
    for key in items.keys():
        var new_item = MenuItemScene.instantiate() \
                .init({ pos = key, val = items[key] })
        node.add_child(new_item)
    if menu_controls.is_node_ready():
        menu_controls.change_selection(Quaternion(), true)


func clean_menu_items(node: Node3D):
    for i in node.get_children():
        if i.is_in_group("menu_item"):
            i.queue_free()


func open_menu_section(node: Node3D, items: Dictionary):
    if menu_state.forth(items, node.quaternion) == OK:
        show_section(node, items)


func open_options_section(node: Node3D, items: Dictionary):
    open_menu_section(node, items)


func show_section(node: Node3D, section: Dictionary):
    var layer: Dictionary
    if section.has("options"):
        var options: Dictionary = section.options.duplicate(true)
        _put_current_option_first(options, section.get("setting", ""))
        layer = { items = options }
    else:
        layer = section.duplicate(true)
    if not menu_state.history.is_empty():
        add_back_button(layer)
    clean_menu_items(node)
    add_menu_items(node, layer)
    gui.get_node("SectionTitle").text = (
        str(section.get("name", "")).replace("\n", " ")
        if not menu_state \
                .history \
                .is_empty()
        else ""
    )
    gui.show_modifier_description(section.get("modifier_description", ""))
    show_modifier_faces(section)


func show_modifier_faces(section: Dictionary) -> void:
    var figure := anchor.get_node_or_null("Icosahedron") as Icosahedron
    if not figure:
        return
    if not section.has("modifier_page"):
        var normal_data := StageGenerator.create_figure(0)
        figure.init(normal_data)
        figure.mesh_icosahedron.apply_side_data(normal_data.sides)
        figure.mesh_icosahedron.set_default_type()
        figure.mesh_icosahedron.set_controlled(false)
        return
    var preview := FigureData.new()
    preview.easy_side = 0
    for variant_id in IcosahedronVarints.figure_variants_v2.keys():
        var variant: Vector4 = IcosahedronVarints.figure_variants_v2[variant_id]
        preview.sides.append(SideData.new().init(
                variant_id,
                Vector3(variant.x, variant.y, variant.z),
                SideData.Kind.SOLID,
            ))
    for item in anchor.get_children():
        if not item is MenuItem or item.is_queued_for_deletion():
            continue
        var id: String = item.items.get("modifier_id", "")
        if id.is_empty():
            continue
        var side_id := _menu_item_side(figure, item)
        var side: SideData = preview.sides[side_id]
        side.kind = SideData.Kind.POSITIVE
        side.modifier = UpgradeCatalog.pickup(id, 2)
        side.score_delta = side.modifier.score_value
    figure.init(preview)
    figure.mesh_icosahedron.apply_side_data(preview.sides)
    for label in figure.mesh_icosahedron._pickup_labels:
        label.offset.y = 150
        # Sprite children do not inherit Label3D's drawing offset.
        for icon in label.get_children():
            if icon is Sprite3D:
                icon.offset.y = label.offset.y * label.pixel_size / icon.pixel_size
    figure.mesh_icosahedron.set_default_type()
    figure.mesh_icosahedron.set_controlled(true)


func _menu_item_side(figure: Icosahedron, item: MenuItem) -> int:
    var toward_label := (item.label_3d.global_position - figure.global_position).normalized()
    var best_id := 0
    var best_dot := -INF
    for variant_id in IcosahedronVarints.figure_variants_v2.keys():
        var variant: Vector4 = IcosahedronVarints.figure_variants_v2[variant_id]
        var normal := (
            figure.global_transform.basis * Vector3(variant.x, variant.y, variant.z)
        ).normalized()
        var candidate := normal.dot(toward_label)
        if candidate > best_dot:
            best_dot = candidate
            best_id = variant_id
    return best_id


func go_back():
    if menu_state.history.is_empty():
        return
    var section := menu_state.back()
    show_section(anchor, section)
    menu_controls.change_selection(menu_state.restored_rotation, true)


func _put_current_option_first(options: Dictionary, setting: String) -> void:
    if setting.is_empty() or not G.settings.has(setting):
        return

    var current_option := -1
    for key in options:
        options[key]["setting"] = setting
        if current_option < 1 and options[key].get("value", null) == G.settings[setting]:
            current_option = key
    if current_option < 1:
        return

    options[current_option]["is_current"] = true
    if current_option == 1:
        return

    var first_option = options[1]
    options[1] = options[current_option]
    options[current_option] = first_option


func add_back_button(d: Dictionary) -> Dictionary:
    if not d.get("items"):
        return d
    if d.items.get(5):
        return d
    d.items[5] = { name = "back", action = "menu_back" }
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
