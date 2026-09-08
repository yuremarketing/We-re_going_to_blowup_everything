extends Node3D

@export var enemy_scenes: Array[PackedScene]
@export var boss_scene: PackedScene
@export var enemies_per_wave: int = 5
@export var spawn_interval: float = 1.5
@export var spawn_z_offset: float = -30.0
@export var lane_width: float = 8.0  # metade pra cada lado do centro

@export var time_between_waves: float = 5.0
@export var total_waves: int = 5

var _spawned_this_wave: int = 0
var _current_wave: int = 0
var _timer: Timer
var _waiting_for_next_wave: bool = false
var _boss_spawned: bool = false

func _ready() -> void:
	_timer = Timer.new()
	_timer.wait_time = spawn_interval
	_timer.timeout.connect(_on_spawn_tick)
	add_child(_timer)
	_timer.start()
	_update_wave_label()

func _get_enemies_for_wave(wave: int) -> int:
	match wave:
		0: return 5
		1: return 7
		2: return 9
		3: return 12
		_: return 15

func _get_spawn_interval_for_wave(wave: int) -> float:
	match wave:
		0: return 1.8
		1: return 1.5
		2: return 1.3
		3: return 1.1
		_: return 0.9

func _choose_enemy_for_wave(wave: int) -> PackedScene:
	if enemy_scenes.is_empty():
		return null
	if enemy_scenes.size() == 1 or wave == 0:
		return enemy_scenes[0]
	elif wave == 1:
		return enemy_scenes[1] if randf() < 0.25 and enemy_scenes.size() > 1 else enemy_scenes[0]
	elif wave == 2:
		var r = randf()
		if r < 0.15 and enemy_scenes.size() > 2:
			return enemy_scenes[2]
		elif r < 0.40 and enemy_scenes.size() > 1:
			return enemy_scenes[1]
		return enemy_scenes[0]
	else:
		var r = randf()
		if r < 0.20 and enemy_scenes.size() > 2:
			return enemy_scenes[2]
		elif r < 0.50 and enemy_scenes.size() > 1:
			return enemy_scenes[1]
		return enemy_scenes[0]

func _on_spawn_tick() -> void:
	if _waiting_for_next_wave:
		_waiting_for_next_wave = false
		_timer.wait_time = _get_spawn_interval_for_wave(_current_wave)
		_timer.start()
		return

	var target_enemies = _get_enemies_for_wave(_current_wave)
	if _spawned_this_wave >= target_enemies:
		_current_wave += 1
		_update_wave_label()
		if _current_wave >= total_waves:
			if not _boss_spawned:
				var boss = boss_scene.instantiate()
				boss.position = Vector3(0, 1.0, spawn_z_offset)
				get_tree().current_scene.add_child(boss)
				_boss_spawned = true
				var audio = get_node_or_null("/root/AudioManager")
				if audio:
					audio.play_sfx("boss_spawn")
				print("Todas as ondas concluídas! Chefão spawnado!")
			_timer.stop()
			return
		
		# Inicia a espera entre ondas
		_spawned_this_wave = 0
		_waiting_for_next_wave = true
		_timer.wait_time = time_between_waves
		_timer.start()
		return

	var enemy_scene = _choose_enemy_for_wave(_current_wave)
	if enemy_scene:
		var enemy = enemy_scene.instantiate()
		var x = randf_range(-lane_width / 2.0, lane_width / 2.0)
		enemy.position = Vector3(x, 1.0, spawn_z_offset)
		get_tree().current_scene.add_child(enemy)
	_spawned_this_wave += 1

func _update_wave_label() -> void:
	var label = get_tree().get_first_node_in_group("hud_wave")
	if label:
		label.text = "Onda: %d/%d" % [min(_current_wave + 1, total_waves), total_waves]
