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
var forge_values: Array[int] = []
var last_pickup_kind := ""
var tier_streak_count := 0


func pending_points() -> int:
    return sign_value * accumulated_points * (2 if all_in else 1)


func collect(session: Object, pickup: ModifierData) -> void:
    if not pickup:
        return
    var kind := pickup.pickup_kind
    if all_in and kind != "points":
        discard_chain()
        pickup_collected.emit("All-in lost · Chain discarded", Color.WHITE)
    if kind == "forge":
        _collect_forge(pickup)
        return
    if not all_in and _store_ingredient(session, pickup):
        return

    var message := ""
    match kind:
        "points":
            var delta := _collect_points(session, pickup.pickup_value)
            message = "Points charged" if pending else "%+d scored" % delta
        "sign":
            if pending:
                sign_value = pickup.pickup_value
                if sign_value < 0:
                    points_multiplier = 2
                message = "Sign → positive · Bonus kept" if sign_value > 0 else "Sign → negative · Next POINTS ×2 · Convert before banking"
        "tier":
            message = _collect_tier(session, pickup.pickup_value)
        "echo":
            echo_pending = true
            message = "ECHO READY · Next POINTS reward or TIER strength ×2"
        "all_in":
            if pending:
                all_in = true
                message = "ALL-IN · POINTS NEXT OR LOSE · Next POINTS banks ×2"
        "inversion":
            if pending:
                sign_value = -sign_value
                accumulated_points *= 2
                message = "Inverted → positive · Pot ×2" if sign_value > 0 else "Inverted → negative · Pot ×2 · Convert before banking"
    if kind.is_empty():
        return
    _remember_pickup(kind)
    if message.is_empty():
        message = "No effect · Collect TIER first"
    if pending:
        message += " · %+d pending" % pending_points()
    pickup_collected.emit(message, pickup.pickup_color)


func _collect_forge(pickup: ModifierData) -> void:
    if forge_slots > 0:
        _remember_pickup("forge")
        pickup_collected.emit("Forge already active · Recipe kept", pickup.pickup_color)
        return
    var upgraded := last_pickup_kind == "tier"
    forge_slots = clampi(pickup.pickup_value + 1 + (1 if upgraded else 0), 2, 3)
    forge_count = 0
    forge_kind = ""
    # With no recipe ingredient, forge_value doubles as the visible Forge level.
    forge_value = forge_slots if upgraded else 0
    forge_values.clear()
    _remember_pickup("forge")
    var message := (
        "Forge upgraded by TIER · %d slots · Matching POINTS or TIER wait" % forge_slots
        if upgraded
        else "Forge armed · Matching POINTS or TIER wait instead of activating"
    )
    pickup_collected.emit(message, pickup.pickup_color)


func _store_ingredient(session: Object, pickup: ModifierData) -> bool:
    if forge_slots == 0 or pickup.pickup_kind not in ["points", "tier"]:
        return false
    if not forge_kind.is_empty() and forge_kind != pickup.pickup_kind:
        return false
    forge_kind = pickup.pickup_kind
    if forge_count == 0:
        forge_value = pickup.pickup_value
    forge_values.append(pickup.pickup_value)
    forge_count = forge_values.size()
    if forge_count < forge_slots:
        _remember_pickup(pickup.pickup_kind)
        pickup_collected.emit("Stored, not activated · " + forge_summary(), pickup.pickup_color)
        return true

    var recipe_kind := forge_kind
    var values := forge_values.duplicate()
    discard_forge()
    session.crafts_completed = mini(session.crafts_completed + 1, RunState.required_crafts())
    if recipe_kind == "points":
        _complete_points_recipe(session, values, pickup.pickup_color)
    else:
        _complete_tier_recipe(session, values, pickup.pickup_color)
    return true


func _collect_points(session: Object, pickup_value: int) -> int:
    var repeats := 2 if echo_pending else 1
    if echo_pending:
        echo_pending = false
    tier = clampi(
        pickup_value + (1 if tier_remaining > 0 else 0),
        1,
        UpgradeCatalog.data.points_by_tier.size(),
    )
    accumulated_points += int(UpgradeCatalog.data.points_by_tier[tier - 1]) * repeats * points_multiplier
    tier_remaining = 0 if all_in else maxi(0, tier_remaining - 1)
    pending = tier_remaining > 0
    if pending:
        return 0
    return _bank_chain(session)


