extends SceneTree

func _init():
	print("--- Headless Verification Start ---")
	var project_name = ProjectSettings.get_setting("application/config/name")
	var render_method = ProjectSettings.get_setting("rendering/renderer/rendering_method")
	var width = ProjectSettings.get_setting("display/window/size/viewport_width")
	var height = ProjectSettings.get_setting("display/window/size/viewport_height")
	var orientation = ProjectSettings.get_setting("display/window/handheld/orientation")
	var stretch_mode = ProjectSettings.get_setting("display/window/stretch/mode")
	var stretch_aspect = ProjectSettings.get_setting("display/window/stretch/aspect")
	
	print("Project: ", project_name)
	print("Rendering method: ", render_method)
	print("Viewport: ", width, "x", height)
	print("Orientation: ", orientation)
	print("Stretch: ", stretch_mode, "/", stretch_aspect)
	
	var main_scene = load("res://scenes/main.tscn")
	if not main_scene:
		printerr("ERROR: Could not load scenes/main.tscn")
		quit(1)
		return
	var inst = main_scene.instantiate()
	var cam = inst.get_node_or_null("Player/Camera3D")
	if cam:
		print("Camera3D keep_aspect: ", cam.keep_aspect, " (0=KEEP_WIDTH, 1=KEEP_HEIGHT)")
		print("Camera3D FOV: ", cam.fov)
	
	var menu_scene = load("res://scenes/main_menu.tscn")
	if not menu_scene:
		printerr("ERROR: Could not load scenes/main_menu.tscn")
		quit(1)
		return
	var menu_inst = menu_scene.instantiate()
	print("Scenes loaded and instantiated successfully!")
	print("--- Headless Verification End ---")
	quit(0)
