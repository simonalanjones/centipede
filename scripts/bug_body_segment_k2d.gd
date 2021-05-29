extends BugBaseSegment

#const CLASS_NAME = "Segment"

var last_vector_move: int  # move direction to target u/d/l/r

var has_reached_target:bool = false setget ,has_reached_target_position
var target_position: Vector2 setget set_target_position, get_target_position
var start_position: Vector2


func _ready() -> void:
	start_position = position
	$Label.set_text(str(get_index()))


func _to_string() -> String:
	return "Bug body segment"	
	
	
func move_to_target_position():
	position = target_position
	return position


func move_to_start_position():
	position = start_position
	print('start pos:' + str(start_position))
	return position

	
func set_target_position(new_position: Vector2) -> void:
	start_position = position
	target_position = new_position
	
	if target_position.x  > position.x:
		sprite.flip_h = true
	else:
		sprite.flip_h = false		
	
	var diff:Vector2 = target_position - position
		
	# animation
	if diff.x == 0 and abs(diff.y) == 8:
		sprite.play("down")
	else:
		sprite.play("default")
				
	if diff.x > 0:
		horizontal_direction = Directions.RIGHT
	elif diff.x < 0:
		horizontal_direction = Directions.LEFT
		
	#print('setting init to' + str(last_horizontal_direction))	
	has_reached_target = false
	
	
func get_target_position() -> Vector2:
	return target_position
	

func has_reached_target_position() -> bool:
	return has_reached_target


func _physics_process(_delta: float) -> void:
	if position != target_position:
		if can_move == true and cycles >= cycles_limit:	
			cycles = 0
			#if has_reached_target == false:
			var move_direction = get_move_direction()
			
			if move_direction in [Directions.LEFT, Directions.RIGHT, Directions.UP, Directions.DOWN]:
				# store this for future reference in creating a new bug
				# we'll need an initial direction for the head
				last_vector_move = move_direction
				#print(last_vector_move)
				
			if move_direction in [Directions.LEFT, Directions.RIGHT]:
				# store last horizontal direction for future use
				# head will need to refer to if travelling vertically
				horizontal_direction = move_direction
				
			var velocity = movement_vectors[move_direction] * speed
			var collision = move_and_collide(velocity)
			if collision:
				print('body segment collided')
				print(collision.collider.get_class())
				if collision.collider is PlayerShot:
					hit()
					print('was hit by player shot')
					print('-----')
				
			if position == target_position and has_reached_target == false:
				has_reached_target = true
		else:
			cycles += 1
	
	
func get_move_direction():
		
	var diff: Vector2 = target_position - position
				
	if diff.x > 0:
		return Directions.RIGHT
	elif diff.x < 0:
		return Directions.LEFT
	elif diff.y > 0:
		return Directions.DOWN
	elif diff.y < 0:
		return Directions.UP
	else:
		print('index:' + str(get_index()) + ' ERROR')

