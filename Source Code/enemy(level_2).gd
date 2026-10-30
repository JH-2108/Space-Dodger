extends Area2D

@export var speed: float = 220.0
@export var health: int = 2
@export var enemy_bullet_scene: PackedScene
@export var fire_rate: float = 1.0
@export var explosion_scene: PackedScene
@export var powerup_scene: PackedScene
@export var health_powerup_scene: PackedScene
@export var rapid_fire_powerup_scene: PackedScene
@export var double_shot_powerup_scene: PackedScene

var is_destroyed: bool = false
var fire_timer: float = 1.0
var choice := randi_range(0, 2)
var chosen_scene: PackedScene

func _ready() -> void:
	add_to_group("enemies")
	body_entered.connect(_on_body_entered)

func _process(delta: float) -> void:
	# Move independently down the screen
	global_position.y += speed * delta

	# Shoot periodically
	fire_timer -= delta
	if fire_timer <= 0.0:
		shoot()
		fire_timer = fire_rate

	# Remove when off-screen
	if global_position.y > get_viewport_rect().size.y + 50.0:
		queue_free()

func shoot() -> void:
	if enemy_bullet_scene == null:
		return

	var bullet = enemy_bullet_scene.instantiate()
	get_tree().current_scene.add_child(bullet)
	bullet.global_position = global_position + Vector2(0, 25)

func destroy() -> void: 
	if explosion_scene != null: 
		var explosion = explosion_scene.instantiate()
		get_tree().current_scene.add_child(explosion)
		explosion.global_position = global_position
		get_tree().call_group("audio_manager", "play_explosion")
		
		
	print ("ABOUT TO DROP POWERUP")
	drop_powerup()
	
	get_tree().call_group("score_manager", "add_score", 100)
	queue_free()
	
	if powerup_scene != null and randf() < 0.25:
		var powerup = powerup_scene.instantiate()
		get_tree().current_scene.add_child(powerup)
		powerup.global_position = global_position

func _on_body_entered(body: Node2D) -> void: 
	if body.is_in_group("player"):
		if body.has_method("take_damage"):
			body.take_damage(20)
		queue_free()



func drop_powerup() -> void:
	var roll := randf()

	if roll >= 0.25:
		return

	match choice:
		0:
			chosen_scene = health_powerup_scene
			print("Selected: Health")
		1:
			chosen_scene = rapid_fire_powerup_scene
			print("Selected: Rapid Fire")
		2:
			chosen_scene = double_shot_powerup_scene
			print("Selected: Double Shot")

	if chosen_scene == null:
		push_error("Selected power-up scene is not assigned!")
		return

	var powerup = chosen_scene.instantiate()
	powerup.global_position = global_position
	get_tree().current_scene.add_child.call_deferred(powerup)


func take_damage(amount: int) -> void:
	if is_destroyed:
		return

	health -= amount

	if health <= 0:
		destroy()
