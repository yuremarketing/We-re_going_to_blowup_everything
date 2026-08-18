extends Node3D

@export var enemy_scene: PackedScene
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

func _on_spawn_tick() -> void:
	if _waiting_for_next_wave:
		_waiting_for_next_wave = false
		_timer.wait_time = spawn_interval
		_timer.start()
		return

	if _spawned_this_wave >= enemies_per_wave:
		_current_wave += 1
		if _current_wave >= total_waves:
			if not _boss_spawned:
				var boss = boss_scene.instantiate()
				boss.position = Vector3(0, 1.0, spawn_z_offset)
				get_tree().current_scene.add_child(boss)
				_boss_spawned = true
				print("Todas as ondas concluídas! Chefão spawnado!")
			_timer.stop()
			return
		
		# Inicia a espera entre ondas
		_spawned_this_wave = 0
		_waiting_for_next_wave = true
		_timer.wait_time = time_between_waves
		_timer.start()
		return

	var enemy = enemy_scene.instantiate()
	var x = randf_range(-lane_width / 2.0, lane_width / 2.0)
	enemy.position = Vector3(x, 1.0, spawn_z_offset)
	get_tree().current_scene.add_child(enemy)
	_spawned_this_wave += 1
