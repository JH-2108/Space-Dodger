extends CharacterBody2D

@export var speed: float = 350.0 
@export var bullet_scene: PackedScene
@export var fire_rate: float = 0.15 
@export var max_health: int = 100
@onready var ship_body: Sprite2D = $ship
@onready var death_animation: AnimatedSprite2D = $player_explosion
var health: int = 100 
var invulnerable: bool = false
var rapid_fire_active: bool = false
var rapid_fire_timer: float = 0.0 
var original_fire_rate: float = 0.15
var double_shot_power_up: bool = false 
var double_shot_timer: float = 0.0 
var double_shot_active: bool = false 

var fire_timer: float = 0.0 

func _process(delta: float) -> void:
	if health <= 0:
		return
	fire_timer -= delta
	update_double_shot(delta)
	
	if Input.is_action_pressed("shoot") and fire_timer <= 0.0: 
		shoot() 
		fire_timer = fire_rate 
	
func shoot() -> void: 
	if bullet_scene == null: 
		return
		
	if double_shot_active: 
		spawn_bullet(Vector2(-12.0, -30.0))
		spawn_bullet(Vector2(12.0, -30.0))
	else: 
		spawn_bullet(Vector2(0.0, -30.0))
		
func spawn_bullet(offset: Vector2) -> void:
	var bullet = bullet_scene.instantiate()
	get_tree().current_scene.add_child(bullet)
	bullet.global_position = global_position + offset
	get_tree().call_group("audio_manager", "play_shoot")

@onready var engine_flames: AnimatedSprite2D = $"engine flame"
func _ready() -> void: 
	global_position = Vector2(
		get_viewport_rect().size.x / 2, 
		get_viewport_rect().size.y - 100 
	)
	engine_flames.play("default")
	
	add_to_group("player")
	get_tree().call_group(
		"score_manager",
		"update_health_bar",
		health,
		max_health
	)

func _physics_process(_delta: float) -> void:
	if health <= 0:
		return
	var direction := Input.get_vector(
		"move_left",
		"move_right",
		"move_up", 
		"move_down"
	)
	
	velocity = direction * speed 
	move_and_slide()
	
	var screen_size = get_viewport_rect().size
	var margin = 30.0 
	
	global_position.x = clampf(
		global_position.x, margin, screen_size.x - margin
	)
	global_position.y = clampf( 
		global_position.y, margin, screen_size.y - margin 
	)
	
func take_damage(amount: int = 20) -> void: 
	if invulnerable or health <= 0: 
		return
		
	health = max(0, health - amount)
	
	get_tree().call_group(
		"score_manager",
		"update_health_bar",
		health,
		max_health
	)
	
	if health <= 0: 
		invulnerable = true
		velocity = Vector2.ZERO
		
		ship_body.hide()
		engine_flames.hide()
		death_animation.show()
		death_animation.play("default")
		get_tree().call_group("audio_manager", "play_game_over")
		
		await death_animation.animation_finished 
		
		get_tree().call_group("score_manager", "show_game_over")
		return 
		
	invulnerable = true 
	await get_tree().create_timer(1.0).timeout
	invulnerable = false 

func level_up() -> void: 
	if health <= 0: 
		return 
		
	max_health += 60
	health = min(health + 60, max_health)
	
	get_tree().call_group(
		"score_manager",
		"update_health+bar",
		health,
		max_health
	)

func heal(amount: int) -> void: 
	if health <= 0: 
		return 
	
	health = min(health + amount, max_health)
	
	get_tree().call_group(
		"score_manager",
		"update_health_bar",
		health,
		max_health
	)

func apply_rapid_fire(duration: float) -> void: 
	original_fire_rate = fire_rate
	rapid_fire_timer = maxf(rapid_fire_timer, duration)
	rapid_fire_active = true 
	fire_rate = 0.075
	
func update_rapid_fire(delta: float) -> void: 
	if not rapid_fire_active: 
		return 
	
	rapid_fire_timer -= delta
	
	if rapid_fire_timer <= 0.0: 
		rapid_fire_active = false 
		fire_rate = original_fire_rate
		
func apply_double_shot(duration: float) -> void: 
	double_shot_active = true 
	double_shot_timer = maxf(double_shot_timer, duration)
	get_tree().call_group("score_manager", "update_double_shot_timer", double_shot_timer)
	
func update_double_shot(delta: float) -> void: 
	if not double_shot_active: 
		return 
	
	double_shot_timer -= delta 
	get_tree().call_group("score_manager", "update_double_shot_timer", double_shot_timer)
	
	if double_shot_timer <= 0.0:
		double_shot_active = false
		double_shot_timer = 0.0 
		print("Double Shot Ended")
		get_tree().call_group("score_manager", "hide_double_shot_timer")
