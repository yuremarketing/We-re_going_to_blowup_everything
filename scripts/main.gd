extends Node3D

func _ready() -> void:
	var state = get_node_or_null("/root/GameState")
	if state:
		state.reset()
