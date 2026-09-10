extends RefCounted
class_name FaceTopology

static func normal(id: int) -> Vector3:
    var v: Vector4 = IcosahedronVarints.figure_variants_v2[id]
    return Vector3(v.x, v.y, v.z).normalized()

static func neighbors(id: int) -> Array[int]:
    var result: Array[int] = []
    for other in 20:
        # Fixed regular icosahedron: adjacent normals have dot sqrt(5)/3.
        if other != id and normal(id).dot(normal(other)) > 0.74:
            result.append(other)
    return result

static func distances(center: int) -> Array[int]:
    var result: Array[int] = []
    result.resize(20)
    result.fill(-1)
    result[center] = 0
    var queue: Array[int] = [center]
    for id in queue:
        for next in neighbors(id):
            if result[next] < 0:
                result[next] = result[id] + 1
                queue.append(next)
    return result

static func nearest(direction: Vector3) -> int:
    var best := 0
    for id in range(1, 20):
        if normal(id).dot(direction) > normal(best).dot(direction):
            best = id
    return best

static func _face_basis(id: int) -> Basis:
    var z := normal(id)
    var neighbor := normal(neighbors(id)[0])
    var x := (neighbor - z * neighbor.dot(z)).normalized()
    return Basis(x, z.cross(x), z)

static func face_mapping(from: int, to: int) -> Array[int]:
    # Mapping an oriented face AND an edge gives an exact icosahedral symmetry,
    # unlike a shortest-arc quaternion between normals (which can twist edges).
    var rotation := _face_basis(to) * _face_basis(from).inverse()
    var result: Array[int] = []
    for id in 20:
        result.append(nearest(rotation * normal(id)))
    return result

static func recenter(figure: FigureData, center: int) -> void:
    if figure.easy_side < 0 or figure.easy_side == center:
        return
    var mapping := face_mapping(figure.easy_side, center)
    var kinds := []
    var modifiers := []
    var entities := []
    for side in figure.sides:
        kinds.append(side.kind)
        modifiers.append(side.modifier)
        entities.append(side.modifier_entity)
    for id in 20:
        # Keep SideData identity: live colliders refer to these resources.
        var side := figure.sides[mapping[id]]
        side.kind = kinds[id]
        side.modifier = modifiers[id]
        side.modifier_entity = entities[id]
        side.score_delta = side.modifier.score_value if side.modifier else 0
    figure.easy_side = center
