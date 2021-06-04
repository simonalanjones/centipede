extends BugBaseSegment

#signal side_feed_triggered
var previous_vars: Array = []

"""
array hold:
* position
* vertical_direction
* is_moving_vertically
* is_moving_horizontally
* horizontal_direction (from bug_base)
"""


var side_feed_triggered: bool = false

# is the centipede in a overall downwards or upwards movement
var vertical_direction: int = Directions.DOWN
var is_moving_vertically:bool = false
var is_moving_horizontally:bool = true


var check_map_function: Reference

var raycast_suspended:bool = false
onready var previous_boundary_position: Vector2 = position


#func _ready():
#	save_vars_to_array()
	
	
func save_vars_to_array():
	previous_vars.push_front({
		'position' : position,
		'vertical_direction' : vertical_direction,
		'is_moving_vertically' : is_moving_vertically,
		'is_moving_horizontally' : is_moving_horizontally,
		'horizontal_direction' : horizontal_direction
		})
	
	
func clear_previous_vars():
	previous_vars = []
	
	
func _to_string() -> String:
	return "Bug head segment"	


func move_to_next_boundary():
	while not is_on_grid_boundary():
		set_direction_vars()
		var velocity = get_move_vector() * speed
		position += velocity
	return position
	
	
func move_to_previous_boundary():
	position = previous_boundary_position
	return position
	
		

func is_moving_left() -> int:
	return horizontal_direction == Directions.LEFT and is_moving_horizontally == true
	
	
func is_moving_right() -> int:
	return horizontal_direction == Directions.RIGHT	and is_moving_horizontally == true
	
	
func is_moving_up() -> bool:
	return is_moving_vertically and vertical_direction == Directions.UP

	
func is_moving_down() -> bool:
	return is_moving_vertically and vertical_direction == Directions.DOWN
		
	
func is_on_grid_boundary() -> bool:
	return int(position.x) % 8 == 0 and int(position.y) % 8 == 0
	

func is_at_screen_edge() -> bool:
	return position.x >= 232 or position.x <= 0


func is_on_bottom_line() -> bool:
	return position.y >= 248


func is_within_outfield() -> bool:
	return position.y <= 152

		
func is_within_infield() -> bool:
	return position.y >= 160
	
	
func set_horizontal_direction(set_direction:int) -> void:
	if set_direction in [ Directions.LEFT, Directions.RIGHT ]:
		horizontal_direction = set_direction
	else:
		print('error setting inital direction')
		

func check_mushroom_map(screen_position: Vector2) -> bool:
	return true if check_map_function.call_func(screen_position) != -1 else false
		
		
func check_for_mushroom_collision() -> bool:
	if horizontal_direction == Directions.LEFT:
		return check_mushroom_map(position + (Vector2.LEFT*8))
	elif horizontal_direction == Directions.RIGHT:
		return check_mushroom_map(position + (Vector2.RIGHT*8))
	else:
		return false


func suspend_raycast():
	#print('suspended raycast')
	raycast_suspended = false
	
	
#func _physics_process(_delta: float) -> void:
func move():	
	get_node("/root/root/is_moving_vertically").set_text(str(is_moving_vertically))
	get_node("/root/root/is_moving_horizontally").set_text(str(is_moving_horizontally))
	get_node("/root/root/is_on_grid_boundary").set_text(str(is_on_grid_boundary()))
	get_node("/root/root/is_at_screen_edge").set_text(str(is_at_screen_edge()))
	#get_node("/root/root/has_moved_all_body").set_text(str(get_parent().has_moved_all_body_segments()))
	get_node("/root/root/head_pos").set_text(str(position))

	
	if can_move == true: #and cycles >= cycles_limit:
		set_direction_vars()
		save_vars_to_array()
		#cycles = 0
		var velocity = get_move_vector() * speed
		position += velocity
		
	#else:
	#	cycles += 1


