extends CanvasLayer

@onready var music_slider: HSlider = get_node_or_null("Panel/VBox/MusicBox/MusicSlider")
@onready var music_label: Label = get_node_or_null("Panel/VBox/MusicBox/MusicLabel")
@onready var sfx_slider: HSlider = get_node_or_null("Panel/VBox/SFXBox/SFXSlider")
@onready var sfx_label: Label = get_node_or_null("Panel/VBox/SFXBox/SFXLabel")

@onready var resume_button: Button = get_node_or_null("Panel/VBox/ResumeButton")
@onready var restart_button: Button = get_node_or_null("Panel/VBox/RestartButton")
@onready var menu_button: Button = get_node_or_null("Panel/VBox/MenuButton")

func _ready() -> void:
	visible = false
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	if resume_button:
		resume_button.pressed.connect(_on_resume_pressed)
	if restart_button:
		restart_button.pressed.connect(_on_restart_pressed)
	if menu_button:
		menu_button.pressed.connect(_on_menu_pressed)
		
	if music_slider:
		music_slider.value_changed.connect(_on_music_value_changed)
	if sfx_slider:
		sfx_slider.value_changed.connect(_on_sfx_value_changed)

func open_pause() -> void:
	var end_screen = get_node_or_null("../EndScreen")
	if not end_screen and is_inside_tree():
		end_screen = get_tree().get_first_node_in_group("end_screen")
	if end_screen and end_screen.visible:
		return
	
	var tree: SceneTree = get_tree() if is_inside_tree() else (Engine.get_main_loop() as SceneTree)
	if tree:
		tree.paused = true
	
	var music_val = _get_audio_volume("Music")
	if music_slider:
		music_slider.set_value_no_signal(music_val)
	_update_music_label(music_val)
	
	var sfx_val = _get_audio_volume("SFX")
	if sfx_slider:
		sfx_slider.set_value_no_signal(sfx_val)
	_update_sfx_label(sfx_val)
	
	visible = true

func close_pause() -> void:
	var tree: SceneTree = get_tree() if is_inside_tree() else (Engine.get_main_loop() as SceneTree)
	if tree:
		tree.paused = false
	visible = false



func toggle_pause() -> void:
	if visible:
		close_pause()
	else:
		open_pause()

func _on_resume_pressed() -> void:
	close_pause()

func _on_restart_pressed() -> void:
	var state = get_node_or_null("/root/GameState")
	if state:
		state.reset()
	get_tree().paused = false
	get_tree().reload_current_scene()

func _on_menu_pressed() -> void:
	var state = get_node_or_null("/root/GameState")
	if state:
		state.reset()
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")

func _on_music_value_changed(val: float) -> void:
	var audio_script = load("res://scripts/audio_manager.gd")
	if audio_script:
		audio_script.set_bus_volume("Music", val)
	_update_music_label(val)

func _on_sfx_value_changed(val: float) -> void:
	var audio_script = load("res://scripts/audio_manager.gd")
	if audio_script:
		audio_script.set_bus_volume("SFX", val)
	_update_sfx_label(val)

func _get_audio_volume(bus_name: String) -> float:
	var audio_script = load("res://scripts/audio_manager.gd")
	if audio_script:
		return audio_script.get_bus_volume(bus_name)
	return 1.0

func _update_music_label(val: float) -> void:
	if music_label:
		music_label.text = "Música: %d%%" % int(val * 100)

func _update_sfx_label(val: float) -> void:
	if sfx_label:
		sfx_label.text = "SFX: %d%%" % int(val * 100)
