extends Node2D

# don't forget to use stretch mode 'viewport' and aspect 'ignore'
onready var viewport: Viewport = get_viewport()


func _screen_resized():
	var window_size = OS.get_window_size()
	# see how big the window is compared to the viewport size
	# floor it so we only get round numbers (0, 1, 2, 3 ...)
	var scale_x = floor(window_size.x / viewport.size.x)
	var scale_y = floor(window_size.y / viewport.size.y)

	# use the smaller scale with 1x minimum scale
	var scale = max(1, min(scale_x, scale_y))

	# find the coordinate we will use to center the viewport inside the window
	var diff = window_size - (viewport.size * scale)
	var diffhalf = (diff * 0.5).floor()

	# attach the viewport to the rect we calculated
	viewport.set_attach_to_screen_rect(Rect2(diffhalf, viewport.size * scale))


func _ready():
	
	randomize()
	var mushroom_spawner = get_node("/root/root/mushroom_spawner")
	var bug_spawner = get_node("/root/root/bug_spawner")
	var flea_spawner = get_node("/root/root/flea_spawner")

	var _a = get_tree().connect("screen_resized", self, "_screen_resized")
	var _b = bug_spawner.connect("wave_complete", self, "_on_wave_complete")
	var _c = bug_spawner.connect("segment_hit", mushroom_spawner, "spawn_mushroom_from_world_position")
	var _d = flea_spawner.connect("mushroom_spawned",  mushroom_spawner, "spawn_mushroom_from_world_position")
	_screen_resized()
	

	

	
		
	#var bug_spawner = get_node("/root/root/bug_spawner")
	
	#var mushroom_spawner = get_node("/root/root/mushroom_spawner")
	var score_board = get_node("/root/root/ui/score")
	#var bug_spawner = get_node("/root/root/bug_spawner")
	
	flea_spawner.get_score = funcref(score_board, "get_score")
	
	#flea_spawner.mushroom_spawn = funcref(mushroom_spawner, "spawn_mushroom")
	flea_spawner.infield_mushroom_count = funcref(mushroom_spawner, "mushrooms_in_infield")
	bug_spawner.mushroom_spawn = funcref(mushroom_spawner, "spawn_mushroom")
	
	

	
	
	
	#mushroom_spawner.check_mushroom_grid = funcref(grid, "check_grid")
	#mushroom_spawner.remove_from_mushroom_grid = funcref(grid, "remove_from_grid")
	#mushroom_spawner.add_to_mushroom_grid = funcref(grid, "add_to_grid")
	#mushroom_spawner.debug_grid = funcref(grid, "debug_grid")
	#yield(get_tree(), "idle_frame")
	
func _on_wave_complete():
	pass
	



