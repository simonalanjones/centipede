extends Node2D

signal wave_complete

var attack_wave:int = 1

onready var bug_scene: PackedScene = preload("res://scenes/bug.tscn")
onready var bug_body_scene: PackedScene = preload("res://scenes/bug_segment_body.tscn")
onready var bug_head_scene: PackedScene = preload("res://scenes/bug_segment_head.tscn")
onready var mushroom_spawner = get_node("/root/root/mushroom_spawner")

onready var Rng = RandomNumberGenerator.new()

onready var side_feed_triggered: bool = false
onready var cycles_per_side_feed_spawn: int = 180
onready var cycle_count:int = 0

var mushroom_spawn: Reference

enum Directions { UP, DOWN, LEFT, RIGHT }




func _ready() -> void:
	Rng.randomize()
	new_attack_wave()
		

func create_position_array(positions: int, build_direction: int, screen_start: Vector2) -> Array:
	var position_array:Array = []
			
	while position_array.size() < positions:
		position_array.append(Vector2(screen_start))    #.snapped(Vector2(8,8)))
		if build_direction == Directions.LEFT:
			screen_start += (Vector2.LEFT * 8)
		else:
			screen_start += (Vector2.RIGHT * 8)
	
	return position_array

	
func new_attack_wave() -> void:
	# number of body segments, build direction
	var start_positions = create_position_array(12, Directions.LEFT, Vector2(66, 8))
	# screen positions, moving direction
	var bug = create_bug_from_position_array(start_positions, Directions.RIGHT, Directions.DOWN)
	bug.stop_bug()
	bug.add_to_group("bugs")
	call_deferred("add_child", bug)
	
	

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


func create_bug_from_position_direction_array(positions: Array, horizontal_directions: Array, vertical_direction: int):
	var bug = bug_scene.instance()
	bug.set_speed_factor(1)
	
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
		



func create_bug_from_position_array(positions: Array, horizontal_direction: int, vertical_direction: int):

	var bug = bug_scene.instance()
	bug.set_speed_factor(1)
	
	var bug_segment#: BugBaseSegment
	
	for n in range(0, positions.size()):
		
		if n == 0:
			# this needs to know if we're moving vertically
			
			bug_segment = bug_head_scene.instance()
			# needed for when instancing first time
			bug_segment.set_horizontal_direction(horizontal_direction)
			bug_segment.set_vertical_direction(vertical_direction)
			bug_segment.is_moving_horizontally = true
			
			#bug_segment.connect('side_feed_triggered', self, '_on_side_feed_triggered')
			bug_segment.check_map_function = funcref(mushroom_spawner, "check_map_location")
		else:
			bug_segment = bug_body_scene.instance()

			#bug_segment.set_initial_direction(initial_direction)
		
		bug_segment.set_speed(1)
		# warning-ignore:return_value_discarded
		bug_segment.connect('segment_hit', bug, '_on_segment_hit')
		bug_segment.position = positions[n]
		bug.call_deferred("add_child", bug_segment)
	
	bug.connect("bug_hit", self, "_on_bug_hit")
	return bug


func _on_bug_hit(segment, bug):
	
	# put some conditional logic around if head or body segment then change pos
	var spawn_pos = segment.position.snapped(Vector2(8,8))
	mushroom_spawn.call_func(spawn_pos)
	
	if bug.get_child_count() == 1:  # head only remaining
		bug.queue_free()
	else:
		if segment.get_index() == 0: # head segment is always index 0
			new_handle_head_segment_hit(segment, bug)
		else:
			new_handle_body_segment_hit(segment, bug)
			
			
			
