class_name BugSegmentBody

extends BugSegmentBase


var has_reached_target:bool = false setget ,has_reached_target_position
var target_position: Vector2 setget set_target_position, get_target_position

var target_is_moving_horizontally: bool
var target_is_moving_vertically: bool

var start_position: Vector2


func _ready() -> void:
	start_position = position

func move():
	if can_move == true: #or Input.is_action_just_released("ui_accept"):
		var velocity = get_move_vector() * speed
		position += velocity
		

func get_move_vector() -> Vector2:
	
	if is_moving_horizontally == true:
		return movement_vectors[horizontal_direction]
	elif is_moving_vertically == true:
		return movement_vectors[vertical_direction]
	else:
		print('ERROR!! - no direction set in body')
		return Vector2.ZERO	



func set_direction_vars():
	
	var diff:Vector2 = target_position - position
	#print('diff between target and current:' + str(diff))
	
	## target node position: right and below
	if diff.x > 0 and diff.y > 0:
		
		if target_is_moving_vertically:
			#print('1')
			# pack this into a sub function
			horizontal_direction = Directions.RIGHT
			is_moving_horizontally = true
			is_moving_vertically = false
			has_reached_target = false
		else:
			#print('2')
			vertical_direction = Directions.DOWN
			is_moving_vertically = true
			is_moving_horizontally = false
			has_reached_target = false
			
	
	## target node position: left and below		
	elif diff.x < 0 and diff.y > 0:
		#print('3')
		if target_is_moving_vertically:
			horizontal_direction = Directions.LEFT
			is_moving_horizontally = true
			is_moving_vertically = false
			has_reached_target = false	
		else:
			#print('4')
			vertical_direction = Directions.DOWN
			is_moving_vertically = true
			is_moving_horizontally = false
			has_reached_target = false

		
	## target node position: right and above
	elif diff.x > 0 and diff.y < 0:
		#print('5')
		horizontal_direction = Directions.RIGHT
		is_moving_horizontally = true
		is_moving_vertically = false
		has_reached_target = false
	
	## target node position: left and above		
	elif diff.x < 0 and diff.y < 0:
		#print('6')
		horizontal_direction = Directions.LEFT
		is_moving_horizontally = true
		is_moving_vertically = false
		has_reached_target = false	
		
		
		
		
	## level with target node in the x axis	but target node above
	## target node position: directly above
	elif diff.x == 0 and diff.y < 0:
		#print('7')
		vertical_direction = Directions.UP
		is_moving_vertically = true
		is_moving_horizontally = false
		has_reached_target = false

	## target node position: directly below
	elif diff.x == 0 and diff.y > 0:
		#print('8')
		vertical_direction = Directions.DOWN
		is_moving_vertically = true
		is_moving_horizontally = false
		has_reached_target = false
				
	
						
	## level with target node in the y axis but target node right
	## target node position: right
	elif diff.y == 0 and diff.x > 0:
		#print('9')
		horizontal_direction = Directions.RIGHT
		is_moving_horizontally = true
		is_moving_vertically = false
		has_reached_target = false
		
		
	## level with target node in the y axis but target node left	
	## target node position: left
	elif diff.y == 0 and diff.x < 0:
		#print('10')
		horizontal_direction = Directions.LEFT
		is_moving_horizontally = true
		is_moving_vertically = false
		has_reached_target = false
		
	
		
	
	else:
		print('what?')
		
		print('position:' + str(position))
		print('target position:' + str(target_position))
		print("diff:" + str(diff))
		print("is moving horizontally:" + str(is_moving_horizontally))
		print("is moving vertically:" + str(is_moving_vertically))
		print("horizontal dir:" + str(horizontal_direction))
		print("vertical dir:" + str(vertical_direction))
		print("has reached target:" + str(has_reached_target))
		print('--------------------')
		
		has_reached_target = true



			

func has_reached_target_position() -> bool:
	return position == target_position
	
		
func get_target_position() -> Vector2:
	return target_position
	
	
func set_target_data(target_dict):
	#print(target_dict)
	start_position = position
	target_position = target_dict.target_position
	target_is_moving_horizontally = target_dict.is_moving_horizontally
	target_is_moving_vertically = target_dict.is_moving_vertically
	set_direction_vars()
	
	
	
# func set_target_position(target_position: Vector2, target_node_direction: Vector2)
func set_target_position(new_position: Vector2) -> void:
	#print(position)
	#print(new_position)
	#print('-----')
	start_position = position
	target_position = new_position
	set_direction_vars()
		
	


func __on_Area2D_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and event.pressed:
			print("body clicked (" + str(get_index()) + ")")
			print("is_moving_vertically: " + str(is_moving_vertically))
			print("is_moving_horizontally: " + str(is_moving_horizontally))
			print("horizontal_direction: " + str(horizontal_direction))
			print("vertical_direction: " + str(vertical_direction))
			print("-------------------")