func set_direction_vars() -> void:
	
	if is_at_screen_edge() or is_on_grid_boundary():
		pass
		# if size of previous_vars >= 16
		# remove back 8
		#
		#print(previous_vars)
		#print(previous_vars.size())
		#clear_previous_vars()
		#print('-----')
	
	if is_at_screen_edge():
				
		if is_on_bottom_line() and vertical_direction == Directions.DOWN:
			#print('here..')
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
				#print('at boundary:' + str(position))
				is_moving_vertically = false
				is_moving_horizontally = true
			
		
	
	elif is_on_grid_boundary():
		
		#if $RayCastUp.is_colliding():
		#	if $RayCastUp.get_collider().get_parent() != get_parent():
		#		print('raycast up colliding')

		#if $RayCastDown.is_colliding():
		#	if $RayCastDown.get_collider().get_parent() != get_parent():
		#		print('raycast down colliding')
						
		previous_boundary_position = position
		raycast_suspended = false
		
		if is_within_outfield() and vertical_direction == Directions.UP and is_moving_horizontally == true:
			vertical_direction = Directions.DOWN 
		
		# check raycasts
		#elif is_moving_left() and $RayCastLeft.is_colliding() and $RayCastLeft.get_collider().get_parent() != get_parent():
		#		print('ray left collision')
		#		print('parent:' + str(get_parent().get_instance_id()))
		#		print('collider parent:' + str($RayCastLeft.get_collider().get_parent().get_instance_id()))
		#		print('-----')
		#		is_moving_vertically = true
		#		if is_on_bottom_line():
		#			vertical_direction = Directions.UP
		#		is_moving_horizontally = false
		#		horizontal_direction = Directions.LEFT if horizontal_direction == Directions.RIGHT else Directions.RIGHT
				#$RayCastLeft.get_collider().suspend_raycast()
			
		#elif is_moving_right() and $RayCastRight.is_colliding() and $RayCastRight.get_collider().get_parent() != get_parent():
		#		print('ray right collision')
		#		#print($RayCastRight.get_collider().get_parent())
		#		print('parent:' + str(get_parent().get_instance_id()))
		#		print('collider parent:' + str($RayCastRight.get_collider().get_parent().get_instance_id()))
		#		print('-----')
		#		is_moving_vertically = true
		#		if is_on_bottom_line():
		#			vertical_direction = Directions.UP
		#		is_moving_horizontally = false
		#		horizontal_direction = Directions.LEFT if horizontal_direction == Directions.RIGHT else Directions.RIGHT
				#$RayCastRight.get_collider().suspend_raycast()
		
		elif check_for_mushroom_collision() == true:
			#print('mush...')
			horizontal_direction = Directions.LEFT if horizontal_direction == Directions.RIGHT else Directions.RIGHT
			set_ortientation()
			is_moving_vertically = true
			is_moving_horizontally = false
		
		else:
			
			if is_moving_vertically == true:
				is_moving_vertically = false
				is_moving_horizontally = true
				
		
	
func __set_direction_vars() -> void:
	#
	# if at screen edge we need to change direction etc
	#
	#if not is_at_screen_edge():
	#	screen_edge_flag = false

	# no movement defined - this is at start and after shooting segment head/body
	if is_moving_horizontally != true and is_moving_vertically != true:
		print('came in at top')
		if check_for_mushroom_collision() == true:
			#print('mush...')
			horizontal_direction = Directions.LEFT if horizontal_direction == Directions.RIGHT else Directions.RIGHT
			set_ortientation()
			is_moving_vertically = true
			is_moving_horizontally = false
			return 

		elif is_at_screen_edge():
			print('1st at screen edge...')
			if position.x >= 232:
				print('r')
				horizontal_direction = Directions.LEFT
				is_moving_vertically = true
				set_ortientation()
				return
				
			elif position.x <= 0:
				print('l')
				horizontal_direction = Directions.RIGHT
				is_moving_vertically = true
				set_ortientation()
				return
			else:
				print('this shouldnt happen')	
				
		else:
			if not horizontal_direction in [ Directions.LEFT, Directions.RIGHT ]:
				print('no direction information set')
				return
			else:
				print('hello')
				is_moving_horizontally = true
				return
		
			
	if is_at_screen_edge():
		print('2nd at screen edge')	
			
		if is_on_bottom_line() and vertical_direction == Directions.DOWN:
			print('got to bottom line rule')
			vertical_direction = Directions.UP
			is_moving_vertically = true
			is_moving_horizontally = false
			return

		
		# first cycle at screen edge
		if is_moving_horizontally == true: #  and screen_edge_flag == false:

			#screen_edge_flag = true
			# repeat flipping of direction 
			horizontal_direction = Directions.LEFT if horizontal_direction == Directions.RIGHT else Directions.RIGHT
			set_ortientation()
			is_moving_vertically = true
			is_moving_horizontally = false
			return
			
			
		else:
			# clear flag here
			#screen_edge_flag = false
			# subsequent cycles at screen edge
			if is_on_grid_boundary():
				print('on grid boundary..')
				is_moving_vertically = false
				is_moving_horizontally = true
				
				if position.x == 232:
					horizontal_direction = Directions.LEFT
				elif position.x == 0:
					horizontal_direction = Directions.RIGHT
				else:
					print('error at screen edge but no idea which side')
				return
	
	#			
	# if on grid boundary we check for mushroom collisions
	#
	if is_on_grid_boundary() and not is_at_screen_edge():
		
		if is_within_outfield() and vertical_direction == Directions.UP:
			vertical_direction = Directions.DOWN
			return
					
		if check_for_mushroom_collision() == true:
			horizontal_direction = Directions.LEFT if horizontal_direction == Directions.RIGHT else Directions.RIGHT
			set_ortientation()
			is_moving_vertically = true
			is_moving_horizontally = false
			
		elif is_moving_vertically == true:
			is_moving_vertically = false
			is_moving_horizontally = true
		
		else:
			is_moving_horizontally = true
			

	else:
		pass
		# default - none of the above true
		#print('here')
	#	is_moving_horizontally = true



func get_move_vector() -> Vector2:

	if is_moving_horizontally == true:
		return movement_vectors[horizontal_direction]
	elif is_moving_vertically == true:
		return movement_vectors[vertical_direction]
	else:
		print('ERROR!!')
		return Vector2.ZERO	

		

