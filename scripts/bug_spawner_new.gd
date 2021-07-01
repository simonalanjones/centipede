class_name BugSpawner

extends Node

onready var bug_scene: PackedScene = preload("res://scenes/bug.tscn")
onready var bug_body_scene: PackedScene = preload("res://scenes/bug_segment_body.tscn")
onready var bug_head_scene: PackedScene = preload("res://scenes/bug_segment_head.tscn")


# return new bug based on start position from bug manager
func spawn_from_vector2_array(positions:Array, horizontal_direction:int, vertical_direction:int):
	
	var bug = bug_scene.instance()
	# move creation into bug itself??
	# bug.create_from_data(positions, h_direction, v_direction) 
	var bug_segment

	for n in range(0, positions.size()):
		if n == 0:
			bug_segment = bug_head_scene.instance()
			bug_segment.set_horizontal_direction(horizontal_direction)
			bug_segment.is_moving_horizontally = true
			bug_segment.connect('set_poisoned', bug, '_on_head_poisoned')
			bug_segment.connect('unset_poisoned', bug, '_on_head_clear_poisoned')
		else:
			bug_segment = bug_body_scene.instance()
		
		bug_segment.set_horizontal_direction(horizontal_direction)
		bug_segment.set_vertical_direction(vertical_direction)	
		# warning-ignore:return_value_discarded
		bug_segment.connect('segment_hit', bug, '_on_segment_hit')
		bug_segment.position = positions[n]
		bug.call_deferred("add_child", bug_segment)
			
	return bug


func spawn_from_body_segment_hit(body_segment:BugSegmentBody, bug:Bug):
	bug.modulate.a = 0.6
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
				new_head_segment.connect('set_poisoned', new_bug, '_on_head_poisoned')
				# warning-ignore:return_value_discarded
				new_head_segment.connect('unset_poisoned', new_bug, '_on_head_clear_poisoned')
				
				# warning-ignore:return_value_discarded
				new_head_segment.connect('segment_hit', new_bug, '_on_segment_hit')
				
				
				# warning-ignore:return_value_discarded
				new_bug.call_deferred("add_child", new_head_segment)
				has_spawned_head = true
			else:
				new_bug.call_deferred("add_child", bug_segment)
				# disconnect old signal from current bug and reconnect to new bug
				if bug_segment.is_connected('segment_hit', bug, '_on_segment_hit'):
					bug_segment.disconnect('segment_hit', bug, '_on_segment_hit')
					# warning-ignore:return_value_discarded
					bug_segment.connect('segment_hit', new_bug, '_on_segment_hit')
	body_segment.queue_free()
	return new_bug
				
