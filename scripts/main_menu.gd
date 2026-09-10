extends CanvasLayer

@onready var play_button: Button = get_node_or_null("Panel/VBox/PlayButton")
@onready var music_slider: HSlider = get_node_or_null("Panel/VBox/MusicBox/MusicSlider")
@onready var music_label: Label = get_node_or_null("Panel/VBox/MusicBox/MusicLabel")
@onready var sfx_slider: HSlider = get_node_or_null("Panel/VBox/SFXBox/SFXSlider")
@onready var sfx_label: Label = get_node_or_null("Panel/VBox/SFXBox/SFXLabel")

func _ready() -> void:
	if not play_button:
		play_button = get_node_or_null("PlayButton")
	if play_button:
		play_button.pressed.connect(_on_play_pressed)
		
	var music_val = _get_audio_volume("Music")
	if music_slider:
		music_slider.set_value_no_signal(music_val)
		music_slider.value_changed.connect(_on_music_value_changed)
	_update_music_label(music_val)
	
	var sfx_val = _get_audio_volume("SFX")
	if sfx_slider:
		sfx_slider.set_value_no_signal(sfx_val)
		sfx_slider.value_changed.connect(_on_sfx_value_changed)
	_update_sfx_label(sfx_val)

func _on_play_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main.tscn")

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

