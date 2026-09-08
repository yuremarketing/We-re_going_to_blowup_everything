extends Node

const AUDIO_DIR = "res://assets/audio/"

static var instance = null

var _sfx_streams: Dictionary = {}
var _music_stream: AudioStream = null

var _sfx_players: Array[AudioStreamPlayer] = []
var _sfx_player_count: int = 8
var _current_sfx_index: int = 0

var _music_player: AudioStreamPlayer = null
var _music_tween: Tween = null

func _init() -> void:
	instance = self

func _ready() -> void:
	instance = self
	process_mode = Node.PROCESS_MODE_ALWAYS
	_setup_audio_nodes()
	_load_audio_streams()

func _setup_audio_nodes() -> void:
	_music_player = AudioStreamPlayer.new()
	_music_player.bus = "Music"
	add_child(_music_player)
	
	for i in range(_sfx_player_count):
		var player = AudioStreamPlayer.new()
		player.bus = "SFX"
		add_child(player)
		_sfx_players.append(player)

func _load_audio_streams() -> void:
	var sfx_files = {
		"attack": "sfx_attack.wav",
		"hit": "sfx_hit.wav",
		"player_hurt": "sfx_player_hurt.wav",
		"enemy_death": "sfx_enemy_death.wav",
		"boss_spawn": "sfx_boss_spawn.wav",
		"victory": "sfx_victory.wav",
		"game_over": "sfx_game_over.wav",
	}
	for key in sfx_files:
		var path = AUDIO_DIR + sfx_files[key]
		if ResourceLoader.exists(path):
			_sfx_streams[key] = load(path)
	
	var bgm_path = AUDIO_DIR + "bgm_combat.wav"
	if ResourceLoader.exists(bgm_path):
		_music_stream = load(bgm_path)

static func play_sfx(sfx_name: String, pitch_jitter: float = 0.05) -> void:
	if instance:
		instance._play_sfx_internal(sfx_name, pitch_jitter)

func _play_sfx_internal(sfx_name: String, pitch_jitter: float = 0.05) -> void:
	if not _sfx_streams.has(sfx_name):
		return
	var stream = _sfx_streams[sfx_name]
	if not stream or _sfx_players.is_empty():
		return
		
	var player = _sfx_players[_current_sfx_index]
	_current_sfx_index = (_current_sfx_index + 1) % _sfx_player_count
	
	player.stream = stream
	if pitch_jitter > 0.0:
		player.pitch_scale = randf_range(1.0 - pitch_jitter, 1.0 + pitch_jitter)
	else:
		player.pitch_scale = 1.0
	player.play()

static func play_music(fade_in: float = 0.5) -> void:
	if instance:
		instance._play_music_internal(fade_in)

func _play_music_internal(fade_in: float = 0.5) -> void:
	if not _music_stream or not _music_player:
		return
	if _music_player.playing:
		return
	
	_music_player.stream = _music_stream
	if fade_in > 0.0:
		_music_player.volume_db = -40.0
		_music_player.play()
		if _music_tween and _music_tween.is_valid():
			_music_tween.kill()
		_music_tween = create_tween()
		_music_tween.tween_property(_music_player, "volume_db", 0.0, fade_in)
	else:
		_music_player.volume_db = 0.0
		_music_player.play()

static func stop_music(fade_out: float = 0.5) -> void:
	if instance:
		instance._stop_music_internal(fade_out)

func _stop_music_internal(fade_out: float = 0.5) -> void:
	if not _music_player or not _music_player.playing:
		return
	if fade_out > 0.0:
		if _music_tween and _music_tween.is_valid():
			_music_tween.kill()
		_music_tween = create_tween()
		_music_tween.tween_property(_music_player, "volume_db", -40.0, fade_out)
		_music_tween.tween_callback(_music_player.stop)
	else:
		_music_player.stop()
