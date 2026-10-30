
extends Area2D

@export var max_health: int = 15000
@export var stop_y: float = 140.0
@export var entry_speed: float = 150.0

@export var fire_interval: float = 2.5
@export var warning_duration: float = 0.8

@export var projectile_scene: PackedScene
@export var telegraph_scene: PackedScene
@export var explosion_scene: PackedScene

var health: int
var is_destroyed: bool = false
var has_stopped: bool = false
var attack_timer: float = 1.5
var attack_in_progress: bool = false

@onready var engine_fire: AnimatedSprite2D = get_node_or_null("EngineFire")

func _ready() -> void:
	health = max_health
	add_to_group("enemies")
	add_to_group("boss")

	if engine_fire != null:
		engine_fire.play()

	get_tree().call_group(
		"score_manager",
		"update_boss_health",
		health,
		max_health
	)

func _process(delta: float) -> void:
	if is_destroyed:
		return

	if not has_stopped:
		global_position.y += entry_speed * delta

		if global_position.y >= stop_y:
			global_position.y = stop_y
			has_stopped = true

		return

	if attack_in_progress:
		return

	attack_timer -= delta

	if attack_timer <= 0.0:
		attack_timer = fire_interval
		attack_in_progress = true
		fire_at_player()

func fire_at_player() -> void:
	var player := get_tree().get_first_node_in_group("player") as Node2D

	if player == null:
		attack_in_progress = false
		return

	# Record the target position when the warning begins.
	var target_position: Vector2 = player.global_position

	if telegraph_scene != null:
		var warning := telegraph_scene.instantiate() as Node2D
		get_tree().current_scene.add_child(warning)
		warning.global_position = target_position

	await get_tree().create_timer(warning_duration).timeout

	if not is_inside_tree() or is_destroyed:
		return

	if projectile_scene != null:
		var projectile := projectile_scene.instantiate() as Area2D
		get_tree().current_scene.add_child(projectile)
		projectile.global_position = global_position

		if projectile.has_method("launch"):
			projectile.launch(target_position)

	attack_in_progress = false

func take_damage(amount: int) -> void:
	if is_destroyed:
		return

	health = maxi(health - amount, 0)

	get_tree().call_group(
		"score_manager",
		"update_boss_health",
		health,
		max_health
	)

	if health <= 0:
		destroy()

func destroy() -> void:
	if is_destroyed:
		return

	is_destroyed = true
	attack_in_progress = false
	remove_from_group("enemies")
	
	get_tree().call_group("audio_manager", "play_boss_explosion")

	# Spawn the explosion independently so it survives the boss.
	if explosion_scene != null:
		var explosion := explosion_scene.instantiate()
		get_tree().current_scene.add_child(explosion)

		if explosion is Node2D:
			explosion.global_position = global_position

		var animation := explosion.get_node_or_null(
            "AnimatedSprite2D"
		) as AnimatedSprite2D

		if animation != null:
			animation.animation_finished.connect(
				func(): explosion.queue_free(),
				CONNECT_ONE_SHOT
			)
			animation.play()
		else:
			push_warning(
                "Boss explosion needs a child named AnimatedSprite2D."
			)

	get_tree().call_group("score_manager", "add_score", 1000)
	get_tree().call_group("score_manager", "hide_boss_health")
	get_tree().call_group("score_manager", "award_boss_medal")
	get_tree().call_group("score_manager", "show_victory")
	get_tree().call_group("enemy_spawner", "on_boss_defeated")

	queue_free()
