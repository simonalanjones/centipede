class_name BugSegmentHead

extends BugSegmentBase

#signal side_feed_triggered
signal set_poisoned
signal unset_poisoned

var is_side_feed:bool = false # temporary permission until fully on screen
var is_poisoned:bool = false
var is_descending_as_poisoned:bool = false
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
	
#	if is_on_bottom_line() and has_side_feed_triggered == false:
#		has_side_feed_triggered = true
		#emit_signal("side_feed_triggered")
		
	if is_side_feed == true:
		if position.x > 6 and horizontal_direction == Directions.RIGHT:
			is_side_feed = false
		if position.x < 231 and horizontal_direction == Directions.LEFT:
			is_side_feed = false
			
	if check_for_poisoned_mushroom() == true and is_poisoned == false:
		is_poisoned = true
		is_descending_as_poisoned = true
		emit_signal("set_poisoned") # sends signal back to parent bug
		make_poisoned_animation()
	
	
		
func get_move_vector() -> Vector2:
	if is_moving_horizontally == true:
		return movement_vectors[horizontal_direction]
	elif is_moving_vertically == true:
		return movement_vectors[vertical_direction]
	else:
		print('nothing to return!')
		return Vector2.ZERO	


func set_direction_vars() -> void:
	if is_at_screen_edge() and is_off_screen() == false and is_side_feed == false and is_poisoned == false:
				
		if is_on_bottom_line() and vertical_direction == Directions.DOWN:
			vertical_direction = Directions.UP
		
		# start of edge drop at edge of screen
		if is_moving_vertically == false:
			make_turn_animation(horizontal_direction)
			is_moving_vertically = true
			is_moving_horizontally = false
			
		else:
			# at bottom of edge drop - about to change direction
			if is_on_grid_boundary():
				is_moving_vertically = false
				is_moving_horizontally = true
			
				if position.x == 0:
					horizontal_direction = Directions.RIGHT
					
				elif position.x == 232:
					horizontal_direction = Directions.LEFT
					
					
	elif is_poisoned == true and is_on_grid_boundary():
		
		# grid aligned at top of poisoned mushroom
		if not is_on_bottom_line() and is_descending_as_poisoned == true:	
			vertical_direction = Directions.DOWN
			is_moving_vertically = true
			is_moving_horizontally = false
			
		# bottom of screen while travelling down	
		elif is_on_bottom_line() and is_moving_vertically == true:
			is_moving_horizontally = true
			is_moving_vertically = false
			horizontal_direction = Directions.LEFT if horizontal_direction == Directions.RIGHT else Directions.RIGHT
			is_descending_as_poisoned = false
			
		# bottom of screen horiz move to next square
		elif is_on_bottom_line() and is_moving_horizontally == true:
			vertical_direction = Directions.UP
			is_moving_horizontally = false
			is_moving_vertically = true
		else:
			horizontal_direction = Directions.LEFT if horizontal_direction == Directions.RIGHT else Directions.RIGHT
			is_moving_horizontally = true
			is_moving_vertically = false
			is_poisoned = false

		
					
	elif is_off_screen(): # sidefeed spawning in
		is_moving_vertically = false
		is_moving_horizontally = true

	elif is_on_grid_boundary() and is_off_screen() == false:
		
		# modify this - can only go as high as 6th level
		if is_at_top_of_retreat() and vertical_direction == Directions.UP and is_moving_horizontally == true:
			vertical_direction = Directions.DOWN 
				
		elif check_for_mushroom_collision() == true:
			make_turn_animation(horizontal_direction)
			horizontal_direction = Directions.LEFT if horizontal_direction == Directions.RIGHT else Directions.RIGHT
			is_moving_vertically = true
			is_moving_horizontally = false
			
		elif check_bug_collision() == true:
			
			horizontal_direction = Directions.LEFT if horizontal_direction == Directions.RIGHT else Directions.RIGHT
			
			if is_on_bottom_line():
				vertical_direction = Directions.UP
			is_moving_vertically = true
			is_moving_horizontally = false
			
			#make_turn_animation()
			
			
		else:
			# this happens if we hit screen edge or mushroom
			# which triggers a vertical descend
			if is_moving_vertically == true:
				is_moving_vertically = false
				is_moving_horizontally = true

				if position.x == 0:
					horizontal_direction = Directions.RIGHT
					make_turn_animation(Directions.RIGHT)
					
				elif position.x == 232:
					horizontal_direction = Directions.LEFT
					make_turn_animation(Directions.LEFT)
	


func _on_Sprite_animation_finished() -> void:
	if $Sprite.get_animation() == 'turn-fast':
		$Sprite.set_animation('default')
		$Sprite.frame = 0
		if horizontal_direction == Directions.LEFT:
			sprite.flip_h = false
			sprite.offset.x = 0
		else:
			sprite.flip_h = true
			sprite.offset.x = -1


func reset_poisoned_animation(horizontal_direction):
	$Sprite.set_animation('default')
	$Sprite.frame = 0
	if horizontal_direction == Directions.LEFT:
		sprite.flip_h = false
		sprite.offset.x = 0
	else:
		sprite.flip_h = true
		sprite.offset.x = -1


func make_poisoned_animation():
	$Sprite.offset.x = 0
	$Sprite.flip_v = false	
	$Sprite.set_animation('poisoned')
	$Sprite.frame = 0
	

func make_turn_animation(direction):
	if direction == Directions.LEFT:
		$Sprite.flip_h = false
	else:
		$Sprite.flip_h = true
		
	if vertical_direction == Directions.UP:
		$Sprite.flip_v = true
	else:
		$Sprite.flip_v = false
		
	$Sprite.set_animation('turn-fast')
	$Sprite.frame = 0


func ___flip_horizontal_direction():
	
	# get current horizontal direction
	if horizontal_direction == Directions.LEFT:
		sprite.flip_h = false
	else:
		sprite.flip_h = true
	$Sprite.set_animation('turn')
	$Sprite.frame = 0
		
	horizontal_direction = Directions.LEFT if horizontal_direction == Directions.RIGHT else Directions.RIGHT
	
	
