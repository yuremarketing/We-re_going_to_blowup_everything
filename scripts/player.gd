extends CharacterBody3D

@export var max_hp: int = 5
@export var attack_cooldown: float = 0.22
@export var invulnerability_duration: float = 0.75
@export var attack_range: float = 2.4

static var _slash_mesh: BoxMesh = null

var hp: int
var is_dead: bool = false
var _attack_timer: float = 0.0
var _invulnerable_timer: float = 0.0
var _is_invulnerable: bool = false

const SPEED = 8.0

@onready var camera: Camera3D = $Camera3D
var _shake_tween: Tween

func _get_audio():
	return get_node_or_null("/root/AudioManager")

func _ready() -> void:
	add_to_group("player")
	hp = max_hp
	_update_hp_label()
	var audio = _get_audio()
	if audio:
		audio.play_music(0.5)

func _physics_process(delta: float) -> void:
	if is_dead:
		return
		
	if _attack_timer > 0.0:
		_attack_timer -= delta
	if _invulnerable_timer > 0.0:
		_invulnerable_timer -= delta
		if _invulnerable_timer <= 0.0:
			_is_invulnerable = false
			var mesh = get_node_or_null("MeshInstance3D")
			if mesh:
				mesh.visible = true

	# Movimento linear na viela (eixo Z)
	# ui_up move para frente (-Z), ui_down move para trás (+Z)
	var input_dir = Input.get_axis("ui_up", "ui_down")
	
	if input_dir != 0:
		velocity.z = input_dir * SPEED
	else:
		velocity.z = move_toward(velocity.z, 0, SPEED)

	# Gravidade básica
	if not is_on_floor():
		velocity.y -= 9.8 * delta

	move_and_slide()

	# Ataque
	if Input.is_action_just_pressed("ui_accept") and _attack_timer <= 0.0:
		attack()

func attack() -> void:
	_attack_timer = attack_cooldown
	print("POW! Ataque executado contra a horda.")
	var audio = _get_audio()
	if audio:
		audio.play_sfx("attack", 0.08)
	# Feedback visual simples usando Tween (cresce e volta ao normal)
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector3(1.2, 1.2, 1.2), 0.1)
	tween.tween_property(self, "scale", Vector3(1.0, 1.0, 1.0), 0.1)
	_spawn_slash_vfx()

	var hit_any: bool = false
	for enemy in get_tree().get_nodes_in_group("enemies"):
		if abs(enemy.position.z - position.z) < attack_range:
			enemy.take_damage(1)
			hit_any = true

	if hit_any:
		if audio:
			audio.play_sfx("hit", 0.05)
		apply_shake(0.08, 0.12)

func _spawn_slash_vfx() -> void:
	if not is_inside_tree():
		return
	if not _slash_mesh:
		_slash_mesh = BoxMesh.new()
		_slash_mesh.size = Vector3(0.08, 0.08, 0.08)
		var mat = StandardMaterial3D.new()
		mat.albedo_color = Color(1.0, 1.0, 1.0)
		mat.emission_enabled = true
		mat.emission = Color(0.8, 0.9, 1.0)
		_slash_mesh.material = mat

	var particles = CPUParticles3D.new()
	particles.top_level = true
	particles.process_mode = Node.PROCESS_MODE_ALWAYS
	particles.emitting = false
	particles.one_shot = true
	particles.explosiveness = 1.0
	particles.amount = 7
	particles.lifetime = 0.15
	particles.direction = Vector3(0, 0, -1)
	particles.spread = 35.0
	particles.initial_velocity_min = 3.0
	particles.initial_velocity_max = 5.0
	particles.gravity = Vector3.ZERO
	particles.mesh = _slash_mesh

	var parent_node = get_parent()
	if parent_node:
		parent_node.add_child(particles)
	elif get_tree() and get_tree().root:
		get_tree().root.add_child(particles)

	if particles.is_inside_tree():
		particles.global_position = global_position + Vector3(0, 1.0, -0.8)
		particles.emitting = true
		particles.finished.connect(particles.queue_free)
		var tree = get_tree()
		if tree:
			var p_ref = weakref(particles)
			tree.create_timer(particles.lifetime + 0.2, true).timeout.connect(func():
				var p = p_ref.get_ref()
				if p and is_instance_valid(p):
					p.queue_free()
			)
	else:
		particles.queue_free()

