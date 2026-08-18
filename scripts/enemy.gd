extends CharacterBody3D

@export var speed: float = 3.0
@export var hp: int = 1

func _ready() -> void:
	add_to_group("enemies")

func _physics_process(delta: float) -> void:
	# Anda em direção ao player, no sentido +Z (o player nasce em Z menor e avança em -Z)
	velocity.z = speed
	if not is_on_floor():
		velocity.y -= 9.8 * delta
	move_and_slide()

func take_damage(amount: int) -> void:
	hp -= amount
	if hp <= 0:
		queue_free()
