extends Node

signal points_awarded(points)

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


func spawn_mushroom_from_world_position(world_position: Vector2) -> void:
	spawn_mushroom(mushroom_map.world_to_map(world_position))
	

func spawn_mushroom(mushroom_position: Vector2) -> void:
	var cell_value:int = mushroom_map.get_cellv(mushroom_position)
	if cell_value == -1:
		mushroom_map.set_cell(mushroom_position.x,mushroom_position.y, 0)
		# need to track the mushrooms that are spawned within infield group
		if mushroom_position.y >= 25 and not infield_array.has(Vector2(mushroom_position)):
			infield_array.append(mushroom_position)


func poison_mushroom(world_position: Vector2) -> void:
	var local_position = mushroom_map.world_to_map(world_position)
	mushroom_map.set_cell(local_position.x, local_position.y, 4)
	
	
func remove_from_infield_array(mushroom_position: Vector2) -> void:
	var index = infield_array.find(Vector2(mushroom_position.x,mushroom_position.y))
	if index != -1:
		infield_array.remove(index)
	
	
func _on_mushroom_hit(mushroom_position: Vector2) -> void:
	var cell_value:int = mushroom_map.get_cellv(mushroom_position)
	#var index:int
	
	# if cell value is 3 (last frame of mushroom) remove it by setting -1 value
	if cell_value == 3:
		emit_signal("points_awarded", 1)
		mushroom_map.set_cell(mushroom_position.x,mushroom_position.y, -1)
		# check infield array (used by flea spawner) and remove entry if found
		remove_from_infield_array(Vector2(mushroom_position.x,mushroom_position.y))
		#index = infield_array.find(Vector2(mushroom_position.x,mushroom_position.y))
		#if index != -1:
		#	infield_array.remove(index)
			
	# if cell value is 6 (last frame of poisoned mushroom) remove it by setting -1 value		
	elif cell_value == 6:
		emit_signal("points_awarded", 5)
		mushroom_map.set_cell(mushroom_position.x,mushroom_position.y, -1)
		remove_from_infield_array(Vector2(mushroom_position.x,mushroom_position.y))
		#index = infield_array.find(Vector2(mushroom_position.x,mushroom_position.y))
		#if index != -1:
		#	infield_array.remove(index)
		
	else:
		mushroom_map.set_cell(mushroom_position.x, mushroom_position.y, cell_value + 1) 
