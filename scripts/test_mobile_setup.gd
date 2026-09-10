extends SceneTree

func _initialize():
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
	
	var audio_script = preload("res://scripts/audio_manager.gd")
	var audio_mgr = audio_script.new()
	audio_mgr.name = "AudioManager"
	root.add_child(audio_mgr)
	print("AudioManager initialized OK")
	
	var state_script = preload("res://scripts/game_state.gd")
	var state_mgr = state_script.new()
	state_mgr.name = "GameState"
	root.add_child(state_mgr)
	print("GameState initialized OK")
	
	var autoload_state = ProjectSettings.get_setting("autoload/GameState")
	assert(autoload_state != null, "autoload/GameState must be configured in ProjectSettings")
	
	var main_scene = load("res://scenes/main.tscn")
	if not main_scene:
		printerr("ERROR: Could not load scenes/main.tscn")
		quit(1)
		return
	var inst = main_scene.instantiate()
	root.add_child(inst)
	current_scene = inst
	
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
	
	# Verify HUD Kills Label
	var kills_label = inst.get_node_or_null("HUD/KillsLabel")
	assert(kills_label != null, "HUD/KillsLabel must exist")
	assert(kills_label.is_in_group("hud_kills"), "KillsLabel must be in group hud_kills")
	assert(kills_label.text == "Kills: 0", "Initial kills label text must be 'Kills: 0'")
	print("HUD KillsLabel verified OK")
	
	# Verify Wave Banner
	var wave_banner = inst.get_node_or_null("HUD/WaveBanner")
	assert(wave_banner != null, "HUD/WaveBanner must exist")
	assert(wave_banner.is_in_group("wave_banner"), "WaveBanner must be in group wave_banner")
	assert(wave_banner.get_node_or_null("BannerLabel") != null, "BannerLabel must exist in WaveBanner")
	var wm = inst.get_node_or_null("WaveManager")
	assert(wm != null, "WaveManager must exist")
	assert(wm.has_method("show_wave_banner"), "WaveManager must implement show_wave_banner")
	wm.show_wave_banner("TEST WAVE")
	print("Wave Banner and WaveManager integration verified OK")
	
	# Verify Enemy VFX (Hit Flash & Death Particles) and Kill Counting
	var initial_kills = state_mgr.kills
	var enemy_scene = load("res://scenes/enemy.tscn")
	var enemy_inst = enemy_scene.instantiate()
	inst.add_child(enemy_inst)
	assert(enemy_inst.has_method("play_hit_flash"), "Enemy must implement play_hit_flash")
	assert(enemy_inst.has_method("spawn_death_particles"), "Enemy must implement spawn_death_particles")
	enemy_inst.play_hit_flash()
	enemy_inst.take_damage(1)
	assert(state_mgr.kills == initial_kills + 1, "Killing enemy must increment GameState.kills")
	assert(kills_label.text == "Kills: 1", "HUD KillsLabel must update to 'Kills: 1'")
	print("Enemy Hit Flash, Death Particles & Kill counting verified OK")
	
	# Verify Boss VFX (Hit Flash & Death Particles)
	var boss_scene = load("res://scenes/boss.tscn")
	var boss_inst = boss_scene.instantiate()
	inst.add_child(boss_inst)
	assert(boss_inst.has_method("play_hit_flash"), "Boss must implement play_hit_flash")
	assert(boss_inst.has_method("spawn_death_particles"), "Boss must implement spawn_death_particles")
	boss_inst.play_hit_flash()
	boss_inst.take_damage(2)
	print("Boss Hit Flash verified OK (HP remaining: ", boss_inst.hp, ")")
	
	# Verify EndScreen nodes and summary
	var end_screen = inst.get_node_or_null("EndScreen")
	assert(end_screen != null, "EndScreen node must exist")
	assert(end_screen.get_node_or_null("ResultLabel") != null, "ResultLabel must exist")
	assert(end_screen.get_node_or_null("KillsSummaryLabel") != null, "KillsSummaryLabel must exist")
	assert(end_screen.get_node_or_null("RestartButton") != null, "RestartButton must exist")
	assert(end_screen.get_node_or_null("MenuButton") != null, "MenuButton must exist")
	
	end_screen.show_result("VITÓRIA!", state_mgr.kills)
	var kills_summary = end_screen.get_node_or_null("KillsSummaryLabel")
	assert(kills_summary.text == "Inimigos abatidos: %d" % state_mgr.kills, "EndScreen must show total kills")
	print("EndScreen buttons, labels & kills summary verified OK")
	
	# Test GameState reset
	state_mgr.reset()
	assert(state_mgr.kills == 0, "GameState.reset() must reset kills to 0")
	assert(kills_label.text == "Kills: 0", "HUD KillsLabel must reset to 'Kills: 0'")
	print("GameState reset verified OK")
	
	var menu_scene = load("res://scenes/main_menu.tscn")
	var menu_inst = menu_scene.instantiate()
	
	# Verify AudioManager SFX and Music
	audio_mgr.play_sfx("attack")
	audio_mgr.play_sfx("hit")
	audio_mgr.play_sfx("player_hurt")
	audio_mgr.play_sfx("enemy_death")
	audio_mgr.play_sfx("boss_spawn")
	audio_mgr.play_sfx("victory")
	audio_mgr.play_sfx("game_over")
	audio_mgr.play_music(0.1)
	audio_mgr.stop_music(0.0)
	print("AudioManager SFX and Music playback verified OK")
	
	print("All scenes, mobile controls, audio and VFX verified successfully!")
	print("--- Headless Mobile, Touch & VFX Verification End ---")
	inst.free()
	menu_inst.free()
	quit(0)
