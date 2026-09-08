extends CharacterBody3D

@export var max_hp: int = 5
@export var attack_cooldown: float = 0.22
@export var invulnerability_duration: float = 0.75

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

	var hit_any: bool = false
	for enemy in get_tree().get_nodes_in_group("enemies"):
		if abs(enemy.position.z - position.z) < 2.0:
			enemy.take_damage(1)
			hit_any = true
			
	if hit_any:
		if audio:
			audio.play_sfx("hit", 0.05)
		apply_shake(0.08, 0.12)

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
		screen.show_result("GAME OVER")
