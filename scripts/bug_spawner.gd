extends Node2D

signal wave_complete
signal segment_hit

const SCREEN_RIGHT_EDGE = 232
const SCREEN_LEFT_EDGE = 0

var attack_wave:int = 0
var mushroom_spawn: Reference

onready var bug_scene: PackedScene = preload("res://scenes/bug.tscn")
onready var bug_body_scene: PackedScene = preload("res://scenes/bug_segment_body.tscn")
onready var bug_head_scene: PackedScene = preload("res://scenes/bug_segment_head.tscn")
onready var mushroom_spawner = get_node("/root/root/mushroom_spawner")
onready var Rng = RandomNumberGenerator.new()

onready var side_feed_triggered: bool = false
onready var cycles_per_side_feed_spawn: int = 180
onready var cycle_count:int = 0


enum Directions { UP, DOWN, LEFT, RIGHT }


func _ready() -> void:
	Rng.randomize()
	new_attack_wave()
		
# create an array of Vector2 positions
func create_screen_positions(amount: int, build_direction: int, screen_start: Vector2) -> Array:
	var position_array:Array = []
			
	while position_array.size() < amount:
		position_array.append(Vector2(screen_start))
		if build_direction == Directions.LEFT:
			screen_start += (Vector2.LEFT * 8)
		else:
			screen_start += (Vector2.RIGHT * 8)
	
	return position_array



	
func new_attack_wave() -> void:
	attack_wave += 1
	# number of body segments, build direction
	var start_positions = create_screen_positions(12, Directions.LEFT, Vector2(8*3, 8))
	# screen positions, moving direction
	var bug:Bug = create_bug_from_positions(start_positions, Directions.RIGHT, Directions.DOWN)
	bug.stop_bug()
	bug.add_to_group("bugs")
	bug.set_speed(1)
	call_deferred("add_child", bug)
	
	#var start_positions2 = create_position_array(1, Directions.RIGHT, Vector2(8*12, 8))
	# screen positions, moving direction
	#var bug2 = create_bug_from_position_array(start_positions2, Directions.LEFT, Directions.DOWN)
	#bug2.stop_bug()
	#bug2.add_to_group("bugs")
	#bug2.set_speed(1)
	#call_deferred("add_child", bug2)
	
	

#	var bug = create_new_bug(create_vars)
#	bug.add_to_group("bugs")
#	call_deferred("add_child", bug)
	
	#
	# after the first wave we instance individual bugs
	# in place of being in the main centipede
	# this increases in number each wave, decreasing the
	# size of the main centipede by 1 each time
	#
#	if attack_wave > 1:
#		
#		var spawn_x: int
#		var cols_used: Array = []
#		
#		for _n in range(0, attack_wave - 1):
#
#			# find an empty column for it to spawn in
#			while true:
#				spawn_x = rng.randi_range(1, 30)
#				if not cols_used.has(spawn_x):
#					break
					
#			cols_used.append(spawn_x)
			
#			create_vars = {
#				'num_sections': 1,
#				'x_position': 8 * spawn_x,
#				'y_position': 8,
#				'direction': Directions.RIGHT,
#				'speed_factor': 1
#			}
#			
#			bug = create_new_bug(create_vars)
#			bug.add_to_group("bugs")
#			call_deferred("add_child", bug)


func __create_bug_from_position_direction_array(positions: Array, horizontal_directions: Array, vertical_direction: int):
	var bug = bug_scene.instance()
	
	var bug_segment: BugBaseSegment
	
	for n in range(0, positions.size()):
		
		if n == 0:	
			bug_segment = bug_head_scene.instance()
			bug_segment.vertical_direction = vertical_direction
			# needed for when instancing first time
			bug_segment.set_horizontal_direction(horizontal_directions[n])
			#bug_segment.connect('side_feed_triggered', self, '_on_side_feed_triggered')
			bug_segment.check_map_function = funcref(mushroom_spawner, "check_map_location")
		else:
			bug_segment = bug_body_scene.instance()
		
		bug_segment.set_speed(1)
		# warning-ignore:return_value_discarded
		bug_segment.connect('segment_hit', bug, '_on_segment_hit')
		bug_segment.position = positions[n]
		bug.call_deferred("add_child", bug_segment)
	
	bug.connect("bug_hit", self, "_on_bug_hit")
	return bug



func create_bug_from_positions(positions: Array, horizontal_direction: int, vertical_direction: int):

	var bug:Bug = bug_scene.instance()
	var bug_segment

	for n in range(0, positions.size()):
		
		if n == 0:
			bug_segment = bug_head_scene.instance()
			# needed for when instancing first time
			bug_segment.set_horizontal_direction(horizontal_direction)
			bug_segment.is_moving_horizontally = true
			
			bug_segment.connect('side_feed_triggered', self, '_on_side_feed_triggered')
			bug_segment.check_map_function = funcref(mushroom_spawner, "check_map_location")
		else:
			bug_segment = bug_body_scene.instance()
		
		bug_segment.set_horizontal_direction(horizontal_direction)
		bug_segment.set_vertical_direction(vertical_direction)	

		# warning-ignore:return_value_discarded
		bug_segment.connect('segment_hit', bug, '_on_segment_hit')
		bug_segment.position = positions[n]
		bug.call_deferred("add_child", bug_segment)
	
	bug.connect("bug_hit", self, "_on_bug_hit")
	return bug


