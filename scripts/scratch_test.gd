extends SceneTree

func _init():
	var root_node = Node2D.new()
	root.add_child(root_node)
	
	var btn = TouchScreenButton.new()
	var shape = RectangleShape2D.new()
	shape.size = Vector2(100, 100)
	btn.shape = shape
	btn.action = "ui_up"
	btn.position = Vector2(50, 50)
	root_node.add_child(btn)
	
	print("Initial ui_up pressed:", Input.is_action_pressed("ui_up"))
	
	# Simulate screen touch
	var event = InputEventScreenTouch.new()
	event.position = Vector2(70, 70)
	event.pressed = true
	Input.parse_input_event(event)
	
	# Wait a frame or process
	# TouchScreenButton processes in _input
	btn._input(event)
	print("After touch event ui_up pressed:", Input.is_action_pressed("ui_up"))
	
	var release = InputEventScreenTouch.new()
	release.position = Vector2(70, 70)
	release.pressed = false
	btn._input(release)
	print("After release event ui_up pressed:", Input.is_action_pressed("ui_up"))
	
	quit(0)
