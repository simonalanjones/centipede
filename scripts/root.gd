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
	var bug_spawner = get_node("bug_spawner")
	var flea_spawner = get_node("flea_spawner")
	var explosion_spawner = get_node("explosion_spawner")
	var mushroom_map = get_node("mushroom_map")
	var scorpion_spawner = get_node("scorpion_spawner")
	#var score_board = get_node("ui/score")
	var game_manager = get_node("game_manager")
	var player = get_node("player")
	
	
	player.register_mushroom_hit = funcref(mushroom_map, "_on_mushroom_hit")
	
	game_manager.spawn_flea = funcref(flea_spawner, "spawn")
	game_manager.spawn_new_wave = funcref(bug_spawner, "spawn_wave")
	#game_manager.get_score = funcref(score_board, "get_score")
	#game_manager.add_points = funcref(score_board, "add_points")
	#game_manager.count_infield_mushrooms = funcref(mushroom_map, "count_infield_mushrooms")
	game_manager.spawn_scorpion = funcref(scorpion_spawner, "spawn")
	#game_manager.check_map_location = funcref(mushroom_map, "check_map_location")
	#game_manager.poison_mushroom =  funcref(mushroom_map, "poison_mushroom")
	#game_manager.eat_mushroom =  funcref(mushroom_map, "eat_mushroom")
	#game_manager.spawn_mushroom = funcref(mushroom_map, "spawn_at_world_position")
	game_manager.spawn_explosion = funcref(explosion_spawner, "spawn")
	#flea_spawner.get_score = funcref(score_board, "get_score")
	#scorpion_spawner.get_score = funcref(score_board, "get_score")
	#scorpion_spawner.attack_wave = funcref(bug_spawner, "attack_wave_counter")
	
	#flea_spawner.mushroom_spawn = funcref(mushroom_spawner, "spawn_mushroom")
	#flea_spawner.infield_mushroom_count = funcref(mushroom_spawner, "mushrooms_in_infield")
	
	
	bug_spawner.mushroom_spawn = funcref(mushroom_map, "spawn_mushroom")
	bug_spawner.check_mushroom = funcref(mushroom_map, "check_map_location")
	
	var _c = bug_spawner.connect("segment_hit", game_manager, "segment_hit")
	var _i = bug_spawner.connect("wave_complete", game_manager, "_on_wave_complete")
	
	var _f = flea_spawner.connect("mushroom_spawned",  mushroom_map, "spawn_at_world_position")
	var _j = flea_spawner.connect("flea_left_screen", game_manager, "on_flea_left_screen")
	var _l = flea_spawner.connect("flea_destroyed", game_manager, "flea_destroyed")
	
	var _g = mushroom_map.connect("points_awarded",  game_manager, "on_points_awarded")
	
	
	var _k = scorpion_spawner.connect("scorpion_left_screen", game_manager, "on_scorpion_left_screen")
	var _h = scorpion_spawner.connect("scorpion_destroyed",  game_manager, "on_scorpion_destroyed")
		
	var _a = get_tree().connect("screen_resized", self, "_screen_resized")
	_screen_resized()
	
