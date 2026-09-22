extends GutTest


func test_sequences_require_steering_and_keep_a_reachable_neutral_route() -> void:
    for difficulty in [0, 1, 3, 10]:
        var generator := StageGenerator.new()
        var rng := RandomNumberGenerator.new()
        rng.seed = 812 + difficulty
        var streaks: Array[int] = []
        streaks.resize(20)
        streaks.fill(0)
        var last_route := 0
        var holds := 0
        var moves := 0
        var recoveries := 0
        for i in 200:
            var figure := generator.next_figure(rng, true, 0, difficulty, 2.0)
            var distance := FaceTopology.distances(last_route)
            assert_lte(distance[generator.route], 1)
            assert_true(figure.sides[generator.route].is_empty())
            assert_null(figure.sides[generator.route].modifier)
            holds += int(generator.route == last_route)
            moves += int(generator.route != last_route)
            var easy_open := 0
            var points := 0
            var tiers := 0
            for side in figure.sides:
                streaks[side.id] = streaks[side.id] + 1 if side.is_empty() else 0
                assert_lte(streaks[side.id], 2, "No face permits three passive passes")
                if side.is_empty() and distance[side.id] <= 1:
                    easy_open += 1
                if side.modifier:
                    if side.modifier.pickup_kind == "points":
                        points += 1
                        assert_gte(distance[side.id], 2)
                    if side.modifier.pickup_kind == "tier":
                        tiers += 1
            assert_gte(points, 1)
            assert_gte(tiers, 1)
            recoveries += int(easy_open > 1)
            last_route = generator.route
        assert_gt(holds, 0)
        assert_gt(moves, holds)
        assert_gt(recoveries, 0)


func test_sequences_are_seeded_and_ignore_live_aim_after_start() -> void:
    var a := StageGenerator.new()
    var b := StageGenerator.new()
    var ra := RandomNumberGenerator.new()
    var rb := RandomNumberGenerator.new()
    ra.seed = 47
    rb.seed = 47
    for i in 100:
        var first := a.next_figure(ra, true, 0, 0, 2.0)
        var second := b.next_figure(rb, true, i % 20, 0, 2.0)
        assert_eq(a.route, b.route)
        for id in 20:
            assert_eq(first.sides[id].kind, second.sides[id].kind)
            if first.sides[id].modifier:
                assert_eq(first.sides[id].modifier.id, second.sides[id].modifier.id)


func test_initial_recenter_remaps_sequence_history() -> void:
    var generator := StageGenerator.new()
    var rng := RandomNumberGenerator.new()
    rng.seed = 17
    var figure := generator.next_figure(rng, true, 0, 0, 2.0)
    generator.recenter(0, 13)
    FaceTopology.recenter(figure, 13)
    assert_true(figure.sides[generator.route].is_empty())
    for side in figure.sides:
        assert_eq(generator.open_streak[side.id], int(side.is_empty()))
