
extends Area2D

@export var speed: float = 900.0
@export var damage: int = 20

func _ready() -> void:
	area_entered.connect(_on_area_entered)

func _process(delta: float) -> void:
	global_position.y -= speed * delta

	if global_position.y < -50.0:
		queue_free()

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("enemies"):
		if area.has_method("take_damage"):
			area.take_damage(damage)
		else:
			area.queue_free()

		queue_free()
