class_name BugSegmentHead

extends BugSegmentBase

signal side_feed_triggered
var has_side_feed_triggered:bool = false

var check_map_function: Reference
var previous_vars: Array = []
var is_side_feed:bool = false

# this allows us to recall all the positional data at a previous position
# when we hit the head we want to push it back to previous segment position

func save_vars_to_array():
	
	previous_vars.push_front({
		'position' : position,
		'horizontal_direction' : horizontal_direction,
		'vertical_direction' : vertical_direction,
		'is_moving_horizontally' : is_moving_horizontally,
		'is_moving_vertically' : is_moving_vertically
		})
		
	# keep the array trimmed by removing off the back
	#if previous_vars.size() > 32:
	#	previous_vars.pop_back()
		
	
	
func get_data_at_position(position_required: Vector2) -> Dictionary:
	for element in previous_vars:
		if element.position == Vector2(position_required):
			return element
			
	# if we haven't yet logged the position, use current data
	return {
		'position' : position,
		'vertical_direction' : vertical_direction,
		'is_moving_vertically' : is_moving_vertically,
		'is_moving_horizontally' : is_moving_horizontally,
		'horizontal_direction' : horizontal_direction	
	}
		
	
func check_mushroom_map(screen_position: Vector2) -> bool:
	return true if check_map_function.call_func(screen_position) != -1 else false
	
	
func check_for_mushroom_collision() -> bool:
	if horizontal_direction == Directions.LEFT:
		return check_mushroom_map(position + (Vector2.LEFT*8))
	elif horizontal_direction == Directions.RIGHT:
		return check_mushroom_map(position + (Vector2.RIGHT*8))
	else:
		return false
		
# check if this bug head collides with another in opposite direction
func check_bug_collision() -> bool:
	#if horizontal_direction == Directions.LEFT and $RayCastLeft.is_colliding():
	if is_moving_left() and $RayCastLeft.is_colliding():
		#print($RayCastLeft.get_collider().get_parent().get_instance_id())
		#print(get_parent().get_instance_id())
		#print('left collide')	
		
		return $RayCastLeft.get_collider() is BugSegmentBase

			#print('collided moving left:' + str(get_parent().get_index()))
			#return $RayCastLeft.get_collider().is_moving_right()
			#return $RayCastLeft.get_collider().position.x 
				
	elif is_moving_right() and $RayCastRight.is_colliding():
		#print($RayCastRight.get_collider().get_parent().get_instance_id())
		#print(get_parent().get_instance_id())
		#print('right collide')
		#print('---------')
		return $RayCastRight.get_collider() is BugSegmentBase

			#print('collided moving right:' + str(get_parent().get_index()))
			#return $RayCastRight.get_collider().is_moving_left()	
	return false
		
	

func move():
	if can_move == true:# or Input.is_action_just_released("ui_end"):
		
		#if is_on_vertical_boundary() == false and  is_on_horizontal_boundary() == false:
		#	print('bug off alignment')
		#	get_parent().stop_bug()
			
			
		
		set_direction_vars()
		position += get_move_vector() * get_speed()
		save_vars_to_array()
		
		if is_on_bottom_line() and has_side_feed_triggered == false:
			has_side_feed_triggered = true
			emit_signal("side_feed_triggered")
			
		
		if is_side_feed == true:	
			if position.x > 6 and horizontal_direction == Directions.RIGHT:
				is_side_feed = false		
			if position.x < 231 and horizontal_direction == Directions.LEFT:
				is_side_feed = false	

		
		
func get_move_vector() -> Vector2:
	if is_moving_horizontally == true:
		return movement_vectors[horizontal_direction]
	elif is_moving_vertically == true:
		return movement_vectors[vertical_direction]
	else:
		#get_parent().stop_bug()
		#print('ERROR!! - no direction set in head:' + str(get_instance_id()))
		return Vector2.ZERO	
		
		
func set_direction_vars() -> void:
		
	# when side spawn goes from -8 to 0 it will trigger this
	# and drop down
	# extra var to hold side feed state: has_just_side_spawned
		
	if is_at_screen_edge() and is_off_screen() == false and is_side_feed == false:
				
		if is_on_bottom_line() and vertical_direction == Directions.DOWN:
			vertical_direction = Directions.UP
		
		if is_moving_vertically == false:
			is_moving_vertically = true
			is_moving_horizontally = false
			
		else:
			if is_on_grid_boundary():
				is_moving_vertically = false
				is_moving_horizontally = true

				if position.x == 0:
					horizontal_direction = Directions.RIGHT
				elif position.x == 232:
					horizontal_direction = Directions.LEFT
				
				
	elif is_off_screen():
		is_moving_vertically = false
		is_moving_horizontally = true

				
	elif is_on_grid_boundary() and is_off_screen() == false:
		
		if is_within_outfield() and vertical_direction == Directions.UP and is_moving_horizontally == true:
			vertical_direction = Directions.DOWN 
				
		elif check_for_mushroom_collision() == true:
			horizontal_direction = Directions.LEFT if horizontal_direction == Directions.RIGHT else Directions.RIGHT
			is_moving_vertically = true
			is_moving_horizontally = false
			
		elif check_bug_collision() == true:
			horizontal_direction = Directions.LEFT if horizontal_direction == Directions.RIGHT else Directions.RIGHT
			
			if is_on_bottom_line():
				vertical_direction = Directions.UP
			is_moving_vertically = true
			is_moving_horizontally = false
			#print('switched to vertical move:' + str(vertical_direction))
			
		else:
			# this happens if we hit screen edge or mushroom
			# which triggers a vertical descend
			# we might hit the head and reposition in a way that
			# doesnt correspond with this logic
			#
			# should we look at setting head vars in a way that matches this here
			if is_moving_vertically == true:
				is_moving_vertically = false
				is_moving_horizontally = true
				
				if position.x == 0:
					horizontal_direction = Directions.RIGHT
				elif position.x == 232:
					horizontal_direction = Directions.LEFT
	


func _on_Area2D_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and event.pressed:
			print("head clicked - index (" + str(get_index()) + ")")
			print("is_side_feed: " + str(is_side_feed))
			print("is_moving_vertically: " + str(is_moving_vertically))
			print("is_moving_horizontally: " + str(is_moving_horizontally))
			print("horizontal_direction: " + str(horizontal_direction))
			print("vertical_direction: " + str(vertical_direction))
			print("is_on_grid_boundary: " + str(is_on_grid_boundary()))
			print("is_at_screen_edge: " + str(is_at_screen_edge()))
			
			
			print("position: " + str(position))
			get_parent().print_tree_pretty()
			print("-------------------")
			
		
