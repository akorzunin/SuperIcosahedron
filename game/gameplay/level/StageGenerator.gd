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
    if id == posmod(stage, 20):
        return SideData.Kind.POSITIVE
    return SideData.Kind.SOLID

static func _score_for(kind: SideData.Kind, _id: int) -> int:
    return 1 if kind == SideData.Kind.POSITIVE else 0

static func _kind_name(kind: SideData.Kind) -> String:
    return SideData.Kind.keys()[kind].to_lower()
