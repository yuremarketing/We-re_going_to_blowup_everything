extends Area3D

@export var heal_amount: int = 1
@export var lifetime: float = 8.0

static var _cached_mesh: BoxMesh = null

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	_setup_visual()
	get_tree().create_timer(lifetime, true).timeout.connect(func():
		if is_instance_valid(self):
			queue_free()
	)

func _setup_visual() -> void:
	var mesh_inst = get_node_or_null("MeshInstance3D")
	if not mesh_inst:
		return
	if not _cached_mesh:
		_cached_mesh = BoxMesh.new()
		_cached_mesh.size = Vector3(0.3, 0.3, 0.3)
		var mat = StandardMaterial3D.new()
		mat.albedo_color = Color(0.3, 1.0, 0.4)
		mat.emission_enabled = true
		mat.emission = Color(0.3, 1.0, 0.4)
		_cached_mesh.material = mat
	mesh_inst.mesh = _cached_mesh

func _on_body_entered(body: Node) -> void:
	if not body.is_in_group("player"):
		return
	if not ("hp" in body and "max_hp" in body):
		return
	if body.hp >= body.max_hp:
		return
	if body.has_method("heal"):
		body.heal(heal_amount)
	_spawn_collect_particles()
	if is_inside_tree():
		var audio = get_node_or_null("/root/AudioManager")
		if audio:
			audio.play_sfx("heal", 0.05)
	queue_free()

func _spawn_collect_particles() -> void:
	if not is_inside_tree():
		return
	var particles = CPUParticles3D.new()
	particles.top_level = true
	particles.process_mode = Node.PROCESS_MODE_ALWAYS
	particles.emitting = false
	particles.one_shot = true
	particles.explosiveness = 1.0
	particles.amount = 10
	particles.lifetime = 0.3
	particles.direction = Vector3(0, 1, 0)
	particles.spread = 180.0
	particles.initial_velocity_min = 1.5
	particles.initial_velocity_max = 3.5
	particles.gravity = Vector3(0, -6.0, 0)
	particles.mesh = _cached_mesh

	var tree = get_tree()
	var spawn_pos = global_position
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
			var p_ref = weakref(particles)
			tree.create_timer(particles.lifetime + 0.3, true).timeout.connect(func():
				var p = p_ref.get_ref()
				if p and is_instance_valid(p):
					p.queue_free()
			)
	else:
		particles.queue_free()
