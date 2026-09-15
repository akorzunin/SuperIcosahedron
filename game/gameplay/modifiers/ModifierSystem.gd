extends RefCounted
class_name ModifierSystem

signal pickup_collected(message: String, color: Color)

const C_MODIFIER := &"modifier"
const C_SCORE := &"score_delta"

var world := EcsWorld.new()
var pending := false
var tier_remaining := 0
var accumulated_points := 0
var tier := 1
var sign_value := 1
var last_activation := ""
var echo_pending := false
var all_in := false
var chain_has_tier := false
var points_multiplier := 1
var forge_slots := 0
var forge_count := 0
var forge_kind := ""
var forge_value := 0


func pending_points() -> int:
    return sign_value * accumulated_points * (2 if all_in else 1)


func collect(session: Object, pickup: ModifierData) -> void:
    if all_in and pickup.pickup_kind != "points":
        discard_chain()
    if pickup.pickup_kind == "forge":
        if forge_slots == 0:
            forge_slots = clampi(pickup.pickup_value + 1, 2, 3)
            pickup_collected.emit(
                "Forge armed · Matching POINTS or TIER wait instead of activating",
                pickup.pickup_color,
            )
        else:
            pickup_collected.emit("Forge already active · Recipe kept", pickup.pickup_color)
        return
    var crafted_multiplier := 1
    if forge_slots > 0 and pickup.pickup_kind in ["points", "tier"] \
            and (forge_kind.is_empty() or forge_kind == pickup.pickup_kind):
        forge_kind = pickup.pickup_kind
        # Same-kind recipes use the first ingredient's strength; mixed-strength blending can come later.
        if forge_count == 0:
            forge_value = pickup.pickup_value
        forge_count += 1
        if forge_count < forge_slots:
            pickup_collected.emit("Stored, not activated · " + forge_summary(), pickup.pickup_color)
            return
        crafted_multiplier = 1 << forge_slots
        pickup = pickup.duplicate() as ModifierData
        pickup.pickup_value = forge_value
        if forge_kind == "tier":
            pickup.pickup_value *= crafted_multiplier
        discard_forge()
    var message := ""
    var repeats := 2 if echo_pending and pickup.pickup_kind in ["sign", "tier"] else 1
    if pickup.pickup_kind in ["sign", "tier"]:
        echo_pending = false
    match pickup.pickup_kind:
        "points":
            tier = clampi(
                pickup.pickup_value + (1 if tier_remaining > 0 else 0),
                1,
                UpgradeCatalog.data.points_by_tier.size(),
            )
            accumulated_points += int(UpgradeCatalog.data.points_by_tier[tier - 1]) * crafted_multiplier * points_multiplier
            tier_remaining = maxi(0, tier_remaining - 1)
            pending = tier_remaining > 0
            message = "Points charged"
            if not pending:
                var delta := pending_points()
                session.score += delta
                if chain_has_tier:
                    session.charges_completed = mini(
                        session.charges_completed + 1,
                        RunState.required_charges(),
                    )
                last_activation = "Activated: %+d points" % delta
                message = "%+d scored" % delta
                discard_chain()
        "sign":
            if pending:
                sign_value = pickup.pickup_value
                if sign_value < 0:
                    points_multiplier = 2
                message = "Sign → positive · Bonus kept" if sign_value > 0 else "Sign → negative · Next POINTS ×2 · Convert before banking"
        "tier":
            tier_remaining = pickup.pickup_value * repeats
            pending = true
            chain_has_tier = true
            # Tier units remain build statistics, not level progress.
            session.tiers_collected += tier_remaining
            message = "Tier armed · %d POINTS remaining" % tier_remaining
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
    if message.is_empty():
        message = "No effect · Collect TIER first"
    if pending:
        message += " · %+d pending" % pending_points()
    if crafted_multiplier > 1:
        message = "Forged %s ×%d · " % [pickup.pickup_kind.to_upper(), crafted_multiplier] + message
    pickup_collected.emit(message, pickup.pickup_color)


func discard_forge() -> void:
    forge_slots = 0
    forge_count = 0
    forge_kind = ""
    forge_value = 0


func forge_summary() -> String:
    if forge_slots == 0:
        return ""
    var slots: Array[String] = []
    for i in forge_slots:
        slots.append("[%s]" % forge_kind.to_upper() if i < forge_count else "[ _ ]")
    var recipe := (
        "Next POINTS/TIER starts recipe"
        if forge_kind.is_empty()
        else "%s %d ×%d · Collect %d matching"
        % [forge_kind.to_upper(), forge_value, 1 << forge_slots, forge_slots - forge_count]
    )
    return "FORGE · " + " ".join(slots) + " · " + recipe + " · Others activate normally"


func discard_chain() -> void:
    pending = false
    tier_remaining = 0
    accumulated_points = 0
    chain_has_tier = false
    echo_pending = false
    all_in = false
    tier = 1
    sign_value = 1
    points_multiplier = 1


func summary() -> String:
    var forging := "\n" + forge_summary() if forge_slots > 0 else ""
    return chain_summary() + forging


func chain_summary() -> String:
    var title := UpgradeCatalog.pickup(UpgradeCatalog.base_id()).title
    if not pending:
        return "%s score immediately · TIER upgrades next POINTS" % title
    return "Pending: %s T%d (%+d) | %d POINTS to bank%s%s" % [
        title,
        tier,
        pending_points(),
        tier_remaining,
        " | Echo: next SIGN/TIER activation" if echo_pending else "",
        " | ALL-IN: POINTS next shell!" if all_in else "",
    ] \
            + (" | POINTS ×%d" % points_multiplier if points_multiplier > 1 else "")


func reset() -> void:
    world.clear()
    discard_chain()
    discard_forge()
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
