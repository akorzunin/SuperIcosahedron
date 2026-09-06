extends Resource
class_name ModifierData

@export var id := ""
@export var title := ""
@export var quality := "normal"
@export var duration := "stage"
@export var score_value := 0

func init(_id: String, _title: String, _score_value: int = 0, _quality := "normal", _duration := "stage") -> ModifierData:
    id = _id
    title = _title
    score_value = _score_value
    quality = _quality
    duration = _duration
    return self
