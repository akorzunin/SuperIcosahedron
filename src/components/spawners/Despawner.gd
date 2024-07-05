extends Area3D
class_name Despawner

@onready var despawner_shape: CollisionShape3D = $DespawnerShape
@onready var settings: Settings = %Settings

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    despawner_shape.position = Vector3(settings.gs.DESPAWNER_MODE / 1000., 0, 0)
    area_shape_entered.connect(_on_shape_entered)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    pass

func _on_shape_entered(area_rid: RID, area: Area3D, area_shape_index: int, local_shape_index: int):
    area.get_parent().queue_free()
