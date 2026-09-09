extends Node3D

# Lab-only wireframes from the actual physics resources, not reconstructed faces.
var gameplay: LoopScene
var enabled := false
var observer := false
var shapes: Dictionary = {}
var camera_transform: Transform3D

func _ready() -> void:
    camera_transform = gameplay.get_node("Environment/Camera3D").transform

func set_enabled(value: bool) -> void:
    enabled = value
    visible = value
    gameplay.get_node("EndDetector").debug_contacts = value

func set_observer(value: bool) -> void:
    observer = value
    var camera: Camera3D = gameplay.get_node("Environment/Camera3D")
    if value:
        camera.position = Vector3(22, 14, 25)
        camera.look_at(Vector3(0, 3, 5))
    else:
        camera.transform = camera_transform

func _process(_delta: float) -> void:
    if not enabled:
        return
    var current: Array[CollisionShape3D] = []
    current.append(gameplay.get_node("EndDetector/CollisionShape3D"))
    for figure in gameplay.figure_root.get_live_figures():
        for area in figure.get_node("MeshIcosahedron/SideColliders").get_children():
            current.append(area.get_child(0))
    # O(n²) membership scan is lab-only; use a set if many live shells make it slow.
    for shape in shapes.keys():
        if not is_instance_valid(shape) or not current.has(shape):
            shapes[shape].queue_free()
            shapes.erase(shape)
    for shape in current:
        if not shapes.has(shape):
            var wire := MeshInstance3D.new()
            var lines := ImmediateMesh.new()
            lines.surface_begin(Mesh.PRIMITIVE_LINES)
            if shape.get_parent() is EndDetector:
                # Draw the actual prism perimeter without cap-triangulation spokes.
                var points: PackedVector3Array = shape.shape.points
                var count := points.size() / 2
                for i in count:
                    for cap in 2:
                        lines.surface_add_vertex(points[cap * count + i])
                        lines.surface_add_vertex(points[cap * count + (i + 1) % count])
                    lines.surface_add_vertex(points[i])
                    lines.surface_add_vertex(points[count + i])
            else:
                var faces := shape.shape.get_debug_mesh().get_faces()
                for triangle in range(0, faces.size(), 3):
                    for edge in 3:
                        lines.surface_add_vertex(faces[triangle + edge])
                        lines.surface_add_vertex(faces[triangle + (edge + 1) % 3])
            lines.surface_end()
            wire.mesh = lines
            var material := StandardMaterial3D.new()
            material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
            material.no_depth_test = true
            var area := shape.get_parent()
            material.albedo_color = Color.MAGENTA
            if area is SideCollider:
                material.albedo_color = Color.LIME_GREEN if area.side.is_empty() else Color.RED
            wire.material_override = material
            add_child(wire)
            shapes[shape] = wire
        # Sibling debug meshes stay visible after a committed shell hides.
        shapes[shape].global_transform = shape.global_transform
        shapes[shape].visible = not shape.disabled
