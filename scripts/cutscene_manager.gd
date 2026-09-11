extends Node

signal cutscene_finished

const OVERLAY_SCENE := preload("res://scenes/cutscene_overlay.tscn")
const SETTINGS_PATH := "user://settings.cfg"

var is_playing: bool = false
var skip_cutscenes: bool = false

var _overlay: CanvasLayer
var _root_ctrl: Control
var _art: TextureRect
var _caption: Label
var _skip_requested: bool = false
var _fade_tween: Tween

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_load_prefs()
	_ensure_overlay()

func _ensure_overlay() -> void:
	if _overlay and is_instance_valid(_overlay):
		return
	_overlay = OVERLAY_SCENE.instantiate()
	add_child(_overlay)
	_root_ctrl = _overlay.get_node_or_null("Root")
	_art = _overlay.get_node_or_null("Root/ArtTexture")
	_caption = _overlay.get_node_or_null("Root/CaptionPanel/CaptionLabel")
	var skip_btn = _overlay.get_node_or_null("Root/SkipButton")
	if skip_btn and not skip_btn.pressed.is_connected(skip):
		skip_btn.pressed.connect(skip)
	if _root_ctrl and not _root_ctrl.gui_input.is_connected(_on_root_gui_input):
		_root_ctrl.gui_input.connect(_on_root_gui_input)
	_overlay.visible = false

func _on_root_gui_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch and event.pressed:
		skip()
	elif event is InputEventMouseButton and event.pressed:
		skip()

# Beats: array de {texture: Texture2D, caption: String, duration: float, is_boss: bool (opcional)}
func play_intro() -> void:
	if skip_cutscenes:
		return
	await _play_sequence([
		{
			"texture": preload("res://assets/cutscenes/survivor_v2.jpg"),
			"caption": "Um surto começou numa viela de bairro qualquer. Não deu tempo de evacuar — só de correr, revidar, e sobreviver a mais uma onda.",
			"duration": 2.0,
		},
		{
			"texture": preload("res://assets/cutscenes/enemy_common_v1.jpg"),
			"caption": "Não são só infectados genéricos — cada variação carrega um resquício de quem foram.",
			"duration": 2.0,
		},
	])

func play_boss_alert() -> void:
	if skip_cutscenes:
		return
	await _play_sequence([
		{
			"texture": preload("res://assets/cutscenes/boss_v2.jpg"),
			"caption": "⚠️ O primeiro infectado da viela, mutado além dos outros. Não recua no contato — só cai depois de sucessivos ataques.",
			"duration": 2.2,
			"is_boss": true,
		},
	])
	_reset_player_movement()

func skip() -> void:
	if not is_playing:
		return
	_skip_requested = true

func _play_sequence(beats: Array) -> void:
	_ensure_overlay()
	is_playing = true
	_skip_requested = false

	var tree := get_tree()
	if tree:
		tree.paused = true
	_overlay.visible = true
	_root_ctrl.modulate.a = 0.0

	for beat in beats:
		if _skip_requested:
			break
		_art.texture = beat.get("texture")
		_art.scale = Vector2(1.0, 1.0)
		_art.pivot_offset = _art.size / 2.0
		_caption.text = beat.get("caption", "")
		_caption.modulate = Color(1.0, 0.4, 0.4) if beat.get("is_boss", false) else Color.WHITE

		await _fade_to(1.0, 0.4)
		if _skip_requested:
			break

		var pan_tween := create_tween()
		pan_tween.tween_property(_art, "scale", Vector2(1.12, 1.12), beat.get("duration", 2.0)).set_trans(Tween.TRANS_SINE)
		await pan_tween.finished
		if _skip_requested:
			break

		await _fade_to(0.0, 0.3)

	if _root_ctrl:
		_root_ctrl.modulate.a = 0.0
	if _overlay:
		_overlay.visible = false
	if tree:
		tree.paused = false
	is_playing = false
	_skip_requested = false
	cutscene_finished.emit()

func _fade_to(target_alpha: float, duration: float) -> void:
	if _fade_tween and _fade_tween.is_valid():
		_fade_tween.kill()
	_fade_tween = create_tween()
	_fade_tween.tween_property(_root_ctrl, "modulate:a", target_alpha, duration)
	await _fade_tween.finished

func _reset_player_movement() -> void:
	var tree := get_tree()
	if not tree:
		return
	var player = tree.get_first_node_in_group("player")
	if player and player.has_method("reset_movement"):
		player.reset_movement()

func set_skip_cutscenes(value: bool) -> void:
	skip_cutscenes = value
	_save_prefs()

func _load_prefs() -> void:
	var cfg := ConfigFile.new()
	if cfg.load(SETTINGS_PATH) == OK:
		skip_cutscenes = cfg.get_value("cutscenes", "skip", false)

func _save_prefs() -> void:
	var cfg := ConfigFile.new()
	cfg.load(SETTINGS_PATH)
	cfg.set_value("cutscenes", "skip", skip_cutscenes)
	cfg.save(SETTINGS_PATH)
