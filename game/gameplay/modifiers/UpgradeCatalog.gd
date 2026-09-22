extends RefCounted
class_name UpgradeCatalog

const PATH := "res://game/gameplay/config/upgrades.json"
static var data: Dictionary = _load_data()


static func _load_data() -> Dictionary:
    var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(PATH))
    assert(parsed is Dictionary, "Invalid upgrade catalog JSON")
    assert(parsed.get("schema_version") == 2, "Unsupported upgrade catalog version")
    assert(
        parsed.controls_required_for_level_1 > 0
        and parsed.controls_required_for_level_1 == floor(parsed.controls_required_for_level_1),
        "Level 1 requires a positive integer control demonstration count",
    )
    assert(
        parsed.chains_required_for_level_2 > 0
        and parsed.chains_required_for_level_2 == floor(parsed.chains_required_for_level_2),
        "Level 2 requires a positive integer chain count",
    )
    assert(
        parsed.crafts_required_for_level_3 > 0
        and parsed.crafts_required_for_level_3 == floor(parsed.crafts_required_for_level_3),
        "Level 3 requires a positive integer craft count",
    )
    assert(parsed.points_by_tier.size() > 0, "Upgrade tiers cannot be empty")
    for field in ["streak_points", "streak_increment"]:
        assert(
            parsed.get(field) > 0 and parsed.get(field) == floor(parsed.get(field)),
            "%s must be a positive integer" % field,
        )
    var previous := -1
    for level in parsed.difficulty_levels:
        assert(level.tiers_required == floor(level.tiers_required))
        assert(int(level.tiers_required) > previous, "Tier thresholds must increase")
        previous = int(level.tiers_required)
        assert(level.easy_open_faces.size() == 2)
        assert(int(level.easy_open_faces[0]) >= 1 and int(level.easy_open_faces[1]) <= 3)
        assert(level.easy_open_faces[0] <= level.easy_open_faces[1])
        assert(
            level.easy_open_faces[0] == floor(level.easy_open_faces[0])
            and level.easy_open_faces[1] == floor(level.easy_open_faces[1])
        )
        assert(level.easy_pickup_chance >= 0 and level.easy_pickup_chance <= 1)
        assert(level.open_chance_by_steps.size() == 6)
        for chance in level.open_chance_by_steps:
            assert(chance >= 0 and chance <= 1)
    assert(
        not parsed.difficulty_levels.is_empty() and parsed.difficulty_levels[0].tiers_required == 0
    )
    var ids := { }
    var bases := 0
    var tiers := 0
    for entry in parsed.pickups:
        assert(entry.get("enabled", true) is bool, "Pickup enabled must be a boolean")
        assert(
            entry.get("enabled", true) or entry.kind not in ["points", "tier", "forge"],
            "Progression pickups must remain enabled",
        )
        assert(not ids.has(entry.id), "Duplicate upgrade ID")
        ids[entry.id] = true
        assert(
            entry.kind in ["points", "sign", "tier", "echo", "all_in", "inversion", "forge"],
            "Unknown pickup kind",
        )
        assert(Color.html_is_valid(entry.color), "Invalid pickup color")
        assert(
            entry.min_steps == floor(entry.min_steps) and entry.max_steps == floor(entry.max_steps)
        )
        assert(entry.min_steps >= 0 and entry.max_steps <= 5 and entry.min_steps <= entry.max_steps)
        assert(entry.weight > 0 and entry.value_by_steps.size() == 6)
        for value in [entry.value] + entry.value_by_steps:
            assert(value == floor(value), "Pickup values must be integers")
            if entry.kind == "sign":
                assert(int(value) in [-1, 1])
            else:
                assert(value > 0)
                if entry.kind == "points":
                    assert(value <= parsed.points_by_tier.size())
                elif entry.kind == "forge":
                    assert(int(value) in [1, 2])
        if entry.kind == "points":
            assert(entry.max_steps >= 1, "Center is neutral; base needs a non-center placement")
            bases += 1
        elif entry.kind == "tier":
            assert(entry.max_steps >= 2, "Tier must fit outside the reserved easy routes")
            tiers += 1
    assert(bases == 1 and tiers > 0, "A points base and a tier pickup are required")
    var base: Dictionary = parsed.pickups.filter(
        func(entry):
            return entry.kind == "points",
    )[0]
    assert(
        base.min_steps < 5 or parsed.pickups.any(
            func(entry):
                return entry.kind == "tier" and entry.min_steps < 5,
        ),
        "Base and all tiers cannot compete for the single opposite face",
    )
    for points in parsed.points_by_tier:
        assert(points > 0 and points == floor(points), "Tier points must be positive integers")
    return parsed


static func pickup(id: String, steps: int = -1) -> ModifierData:
    for entry in data.pickups:
        if entry.id == id:
            var result := ModifierData.new().init(entry.id, entry.title)
            result.pickup_kind = entry.kind
            result.pickup_value = int(entry.value if steps < 0 else entry.value_by_steps[steps])
            result.pickup_color = Color(entry.color)
            if entry.kind == "forge":
                result.title += " · %d slots" % (result.pickup_value + 1)
            if steps >= 0:
                if entry.kind == "points":
                    result.title += " T%d" % result.pickup_value
                elif entry.kind == "tier":
                    result.title += " +%d" % result.pickup_value
                result.title += "\n%d step%s" % [steps, "" if steps == 1 else "s"]
            return result
    assert(false, "Unknown upgrade ID: " + id)
    return null


static func base_id() -> String:
    for entry in data.pickups:
        if entry.kind == "points":
            return entry.id
    return ""


static func difficulty_index(tiers_collected: int) -> int:
    var result := 0
    for i in data.difficulty_levels.size():
        if tiers_collected >= int(data.difficulty_levels[i].tiers_required):
            result = i
    return result


static func enabled_pickups() -> Array:
    return data.pickups.filter(
        func(entry):
            return entry.get("enabled", true),
    )


static func eligible(steps: int, has_chain: bool, difficulty: int = 0) -> Array:
    return enabled_pickups().filter(
        func(entry):
            return (
                steps >= int(entry.min_steps) \
                        and steps <= int(entry.max_steps)
                and (has_chain or entry.kind in ["points", "tier", "forge"])
            ) \
                    and (entry.kind != "forge" or difficulty >= 1),
    )


static func choose(pool: Array, rng: RandomNumberGenerator) -> String:
    var total := 0.0
    for entry in pool:
        total += float(entry.weight)
    var roll := rng.randf() * total
    for entry in pool:
        roll -= float(entry.weight)
        if roll <= 0:
            return entry.id
    return pool.back().id
