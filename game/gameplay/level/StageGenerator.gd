extends RefCounted
class_name StageGenerator

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

static func create_modifier_figure(rng: RandomNumberGenerator, has_chain: bool,
        center: int = 0, tiers_collected: int = 0) -> FigureData:
    var figure := create_figure(0)
    figure.easy_side = center
    figure.stage = UpgradeCatalog.difficulty_index(tiers_collected)
    var level: Dictionary = UpgradeCatalog.data.difficulty_levels[figure.stage]
    var steps := FaceTopology.distances(center)
    for side in figure.sides:
        side.kind = SideData.Kind.SOLID
        side.modifier = null
        side.score_delta = 0
    # Sample the whole easy zone: staying centered must not guarantee passage.
    var candidates := FaceTopology.neighbors(center)
    candidates.append(center)
    var easy_count := rng.randi_range(int(level.easy_open_faces[0]), int(level.easy_open_faces[1]))
    for i in easy_count:
        var id: int = candidates.pop_at(rng.randi_range(0, candidates.size() - 1))
        figure.sides[id].kind = SideData.Kind.POSITIVE
    # Guarantee a base (nearest eligible opening) and a route to voluntary tier progression.
    _place_required(figure, steps, "base", has_chain, rng)
    if has_chain:
        _place_required(figure, steps, "tier", has_chain, rng)
    for side in figure.sides:
        if side.id == center or side.modifier:
            continue
        var distance := steps[side.id]
        var chance := float(level.easy_pickup_chance) if distance <= 1 else float(level.open_chance_by_steps[distance])
        if distance <= 1 and not side.is_empty():
            continue
        var pool := UpgradeCatalog.eligible(distance, has_chain)
        if not pool.is_empty() and rng.randf() < chance:
            _set_pickup(side, UpgradeCatalog.choose(pool, rng), distance)
    return figure

static func _set_pickup(side: SideData, id: String, steps: int) -> void:
    side.modifier = UpgradeCatalog.pickup(id, steps)
    side.kind = SideData.Kind.NEGATIVE if side.modifier.pickup_value < 0 else SideData.Kind.POSITIVE

static func _place_required(figure: FigureData, steps: Array[int], kind: String,
        has_chain: bool, rng: RandomNumberGenerator) -> void:
    for distance in 6:
        var candidates: Array[int] = []
        var pool := UpgradeCatalog.eligible(distance, has_chain).filter(func(entry): return entry.kind == kind)
        if pool.is_empty():
            continue
        for side in figure.sides:
            if side.id != figure.easy_side and not side.modifier and steps[side.id] == distance \
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
