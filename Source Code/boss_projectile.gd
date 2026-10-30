extends Area2D

@export var speed: float = 300.0 
@export var damage: int = 30 

var direction: Vector2 = Vector2.DOWN
var has_hit: bool = false 

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func launch(target_position: Vector2) -> void:
	direction = (target_position - global_position). normalized()
	rotation = direction.angle() + PI / 2.0 

func _process(delta: float) -> void: 
	global_position += direction * speed * delta 
	
	var screen_size := get_viewport_rect().size 
	if (
		global_position.x < -100.0 
		or global_position.x > screen_size.x + 100.0 
		or global_position.y < -100.0 
		or global_position.y > screen_size.y + 100.0 
	):
		queue_free() 
	
func _on_body_entered(body: Node2D) -> void: 
	if has_hit or not body.is_in_group("player"): 
		return 
		
	has_hit = true 
	
	if body.has_method("take_damage"):
		body.take_damage(damage)
	
	queue_free()
