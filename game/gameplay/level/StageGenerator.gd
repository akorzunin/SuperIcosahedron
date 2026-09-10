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

static func create_modifier_figure(rng: RandomNumberGenerator, has_chain: bool) -> FigureData:
    var figure := create_figure(0)
    for side in figure.sides:
        side.kind = SideData.Kind.SOLID
        side.modifier = null
        side.score_delta = 0
    var available := range(20)
    var pool: Array = UpgradeCatalog.data.pickups.filter(
        func(entry): return entry.kind != "base")
    for choice in int(UpgradeCatalog.data.choices_per_figure):
        var index := rng.randi_range(0, available.size() - 1)
        var side: SideData = figure.sides[available.pop_at(index)]
        # Icosahedron neighbors have normal dot sqrt(5)/3. Keep solid borders:
        # the passage predictor requires the whole window inside one opening.
        available = available.filter(func(other): return side.normal.dot(figure.sides[other].normal) < 0.74)
        var id := UpgradeCatalog.base_id()
        if choice > 0 and has_chain:
            id = pool[rng.randi_range(0, pool.size() - 1)].id
        side.modifier = UpgradeCatalog.pickup(id)
        side.kind = SideData.Kind.NEGATIVE if side.modifier.pickup_value < 0 else SideData.Kind.POSITIVE
    return figure

static func _kind_for(id: int, stage: int) -> SideData.Kind:
    if id == posmod(stage, 20):
        return SideData.Kind.POSITIVE
    return SideData.Kind.SOLID

static func _score_for(kind: SideData.Kind, _id: int) -> int:
    return 1 if kind == SideData.Kind.POSITIVE else 0

static func _kind_name(kind: SideData.Kind) -> String:
    return SideData.Kind.keys()[kind].to_lower()
