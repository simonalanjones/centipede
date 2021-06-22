extends TileMap

signal points_awarded(points)

const TILEMAP_NEW_MUSHROOM_CELL = 0
const TILEMAP_NEW_POISONED_CELL = 4
const TILEMAP_LAST_MUSHROOM_CELL = 3
const TILEMAP_LAST_POISONED_CELL = 6
const TILEMAP_EMPTY_CELL = -1
const MUSHROOM_POINTS = 1
const POISONED_POINTS = 5

var Rng = RandomNumberGenerator.new()
var infield_array:Array = []

func _ready() -> void:
	
#	for n in get_used_cells():
#		set_cell(n.x,n.y, TILEMAP_EMPTY_CELL)
		
	Rng.randomize()
	for _n in range(1,1):
		var x = (Rng.randi() % 30)
		var y = (Rng.randi() % 30)
		spawn_at_cell_position(Vector2(x,y))



func needs_more_infield_mushrooms() -> bool:
	var score = Globals.player_score()
	var required:int = 0
	
	if score <= 20000:
		required = 5
	elif score <= 120000:
		required = 9
	else:
		required = 15 + ((score - 140000) / 20000)
		
	return infield_array.size() < required
		
		
func check_map_location(global_position: Vector2) -> int:
	var local_position = to_local(global_position)
	var map_position = world_to_map(local_position)
	return get_cellv(map_position)
		

func spawn_at_cell_position(mushroom_position: Vector2) -> void:
	var cell_value:int = get_cellv(mushroom_position)
	if cell_value == TILEMAP_EMPTY_CELL:
		set_cellv(mushroom_position, TILEMAP_NEW_MUSHROOM_CELL)
		# need to track the mushrooms that are spawned within infield group
		if mushroom_position.y >= 25 and not infield_array.has(Vector2(mushroom_position)):
			infield_array.append(mushroom_position)


func segment_hit(segment: BugSegmentBase):
	spawn_at_world_position(segment.mushroom_spawn_position())
	
		
func spawn_at_world_position(world_position: Vector2) -> void:
	spawn_at_cell_position(world_to_map(world_position))
	

func poison_mushroom(world_position: Vector2) -> void:
	var local_position = world_to_map(world_position)
	set_cellv(local_position, TILEMAP_NEW_POISONED_CELL)
	

func eat_mushroom(mushroom_position: Vector2) -> void:
	clear_cell(mushroom_position)


func clear_cell(mushroom_position: Vector2):
	set_cellv(mushroom_position, TILEMAP_EMPTY_CELL)
	var index = infield_array.find(Vector2(mushroom_position.x, mushroom_position.y))
	if index != TILEMAP_EMPTY_CELL:
		infield_array.remove(index)
				
			
func _on_mushroom_hit(mushroom_position: Vector2) -> void:
	match get_cellv(mushroom_position):
		TILEMAP_LAST_MUSHROOM_CELL:
			emit_signal("points_awarded", MUSHROOM_POINTS)
			clear_cell(mushroom_position)
		TILEMAP_LAST_POISONED_CELL:
			emit_signal("points_awarded", POISONED_POINTS)
			clear_cell(mushroom_position)
		# if anyting else just increment it
		_:
			set_cellv(mushroom_position, get_cellv(mushroom_position) + 1) 