func _on_bug_hit(segment: BugSegmentBase, bug: Bug):
	bug.set_block_signals(true)
	
	# mushroom is deployed
	emit_signal("segment_hit", segment.position)
	
	if bug.get_child_count() == 1:  # head only remaining
		bug.queue_free()
	else:
		if segment is BugSegmentHead:
			handle_head_segment_hit(segment, bug)
			#pass
		else:
			handle_body_segment_hit(segment, bug)
			#pass
			
	bug.set_block_signals(false)	


func handle_body_segment_hit(body_segment:BugSegmentBody, bug:Bug) -> void:
	body_segment.queue_free()
		
	# skip making another bug if we hit the last body segment
	if body_segment.get_index() < bug.get_child_count() - 1:
	
		var has_spawned_head: bool = false
		var new_bug:Bug = bug_scene.instance()
		var new_head_segment:BugSegmentHead = bug_head_scene.instance()
		
		for bug_segment in bug.get_children():
			
			if bug_segment.get_index() > body_segment.get_index():
				bug.remove_child(bug_segment)
				
				if has_spawned_head == false:
					bug_segment.queue_free()
					new_head_segment.position = bug_segment.position
					new_head_segment.horizontal_direction = bug_segment.horizontal_direction
					new_head_segment.vertical_direction = bug_segment.vertical_direction
					new_head_segment.is_moving_horizontally = bug_segment.is_moving_horizontally
					new_head_segment.is_moving_vertically = bug_segment.is_moving_vertically
					# warning-ignore:return_value_discarded
					new_head_segment.connect('segment_hit', new_bug, '_on_segment_hit')
					# warning-ignore:return_value_discarded
					new_head_segment.connect('side_feed_triggered', self, '_on_side_feed_triggered')
					new_head_segment.check_map_function = funcref(mushroom_spawner, "check_map_location")
					new_bug.add_child(new_head_segment)
					has_spawned_head = true
				else:
					new_bug.add_child(bug_segment)
					# disconnect old signal from current bug and reconnect to new bug
					if bug_segment.is_connected('segment_hit', bug, '_on_segment_hit'):
						bug_segment.disconnect('segment_hit', bug, '_on_segment_hit')
						# warning-ignore:return_value_discarded
						bug_segment.connect('segment_hit', new_bug, '_on_segment_hit')
						
		
		#new_bug.set_body_target_positions()
		if new_bug.get_child_count() > 0:
			new_bug.add_to_group("bugs")
			new_bug.set_speed(bug.get_speed())
			# warning-ignore:return_value_discarded
			new_bug.connect("bug_hit", self, "_on_bug_hit")
			#new_bug.modulate.a = 0.4
			new_bug.start_bug()
			#new_bug.get_head().modulate.a = 0.5
			#new_bug.print_tree_pretty()
			call_deferred("add_child", new_bug)
	else:
		print('size <= 2 - skipped')


	
func handle_head_segment_hit(head_segment:BugSegmentHead, bug:Bug) -> void:
	# remove bug completely if only head remains
	if bug.get_child_count() <= 1:
		bug.queue_free()
	else:
		
		bug.stop_bug()
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
	
		# remove the original first segment now taken by head	
		first_body_segment.queue_free()
		bug.start_bug()
		
		
		
func _on_side_feed_triggered() -> void:
	side_feed_triggered = true


# this happens when all centipede links are destroyed
func stop_side_feed() -> void:
	side_feed_triggered = false	


func _process(_delta: float) -> void:
	if side_feed_triggered == true:
		cycle_count +=1
		if cycle_count >= cycles_per_side_feed_spawn:
			cycle_count = 0
			spawn_side_feed()
			# reduce cycles_per_side_feed_spawn by 7


func spawn_side_feed() -> void:
	# put a hard limit on the number of bugs on screen
	if get_tree().get_nodes_in_group("bugs").size() < 60:
		# default spawn vars (start off screen)
		var start_x = SCREEN_RIGHT_EDGE + 8
		var direction = Directions.LEFT
		# random variation
		if randf() < 0.5:
			start_x = SCREEN_LEFT_EDGE - 8
			direction = Directions.RIGHT
			
		var start_positions = create_screen_positions(1, direction, Vector2(start_x, 23 * 8))
		var bug:Bug = create_bug_from_positions(start_positions, direction, Directions.DOWN)
		bug.is_side_feed = true
		
		bug.add_to_group("bugs")
		call_deferred("add_child", bug)


func _on_Timer_timeout() -> void:
	if get_tree().get_nodes_in_group("bugs").size() == 0:
		#print('wave complete')
		stop_side_feed()
		new_attack_wave()
		emit_signal("wave_complete")
