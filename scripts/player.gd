extends CharacterBody3D

@export var max_hp: int = 5
var hp: int
var is_dead: bool = false

const SPEED = 8.0

func _ready() -> void:
	add_to_group("player")
	hp = max_hp
	_update_hp_label()

func _physics_process(delta: float) -> void:
	if is_dead:
		return
		
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

	# Ataque placeholder
	if Input.is_action_just_pressed("ui_accept"):
		attack()

func attack() -> void:
	print("POW! Ataque placeholder executado contra a horda.")
	# Feedback visual simples usando Tween (cresce e volta ao normal)
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector3(1.2, 1.2, 1.2), 0.1)
	tween.tween_property(self, "scale", Vector3(1.0, 1.0, 1.0), 0.1)

	for enemy in get_tree().get_nodes_in_group("enemies"):
		if abs(enemy.position.z - position.z) < 2.0:
			enemy.take_damage(1)

func take_damage(amount: int) -> void:
	if is_dead:
		return
	hp -= amount
	print("Player tomou dano! HP: ", hp, "/", max_hp)
	_update_hp_label()
	if hp <= 0:
		game_over()

func _update_hp_label() -> void:
	var label = get_tree().get_first_node_in_group("hud_hp")
	if label:
		label.text = "HP: %d/%d" % [hp, max_hp]

func game_over() -> void:
	is_dead = true
	print("GAME OVER")
	get_tree().paused = true
	var screen = get_tree().get_first_node_in_group("end_screen")
	if screen:
		screen.show_result("GAME OVER")
