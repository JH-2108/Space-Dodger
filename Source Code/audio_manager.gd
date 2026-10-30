extends Node 

@export var background_music: AudioStream
@export var regular_explosion: AudioStream
@export var boss_explosion: AudioStream
@export var shooting_sound: AudioStream
@export var victory_sound: AudioStream
@export var loss_sound: AudioStream

var music_player: AudioStreamPlayer

func _ready() -> void:
	add_to_group("audio_manager")
	
	music_player = AudioStreamPlayer.new()
	music_player.name = "BackgroundMusic"
	music_player.bus = "Master"
	music_player.volume_db = 10
	add_child(music_player)
	
	if background_music != null:
		music_player.stream = background_music
		
		if music_player.stream is AudioStreamOggVorbis:
			music_player.stream.loop = true
			
		music_player.play() 
	else:
		push_warning("Assign the audio in the AudioManager")
		
func play_shoot() -> void: 
	play_one_shot(shooting_sound, 0.0)

func play_enemy_shoot() -> void:
	play_one_shot(shooting_sound, -50.0)
	
func play_explosion() -> void:
	play_one_shot(regular_explosion, 10.0)
	
func play_boss_explosion() -> void:
	play_one_shot(boss_explosion, 60.0)
	
func play_one_shot(sound: AudioStream, volume_db: float = 0.0) -> void:
	if sound == null:
		#these warnings rly help me identify the issues icl
		push_warning("the sound hasn't been assigned")
		return
		
	var player := AudioStreamPlayer.new()
	player.stream = sound 
	player.volume_db = volume_db 
	player.bus = "Master"
	add_child(player)
	
	player.finished.connect(player.queue_free)
	player.play()

func play_victory() -> void:
	play_one_shot(victory_sound, 5.0)
	
func play_loss() -> void:
	play_one_shot(loss_sound, 30.0)

func play_game_over() -> void:
	if music_player != null:
		music_player.stop()
		
	if loss_sound == null:
		push_warning("Assign your loss sound in the AudioManager inspecting place")
		return
		
	var player := AudioStreamPlayer.new()
	player.name = "GameOverSound"
	player.stream = loss_sound
	player.bus = "Master"
	add_child(player)
	
	player.process_mode = Node.PROCESS_MODE_ALWAYS

	player.play()
	await player.finished 
	player.queue_free()
	
	
	get_tree().call_group("score_manager", "show_restart_progress")
	
