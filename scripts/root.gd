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
	var _a = get_tree().connect("screen_resized", self, "_screen_resized")
	var _b = $bug_spawner.connect("wave_complete", self, "_on_wave_complete")
	#var Mushroom_scene = $mushrooms
	#Smoke_container.add_path_obstacle = funcref(Mushroom_scene, "add_avoid_cell")
	_screen_resized()
	

	var flea_spawner = get_node("/root/root/flea_spawner")
	var score_board = get_node("/root/root/ui/score")
	flea_spawner.get_score =  funcref(score_board, "get_score")

	

func number_of_mushrooms_in_infield(points) -> int:
	if points <= 20000:
		return 5
	elif points <= 120000:
		return 9
	else:
		var factor = ((points - 140000) / 20000)
		return 15 + factor
	

func _on_wave_complete():
	pass
	
