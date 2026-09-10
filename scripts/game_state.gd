extends Node

signal kills_changed(new_kills: int)

static var instance = null

var kills: int = 0

func _init() -> void:
	instance = self

func _ready() -> void:
	instance = self
	process_mode = Node.PROCESS_MODE_ALWAYS

func reset() -> void:
	kills = 0
	kills_changed.emit(0)
	_update_hud()

func add_kill(amount: int = 1) -> void:
	kills += amount
	kills_changed.emit(kills)
	_update_hud()

func _update_hud() -> void:
	var tree: SceneTree = null
	if is_inside_tree():
		tree = get_tree()
	if not tree:
		var main_loop = Engine.get_main_loop()
		if main_loop is SceneTree:
			tree = main_loop
	if tree:
		var label = tree.get_first_node_in_group("hud_kills")
		if not label and tree.root:
			label = tree.root.find_child("KillsLabel", true, false)
		if label:
			label.text = "Kills: %d" % kills
