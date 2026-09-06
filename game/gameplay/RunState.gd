extends RefCounted
class_name RunState

# Run-local state: no scene nodes, UI, input, or application services.
enum Outcome { IGNORED, PASSED, GAME_OVER }

var figures_passed := 0
var score := 0
var ended := false
var collected_sides: Array[SideData] = []
var modifier_system := ModifierSystem.new()
var _resolved_figures: Dictionary[int, bool] = {}

func reset() -> void:
    figures_passed = 0
    score = 0
    ended = false
    collected_sides.clear()
    _resolved_figures.clear()
    modifier_system.reset()

func register_figure(figure: FigureData) -> void:
    for side in figure.sides:
        if side.modifier:
            side.modifier_entity = modifier_system.register_modifier(side.modifier)

func resolve_side(figure_id: int, side: SideData) -> Outcome:
    if ended or not side or _resolved_figures.has(figure_id) or side.collected:
        return Outcome.IGNORED
    _resolved_figures[figure_id] = true
    if not side.is_empty():
        ended = true
        return Outcome.GAME_OVER
    side.collected = true
    collected_sides.append(side)
    modifier_system.apply_to(self, side.modifier_entity)
    figures_passed += 1
    return Outcome.PASSED
