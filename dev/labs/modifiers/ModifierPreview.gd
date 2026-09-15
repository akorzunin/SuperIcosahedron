extends SubViewportContainer

signal modifier_selected(index: int)

var figure: Icosahedron
var viewport: SubViewport
var camera: Camera3D
var dragging := false
var drag_distance := 0.0
var face_indices: Dictionary = { }


func _ready() -> void:
    stretch = true
    custom_minimum_size = Vector2(300, 230)
    size_flags_vertical = Control.SIZE_EXPAND_FILL
    viewport = SubViewport.new()
    viewport.own_world_3d = true
    viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
    add_child(viewport)
    camera = Camera3D.new()
    camera.position = Vector3(0, 0, 2.8)
    camera.fov = 45
    viewport.add_child(camera)
    var environment := WorldEnvironment.new()
    environment.environment = Environment.new()
    environment.environment.background_mode = Environment.BG_COLOR
    environment.environment.background_color = Color("101722")
    environment.environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
    environment.environment.ambient_light_color = Color.WHITE
    environment.environment.ambient_light_energy = 0.7
    viewport.add_child(environment)
    var light := DirectionalLight3D.new()
    light.rotation_degrees = Vector3(-30, -30, 0)
    viewport.add_child(light)
    var data := FigureData.new()
    data.easy_side = 0
    for id in IcosahedronVarints.figure_variants_v2:
        var normal: Vector4 = IcosahedronVarints.figure_variants_v2[id]
        data.sides.append(SideData.new().init(
                id,
                Vector3(normal.x, normal.y, normal.z),
                SideData.Kind.SOLID,
            ))
    # One real pickup face per catalog entry; remaining faces show the solid shell.
    for index in UpgradeCatalog.data.pickups.size():
        var side: SideData = data.sides[index * 2]
        side.kind = SideData.Kind.POSITIVE
        side.modifier = UpgradeCatalog.pickup(UpgradeCatalog.data.pickups[index].id)
        face_indices[side.id] = index
    figure = preload("res://game/gameplay/figure/Icosahedron.tscn").instantiate()
    figure.inital_transform = Quaternion.IDENTITY
    figure.scaling_enabled = false
    figure.shader_type = -1
    figure.data = data
    viewport.add_child(figure)
    figure.mesh_icosahedron.set_controlled(true)
    gui_input.connect(_on_preview_input)


func select_modifier(index: int, steps: int) -> void:
    var side: SideData = figure.data.sides[index * 2]
    side.modifier = UpgradeCatalog.pickup(UpgradeCatalog.data.pickups[index].id, steps)
    figure.mesh_icosahedron.apply_side_data(figure.data.sides)
    figure.mesh_icosahedron.set_controlled(true)
    var points := figure.mesh_icosahedron.get_side_points(side.id)
    var outward := (points[1] + points[2] + points[3]).normalized()
    figure.quaternion = Quaternion(outward, Vector3.BACK)


func _on_preview_input(event: InputEvent) -> void:
    if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
        if event.pressed:
            dragging = true
            drag_distance = 0
        else:
            if dragging and drag_distance < 5:
                _pick_face(event.position)
            dragging = false
        accept_event()
    elif event is InputEventMouseMotion and dragging:
        drag_distance += event.relative.length()
        figure.rotate_y(event.relative.x * 0.01)
        figure.rotate(Vector3.RIGHT, event.relative.y * 0.01)
        accept_event()


func _pick_face(point: Vector2) -> void:
    var origin := camera.project_ray_origin(point)
    var query := PhysicsRayQueryParameters3D.create(
        origin,
        origin + camera.project_ray_normal(point) * 10,
    )
    query.collide_with_areas = true
    query.collide_with_bodies = false
    var hit := viewport.world_3d.direct_space_state.intersect_ray(query)
    if not hit.is_empty() and hit.collider is SideCollider:
        var id: int = hit.collider.side.id
        if face_indices.has(id):
            modifier_selected.emit(face_indices[id])
