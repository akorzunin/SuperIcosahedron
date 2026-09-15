extends RefCounted
class_name RunState

# Run-local state: no scene nodes, UI, input, or application services.
enum Outcome {
    IGNORED,
    PASSED,
    GAME_OVER,
}

var figures_passed := 0
var tiers_collected := 0


static func required_controls() -> int:
    return int(UpgradeCatalog.data.controls_required_for_level_1)


static func required_charges() -> int:
    return int(UpgradeCatalog.data.chains_required_for_level_2)


var charges_completed := 0
var tutorial_commits: Dictionary[int, bool] = { }
var controls_completed := 0
var difficulty := 0
var score := 0
var ended := false
var modifier_system := ModifierSystem.new()
var _resolved_figures: Dictionary[int, bool] = { }


func reset() -> void:
    figures_passed = 0
    tiers_collected = 0
    charges_completed = 0
    controls_completed = 0
    tutorial_commits.clear()
    difficulty = 0
    score = 0
    ended = false
    _resolved_figures.clear()
    modifier_system.reset()


func register_figure(figure: FigureData) -> void:
    for side in figure.sides:
        if side.modifier:
            side.modifier_entity = modifier_system.register_modifier(side.modifier)


func unregister_figure(figure_id: int, figure: FigureData) -> void:
    _resolved_figures.erase(figure_id)
    for side in figure.sides:
        modifier_system.world.components.erase(side.modifier_entity)
        side.modifier_entity = 0


func resolve_side(figure_id: int, side: SideData) -> Outcome:
    if ended or not side or _resolved_figures.has(figure_id) or side.collected:
        return Outcome.IGNORED
    _resolved_figures[figure_id] = true
    if not side.is_empty():
        ended = true
        modifier_system.discard_chain()
        modifier_system.discard_forge()
        return Outcome.GAME_OVER
    side.collected = true
    modifier_system.apply_to(self, side.modifier_entity)
    # First lesson checks align/confirm/pass only; add distinct movement targets for broader control mastery.
    if tutorial_commits.has(figure_id):
        controls_completed = mini(controls_completed + 1, required_controls())
        tutorial_commits.erase(figure_id)
    figures_passed += 1
    return Outcome.PASSED
