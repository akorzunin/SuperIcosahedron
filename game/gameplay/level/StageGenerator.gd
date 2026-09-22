extends RefCounted
class_name StageGenerator

var route := -1
var previous_route := -1
var phrase_step := 0
var phrase_length := 0
var open_streak: Array[int] = []


func next_figure(
    rng: RandomNumberGenerator,
    has_chain: bool,
    center: int,
    tiers_collected: int,
    turn_budget: float,
) -> FigureData:
    var step_angle := FaceTopology.normal(0).angle_to(
        FaceTopology.normal(FaceTopology.neighbors(0)[0])
    )
    # One-edge survival path; a 25% timing margin is a heuristic, not an input simulation.
    # Use controller replay if steering physics or shell spacing becomes variable.
    assert(turn_budget >= step_angle * 1.25, "Spawn interval is too short for a safe steering step")
    if route < 0:
        route = center
        open_streak.resize(20)
        open_streak.fill(0)
    if phrase_step >= phrase_length:
        phrase_step = 0
        phrase_length = rng.randi_range(3, 5)
    var origin := route
    var blocked: Array[int] = []
    for id in 20:
        if open_streak[id] >= 2:
            blocked.append(id)
    # Move, hold, change direction, then recover; never follow the player's live aim.
    var candidates := FaceTopology.neighbors(origin)
    candidates = candidates.filter(
        func(id):
            return id not in blocked,
    )
    if phrase_step == 1 and origin not in blocked:
        route = origin
    else:
        if candidates.size() > 1:
            candidates.erase(previous_route)
        assert(not candidates.is_empty(), "No reachable neutral route")
        route = candidates[rng.randi_range(0, candidates.size() - 1)]
    # Keep an adjacent face closed now so the next movement always has an exit
    # that cannot be forbidden by the two-pass streak limit.
    var exits := FaceTopology.neighbors(route)
    var exit: int = exits[rng.randi_range(0, exits.size() - 1)]
    if exit not in blocked:
        blocked.append(exit)
    var recovery := phrase_step == phrase_length - 1
    var figure := create_modifier_figure(
        rng,
        has_chain,
        origin,
        tiers_collected,
        route,
        blocked,
        recovery,
    )
    for side in figure.sides:
        open_streak[side.id] = open_streak[side.id] + 1 if side.is_empty() else 0
    previous_route = origin
    phrase_step += 1
    return figure


func recenter(from: int, to: int) -> void:
    var mapping := FaceTopology.face_mapping(from, to)
    route = mapping[route]
    previous_route = mapping[previous_route]
    var remapped: Array[int] = []
    remapped.resize(20)
    for id in 20:
        remapped[mapping[id]] = open_streak[id]
    open_streak = remapped


static func create_figure(stage: int = 0) -> FigureData:
    var figure := FigureData.new()
    figure.stage = stage
    for id in IcosahedronVarints.figure_variants_v2.keys():
        var v: Vector4 = IcosahedronVarints.figure_variants_v2[id]
        var kind := _kind_for(id, stage)
        var score := _score_for(kind, id)
        var modifier := ModifierData.new().init("side_%s" % id, _kind_name(kind), score)
        figure.sides.append(SideData.new().init(id, Vector3(v.x, v.y, v.z), kind, modifier))
    return figure


static func create_tutorial_figure(step: int, rng: RandomNumberGenerator) -> FigureData:
    var candidates := FaceTopology.neighbors(0)
    var opening: int
    if step < 3:
        opening = candidates[step]
    else:
        var distances := FaceTopology.distances(0)
        for id in 20:
            if distances[id] == 2:
                candidates.append(id)
        opening = candidates[rng.randi_range(0, candidates.size() - 1)]
    var figure := create_figure(opening)
    for side in figure.sides:
        if side.is_empty():
            side.modifier.score_value = 100
            side.score_delta = 100
    figure.easy_side = 0
    return figure


