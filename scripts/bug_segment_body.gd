class_name BugSegmentBody

extends BugSegmentBase

var has_reached_target:bool = false setget ,has_reached_target_position
var target_position: Vector2 setget set_target_position, get_target_position
var target_is_moving_horizontally: bool
var target_is_moving_vertically: bool
var start_position: Vector2
var points_awarded:int = 10

var direction_right = 	{
		'horizontal_direction': Directions.RIGHT,
		'is_moving_horizontally': true,
		'is_moving_vertically': false
	}
	
var direction_left = {
		'horizontal_direction': Directions.LEFT,
		'is_moving_horizontally': true,
		'is_moving_vertically': false
	}
	
var direction_down = {
		'vertical_direction': Directions.DOWN,
		'is_moving_vertically': true,
		'is_moving_horizontally': false
	}
	
var direction_up = {
		'vertical_direction': Directions.UP,
		'is_moving_vertically': true,
		'is_moving_horizontally': false
	}


func _ready() -> void:
	start_position = position


func move() -> void:	
	var move_vector: Vector2 = Vector2.ZERO
	if is_moving_horizontally:
		move_vector = movement_vectors[horizontal_direction]
	elif is_moving_vertically:
		move_vector = movement_vectors[vertical_direction]
		
	var velocity = move_vector * get_speed()
	position += velocity
		

func set_direction(direction_vars: Dictionary) -> void:
	if direction_vars.is_moving_horizontally == true:
		horizontal_direction = direction_vars.horizontal_direction
	else:
		vertical_direction = direction_vars.vertical_direction
		
	is_moving_horizontally = direction_vars.is_moving_horizontally
	is_moving_vertically = direction_vars.is_moving_vertically
	has_reached_target = false
	

func set_direction_vars() -> void:
	var diff:Vector2 = target_position - position
	
	## target node position: right and below
	if diff.x > 0 and diff.y > 0:
		if target_is_moving_vertically:
			set_direction(direction_right)
		else:
			set_direction(direction_down)
			
	# target node position: left and below		
	elif diff.x < 0 and diff.y > 0:
		if target_is_moving_vertically:
			set_direction(direction_left)
		else:
			set_direction(direction_down)

	## target node position: right and above
	elif diff.x > 0 and diff.y < 0:
		set_direction(direction_right)
	
	## target node position: left and above		
	elif diff.x < 0 and diff.y < 0:
		set_direction(direction_left)
		
	## target node position: directly above
	elif diff.x == 0 and diff.y < 0:
		set_direction(direction_up)

	## target node position: directly below
	elif diff.x == 0 and diff.y > 0:
		set_direction(direction_down)

	## target node position: right
	elif diff.y == 0 and diff.x > 0:
		set_direction(direction_right)
		
	## target node position: left
	elif diff.y == 0 and diff.x < 0:
		set_direction(direction_left)
		

func has_reached_target_position() -> bool:
	return position == target_position
	
		
func get_target_position() -> Vector2:
	return target_position
	
	
func set_target_data(target_dict) -> void:
	start_position = position
	target_position = target_dict.target_position
	target_is_moving_horizontally = target_dict.is_moving_horizontally
	target_is_moving_vertically = target_dict.is_moving_vertically
	set_direction_vars()
	
	
func set_target_position(new_position: Vector2) -> void:
	start_position = position
	target_position = new_position
	set_direction_vars()
