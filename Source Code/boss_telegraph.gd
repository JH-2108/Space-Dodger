
extends Node2D

@export var warning_duration: float = 0.8

func _ready() -> void:
	var square := get_node_or_null("WarningSquare") as Polygon2D

	if square == null:
		push_error("Missing Polygon2D child named WarningSquare!")
		return

	square.polygon = PackedVector2Array([
		Vector2(-45, -45),
		Vector2(45, -45),
		Vector2(45, 45),
		Vector2(-45, 45)
	])

	square.color = Color(1.0, 0.0, 0.0, 0.45)

	var timer := get_tree().create_timer(warning_duration)
	timer.timeout.connect(_on_warning_finished)

func _on_warning_finished() -> void:
	queue_free()
