extends Node
class_name GameSession

signal side_resolved(figure: Icosahedron, side: SideData)
signal score_changed(score: int)
signal game_lost()
signal game_won()

var modifier_system := ModifierSystem.new()
var score := 0
var stage := 0
var collected_sides: Array[SideData] = []

func reset() -> void:
    score = 0
    stage = 0
    collected_sides.clear()
    modifier_system.reset()

func register_figure(figure: FigureData) -> void:
    for side in figure.sides:
        if side.modifier:
            side.modifier_entity = modifier_system.register_modifier(side.modifier)

func resolve_side(figure: Icosahedron, side: SideData) -> void:
    if not side or side.collected:
        return
    if side.kind == SideData.Kind.SOLID:
        game_lost.emit()
        return
    side.collected = true
    collected_sides.append(side)
    modifier_system.apply_to(self, side.modifier_entity)
    side_resolved.emit(figure, side)
    score_changed.emit(score)
    if collected_sides.size() >= 20:
        game_won.emit()
