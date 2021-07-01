extends Node2D

# don't forget to use stretch mode 'viewport' and aspect 'ignore'
onready var viewport: Viewport = get_viewport()

onready	var flea_spawner = get_node("flea_spawner")
onready	var explosion_spawner = get_node("explosion_spawner")
onready	var mushroom_map = get_node("mushroom_map")
onready	var scorpion_spawner = get_node("scorpion_spawner")
onready	var spider_spawner = get_node("spider_spawner")
onready	var game_manager = get_node("game_manager")
onready	var bug_manager = get_node("bug_manager")

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
	#var bug_spawner = get_node("bug_spawner")

		
	game_manager.spawn_flea = funcref(flea_spawner, "spawn")
	game_manager.spawn_new_wave = funcref(bug_manager, "create_new")
	game_manager.spawn_scorpion = funcref(scorpion_spawner, "spawn")
	game_manager.spawn_explosion = funcref(explosion_spawner, "spawn")
	game_manager.spawn_spider = funcref(spider_spawner, "spawn")
	
#	var _c = bug_spawner.connect("segment_hit", game_manager, "segment_hit")
#	var _i = bug_spawner.connect("wave_complete", game_manager, "_on_wave_complete")
	
	var _n = bug_manager.connect("segment_hit", game_manager, "segment_hit")
	var _j = flea_spawner.connect("flea_left_screen", game_manager, "on_flea_left_screen")
	var _l = flea_spawner.connect("flea_destroyed", game_manager, "flea_destroyed")
	var _m = spider_spawner.connect("spider_destroyed", game_manager, "on_spider_destroyed")
	var _g = mushroom_map.connect("points_awarded",  game_manager, "award_points")
	var _k = scorpion_spawner.connect("scorpion_left_screen", game_manager, "on_scorpion_left_screen")
	var _b = spider_spawner.connect("spider_left_screen", game_manager, "on_spider_left_screen")
	var _h = scorpion_spawner.connect("scorpion_destroyed",  game_manager, "on_scorpion_destroyed")
		
	var _a = get_tree().connect("screen_resized", self, "_screen_resized")
	_screen_resized()
	
