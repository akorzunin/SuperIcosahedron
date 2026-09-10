extends RefCounted
class_name UpgradeCatalog

const PATH := "res://game/gameplay/config/upgrades.json"
static var data: Dictionary = _load_data()

static func _load_data() -> Dictionary:
    var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(PATH))
    assert(parsed is Dictionary, "Invalid upgrade catalog JSON")
    assert(parsed.get("schema_version") == 1, "Unsupported upgrade catalog version")
    assert(parsed.points_by_tier.size() > 0, "Upgrade tiers cannot be empty")
    assert(int(parsed.choices_per_figure) >= 2 and int(parsed.choices_per_figure) <= 3)
    var ids := {}
    var bases := 0
    for entry in parsed.pickups:
        assert(not ids.has(entry.id), "Duplicate upgrade ID")
        ids[entry.id] = true
        assert(entry.kind in ["base", "sign", "tier"], "Unknown pickup kind")
        assert(Color.html_is_valid(entry.color), "Invalid pickup color")
        if entry.kind == "base":
            bases += 1
        elif entry.kind == "sign":
            assert(int(entry.value) in [-1, 1])
        else:
            assert(int(entry.value) > 0)
    assert(bases == 1, "Points is the only supported base effect")
    assert(parsed.pickups.size() > bases, "At least one upgrade is required")
    for points in parsed.points_by_tier:
        assert(points is float and points > 0 and points == floor(points), "Tier points must be positive integers")
    return parsed

static func pickup(id: String) -> ModifierData:
    for entry in data.pickups:
        if entry.id == id:
            var result := ModifierData.new().init(entry.id, entry.title)
            result.pickup_kind = entry.kind
            result.pickup_value = int(entry.value)
            result.pickup_color = Color(entry.color)
            return result
    assert(false, "Unknown upgrade ID: " + id)
    return null

static func base_id() -> String:
    for entry in data.pickups:
        if entry.kind == "base":
            return entry.id
    return ""
