
extends Node2D

@export var enemy_level_1_scene: PackedScene
@export var enemy_level_2_scene: PackedScene
@export var enemy_level_3_scene: PackedScene
@export var enemy_level_4_scene: PackedScene
@export var enemy_level_5_scene: PackedScene
@export var enemy_level_6_scene: PackedScene
@export var enemy_level_7_scene: PackedScene
@export var enemy_level_8_scene: PackedScene
@export var enemy_level_9_scene: PackedScene
@export var enemy_level_10_scene: PackedScene

@export var spawn_interval: float = 3.0
@export var enemies_per_wave: int = 5
@export var horizontal_margin: float = 50.0

const LEVEL_2_SCORE: int = 1000
const LEVEL_3_SCORE: int = 2000
const LEVEL_4_SCORE: int = 3000
const LEVEL_5_SCORE: int = 4000
const LEVEL_6_SCORE: int = 5000
const LEVEL_7_SCORE: int = 6000
const LEVEL_8_SCORE: int = 7000
const LEVEL_9_SCORE: int = 8000
const LEVEL_10_SCORE: int = 9000

var spawn_timer: float = 0.0
var boss_spawned: bool = false
var boss_defeated: bool = false 
var boss_pause_timer: float = 0.0 
@export var boss_victory_pause: float = 3.0

func _process(delta: float) -> void:
	if boss_defeated:
		boss_pause_timer -= delta 
		
		if boss_pause_timer <= 0.0:
			boss_defeated = false
			spawn_timer = spawn_interval 
		return 
	
	var hud = get_tree().get_first_node_in_group("score_manager")
	var current_score: int = 0

	if hud != null:
		current_score = hud.get_score()

	if current_score >= LEVEL_10_SCORE and not boss_spawned:
		spawn_boss()
	
	spawn_timer -= delta

	if spawn_timer <= 0.0:
		spawn_wave(current_score)
		spawn_timer = spawn_interval

func spawn_boss() -> void:
	if enemy_level_10_scene == null:
		push_error("Boss scene is not assigned to EnemySpawner!")
		return

	boss_spawned = true

	var boss = enemy_level_10_scene.instantiate()
	get_tree().current_scene.add_child(boss)

	var screen_size = get_viewport_rect().size
	boss.global_position = Vector2(screen_size.x / 2.0, -100.0)

	print("Boss spawned!")

func spawn_wave(current_score: int) -> void:
	var available_scenes: Array[PackedScene] = []

	if enemy_level_1_scene != null:
		available_scenes.append(enemy_level_1_scene)
	if current_score >= LEVEL_2_SCORE and enemy_level_2_scene != null:
		available_scenes.append(enemy_level_2_scene)
	if current_score >= LEVEL_3_SCORE and enemy_level_3_scene != null:
		available_scenes.append(enemy_level_3_scene)
	if current_score >= LEVEL_4_SCORE and enemy_level_4_scene != null:
		available_scenes.append(enemy_level_4_scene)
	if current_score >= LEVEL_5_SCORE and enemy_level_5_scene != null:
		available_scenes.append(enemy_level_5_scene)
	if current_score >= LEVEL_6_SCORE and enemy_level_6_scene != null:
		available_scenes.append(enemy_level_6_scene)
	if current_score >= LEVEL_7_SCORE and enemy_level_7_scene != null:
		available_scenes.append(enemy_level_7_scene)
	if current_score >= LEVEL_8_SCORE and enemy_level_8_scene != null:
		available_scenes.append(enemy_level_8_scene)
	if current_score >= LEVEL_9_SCORE and enemy_level_9_scene != null:
		available_scenes.append(enemy_level_9_scene)

	if available_scenes.is_empty():
		push_error("No regular enemy scenes are assigned!")
		return

	var screen_size = get_viewport_rect().size
	var main = get_tree().current_scene

	for i in range(enemies_per_wave):
		var chosen_scene: PackedScene = available_scenes.pick_random()
		var enemy = chosen_scene.instantiate()
		main.add_child(enemy)

		var spawn_x = randf_range(
			horizontal_margin,
			screen_size.x - horizontal_margin
		)
		var spawn_y = randf_range(-300.0, -80.0)

		enemy.global_position = Vector2(spawn_x, spawn_y)

func on_boss_defeated() -> void: 
	if boss_defeated:
		return
	
	boss_defeated = true
	boss_pause_timer = boss_victory_pause
	spawn_timer = boss_victory_pause
	
	get_tree().call_group("score_manager", "hide_boss_health")
	
	#remove all thy small enemies on the field
	for enemy in get_tree().get_nodes_in_group("enemies"):
		if is_instance_valid(enemy) and not enemy.is_in_group("boss"):
			enemy.queue_free()
