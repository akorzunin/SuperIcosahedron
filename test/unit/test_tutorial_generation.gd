extends GutTest


func test_first_three_figures_cover_every_one_turn_exit() -> void:
    var rng := RandomNumberGenerator.new()
    for center in 20:
        var openings: Array[int] = []
        for step in 3:
            var figure := StageGenerator.create_tutorial_figure(step, rng)
            FaceTopology.recenter(figure, center)
            var empty := figure.sides.filter(
                func(side):
                    return side.is_empty(),
            )
            assert_eq(empty.size(), 1)
            openings.append(empty[0].id)
        openings.sort()
        assert_eq(openings, FaceTopology.neighbors(center))


func test_later_figures_randomize_within_two_turns() -> void:
    var rng := RandomNumberGenerator.new()
    rng.seed = 42
    var seen: Dictionary = { }
    var distances := FaceTopology.distances(0)
    var saw_two_turns := false
    for step in range(3, 103):
        var figure := StageGenerator.create_tutorial_figure(step, rng)
        var empty := figure.sides.filter(
            func(side):
                return side.is_empty(),
        )
        assert_eq(empty.size(), 1)
        var id: int = empty[0].id
        assert_between(distances[id], 1, 2)
        saw_two_turns = saw_two_turns or distances[id] == 2
        seen[id] = true
    assert_gt(seen.size(), 3)
    assert_true(saw_two_turns)
