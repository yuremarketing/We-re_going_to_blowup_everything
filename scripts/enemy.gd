extends CharacterBody3D

@export var speed: float = 3.0
@export var hp: int = 1
@export var heal_drop_chance: float = 0.15
@export var model_path: String = ""

const HEAL_PICKUP_SCENE_PATH = "res://scenes/heal_pickup.tscn"

var _base_albedo: Color = Color.RED
var _base_albedos: Array[Color] = []
var _flash_tween: Tween
static var _cached_mesh_dict: Dictionary = {}

func _ready() -> void:
	add_to_group("enemies")
	if model_path != "":
		_load_character_model(model_path)
	_setup_material()

func _load_character_model(glb_path: String) -> void:
	var mesh_node: MeshInstance3D = get_node_or_null("MeshInstance3D")
	if not mesh_node or not ResourceLoader.exists(glb_path):
		return
	var packed: PackedScene = load(glb_path)
	var instance := packed.instantiate()
	var source_mesh := _find_mesh_instance(instance)
	if source_mesh:
		mesh_node.mesh = source_mesh.mesh
	instance.queue_free()

func _find_mesh_instance(node: Node) -> MeshInstance3D:
	if node is MeshInstance3D:
		return node
	for child in node.get_children():
		var found := _find_mesh_instance(child)
		if found:
			return found
	return null

func _setup_material() -> void:
	var mesh_inst = get_node_or_null("MeshInstance3D")
	if not mesh_inst or not mesh_inst.mesh:
		return
	_base_albedos.clear()
	# meshes low poly importados têm 1 surface por parte do corpo (jaqueta,
	# pele, etc.) — duplica e registra a cor de cada uma pro hit-flash
	# cobrir o personagem inteiro, não só a 1ª surface.
	for i in mesh_inst.mesh.get_surface_count():
		var mat = mesh_inst.get_surface_override_material(i)
		if not mat is StandardMaterial3D:
			mat = mesh_inst.mesh.surface_get_material(i) as StandardMaterial3D
		if mat:
			var dup = mat.duplicate() as StandardMaterial3D
			mesh_inst.set_surface_override_material(i, dup)
			_base_albedos.append(dup.albedo_color)
	if not _base_albedos.is_empty():
		_base_albedo = _base_albedos[0]

func _physics_process(delta: float) -> void:
	if not is_inside_tree():
		return
	# Anda em direção ao player, no sentido +Z (o player nasce em Z menor e avança em -Z)
	velocity.z = speed
	if not is_on_floor():
		velocity.y -= 9.8 * delta
	move_and_slide()
	
	var player = get_tree().get_first_node_in_group("player")
	if player and abs(player.position.z - position.z) < 1.5:
		player.take_damage(1)
		queue_free()
	elif position.z > 25.0:
		queue_free()

func take_damage(amount: int) -> void:
	hp -= amount
	if hp <= 0:
		spawn_death_particles()
		queue_free()
	else:
		play_hit_flash()

func play_hit_flash() -> void:
	if not is_inside_tree():
		return
	var mesh_inst = get_node_or_null("MeshInstance3D")
	if not mesh_inst or not mesh_inst.mesh:
		return
	if _flash_tween and _flash_tween.is_valid():
		_flash_tween.kill()
	_flash_tween = create_tween()
	for i in mesh_inst.mesh.get_surface_count():
		var mat = mesh_inst.get_surface_override_material(i) as StandardMaterial3D
		if not mat:
			continue
		var base: Color = _base_albedos[i] if i < _base_albedos.size() else mat.albedo_color
		mat.emission_enabled = true
		mat.emission = Color.WHITE
		mat.albedo_color = Color(1.5, 1.5, 1.5, 1.0)
		_flash_tween.parallel().tween_property(mat, "albedo_color", base, 0.05).set_delay(0.08)
		_flash_tween.parallel().tween_property(mat, "emission", Color.BLACK, 0.05).set_delay(0.08)
	_flash_tween.tween_callback(func():
		for i in mesh_inst.mesh.get_surface_count():
			var mat = mesh_inst.get_surface_override_material(i) as StandardMaterial3D
			if mat:
				mat.emission_enabled = false
				mat.albedo_color = _base_albedos[i] if i < _base_albedos.size() else mat.albedo_color
	)

func _get_audio():
	if not is_inside_tree():
		return null
	return get_node_or_null("/root/AudioManager")

func _get_game_state():
	if is_inside_tree():
		var root_node = get_node_or_null("/root/GameState")
		if root_node:
			return root_node
	var state_script = load("res://scripts/game_state.gd")
	if state_script and state_script.instance:
		return state_script.instance
	return null

func _maybe_drop_heal(spawn_pos: Vector3) -> void:
	if heal_drop_chance <= 0.0 or randf() > heal_drop_chance:
		return
	var pickup_scene: PackedScene = load(HEAL_PICKUP_SCENE_PATH)
	if not pickup_scene:
		return
	var pickup = pickup_scene.instantiate()
	var parent_node = get_parent()
	if parent_node:
		parent_node.add_child(pickup)
	elif get_tree() and get_tree().root:
		get_tree().root.add_child(pickup)
	if pickup.is_inside_tree():
		pickup.global_position = spawn_pos

func spawn_death_particles() -> void:
	var state = _get_game_state()
	if state:
		state.add_kill(1)
	if not is_inside_tree():
		return
	var audio = _get_audio()
	if audio:
		audio.play_sfx("enemy_death", 0.08)
	_maybe_drop_heal(global_position)
	var particles = CPUParticles3D.new()
	particles.top_level = true
	particles.process_mode = Node.PROCESS_MODE_ALWAYS
	particles.emitting = false
	particles.one_shot = true
	particles.explosiveness = 1.0
	particles.amount = 12
	particles.lifetime = 0.35
	particles.direction = Vector3(0, 1, 0)
	particles.spread = 180.0
	particles.initial_velocity_min = 2.0
	particles.initial_velocity_max = 5.0
	particles.gravity = Vector3(0, -9.8, 0)
	
	var box: BoxMesh
	if _cached_mesh_dict.has(_base_albedo):
		box = _cached_mesh_dict[_base_albedo]
	else:
		box = BoxMesh.new()
		box.size = Vector3(0.12, 0.12, 0.12)
		var p_mat = StandardMaterial3D.new()
		p_mat.albedo_color = _base_albedo
		p_mat.emission_enabled = true
		p_mat.emission = _base_albedo * 0.5
		box.material = p_mat
		_cached_mesh_dict[_base_albedo] = box
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
			var p_ref = weakref(particles)
			tree.create_timer(particles.lifetime + 0.3, true).timeout.connect(func():
				var p = p_ref.get_ref()
				if p and is_instance_valid(p):
					p.queue_free()
			)
	else:
		particles.queue_free()
