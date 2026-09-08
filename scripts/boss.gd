extends CharacterBody3D

@export var speed: float = 1.5
@export var hp: int = 15
@export var contact_damage: int = 2

var _base_albedo: Color = Color(0.5, 0, 0.5, 1)
var _flash_tween: Tween

func _ready() -> void:
	add_to_group("enemies")
	add_to_group("boss")
	_setup_material()

func _setup_material() -> void:
	var mesh_inst = get_node_or_null("MeshInstance3D")
	if not mesh_inst:
		return
	var mat = mesh_inst.get_surface_override_material(0)
	if mat is StandardMaterial3D:
		var dup = mat.duplicate() as StandardMaterial3D
		mesh_inst.set_surface_override_material(0, dup)
		_base_albedo = dup.albedo_color
	elif mesh_inst.material_override is StandardMaterial3D:
		var dup = mesh_inst.material_override.duplicate() as StandardMaterial3D
		mesh_inst.material_override = dup
		_base_albedo = dup.albedo_color
	elif mesh_inst.mesh and mesh_inst.mesh.material is StandardMaterial3D:
		var dup = mesh_inst.mesh.material.duplicate() as StandardMaterial3D
		mesh_inst.set_surface_override_material(0, dup)
		_base_albedo = dup.albedo_color

func _physics_process(delta: float) -> void:
	if not is_inside_tree():
		return
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
		spawn_death_particles()
		queue_free()
		get_tree().paused = true
		var screen = get_tree().get_first_node_in_group("end_screen")
		if screen:
			screen.show_result("VITÓRIA!")
	else:
		play_hit_flash()

func play_hit_flash() -> void:
	if not is_inside_tree():
		return
	var mesh_inst = get_node_or_null("MeshInstance3D")
	if not mesh_inst:
		return
	var mat = mesh_inst.get_surface_override_material(0) as StandardMaterial3D
	if not mat:
		mat = mesh_inst.material_override as StandardMaterial3D
	if not mat:
		return
	if _flash_tween and _flash_tween.is_valid():
		_flash_tween.kill()
	mat.emission_enabled = true
	mat.emission = Color.WHITE
	mat.albedo_color = Color(1.5, 1.5, 1.5, 1.0)
	_flash_tween = create_tween()
	_flash_tween.tween_interval(0.08)
	_flash_tween.tween_property(mat, "albedo_color", _base_albedo, 0.05)
	_flash_tween.parallel().tween_property(mat, "emission", Color.BLACK, 0.05)
	_flash_tween.tween_callback(func():
		if mat:
			mat.emission_enabled = false
			mat.albedo_color = _base_albedo
	)

func spawn_death_particles() -> void:
	var particles = CPUParticles3D.new()
	particles.top_level = true
	particles.process_mode = Node.PROCESS_MODE_ALWAYS
	particles.emitting = false
	particles.one_shot = true
	particles.explosiveness = 1.0
	particles.amount = 25
	particles.lifetime = 0.5
	particles.direction = Vector3(0, 1, 0)
	particles.spread = 180.0
	particles.initial_velocity_min = 3.0
	particles.initial_velocity_max = 7.0
	particles.gravity = Vector3(0, -9.8, 0)
	
	var box = BoxMesh.new()
	box.size = Vector3(0.2, 0.2, 0.2)
	var p_mat = StandardMaterial3D.new()
	p_mat.albedo_color = _base_albedo
	p_mat.emission_enabled = true
	p_mat.emission = _base_albedo
	box.material = p_mat
	particles.mesh = box
	
	var tree = get_tree()
	var spawn_pos = global_position if is_inside_tree() else position
	var parent_node = get_parent()
	if parent_node:
		parent_node.add_child(particles)
	elif tree and tree.root:
		tree.root.add_child(particles)
	
	if particles.is_inside_tree():
		particles.global_position = spawn_pos
		particles.emitting = true
		particles.finished.connect(particles.queue_free)
		if tree:
			tree.create_timer(particles.lifetime + 0.3, true).timeout.connect(func():
				if is_instance_valid(particles):
					particles.queue_free()
			)
	else:
		particles.queue_free()
