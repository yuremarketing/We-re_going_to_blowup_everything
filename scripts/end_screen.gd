extends CanvasLayer

@onready var restart_button: Button = $RestartButton
@onready var result_label: Label = $ResultLabel
@onready var menu_button: Button = $MenuButton

func _ready() -> void:
	visible = false
	restart_button.pressed.connect(_on_restart_pressed)
	menu_button.pressed.connect(_on_menu_pressed)

func show_result(text: String) -> void:
	result_label.text = text
	visible = true
	var audio = get_node_or_null("/root/AudioManager")
	if audio:
		audio.stop_music(0.3)
		if "VITÓRIA" in text.to_upper() or "PARABÉNS" in text.to_upper() or "VITORIA" in text.to_upper():
			audio.play_sfx("victory")
		else:
			audio.play_sfx("game_over")

func _on_restart_pressed() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()

func _on_menu_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
