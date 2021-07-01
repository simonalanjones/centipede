extends Node

signal segment_hit(segment)

enum Directions { UP, DOWN, LEFT, RIGHT }

var Rng = RandomNumberGenerator.new()
var main_bug_start_position:Vector2 = Vector2(120, 8)

onready var bug_spawner = get_node("/root/root/bug_spawner")

func _ready() -> void:
	Rng.randomize()
	
# create an array of Vector2 positions
func create_screen_positions(amount: int, build_direction: int, screen_start: Vector2) -> Array:
	var position_array:Array = []
	while position_array.size() < amount:
		position_array.append(Vector2(screen_start))
		if build_direction == Directions.LEFT:
			screen_start += (Vector2.LEFT * 8)
		elif build_direction == Directions.RIGHT:
			screen_start += (Vector2.RIGHT * 8)
		elif build_direction == Directions.UP:
			screen_start += (Vector2.UP * 8)
	return position_array
	
	
func create_new(attack_wave: int):
	var start_positions:Array = create_screen_positions(13 - attack_wave, Directions.UP, main_bug_start_position)
	var main_bug:Bug = bug_spawner.spawn_from_vector2_array(start_positions, Directions.RIGHT, Directions.DOWN)
	# warning-ignore:return_value_discarded
	main_bug.connect("bug_hit", self, "_on_bug_hit")
	# warning-ignore:return_value_discarded
	main_bug.connect("bug_ready", self, "_on_bug_ready", [main_bug])
	#main_bug.set_speed(Speed.SLOW)	
	add_child(main_bug)
	
	## todo: spawn single bug heads


func _process(_delta: float) -> void:
	if get_tree().get_nodes_in_group("bugs").size() > 0:
		for bug in get_tree().get_nodes_in_group("bugs"):
			bug.move()


## callback from spawner 
func _on_bug_ready(bug: Bug):
	bug.add_to_group("bugs")
	


func _on_bug_hit(segment: BugSegmentBase, bug: Bug) -> void:
	
	emit_signal("segment_hit", segment) # connected to game manager
	
	bug.set_block_signals(true)
	if bug.get_child_count() == 1:  # head only remaining
		bug.queue_free()
	else:
		if segment is BugSegmentHead:
			handle_head_segment_hit(segment, bug)
		else:
			handle_body_segment_hit(segment, bug)
	bug.set_block_signals(false)
	


func handle_head_segment_hit(head_segment:BugSegmentHead, bug:Bug) -> void:
	
	var first_body_segment:BugSegmentBody = bug.get_child(1)
	
	# move the head into the position of the first body segment
	head_segment.position = first_body_segment.position	
	if head_segment.is_on_vertical_boundary():
		head_segment.is_moving_vertically = false
		head_segment.is_moving_horizontally = true
	else:
		head_segment.is_moving_vertically = true
		head_segment.is_moving_horizontally = false
		
	head_segment.vertical_direction = first_body_segment.vertical_direction
	head_segment.horizontal_direction = first_body_segment.horizontal_direction
	# segment in loop cannot be set to move vertically if not on boundary
	if head_segment.is_on_grid_boundary() == true:
		head_segment.is_moving_vertically = first_body_segment.is_moving_vertically
	head_segment.is_moving_horizontally = first_body_segment.is_moving_horizontally
	
	head_segment.is_poisoned = false

	# remove the original first segment now taken by head	
	first_body_segment.free()
	bug.set_body_target_positions(false)


func handle_body_segment_hit(body_segment: BugSegmentBody, bug: Bug):
	
	if body_segment.get_index() < bug.get_child_count() - 1:
		var new_bug = bug_spawner.spawn_from_body_segment_hit(body_segment, bug)
		new_bug.connect("bug_hit", self, "_on_bug_hit")
		# warning-ignore:return_value_discarded
		new_bug.connect("bug_ready", self, "_on_bug_ready", [new_bug])
		add_child(new_bug)
