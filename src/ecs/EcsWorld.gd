extends RefCounted
class_name EcsWorld

var _next_id := 1
var components := {}

func create_entity() -> int:
    var id := _next_id
    _next_id += 1
    components[id] = {}
    return id

func add_component(entity: int, name: StringName, data: Variant) -> void:
    if not components.has(entity):
        components[entity] = {}
    components[entity][name] = data

func get_component(entity: int, name: StringName) -> Variant:
    return components.get(entity, {}).get(name)

func has_component(entity: int, name: StringName) -> bool:
    return components.get(entity, {}).has(name)

func query(required: Array[StringName]) -> Array[int]:
    var out: Array[int] = []
    for entity in components.keys():
        var bag: Dictionary = components[entity]
        if required.all(func(name): return bag.has(name)):
            out.append(entity)
    return out

func clear() -> void:
    _next_id = 1
    components.clear()
