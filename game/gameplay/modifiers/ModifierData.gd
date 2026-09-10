extends Resource
class_name ModifierData

@export var id := ""
@export var title := ""
@export var quality := "normal"
@export var duration := "stage"
@export var score_value := 0
# Empty kind retains immediate-score tutorial/debug fixtures.
@export var pickup_kind := ""
@export var pickup_value := 0
@export var pickup_color := Color.WHITE

func init(_id: String, _title: String, _score_value: int = 0, _quality := "normal", _duration := "stage") -> ModifierData:
    id = _id
    title = _title
    score_value = _score_value
    quality = _quality
    duration = _duration
    return self