func heal(amount: int) -> void:
	if is_dead or amount <= 0:
		return
	hp = mini(hp + amount, max_hp)
	_update_hp_label()
	_play_heal_blink()

const _PLAYER_BASE_COLOR = Color(0.85, 0.85, 0.85)

func _play_heal_blink() -> void:
	var mesh = get_node_or_null("MeshInstance3D")
	if not mesh:
		return
	# O mesh do player não tem material próprio (usa o default do engine) -
	# cria um override na primeira vez pra poder animar a cor de feedback.
	var mat = mesh.get_surface_override_material(0) as StandardMaterial3D
	if not mat:
		mat = StandardMaterial3D.new()
		mat.albedo_color = _PLAYER_BASE_COLOR
		mesh.set_surface_override_material(0, mat)
	var heal_tween = create_tween()
	heal_tween.tween_property(mat, "albedo_color", Color(0.4, 1.0, 0.5), 0.08)
	heal_tween.tween_property(mat, "albedo_color", _PLAYER_BASE_COLOR, 0.12)

func take_damage(amount: int) -> void:
	if is_dead or _is_invulnerable:
		return
	hp -= amount
	_is_invulnerable = true
	_invulnerable_timer = invulnerability_duration
	_play_hurt_blink()
	print("Player tomou dano! HP: ", hp, "/", max_hp)
	var audio = _get_audio()
	if audio:
		audio.play_sfx("player_hurt", 0.05)
	apply_shake(0.18, 0.20)
	_update_hp_label()
	if hp <= 0:
		game_over()

func _play_hurt_blink() -> void:
	var mesh = get_node_or_null("MeshInstance3D")
	if not mesh:
		return
	var blink_tween = create_tween()
	for i in range(4):
		blink_tween.tween_callback(func(): if mesh: mesh.visible = false).set_delay(0.08)
		blink_tween.tween_callback(func(): if mesh: mesh.visible = true).set_delay(0.08)

func apply_shake(intensity: float = 0.1, duration: float = 0.15) -> void:
	if not is_inside_tree():
		return
	if not camera:
		camera = get_node_or_null("Camera3D")
	if not camera:
		return
	if _shake_tween and _shake_tween.is_valid():
		_shake_tween.kill()
		camera.h_offset = 0.0
		camera.v_offset = 0.0
		
	_shake_tween = create_tween()
	var step = duration / 4.0
	_shake_tween.tween_property(camera, "h_offset", intensity, step)
	_shake_tween.parallel().tween_property(camera, "v_offset", -intensity * 0.7, step)
	_shake_tween.tween_property(camera, "h_offset", -intensity * 0.7, step)
	_shake_tween.parallel().tween_property(camera, "v_offset", intensity * 0.5, step)
	_shake_tween.tween_property(camera, "h_offset", intensity * 0.3, step)
	_shake_tween.parallel().tween_property(camera, "v_offset", -intensity * 0.2, step)
	_shake_tween.tween_property(camera, "h_offset", 0.0, step)
	_shake_tween.parallel().tween_property(camera, "v_offset", 0.0, step)
	_shake_tween.tween_callback(func():
		if camera:
			camera.h_offset = 0.0
			camera.v_offset = 0.0
	)

func _update_hp_label() -> void:
	if not is_inside_tree():
		return
	var label = get_tree().get_first_node_in_group("hud_hp")
	if label:
		label.text = "HP: %d/%d" % [hp, max_hp]

func game_over() -> void:
	is_dead = true
	print("GAME OVER")
	if camera:
		camera.h_offset = 0.0
		camera.v_offset = 0.0
	get_tree().paused = true
	var screen = get_tree().get_first_node_in_group("end_screen")
	if screen:
		var state = get_node_or_null("/root/GameState")
		var total_kills = state.kills if state else 0
		screen.show_result("GAME OVER", total_kills)
