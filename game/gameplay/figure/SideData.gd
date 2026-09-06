extends Resource
class_name SideData

enum Kind { POSITIVE, NEGATIVE, SOLID }

@export var id := 0
@export var normal := Vector3.ZERO
@export var kind := Kind.POSITIVE
@export var modifier: ModifierData
@export var modifier_entity := 0
@export var collected := false
@export var score_delta := 0

func init(_id: int, _normal: Vector3, _kind: Kind, _modifier: ModifierData = null) -> SideData:
    id = _id
    normal = _normal.normalized()
    kind = _kind
    modifier = _modifier
    score_delta = _modifier.score_value if _modifier else 0
    return self

func is_empty() -> bool:
    return kind != Kind.SOLID
