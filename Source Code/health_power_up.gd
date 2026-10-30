
extends Area2D

@export var fall_speed: float = 120.0
@export var heal_amount: int = 20

var collected: bool = false

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	print("Health power-up spawned")

func _process(delta: float) -> void:
	global_position.y += fall_speed * delta

	if global_position.y > get_viewport_rect().size.y + 50.0:
		queue_free()

func _on_body_entered(body: Node2D) -> void:
	print("Health power-up touched: ", body.name)

	if collected:
		return

	if body.is_in_group("player"):
		collected = true
		print("Player collected health power-up")

		if body.has_method("heal"):
			body.heal(heal_amount)
			print("Healed by ", heal_amount)
		else:
			push_warning("Player has no heal() method!")

		queue_free()
