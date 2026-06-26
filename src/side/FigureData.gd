extends Resource
class_name FigureData

@export var stage := 0
@export var score := 0
@export var sides: Array[SideData] = []
var collected_sides: Array[SideData] = []

func collect(side: SideData) -> void:
    if side.collected:
        return
    side.collected = true
    collected_sides.append(side)
    score += side.score_delta
