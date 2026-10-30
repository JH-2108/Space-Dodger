
extends CanvasLayer

var score: int = 0
var high_score: int = 0

const SAVE_PATH = "user://space_dodgers_save.cfg"

@onready var high_score_label: Label = $HighScoreLabel
@onready var score_label: Label = $ScoreLabel
@onready var hearts_label: Label = $HeartsLabel
@onready var game_over_label: Label = $GameOverLabel
@onready var health_bar: ProgressBar = $HealthBar


func _ready() -> void:
	add_to_group("score_manager")
	process_mode = Node.PROCESS_MODE_ALWAYS

	load_high_score()
	game_over_label.hide()
	update_scoreboard()
	
	health_bar.min_value = 0 
	health_bar.max_value = 100 
	health_bar.value = 100 
	load_boss_medal()

func add_score(points: int) -> void:
	var old_level = int(score / 1000) + 1
	score += points

	if score > high_score:
		high_score = score
		save_high_score()

	update_scoreboard()
	
	var new_level = int(score / 1000) + 1
	
	if new_level > old_level: 
		for i in range (new_level - old_level): 
			get_tree().call_group("player", "level_up")

func update_scoreboard() -> void:
	score_label.text = "SCORE: " + str(score)
	high_score_label.text = "BEST: " + str(high_score)

func update_health_bar(current_health: int, max_health: int) -> void: 
	health_bar.max_value = max_health
	health_bar.value= current_health 

func show_game_over() -> void:
	game_over_label.text = "GAME OVER\nPress SPACE to restart"
	game_over_label.show()
	get_tree().paused = true

func save_high_score() -> void:
	var save_file = ConfigFile.new()
	save_file.set_value("scores", "high_score", high_score)
	var error = save_file.save(SAVE_PATH)

	if error != OK:
		print("Error saving high score: ", error)

func load_high_score() -> void:
	var save_file = ConfigFile.new()
	var error = save_file.load(SAVE_PATH)

	if error == OK:
		high_score = save_file.get_value("scores", "high_score", 0)
	else:
		high_score = 0

func _input(event: InputEvent) -> void:
	if get_tree().paused and event.is_action_pressed("shoot"):
		get_tree().paused = false
		get_tree().reload_current_scene()
		
func get_score() -> int: 
	return score
	
func update_helper_ship_timer(seconds_remaining: float) -> void: 
	var timer_label = get_node_or_null("HelperShipTimerLabel")
	if timer_label == null:
		#debug messages
		push_warning("HelperShipTimerLabel was not found in HUD!")
		return 
	
	if seconds_remaining <= 0.0:
		timer_label.hide()
	else:
		timer_label.text = "Helper Ship: %ds" % ceili(seconds_remaining)
		timer_label.show() 
	
func hide_helper_ship_timer() -> void: 
	var timer_label = get_node_or_null("HelperShipTimerLabel")
	if timer_label != null: 
		timer_label.hide()
		

func update_double_shot_timer(seconds_remaining: float) -> void:
	var timer_label = get_node_or_null("DoubleShotTimerLabel")
	
	if timer_label == null:
		#worm worm messages 
		push_warning("DoubleShotTimerLabel was not found in HUD")
		return
	
	if seconds_remaining <= 0.0: 
		timer_label.hide()
	else: 
		timer_label.text = "Double Shot: %ds" % ceili(seconds_remaining)
		timer_label.show()
	
func hide_double_shot_timer() -> void: 
	var timer_label = get_node_or_null("DoubleShotTimerLabel")
	
	if timer_label != null:
		timer_label.hide()
		
func update_boss_health(current_health: int, maximum_health: int) -> void:
	$BossHealthBar.max_value = maximum_health 
	$BossHealthBar.value = current_health 
	$BossHealthBar.visible = true 
	
func hide_boss_health() -> void: 
	$BossHealthBar.visible = false

func award_boss_medal() -> void: 
	var config := ConfigFile.new()
	var err := config.load("user://space_dodgers_save.cfg")
	
	if err != OK and err != ERR_FILE_NOT_FOUND:
		#error messages, very very important
		push_warning("Could not load the saved game file!!!")
		
	config.set_value("achievemnts", "boss_medal", true)
	
	var save_err := config.save("user://space_dodgers_save.cfg")
	if save_err != OK:
		#helps me identify if the boss medal does not show in the game after I killed the boss
		push_error("Could not save the boss medal")
		
	$MedalLabel.text = "🎖️"
	$MedalLabel.show()
	

func show_victory() -> void:
	$VictoryLabel.text = "CONGRATULATIONS GNG"
	$NeverEndingLabel.text = "ENDLESS MODEEEEE"
	
	$VictoryLabel.show()
	$NeverEndingLabel.show()
	
	await get_tree().create_timer(3.0).timeout
	
	if is_instance_valid(self):
		$VictoryLabel.hide()
		$NeverEndingLabel.hide()
		
func load_boss_medal() -> void:
	var config := ConfigFile.new()
	var err := config.load("user://space_dodgers_save.cfg")
	
	if err == OK:
		var has_medal: bool = config.get_value(
		"achievements",
		"boss_medal",
		false
		)
		$MedalLabel.visible = has_medal

func show_restart_prompt() -> void:
	$GameOverLabel.show()
	
