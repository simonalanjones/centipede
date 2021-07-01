class_name BugSegmentBody

extends BugSegmentBase

var has_reached_target:bool = false setget ,has_reached_target_position
var target_position: Vector2 setget set_target_position, get_target_position
var target_is_moving_horizontally: bool
var target_is_moving_vertically: bool
var start_position: Vector2
var points_awarded:int = 10
var is_poisoned:bool = false

var trapped = 0

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



func set_poisoned(state: bool):
	is_poisoned = state   
	

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
		#print('rb')
			
			
	# target node position: left and below		
	elif diff.x < 0 and diff.y > 0:
		if target_is_moving_vertically:
			set_direction(direction_left)
		else:
			set_direction(direction_down)
		#print('lb')


	## target node position: right and above
	elif diff.x > 0 and diff.y < 0:
		#print('ra')
		if target_is_moving_vertically:
			set_direction(direction_right)
		else:
			set_direction(direction_up)
		
	## target node position: left and above		
	elif diff.x < 0 and diff.y < 0:
		#print('lb')
		if target_is_moving_vertically:
			set_direction(direction_left)
		else:
			set_direction(direction_up)
	
	
	## target node position: directly above
	elif diff.x == 0 and diff.y < 0:
		#print('da')
		set_direction(direction_up)
		
		if is_poisoned == false:
			make_turn_animation()
		else:
			set_poisoned_animation()
			

	## target node position: directly below
	elif diff.x == 0 and diff.y > 0:
		#print('db')
		set_direction(direction_down)
		if is_poisoned == false:
			make_turn_animation()
		else:
			set_poisoned_animation()	

	## target node position: right
	elif diff.y == 0 and diff.x > 0:
		#print('r')
		set_direction(direction_right)
		
	## target node position: left
	elif diff.y == 0 and diff.x < 0:
		#print('l')
		set_direction(direction_left)
		
	else:
		print('WTF...')
		print(target_position)
		print(position)
		print(diff.y)
		print(diff.x)
		print('size of this bug:' + str(get_parent().get_child_count()))
		print('my index:' + str(get_index()))
		get_parent().modulate.a = 0.5
		print('-------')
		
		
func has_reached_target_position() -> bool:
	return position == target_position
	
		
func get_target_position() -> Vector2:
	return target_position
	

# this is called by bug when bug head is on grid boundary
# every time head reaches boundary, body segments are set their new positions	
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


func make_turn_animation():
	if horizontal_direction == Directions.LEFT:
		$Sprite.flip_h = false
	else:
		$Sprite.flip_h = true
		
	if vertical_direction == Directions.UP:
		$Sprite.flip_v = true
		
	else:
		$Sprite.flip_v = false
			
	$Sprite.set_animation('turn-fast')
	$Sprite.frame = 0


func set_poisoned_animation():
	$Sprite.set_animation('down')
	$Sprite.frame = 0

	

func _on_Sprite_animation_finished() -> void:
	if $Sprite.get_animation() == 'turn-fast':
		$Sprite.set_animation('default')
		$Sprite.frame = 0
		
		if horizontal_direction == Directions.LEFT:
			sprite.flip_h = false
		else:
			sprite.flip_h = true

