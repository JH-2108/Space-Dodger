extends Area2D  

@export var speed: float = 500.0


func _process(delta: float) -> void:
	global_position.y += speed * delta
	
	if global_position.y > get_viewport_rect().size.y + 50.0: 
		queue_free()
	
	get_tree().call_group("audio_manager", "play_enemy_shoot")
		
func _ready() -> void: 
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void: 
	if body.is_in_group("player"): 
		body.take_damage()
		queue_free()

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("enemies"):
		if area.has_method("destroy"):
			area.destroy() 
		
		queue_free()