static func create_modifier_figure(
    rng: RandomNumberGenerator,
    has_chain: bool,
    center: int = 0,
    tiers_collected: int = 0,
    neutral_route: int = -1,
    blocked: Array[int] = [],
    recovery: bool = false,
) -> FigureData:
    var figure := create_figure(0)
    figure.easy_side = center
    figure.stage = UpgradeCatalog.difficulty_index(tiers_collected)
    var level: Dictionary = UpgradeCatalog.data.difficulty_levels[figure.stage]
    var steps := FaceTopology.distances(center)
    for side in figure.sides:
        side.kind = SideData.Kind.SOLID
        side.modifier = null
        side.score_delta = 0
    var candidates := FaceTopology.neighbors(center)
    candidates.append(center)
    candidates = candidates.filter(
        func(id):
            return id not in blocked,
    )
    if neutral_route < 0:
        neutral_route = candidates[rng.randi_range(0, candidates.size() - 1)]
    figure.sides[neutral_route].kind = SideData.Kind.POSITIVE
    candidates.erase(neutral_route)
    var easy_count := rng.randi_range(int(level.easy_open_faces[0]), int(level.easy_open_faces[1]))
    if recovery:
        easy_count = 3
    for i in mini(easy_count - 1, candidates.size()):
        var id: int = candidates.pop_at(rng.randi_range(0, candidates.size() - 1))
        figure.sides[id].kind = SideData.Kind.POSITIVE
    # Neutral survival stays nearby; rewards require at least two face steps.
    _place_required(figure, steps, "points", has_chain, rng, blocked)
    _place_required(figure, steps, "tier", has_chain, rng, blocked)
    var far_open := 2
    for side in figure.sides:
        if side.id == center or side.id == neutral_route or side.id in blocked or side.modifier:
            continue
        var distance := steps[side.id]
        var chance := (
            float(level.easy_pickup_chance)
            if distance <= 1
            else float(level.open_chance_by_steps[distance])
        )
        # At most half the 16 far faces open: streak exclusions cannot exhaust rewards.
        if distance > 1 and far_open >= 8:
            continue
        if distance <= 1 and not side.is_empty():
            continue
        var pool := UpgradeCatalog.eligible(distance, has_chain, figure.stage)
        if distance <= 1:
            pool = pool.filter(
                func(entry):
                    return entry.kind != "points",
            )
        if not pool.is_empty() and rng.randf() < chance:
            _set_pickup(side, UpgradeCatalog.choose(pool, rng), distance)
            if distance > 1:
                far_open += 1
    return figure


static func _set_pickup(side: SideData, id: String, steps: int) -> void:
    side.modifier = UpgradeCatalog.pickup(id, steps)
    side.kind = SideData.Kind.NEGATIVE if side.modifier.pickup_value < 0 else SideData.Kind.POSITIVE


static func _place_required(
    figure: FigureData,
    steps: Array[int],
    kind: String,
    has_chain: bool,
    rng: RandomNumberGenerator,
    blocked: Array[int] = [],
) -> void:
    for distance in range(2, 6):
        var candidates: Array[int] = []
        var pool := UpgradeCatalog.eligible(distance, has_chain, figure.stage).filter(
            func(entry):
                return entry.kind == kind,
        )
        if pool.is_empty():
            continue
        for side in figure.sides:
            if (
                side.id not in blocked and side.id != figure.easy_side
                and not side.modifier and steps[side.id] == distance
            ) \
                    and (distance > 1 or side.is_empty()):
                candidates.append(side.id)
        if not candidates.is_empty():
            var id := candidates[rng.randi_range(0, candidates.size() - 1)]
            _set_pickup(figure.sides[id], UpgradeCatalog.choose(pool, rng), distance)
            return


static func _kind_for(id: int, stage: int) -> SideData.Kind:
    if id == posmod(stage, 20):
        return SideData.Kind.POSITIVE
    return SideData.Kind.SOLID


static func _score_for(kind: SideData.Kind, _id: int) -> int:
    return 1 if kind == SideData.Kind.POSITIVE else 0


static func _kind_name(kind: SideData.Kind) -> String:
    return SideData.Kind.keys()[kind].to_lower()
