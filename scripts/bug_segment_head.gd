class_name BugSegmentHead

extends BugSegmentBase

var check_map_function: Reference
var previous_vars: Array = []


# this allows us to recall all the positional data at a previous position
# when we hit the head we want to push it back to previous segment position

## move this into base node so accessible to all
func save_vars_to_array():
	
	previous_vars.push_front({
		'position' : position,
		'horizontal_direction' : horizontal_direction,
		'vertical_direction' : vertical_direction,
		'is_moving_horizontally' : is_moving_horizontally,
		'is_moving_vertically' : is_moving_vertically
		})
		
	# keep the array trimmed by removing off the back
	if previous_vars.size() > 32:
		previous_vars.pop_back()
		
	
	
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
		
	
		
func flip_horizontal_direction():
	horizontal_direction = Directions.LEFT if horizontal_direction == Directions.RIGHT else Directions.RIGHT
		
func check_mushroom_map(screen_position: Vector2) -> bool:
	return true if check_map_function.call_func(screen_position) != -1 else false
	
	
func check_for_mushroom_collision() -> bool:
	if horizontal_direction == Directions.LEFT:
		return check_mushroom_map(position + (Vector2.LEFT*8))
	elif horizontal_direction == Directions.RIGHT:
		return check_mushroom_map(position + (Vector2.RIGHT*8))
	else:
		return false
		

func move():	
	if can_move == true:# or Input.is_action_just_released("ui_end"):
		set_direction_vars()
		var velocity = get_move_vector() * speed
		position += velocity
		save_vars_to_array()
	
		

func get_move_vector() -> Vector2:
	if is_moving_horizontally == true:
		return movement_vectors[horizontal_direction]
	elif is_moving_vertically == true:
		return movement_vectors[vertical_direction]
	else:
		print('ERROR!! - no direction set in head')
		return Vector2.ZERO	
		
		
func set_direction_vars():
	
	if is_at_screen_edge():
				
		if is_on_bottom_line() and vertical_direction == Directions.DOWN:
			vertical_direction = Directions.UP
		
		
		if is_moving_vertically == false:
			
			is_moving_vertically = true
			is_moving_horizontally = false
			
	#		if position.x == 0:
	#			horizontal_direction = Directions.RIGHT
	#		elif position.x == 232:
	#			horizontal_direction = Directions.LEFT
	##		else:
	#			print('error at screen edge - position:' + str(position))
			
		else:
			if is_on_grid_boundary():
				is_moving_vertically = false			
				#print('got here at position:' + str(position))
				is_moving_horizontally = true

				if position.x == 0:
					horizontal_direction = Directions.RIGHT
				elif position.x == 232:
					horizontal_direction = Directions.LEFT
				
				
				
	elif is_on_grid_boundary():
		
		if is_within_outfield() and vertical_direction == Directions.UP and is_moving_horizontally == true:
			vertical_direction = Directions.DOWN 
				
		elif check_for_mushroom_collision() == true:
			horizontal_direction = Directions.LEFT if horizontal_direction == Directions.RIGHT else Directions.RIGHT
			is_moving_vertically = true
			is_moving_horizontally = false
		
		else:
			if is_moving_vertically == true:
				is_moving_vertically = false
				is_moving_horizontally = true
				
				if position.x == 0:
					horizontal_direction = Directions.RIGHT
				elif position.x == 232:
					horizontal_direction = Directions.LEFT
				
	


func __on_Area2D_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and event.pressed:
			print("head clicked (" + str(get_index()) + ")")
			print("is_moving_vertically: " + str(is_moving_vertically))
			print("is_moving_horizontally: " + str(is_moving_horizontally))
			print("horizontal_direction: " + str(horizontal_direction))
			print("vertical_direction: " + str(vertical_direction))
			print("is_on_grid_boundary: " + str(is_on_grid_boundary()))
			print("is_at_screen_edge: " + str(is_at_screen_edge()))
			
			print("position: " + str(position))
			print("-------------------")
			
		
