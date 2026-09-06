extends GutTest

const DENT_MESH: Mesh = preload("res://game/gameplay/figure/assets/ico_dent_full.res")

func test_dent_mesh_has_only_the_outer_face() -> void:
    assert_eq(DENT_MESH.get_surface_count(), 1)
    var arrays := DENT_MESH.surface_get_arrays(0)
    var vertices: PackedVector3Array = arrays[Mesh.ARRAY_VERTEX]
    var indices: PackedInt32Array = arrays[Mesh.ARRAY_INDEX]
    assert_eq(indices.size(), 3, "Interior walls must not obscure the empty dent.")
    for index in indices:
        assert_almost_eq(vertices[index].length(), 1.0, 0.0001)

func test_dent_mesh_has_flat_normals_matching_each_triangle() -> void:
    # Every menu/gameplay face uses this mesh; missing normals cause incorrect lighting.
    for surface in DENT_MESH.get_surface_count():
        var arrays := DENT_MESH.surface_get_arrays(surface)
        var vertices: PackedVector3Array = arrays[Mesh.ARRAY_VERTEX]
        var indices: PackedInt32Array = arrays[Mesh.ARRAY_INDEX]
        assert_not_null(arrays[Mesh.ARRAY_NORMAL], "Face mesh must provide lighting normals.")
        if arrays[Mesh.ARRAY_NORMAL] == null:
            return
        var normals: PackedVector3Array = arrays[Mesh.ARRAY_NORMAL]
        assert_eq(normals.size(), vertices.size())
        if normals.size() != vertices.size():
            return
        for i in range(0, indices.size(), 3):
            var a := vertices[indices[i]]
            var b := vertices[indices[i + 1]]
            var c := vertices[indices[i + 2]]
            # Godot uses clockwise front faces. Keep normals flat, not averaged at edges.
            var expected := (c - a).cross(b - a).normalized()
            for j in 3:
                var normal := normals[indices[i + j]]
                assert_almost_eq(normal.length(), 1.0, 0.0001)
                assert_gt(normal.dot(expected), 0.9999, "Normal must match the triangle's facing.")
