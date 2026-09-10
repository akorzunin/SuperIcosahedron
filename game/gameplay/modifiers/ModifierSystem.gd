extends RefCounted
class_name ModifierSystem

const C_MODIFIER := &"modifier"
const C_SCORE := &"score_delta"

var world := EcsWorld.new()
var pending := false
var tier := 1
var sign_value := 1
var last_activation := ""

func collect(session: Object, pickup: ModifierData) -> void:
    match pickup.pickup_kind:
        "base":
            if pending:
                var delta := sign_value * int(UpgradeCatalog.data.points_by_tier[tier - 1])
                session.score += delta
                last_activation = "Activated: %+d points" % delta
            pending = true
            tier = 1
            sign_value = 1
        "sign":
            if pending:
                sign_value = pickup.pickup_value
        "tier":
            if pending:
                tier = mini(tier + pickup.pickup_value, UpgradeCatalog.data.points_by_tier.size())

func discard_chain() -> void:
    pending = false
    tier = 1
    sign_value = 1

func summary() -> String:
    var title := UpgradeCatalog.pickup(UpgradeCatalog.base_id()).title
    if not pending:
        return "Pick %s to start a chain" % title
    return "Pending: %s T%d (%+d) | Next %s activates" % [
        title, tier, sign_value * int(UpgradeCatalog.data.points_by_tier[tier - 1]), title]

func reset() -> void:
    world.clear()
    discard_chain()
    last_activation = ""

func register_modifier(modifier: ModifierData) -> int:
    var entity := world.create_entity()
    world.add_component(entity, C_MODIFIER, modifier)
    world.add_component(entity, C_SCORE, modifier.score_value)
    return entity

func apply_to(session: Object, modifier_entity: int) -> void:
    if modifier_entity <= 0:
        return
    var pickup: ModifierData = world.get_component(modifier_entity, C_MODIFIER)
    if pickup and not pickup.pickup_kind.is_empty():
        collect(session, pickup)
        return
    var score_delta = world.get_component(modifier_entity, C_SCORE)
    var current_score = session.get("score")
    if score_delta != null and current_score != null:
        session.set("score", int(current_score) + int(score_delta))
