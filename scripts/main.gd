extends Node3D

func _ready() -> void:
	var state = get_node_or_null("/root/GameState")
	if state:
		state.reset()
	var pause_btn = get_node_or_null("HUD/PauseButton")
	if pause_btn:
		pause_btn.pressed.connect(toggle_pause)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		toggle_pause()

func toggle_pause() -> void:
	var cutscene = get_node_or_null("/root/CutsceneManager")
	if cutscene and cutscene.is_playing:
		return
	var pause_menu = get_node_or_null("PauseMenu")
	if not pause_menu and is_inside_tree():
		pause_menu = get_tree().get_first_node_in_group("pause_menu")
	if pause_menu and pause_menu.has_method("toggle_pause"):
		pause_menu.toggle_pause()


