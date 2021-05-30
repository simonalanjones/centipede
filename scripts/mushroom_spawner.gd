extends Node2D

#signal mushroom_spawned

onready var mushroom_map = get_node("mushroom_map")

# used to hold positions of mushrooms within the infield
# this is used by the flea spawner to decide when to start
var infield_array:Array = []
var rng = RandomNumberGenerator.new()


func _ready() -> void:
	
	# clear any added for testing
	#for n in get_node("mushroom_map").get_used_cells():
	#	get_node("mushroom_map").set_cell(n.x,n.y, -1)
		
	rng.randomize()
	
	for _n in range(1,1):
		var x = (rng.randi() % 30)
		var y = (rng.randi() % 30)
		spawn_mushroom(Vector2(x,y))


func mushrooms_in_infield() -> int:
	return infield_array.size()
		
		
func check_map_location(global_position: Vector2) -> int:
	var local_position = mushroom_map.to_local(global_position)
	var map_position = mushroom_map.world_to_map(local_position)
	return mushroom_map.get_cellv(map_position)
	

# this has bug if fired for grid/screen position
# need two functions:  spawn_mushroom_grid  spawn_mushroom_screen	
func spawn_mushroom(mushroom_position: Vector2) -> void:
	
	# position from flea will be screen position not tilemap
	if mushroom_position.x > 30 or mushroom_position.y > 30:
		mushroom_position = mushroom_map.world_to_map(mushroom_position)
		
	mushroom_map.set_cell(mushroom_position.x,mushroom_position.y,0)
	# need to track the mushrooms that are spawned within infield group
	if mushroom_position.y >= 25 and not infield_array.has(Vector2(mushroom_position)):
		infield_array.append(mushroom_position)
		
		
func _on_mushroom_hit(mushroom_position: Vector2) -> void:
	
	var cell_value:int = mushroom_map.get_cellv(mushroom_position)
	var index:int
	
	# if cell value is 3 (last frame of mushroom) remove it by setting -1 value
	if cell_value == 3:
		mushroom_map.set_cell(mushroom_position.x,mushroom_position.y, -1)
		# check infield array (used by flea spawner) and remove entry if found
		index = infield_array.find(Vector2(mushroom_position.x,mushroom_position.y))
		if index != -1:
			infield_array.remove(index)
			# and add 1 point to score
	else:
		mushroom_map.set_cell(mushroom_position.x,mushroom_position.y,cell_value+1) 


func _on_bug_segment_hit(segment, bug) -> void:
	
	var map_position:Vector2
	
	if bug.get_head().is_moving_left():
		map_position = mushroom_map.world_to_map(segment.position - Vector2(8,0))
	else:
		map_position = mushroom_map.world_to_map(segment.position + Vector2(8,0))
	spawn_mushroom(map_position)

