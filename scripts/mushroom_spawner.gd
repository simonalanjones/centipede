extends Node2D

var rng = RandomNumberGenerator.new()
onready var mushroom_scene: PackedScene = preload("res://scenes/mushroom.tscn")

func _ready() -> void:
	rng.randomize()
	for _n in range(1,70):
		var x = (rng.randi() % 35 ) * 8
		var y = (rng.randi() % 28 + 3) * 8
		spawn_mushroom(Vector2(x,y))

	
func spawn_mushroom(mushroom_position: Vector2) -> void:
	var x = int(mushroom_position.x)
	var y = int(mushroom_position.y)
	
	# make sure x and y position of mushroom is on a 8 pixel boundary 
	mushroom_position.x = x - int(x % 8)
	mushroom_position.y = y - int(y % 8)
	
	var mushroom = mushroom_scene.instance()
	mushroom.position = mushroom_position
	
	# this group is used to decide when to spawn fleas
	if mushroom_position.y >= 152:
		mushroom.add_to_group('mushrooms_in_infield')
		
	call_deferred("add_child", mushroom)


func _on_bug_segment_hit(segment, bug) -> void:
	
	if bug.get_head().is_moving_left():
		spawn_mushroom(segment.position)
	else:
		spawn_mushroom(segment.position + Vector2(8,0)) # right
