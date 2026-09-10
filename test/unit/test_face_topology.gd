extends GutTest

func test_all_centers_have_expected_step_rings() -> void:
    for center in 20:
        var distances := FaceTopology.distances(center)
        var counts := [0, 0, 0, 0, 0, 0]
        for distance in distances:
            counts[distance] += 1
        assert_eq(counts, [1, 3, 6, 6, 3, 1])
        assert_eq(FaceTopology.neighbors(center).size(), 3)
        assert_eq(distances[center], 0)

func test_recenter_is_bijective_and_preserves_every_distance() -> void:
    for from in 20:
        var original := FaceTopology.distances(from)
        for to in 20:
            var mapping := FaceTopology.face_mapping(from, to)
            var distances := FaceTopology.distances(to)
            var seen := {}
            var preserves_steps := true
            for id in 20:
                seen[mapping[id]] = true
                preserves_steps = preserves_steps and distances[mapping[id]] == original[id]
            assert_eq(seen.size(), 20)
            assert_true(preserves_steps)
            assert_eq(mapping[from], to)

func test_layout_recenter_keeps_pickups_and_collider_resource_identity() -> void:
    var rng := RandomNumberGenerator.new()
    rng.seed = 91
    var figure := StageGenerator.create_modifier_figure(rng, true, 0)
    var identities := figure.sides.duplicate()
    var pickups := []
    var kinds := []
    for side in figure.sides:
        pickups.append(side.modifier)
        kinds.append(side.kind)
        side.modifier_entity = side.id + 1
    var mapping := FaceTopology.face_mapping(0, 15)
    FaceTopology.recenter(figure, 15)
    for id in 20:
        assert_same(figure.sides[id], identities[id])
        assert_eq(figure.sides[mapping[id]].modifier, pickups[id])
        assert_eq(figure.sides[mapping[id]].kind, kinds[id])
        assert_eq(figure.sides[mapping[id]].modifier_entity, id + 1)
    assert_eq(figure.easy_side, 15)
