extends BugSegmentBase

var check_map_function: Reference


func _ready() -> void:
	#is_moving_horizontally = true
	pass
	
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
	if can_move == true or Input.is_action_just_released("ui_end"):
		set_direction_vars()
		var velocity = get_move_vector() * speed
		position += velocity
	
		

func get_move_vector() -> Vector2:
	if is_moving_horizontally == true:
		return movement_vectors[horizontal_direction]
	elif is_moving_vertically == true:
		return movement_vectors[vertical_direction]
	else:
		print('ERROR!! - no direction set in head')
		return Vector2.ZERO	
		
		
func set_direction_vars():


	## what direction vars to use after head set up not on boundary but yes - screen edge
	## why does it move one pixel right
	
	if is_at_screen_edge():
				
		if is_on_bottom_line() and vertical_direction == Directions.DOWN:
			vertical_direction = Directions.UP
		
		
		if is_moving_vertically == false:
			
			is_moving_vertically = true
			is_moving_horizontally = false
			
			if position.x == 0:
				horizontal_direction = Directions.RIGHT
			elif position.x == 232:
				horizontal_direction = Directions.LEFT
			else:
				print('error at screen edge - position:' + str(position))
			
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
			#print('here changes')
			if is_moving_vertically == true:
				is_moving_vertically = false
				is_moving_horizontally = true
				
				if position.x == 0:
					horizontal_direction = Directions.RIGHT
				elif position.x == 232:
					horizontal_direction = Directions.LEFT
				
	


func _on_Area2D_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
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
			
		
