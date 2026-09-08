extends SceneTree

func _init():
	print("--- Headless Mobile, Touch & VFX Verification Start ---")
	var project_name = ProjectSettings.get_setting("application/config/name")
	var render_method = ProjectSettings.get_setting("rendering/renderer/rendering_method")
	var width = ProjectSettings.get_setting("display/window/size/viewport_width")
	var height = ProjectSettings.get_setting("display/window/size/viewport_height")
	var orientation = ProjectSettings.get_setting("display/window/handheld/orientation")
	var stretch_mode = ProjectSettings.get_setting("display/window/stretch/mode")
	var stretch_aspect = ProjectSettings.get_setting("display/window/stretch/aspect")
	var emulate_touch = ProjectSettings.get_setting("input_devices/pointing/emulate_touch_from_mouse")
	var emulate_mouse = ProjectSettings.get_setting("input_devices/pointing/emulate_mouse_from_touch")
	
	print("Project: ", project_name)
	print("Rendering method: ", render_method)
	print("Viewport: ", width, "x", height)
	print("Orientation: ", orientation)
	print("Stretch: ", stretch_mode, "/", stretch_aspect)
	print("Emulate Touch from Mouse: ", emulate_touch)
	print("Emulate Mouse from Touch: ", emulate_mouse)
	
	assert(emulate_touch == true, "emulate_touch_from_mouse must be true")
	assert(emulate_mouse == true, "emulate_mouse_from_touch must be true")
	
	var main_scene = load("res://scenes/main.tscn")
	if not main_scene:
		printerr("ERROR: Could not load scenes/main.tscn")
		quit(1)
		return
	var inst = main_scene.instantiate()
	root.add_child(inst)
	
	# Verify Camera3D and Screen Shake method
	var player = inst.get_node_or_null("Player")
	assert(player != null, "Player node must exist")
	assert(player.has_method("apply_shake"), "Player must implement apply_shake")
	player.apply_shake(0.1, 0.1)
	print("Player apply_shake verified OK")
	
	var cam = inst.get_node_or_null("Player/Camera3D")
	if cam:
		print("Camera3D keep_aspect: ", cam.keep_aspect, " (0=KEEP_WIDTH)")
		assert(cam.keep_aspect == 0, "Camera3D keep_aspect must be KEEP_WIDTH (0)")
	
	# Verify Mobile Controls
	var touch_up = inst.get_node_or_null("HUD/MobileControls/TouchUp")
	var touch_down = inst.get_node_or_null("HUD/MobileControls/TouchDown")
	var touch_attack = inst.get_node_or_null("HUD/MobileControls/TouchAttack")
	
	assert(touch_up != null, "TouchUp node must exist")
	assert(touch_down != null, "TouchDown node must exist")
	assert(touch_attack != null, "TouchAttack node must exist")
	
	assert(touch_up.action == "ui_up", "TouchUp action must be ui_up")
	assert(touch_down.action == "ui_down", "TouchDown action must be ui_down")
	assert(touch_attack.action == "ui_accept", "TouchAttack action must be ui_accept")
	print("TouchScreenButton actions verified OK")
	
	# Verify Enemy VFX (Hit Flash & Death Particles)
	var enemy_scene = load("res://scenes/enemy.tscn")
	var enemy_inst = enemy_scene.instantiate()
	inst.add_child(enemy_inst)
	assert(enemy_inst.has_method("play_hit_flash"), "Enemy must implement play_hit_flash")
	assert(enemy_inst.has_method("spawn_death_particles"), "Enemy must implement spawn_death_particles")
	enemy_inst.play_hit_flash()
	enemy_inst.take_damage(1)
	print("Enemy Hit Flash & Death Particles verified OK")
	
	# Verify Boss VFX (Hit Flash & Death Particles)
	var boss_scene = load("res://scenes/boss.tscn")
	var boss_inst = boss_scene.instantiate()
	inst.add_child(boss_inst)
	assert(boss_inst.has_method("play_hit_flash"), "Boss must implement play_hit_flash")
	assert(boss_inst.has_method("spawn_death_particles"), "Boss must implement spawn_death_particles")
	boss_inst.play_hit_flash()
	boss_inst.take_damage(2)
	print("Boss Hit Flash verified OK (HP remaining: ", boss_inst.hp, ")")
	
	# Verify EndScreen nodes
	var end_screen = inst.get_node_or_null("EndScreen")
	assert(end_screen != null, "EndScreen node must exist")
	assert(end_screen.get_node_or_null("ResultLabel") != null, "ResultLabel must exist")
	assert(end_screen.get_node_or_null("RestartButton") != null, "RestartButton must exist")
	assert(end_screen.get_node_or_null("MenuButton") != null, "MenuButton must exist")
	print("EndScreen buttons & labels verified OK")
	
	var menu_scene = load("res://scenes/main_menu.tscn")
	var menu_inst = menu_scene.instantiate()
	print("All scenes, mobile controls and VFX verified successfully!")
	print("--- Headless Mobile, Touch & VFX Verification End ---")
	inst.free()
	menu_inst.free()
	quit(0)
