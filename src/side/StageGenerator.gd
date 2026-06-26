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

static func _kind_for(id: int, stage: int) -> SideData.Kind:
    if id == (stage * 7) % 20:
        return SideData.Kind.SOLID
    if id % 5 == 0:
        return SideData.Kind.NEGATIVE
    return SideData.Kind.POSITIVE

static func _score_for(kind: SideData.Kind, id: int) -> int:
    match kind:
        SideData.Kind.POSITIVE:
            return 1 + id % 3
        SideData.Kind.NEGATIVE:
            return -1
        _:
            return 0

static func _kind_name(kind: SideData.Kind) -> String:
    return SideData.Kind.keys()[kind].to_lower()
