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

func _on_restart_pressed() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()

func _on_menu_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
