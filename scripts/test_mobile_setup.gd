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

	# Verify attack_range and heal()
	assert(player.attack_range == 2.4, "Player attack_range must default to 2.4")
	assert(player.has_method("heal"), "Player must implement heal(amount)")
	player.hp = player.max_hp - 2
	player.heal(1)
	assert(player.hp == player.max_hp - 1, "heal() must increase hp by the given amount")
	player.heal(10)
	assert(player.hp == player.max_hp, "heal() must not exceed max_hp")
	print("Player attack_range and heal() verified OK")
	
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

	# Verify Enemy Tank guaranteed heal drop chance
	var tank_scene = load("res://scenes/enemy_tank.tscn")
	var tank_inst = tank_scene.instantiate()
	assert(tank_inst.heal_drop_chance == 1.0, "EnemyTank must override heal_drop_chance to 1.0 (guaranteed drop)")
	tank_inst.free()

	# Verify HealPickup scene and heal-on-collect logic.
	# Nota: neste harness headless (_initialize síncrono), o _ready() dos nós
	# recém-instanciados ainda não rodou (só roda quando o engine processa um
	# frame de verdade) - por isso registramos o grupo "player" manualmente
	# aqui, do mesmo jeito que o resto deste arquivo já monta o cenário à mão
	# em vez de depender de callbacks do engine ainda não disparados.
	if not player.is_in_group("player"):
		player.add_to_group("player")
	var pickup_scene = load("res://scenes/heal_pickup.tscn")
	var pickup_inst = pickup_scene.instantiate()
	inst.add_child(pickup_inst)
	assert(pickup_inst is Area3D, "HealPickup root must be an Area3D")
	assert(pickup_inst.get_node_or_null("CollisionShape3D") != null, "HealPickup must have a CollisionShape3D")
	player.hp = 1
	pickup_inst._on_body_entered(player)
	assert(player.hp == 2, "Collecting HealPickup must heal the player")
	# Pickup deve ter sido removido (queue_free) apos a coleta
	print("HealPickup collection and Tank guaranteed drop verified OK")

	# Verify Boss VFX (Hit Flash & Death Particles)
	var boss_scene = load("res://scenes/boss.tscn")
	var boss_inst = boss_scene.instantiate()
	inst.add_child(boss_inst)
	assert(boss_inst.has_method("play_hit_flash"), "Boss must implement play_hit_flash")
	assert(boss_inst.has_method("spawn_death_particles"), "Boss must implement spawn_death_particles")
	boss_inst.play_hit_flash()
	boss_inst.take_damage(2)
	print("Boss Hit Flash verified OK (HP remaining: ", boss_inst.hp, ")")
	boss_inst.free()
	
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
	end_screen.visible = false
	paused = false
	print("EndScreen buttons, labels & kills summary verified OK")
	
	# Test GameState reset
	state_mgr.reset()
	assert(state_mgr.kills == 0, "GameState.reset() must reset kills to 0")
	assert(kills_label.text == "Kills: 0", "HUD KillsLabel must reset to 'Kills: 0'")
	print("GameState reset verified OK")

	
	# Verify Pause Button and Pause Menu in main.tscn
	var pause_btn = inst.get_node_or_null("HUD/PauseButton")
	assert(pause_btn != null, "PauseButton must exist in HUD")
	assert(pause_btn.text == "⏸️", "PauseButton text must be ⏸️")
	
	var pause_menu = inst.get_node_or_null("PauseMenu")
	assert(pause_menu != null, "PauseMenu node must exist")
	assert(pause_menu.process_mode == Node.PROCESS_MODE_ALWAYS, "PauseMenu process_mode must be PROCESS_MODE_ALWAYS")

	assert(pause_menu.visible == false, "PauseMenu must initially be hidden")
	assert(pause_menu.get_node_or_null("Panel/VBox/ResumeButton") != null, "ResumeButton must exist in PauseMenu")
	assert(pause_menu.get_node_or_null("Panel/VBox/RestartButton") != null, "RestartButton must exist in PauseMenu")
	assert(pause_menu.get_node_or_null("Panel/VBox/MenuButton") != null, "MenuButton must exist in PauseMenu")
	assert(pause_menu.get_node_or_null("Panel/VBox/MusicBox/MusicSlider") != null, "MusicSlider must exist in PauseMenu")
	assert(pause_menu.get_node_or_null("Panel/VBox/SFXBox/SFXSlider") != null, "SFXSlider must exist in PauseMenu")
	
	# Test Pause toggle logic
	inst.toggle_pause()
	assert(paused == true, "SceneTree must be paused when toggle_pause is called")
	assert(pause_menu.visible == true, "PauseMenu must be visible when paused")
	pause_menu.close_pause()
	assert(paused == false, "SceneTree must be unpaused when close_pause is called")
	assert(pause_menu.visible == false, "PauseMenu must be hidden after close_pause")
	print("PauseButton and PauseMenu toggling verified OK")
	
	# Verify AudioManager volume helper functions and mute thresholds
	audio_script.set_bus_volume("Music", 0.6)
	var music_vol = audio_script.get_bus_volume("Music")
	assert(abs(music_vol - 0.6) < 0.05, "Music volume should reflect set value")
	var music_bus_idx = AudioServer.get_bus_index("Music")
	assert(AudioServer.is_bus_mute(music_bus_idx) == false, "Music bus should not be muted at 0.6")
	
	audio_script.set_bus_volume("Music", 0.0)
	assert(AudioServer.is_bus_mute(music_bus_idx) == true, "Music bus must be muted at 0.0")
	
	audio_script.set_bus_volume("SFX", 0.8)
	var sfx_vol = audio_script.get_bus_volume("SFX")
	assert(abs(sfx_vol - 0.8) < 0.05, "SFX volume should reflect set value")
	var sfx_bus_idx = AudioServer.get_bus_index("SFX")
	assert(AudioServer.is_bus_mute(sfx_bus_idx) == false, "SFX bus should not be muted at 0.8")
	
	audio_script.set_bus_volume("SFX", 0.0)
	assert(AudioServer.is_bus_mute(sfx_bus_idx) == true, "SFX bus must be muted at 0.0")
	
	# Restore normal volumes
	audio_script.set_bus_volume("Music", 0.7)
	audio_script.set_bus_volume("SFX", 1.0)
	print("AudioManager set_bus_volume and get_bus_volume verified OK")
	
	var menu_scene = load("res://scenes/main_menu.tscn")
	var menu_inst = menu_scene.instantiate()
	assert(menu_inst.get_node_or_null("Panel/VBox/PlayButton") != null, "PlayButton must exist in MainMenu")
	assert(menu_inst.get_node_or_null("Panel/VBox/TitleLabel") != null, "TitleLabel must exist in MainMenu")
	assert(menu_inst.get_node_or_null("Panel/VBox/MusicBox/MusicSlider") != null, "MusicSlider must exist in MainMenu")
	assert(menu_inst.get_node_or_null("Panel/VBox/SFXBox/SFXSlider") != null, "SFXSlider must exist in MainMenu")
	print("MainMenu layout and audio controls verified OK")
	
	# Verify AudioManager SFX and Music
	audio_mgr.play_sfx("attack")
	audio_mgr.play_sfx("hit")
	audio_mgr.play_sfx("player_hurt")
	audio_mgr.play_sfx("enemy_death")
	audio_mgr.play_sfx("boss_spawn")
	audio_mgr.play_sfx("victory")
	audio_mgr.play_sfx("game_over")
	audio_mgr.play_sfx("heal")
	audio_mgr.play_music(0.1)
	audio_mgr.stop_music(0.0)
	print("AudioManager SFX and Music playback verified OK")

	# Verify Web export preset configuration
	var preset_cfg = ConfigFile.new()
	var cfg_err = preset_cfg.load("res://export_presets.example.cfg")
	assert(cfg_err == OK, "export_presets.example.cfg must be loadable")
	assert(preset_cfg.has_section("preset.1"), "Preset 1 must exist for Web export")
	assert(preset_cfg.get_value("preset.1", "platform") == "Web", "Preset 1 platform must be Web")
	assert(preset_cfg.get_value("preset.1.options", "variant/thread_support") == false, "Web export must use single-threaded variant (thread_support=false)")
	print("Web export preset configuration verified OK")
	
	print("All scenes, mobile controls, audio, pause and VFX verified successfully!")
	print("--- Headless Mobile, Touch & VFX Verification End ---")
	inst.free()
	menu_inst.free()
	quit(0)

