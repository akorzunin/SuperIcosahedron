extends RefCounted
class_name ModifierSystem

signal pickup_collected(message: String, color: Color)

const C_MODIFIER := &"modifier"
const C_SCORE := &"score_delta"

var world := EcsWorld.new()
var pending := false
var tier := 1
var sign_value := 1
var last_activation := ""
var echo_pending := false
var all_in := false

func pending_points() -> int:
    return sign_value * int(UpgradeCatalog.data.points_by_tier[tier - 1]) * (2 if all_in else 1)

func collect(session: Object, pickup: ModifierData) -> void:
    if all_in and pickup.pickup_kind != "points":
        discard_chain()
    var message := ""
    var previous_tier := tier
    var repeats := 2 if echo_pending and pickup.pickup_kind in ["sign", "tier"] else 1
    if pickup.pickup_kind in ["sign", "tier"]:
        echo_pending = false
    match pickup.pickup_kind:
        "points":
            if pending:
                var delta := pending_points()
                session.score += delta
                last_activation = "Activated: %+d points" % delta
                message = "%+d scored" % delta
            discard_chain()
            pending = true
            tier = clampi(pickup.pickup_value, 1, UpgradeCatalog.data.points_by_tier.size())
            sign_value = 1
            if message.is_empty():
                message = "Chain started"
        "sign":
            if pending:
                sign_value = pickup.pickup_value
                message = "Sign → positive" if sign_value > 0 else "Sign → negative"
        "tier":
            if pending:
                tier = mini(tier + pickup.pickup_value * repeats, UpgradeCatalog.data.points_by_tier.size())
                # Count acquired tier units even at chain cap; chain commits never reset difficulty.
                session.tiers_collected += pickup.pickup_value * repeats
                message = "Tier +%d" % (tier - previous_tier) if tier > previous_tier else "Tier already at maximum"
        "echo":
            if pending:
                echo_pending = true
                message = "Echo armed"
        "all_in":
            if pending:
                all_in = true
                message = "All-in · Next shell requires POINTS"
        "inversion":
            if pending:
                sign_value = -sign_value
                if sign_value > 0:
                    tier = mini(tier + 1, UpgradeCatalog.data.points_by_tier.size())
                    session.tiers_collected += 1
                message = "Inverted → positive · Tier +1" if sign_value > 0 else "Inverted → negative"
    if pickup.pickup_kind.is_empty():
        return
    if not pending:
        message = "No effect · Collect %s first" % UpgradeCatalog.pickup(UpgradeCatalog.base_id()).title
    else:
        message += " · %+d pending" % pending_points()
    pickup_collected.emit(message, pickup.pickup_color)

func discard_chain() -> void:
    pending = false
    echo_pending = false
    all_in = false
    tier = 1
    sign_value = 1

func summary() -> String:
    var title := UpgradeCatalog.pickup(UpgradeCatalog.base_id()).title
    if not pending:
        return "Pick %s to start a chain" % title
    return "Pending: %s T%d (%+d) | Next %s activates%s%s" % [
        title, tier, pending_points(), title,
        " | Echo" if echo_pending else "", " | ALL-IN: POINTS next shell!" if all_in else ""]

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
        if all_in:
            discard_chain()
            pickup_collected.emit("All-in lost · Chain discarded", Color.WHITE)
        return
    var pickup: ModifierData = world.get_component(modifier_entity, C_MODIFIER)
    if pickup and not pickup.pickup_kind.is_empty():
        collect(session, pickup)
        return
    if all_in:
        discard_chain()
    var score_delta = world.get_component(modifier_entity, C_SCORE)
    var current_score = session.get("score")
    if score_delta != null and current_score != null:
        session.set("score", int(current_score) + int(score_delta))
