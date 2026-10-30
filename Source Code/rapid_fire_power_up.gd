extends Area2D

@export var fall_speed: float = 120.0
@export var duration: float = 8.0

var collected: bool = false

func _ready() -> void: 
	body_entered.connect(_on_body_entered)

func _process(delta: float) -> void: 
	global_position.y += fall_speed * delta 
	
	if global_position.y > get_viewport_rect().size.y + 50.0: 
		queue_free() 
	
func _on_body_entered(body: Node2D) -> void: 
	if collected: 
		return 
	
	if body.is_in_group("player"): 
		collected = true
		body.apply_rapid_fire(duration)
		queue_free()
