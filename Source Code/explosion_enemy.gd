
extends Node2D

@onready var animation: AnimatedSprite2D = get_node_or_null("explosion_enemy") as AnimatedSprite2D

func _ready() -> void:
	if animation == null:
		print("ERROR: Cannot find AnimatedSprite2D!")
		print("Children of explosion root:")
		for child in get_children():
			print(child.name, " — ", child.get_class())
		return

	animation.animation_finished.connect(_on_animation_finished)
	animation.play("default")

func _on_animation_finished() -> void:
	queue_free()
