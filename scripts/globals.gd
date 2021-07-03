extends Node

onready var score_node = get_node("/root/root/ui/score/")
onready var mushroom_map_node = get_node("/root/root/mushroom_map")
onready var explosion_node = get_node("/root/root/explosion_spawner")

func player_score() -> int:
	return score_node.get_score()

func spawn_explosion(world_position: Vector2) -> void:
	explosion_node.spawn(world_position)

func add_score_points(points: int) -> void:
	score_node.add_points(points)

	
func should_spawn_flea():
	return mushroom_map_node.needs_more_infield_mushrooms()


func respawn_mushrooms() -> void:
	mushroom_map_node.respawn()
	
	
func check_map_position(world_position) -> int:
	return mushroom_map_node.check_map_location(world_position)
	

func spawn_tilemap_mushroom(world_position) -> void:
	mushroom_map_node.spawn_at_world_position(world_position)
	
	
func tilemap_cell_value(world_position: Vector2) -> int:
	return mushroom_map_node.check_map_location(world_position)


func register_tilemap_collision(grid_position: Vector2) -> void:
	mushroom_map_node.register_tilemap_collision(grid_position)
	

func poison_tilemap_cell(world_position) -> void:
	mushroom_map_node.poison_mushroom(world_position)
	
	
func eat_tilemap_cell(world_position) -> void:
	mushroom_map_node.eat_mushroom(world_position)
