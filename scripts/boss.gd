extends CharacterBody3D

@export var speed: float = 1.5
@export var hp: int = 15
@export var contact_damage: int = 2

func _ready() -> void:
	add_to_group("enemies")
	add_to_group("boss")

func _physics_process(delta: float) -> void:
	velocity.z = speed
	if not is_on_floor():
		velocity.y -= 9.8 * delta
	move_and_slide()

	var player = get_tree().get_first_node_in_group("player")
	if player and abs(player.position.z - position.z) < 2.0:
		player.take_damage(contact_damage)
		# Chefão NÃO morre no contato (diferente do inimigo comum) — precisa de vários ataques.

func take_damage(amount: int) -> void:
	hp -= amount
	if hp <= 0:
		print("Chefão derrotado! Run concluída.")
		queue_free()
		get_tree().paused = true
		var screen = get_tree().get_first_node_in_group("end_screen")
		if screen:
			screen.show_result("VITÓRIA!")