func _complete_points_recipe(session: Object, values: Array, color: Color) -> void:
    var total := 0
    for value in values:
        # Recipe strength is intentionally not a points multiplier. Each stored
        # POINTS pays its ordinary value, and the completed recipe cashes out
        # the chain so no extra POINTS pickup is required.
        total += _collect_points(session, int(value))
    if pending:
        total += _bank_chain(session)
    _remember_pickup("points")
    pickup_collected.emit("Forged POINTS · %+d scored" % total, color)


func _collect_tier(session: Object, pickup_value: int) -> String:
    var repeats := 2 if echo_pending else 1
    if echo_pending:
        echo_pending = false
    var units := pickup_value * repeats
    var consecutive := last_pickup_kind == "tier"
    # Consecutive TIER pickups grow the streak payout, not the number of
    # POINTS required to cash out the ordinary chain.
    tier_remaining = units
    pending = true
    chain_has_tier = true
    # Tier units remain build statistics, not level progress.
    session.tiers_collected += units
    if consecutive:
        var reward := _award_tier_streak(session)
        return "Tier streak · %+d scored · %d POINTS remaining" % [reward, tier_remaining]
    return "Tier armed · %d POINTS remaining" % tier_remaining


func _complete_tier_recipe(session: Object, values: Array, color: Color) -> void:
    var repeats := 2 if echo_pending else 1
    if echo_pending:
        echo_pending = false
    var units := 0
    for value in values:
        units += int(value)
    units *= repeats
    # The recipe activates the first TIER's ordinary strength; the other
    # ingredients are represented by the streak reward and collection stats.
    tier_remaining = int(values[0]) * repeats
    pending = true
    chain_has_tier = true
    session.tiers_collected += units
    var reward := _award_tier_streak(session)
    _remember_pickup("tier")
    pickup_collected.emit(
        "Forged TIER · %+d scored · %d POINTS remaining" % [reward, tier_remaining],
        color,
    )


func _award_tier_streak(session: Object) -> int:
    var reward := int(UpgradeCatalog.data.streak_points) + tier_streak_count * int(
        UpgradeCatalog.data.streak_increment
    )
    session.score += reward
    tier_streak_count += 1
    last_activation = "Tier streak: %+d points" % reward
    return reward


func _remember_pickup(kind: String) -> void:
    last_pickup_kind = kind
    if kind != "tier":
        tier_streak_count = 0


func discard_forge() -> void:
    forge_slots = 0
    forge_count = 0
    forge_kind = ""
    forge_value = 0
    forge_values.clear()


func forge_summary() -> String:
    if forge_slots == 0:
        return ""
    var slots: Array[String] = []
    for i in forge_slots:
        slots.append("[%s]" % (forge_kind.to_upper() if i < forge_count else " _ "))
    var recipe := (
        "Level %d · Next POINTS/TIER starts recipe" % forge_slots
        if forge_kind.is_empty()
        else "%s %d · Collect %d matching"
        % [forge_kind.to_upper(), forge_value, forge_slots - forge_count]
    )
    return "FORGE · " + " ".join(slots) + " · " + recipe + " · Others activate normally"


func _bank_chain(session: Object) -> int:
    var delta := pending_points()
    session.score += delta
    if chain_has_tier:
        session.charges_completed = mini(session.charges_completed + 1, RunState.required_charges())
    last_activation = "Activated: %+d points" % delta
    discard_chain()
    return delta


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
    last_pickup_kind = ""
    tier_streak_count = 0


func summary() -> String:
    var forging := "\n" + forge_summary() if forge_slots > 0 else ""
    return chain_summary() + forging


func chain_summary() -> String:
    var title := UpgradeCatalog.pickup(UpgradeCatalog.base_id()).title
    var streak := (
        " | TIER STREAK · next +%d"
        % (
            int(UpgradeCatalog.data.streak_points)
            + tier_streak_count * int(UpgradeCatalog.data.streak_increment)
        )
        if tier_streak_count > 0
        else ""
    )
    if not pending:
        return "%s score immediately · TIER upgrades next POINTS%s%s" % [
            title,
            " | ECHO READY · Next POINTS/TIER ×2" if echo_pending else "",
            streak,
        ]
    return "Pending: %s T%d (%+d) | %d POINTS to bank%s%s%s" % [
        title,
        tier,
        pending_points(),
        1 if all_in else tier_remaining,
        " | ECHO READY · Next POINTS/TIER ×2" if echo_pending else "",
        " | ALL-IN: POINTS NEXT OR LOSE · Banks ×2" if all_in else "",
        streak,
    ] \
            + (" | POINTS ×%d" % points_multiplier if points_multiplier > 1 else "") \
            + (" | NEGATIVE POT · CONVERT BEFORE BANKING" if sign_value < 0 else "")


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