func new_handle_body_segment_hit(body_segment, bug):

	bug.set_block_signals(true)
	
	var counter = 0
	var new_bug = bug_scene.instance()
	#new_bug.spawn_mushroom = funcref(mushroom_spawner, "spawn_mushroom_from_object")
	
	for n in range(0, bug.get_child_count()):
				
		var segment_in_loop = bug.get_child(n)
		
		# look at segments with index higher than segment we hit
		if segment_in_loop.get_index() > body_segment.get_index():
			
			if counter == 0:
				var new_head_segment = bug_head_scene.instance()
				new_head_segment.vertical_direction = segment_in_loop.vertical_direction
				new_head_segment.horizontal_direction = segment_in_loop.horizontal_direction
				new_head_segment.is_moving_vertically = segment_in_loop.is_moving_vertically
				new_head_segment.is_moving_horizontally = segment_in_loop.is_moving_horizontally
				new_head_segment.check_map_function = funcref(mushroom_spawner, "check_map_location")
				new_head_segment.position = segment_in_loop.position #.snapped(Vector2(8,8))
				new_head_segment.modulate.a = 0.6
				# warning-ignore:return_value_discarded
				new_head_segment.connect('segment_hit', new_bug, '_on_segment_hit')
				new_bug.add_child(new_head_segment)
			else:
				var new_body_segment = bug_body_scene.instance()
				new_body_segment.vertical_direction = segment_in_loop.vertical_direction
				new_body_segment.horizontal_direction = segment_in_loop.horizontal_direction
				new_body_segment.is_moving_vertically = segment_in_loop.is_moving_vertically
				new_body_segment.is_moving_horizontally = segment_in_loop.is_moving_horizontally
				new_body_segment.position = segment_in_loop.position #.snapped(Vector2(8,8))
				new_body_segment.modulate.a = 0.4
				# warning-ignore:return_value_discarded
				new_body_segment.connect('segment_hit', new_bug, '_on_segment_hit')
				new_bug.add_child(new_body_segment)
				
			segment_in_loop.queue_free()
			counter += 1
			#var new_position = bug.get_child(n).move_to_start_position()
			#new_bug_segment.position = new_position
	
			#new_bug.add_child(new_bug_segment)
			#bug.get_child(n).queue_free()
			
										
	
	if new_bug.get_child_count() > 0:
		# warning-ignore:return_value_discarded
		new_bug.connect("bug_hit", self, "_on_bug_hit")
		new_bug.add_to_group("bugs")
		#new_bug.stop_bug()
		call_deferred("add_child", new_bug)
	
	#body_segment.queue_free()
	body_segment.queue_free()
	bug.set_block_signals(false)		
	#bug.queue_free()    # temp remove original bug to concentrate on secondary
	
	
func new_handle_head_segment_hit(head_segment, bug):
	#bug.set_block_signals(true)	
	#head_segment.queue_free()
	for n in range(0, bug.get_child_count()-1):
		
		if n != 0:
			bug.get_child(n).position = bug.get_child(n+1).position
		else:
			var position_data = bug.get_head().previous_vars
			var previous_position = bug.get_child(n+1).position
			#print('previous position:' + str(previous_position))
			for element in position_data:
				if element.position == Vector2(previous_position):
					#print('found:' + str(element))
					
					bug.get_head().position = Vector2(element.position)
					bug.get_head().is_moving_horizontally = element.is_moving_horizontally
					bug.get_head().is_moving_vertically = element.is_moving_vertically
					bug.get_head().vertical_direction = element.vertical_direction
					bug.get_head().horizontal_direction = element.horizontal_direction
					
			
		
		#if n == 0:
		#	bug.get_child(n).vertical_direction = bug.get_child(n+1).vertical_direction
		#	
		#else:
		#if n != 0:
		#	bug.get_child(n).horizontal_direction = bug.get_child(n+1).horizontal_direction
		#	bug.get_child(n).is_moving_vertically = bug.get_child(n+1).is_moving_vertically
		#	bug.get_child(n).is_moving_horizontally = bug.get_child(n+1).is_moving_horizontally
			
		
	var last = bug.get_child_count()-1
	bug.get_child(last).queue_free()
	# bug head isn't reset to boundary but body segments are
	# have a system for body segments then no need to set target positions
	
	bug.set_body_target_positions()  
	


	
		
		


