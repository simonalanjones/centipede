class_name BugSegmentHead

extends BugSegmentBase

signal side_feed_triggered
var has_side_feed_triggered:bool = false
var is_side_feed:bool = false
var is_poisoned:bool = false
var points_awarded:int = 100


func tilemap_value(screen_position: Vector2) -> int:
	return Globals.tilemap_cell_value(screen_position) 
	
	
func check_for_mushroom_collision() -> bool:
	if horizontal_direction == Directions.LEFT:
		return true if int(tilemap_value(position + (Vector2.LEFT*8))) != -1 else false
	elif horizontal_direction == Directions.RIGHT:
		return true if int(tilemap_value(position + (Vector2.RIGHT*8))) != -1 else false
	else:
		return false


func check_for_poisoned_mushroom() -> bool:
	if horizontal_direction == Directions.LEFT:
		return true if int(tilemap_value(position + (Vector2.LEFT*8))) >= 4 else false
	elif horizontal_direction == Directions.RIGHT:
		return true if int(tilemap_value(position + (Vector2.RIGHT*8))) >= 4 else false
	else:
		return false	
		
		
# check if this bug head collides with another of a different parent
func check_bug_collision() -> bool:
	if is_moving_left() and $RayCastLeft.is_colliding():
		#var parent_id = get_parent().get_instance_id()
		if is_instance_valid($RayCastLeft.get_collider()):
			if $RayCastLeft.get_collider().position == position:
				return false
			else:
				return true
	elif is_moving_right() and $RayCastRight.is_colliding():
		if is_instance_valid($RayCastRight.get_collider()):
			if $RayCastRight.get_collider().position == position:
				return false
			else:
				return true
	return false
		

func move() -> void:
	set_direction_vars()
	position += get_move_vector() * get_speed()
	
	if is_on_bottom_line() and has_side_feed_triggered == false:
		has_side_feed_triggered = true
		emit_signal("side_feed_triggered")
		
	if is_side_feed == true:
		if position.x > 6 and horizontal_direction == Directions.RIGHT:
			is_side_feed = false
		if position.x < 231 and horizontal_direction == Directions.LEFT:
			is_side_feed = false
			
	if check_for_poisoned_mushroom() == true and is_poisoned == false:
		#vertical_direction = Directions.DOWN
		is_poisoned = true
				
				
func get_move_vector() -> Vector2:
	if is_moving_horizontally == true:
		return movement_vectors[horizontal_direction]
	elif is_moving_vertically == true:
		return movement_vectors[vertical_direction]
	else:
		return Vector2.ZERO	
		
		
func set_direction_vars() -> void:
	if is_at_screen_edge() and is_off_screen() == false and is_side_feed == false and is_poisoned == false:
				
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
					
	elif is_poisoned == true and is_on_grid_boundary():
		if is_on_bottom_line():
			vertical_direction = Directions.UP
			is_moving_vertically = true
			is_moving_horizontally = false
			horizontal_direction = Directions.LEFT if horizontal_direction == Directions.RIGHT else Directions.RIGHT
			is_poisoned = false
		else:
			vertical_direction = Directions.DOWN
			is_moving_vertically = true
			is_moving_horizontally = false
		
					
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
			
		else:
			# this happens if we hit screen edge or mushroom
			# which triggers a vertical descend
			if is_moving_vertically == true:
				is_moving_vertically = false
				is_moving_horizontally = true
				
				if position.x == 0:
					horizontal_direction = Directions.RIGHT
				elif position.x == 232:
					horizontal_direction = Directions.LEFT
	