func handle_head_segment_hit(head_segment, bug):
	bug.set_block_signals(true)
	var new_bug = bug_scene.instance()
	new_bug.set_block_signals(true)
	#new_bug.spawn_mushroom = funcref(mushroom_spawner, "spawn_mushroom_from_object")
	var new_bug_segment: BugBaseSegment
	
	
	## try alternative
	## place all segments in range 0, child_count()-1
	## to position of previous segment
	
	for n in range(0, bug.get_child_count()-1):

		if n == 0:
			new_bug_segment = bug_head_scene.instance()
			new_bug_segment.vertical_direction = head_segment.vertical_direction
			
			# should check placement
			new_bug_segment.horizontal_direction = head_segment.horizontal_direction
			new_bug_segment.is_moving_vertically = head_segment.is_moving_vertically
			new_bug_segment.is_moving_horizontally = head_segment.is_moving_horizontally
			new_bug_segment.check_map_function = funcref(mushroom_spawner, "check_map_location")
			
		else:
			new_bug_segment = bug_body_scene.instance()
		
		# warning-ignore:return_value_discarded
		new_bug_segment.connect('segment_hit', new_bug, '_on_segment_hit')
		var new_position = bug.get_child(n+1).move_to_target_position()
		new_bug_segment.position = new_position
		new_bug.add_child(new_bug_segment)
	
	#for n in new_bug.get_children():
	#	var pos = n.position
	#	print(str(n) + ':' + str(pos))
	#print('----')
	
	new_bug.connect("bug_hit", self, "_on_bug_hit")
	bug.queue_free() # remove old bug
	new_bug.add_to_group("bugs") # add new bug
	call_deferred("add_child", new_bug)
	bug.set_block_signals(false)
	new_bug.set_block_signals(false)

func handle_body_segment_hit(body_segment, bug):
	bug.set_block_signals(true)
	
	var new_bug_segment: BugBaseSegment
	var counter = 0
	var new_bug = bug_scene.instance()
	#new_bug.spawn_mushroom = funcref(mushroom_spawner, "spawn_mushroom_from_object")
	
	var existing_bug_head = bug.get_child(0)
	
	
	for n in range(0, bug.get_child_count()):
		# look at segments with index higher than segment we hit
		# handle segments left of collision
		if bug.get_child(n).get_index() > body_segment.get_index():
			
			if counter == 0:
				new_bug_segment = bug_head_scene.instance()
				new_bug_segment.vertical_direction = existing_bug_head.vertical_direction
				new_bug_segment.horizontal_direction = existing_bug_head.horizontal_direction
				new_bug_segment.is_moving_vertically = existing_bug_head.is_moving_vertically
				new_bug_segment.is_moving_horizontally = existing_bug_head.is_moving_horizontally
				new_bug_segment.check_map_function = funcref(mushroom_spawner, "check_map_location")
			else:
				new_bug_segment = bug_body_scene.instance()

		
			counter += 1
			var new_position = bug.get_child(n).move_to_start_position()
			new_bug_segment.position = new_position
			# warning-ignore:return_value_discarded
			new_bug_segment.connect('segment_hit', new_bug, '_on_segment_hit')
			new_bug.add_child(new_bug_segment)
			bug.get_child(n).queue_free()
		
		else:
			# handle segments right of collision
			if bug.get_child(n).get_index() == 0:
				bug.get_child(n).move_to_previous_boundary()
			else:
				bug.get_child(n).move_to_start_position()	

			
										
	
	if new_bug.get_child_count() > 0:
		# warning-ignore:return_value_discarded
		new_bug.connect("bug_hit", self, "_on_bug_hit")
		new_bug.add_to_group("bugs")
		call_deferred("add_child", new_bug)
	
	body_segment.queue_free()	
	bug.set_block_signals(false)		
			
			
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
	
	var start_x
	var direction
	
	if randf() < 0.5:
		start_x = 0
		direction = Directions.RIGHT
	else:
		start_x = 240
		direction = Directions.LEFT
		
	
	var start_positions = create_position_array(1, direction, Vector2(start_x, 23 * 8))
	var bug = create_bug_from_position_array(start_positions, Directions.LEFT, Directions.DOWN)
	
	bug.add_to_group("bugs")
	call_deferred("add_child", bug)
	



func _on_Timer_timeout() -> void:
	var count_of_bugs = get_tree().get_nodes_in_group("bugs").size()
	if count_of_bugs == 0:
		#print('wave complete')
		stop_side_feed()
		attack_wave += 1
		new_attack_wave()
		emit_signal("wave_complete")
