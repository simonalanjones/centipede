extends Area2D

signal segment_hit
signal side_feed_triggered

const CLASS_NAME = "Head"

enum Directions { UP, DOWN, LEFT, RIGHT }

var movement_vectors = [
	Vector2.UP,
	Vector2.DOWN,
	Vector2.LEFT,
	Vector2.RIGHT
]

var side_feed_triggered: bool = false

var direction: int = Directions.RIGHT
var last_direction: int = Directions.RIGHT

# is the centipede in a overall downwards or upwards movement
var main_direction: int = Directions.DOWN

var has_collided:bool = false
var speed_factor:int = 1

func _ready():
	var _a = connect('area_entered', self, '_on_area_entered')
	speed_factor = get_parent().get_speed_factor()


func get_class() -> String:
	return CLASS_NAME
	

func is_on_transit_line() -> bool:
	return int(position.y) % 8 == 0


func is_at_far_right_position() -> bool:
	return position.x >= 232


func is_at_far_left_position() -> bool:
	return position.x <= 0


func is_on_bottom_line() -> bool:
	return position.y >= 248


func is_within_outfield():
	return position.y <= 144

		
func is_within_infield():
	return position.y >= 152
	
	
func is_moving_left():
	return direction == Directions.LEFT
	
	
func is_moving_right():
	return direction == Directions.RIGHT
	
		
func set_initial_direction(set_direction:int) -> void:
	direction = set_direction
	last_direction = set_direction
		
		
func move_in_new_direction(new_direction: int) -> void:
	if new_direction in [ Directions.UP, Directions.DOWN, Directions.LEFT, Directions.RIGHT ]:
		last_direction = direction
		direction = new_direction
		has_collided = false
		position += movement_vectors[direction] * speed_factor
		get_node("Sprite").flip_h = false if direction in [ Directions.LEFT, Directions.DOWN ] else true
	else:
		print('error moving in new direction:' + str(new_direction))
		
	

func move_in_current_direction():
	position += movement_vectors[direction] * speed_factor
	
	if int(position.x) %8 == 0:
		if direction == Directions.LEFT and $RayCastLeft.is_colliding():
			has_collided = true
		elif direction == Directions.RIGHT and $RayCastRight.is_colliding():
			has_collided = true

	
func move():
	
	if position.y > 256:
		print('off screen')
		
	if is_on_bottom_line() and side_feed_triggered == false:
		side_feed_triggered = true
		emit_signal("side_feed_triggered")
		
		
	if has_collided == true and is_on_transit_line():
		
		if is_within_outfield() and main_direction == Directions.UP:
			main_direction = Directions.DOWN
			
		elif is_on_bottom_line() and main_direction == Directions.DOWN:
			main_direction = Directions.UP
		else:
			move_in_new_direction(main_direction)
		
		
	elif direction == Directions.LEFT:
		if is_at_far_left_position():
			
			if is_on_bottom_line() and main_direction == Directions.DOWN:
				main_direction = Directions.UP
				
			elif is_within_outfield() and main_direction == Directions.UP:
				main_direction = Directions.DOWN
			
			move_in_new_direction(main_direction)
		else:
			move_in_current_direction()
			
				
	elif direction == Directions.RIGHT:
		if is_at_far_right_position():
					
			if is_on_bottom_line() and main_direction == Directions.DOWN:
				main_direction = Directions.UP
			elif is_within_outfield() and main_direction == Directions.UP:
				main_direction = Directions.DOWN
	
			move_in_new_direction(main_direction)
		else:
			move_in_current_direction()
	
	
	elif direction == Directions.UP:
		if not is_on_transit_line():
			move_in_current_direction()
		else:
			move_in_new_direction(Directions.LEFT if last_direction == Directions.RIGHT else Directions.RIGHT) 
	
							
	elif direction == Directions.DOWN:
		if not is_on_transit_line():
			move_in_current_direction()
		else:
			move_in_new_direction(Directions.LEFT if last_direction == Directions.RIGHT else Directions.RIGHT) 


func _on_area_entered(area: Area2D) -> void:
	if area.get_class() == "PlayerShot":
		emit_signal("segment_hit", self, area)
	else:
		if area.get_class() == "Mushroom":
			# if the head is colliding with mushroom and travelling horizontally
			if direction in [Directions.LEFT, Directions.RIGHT]:
				has_collided = true
		
		# move to move_in_current_direction???
		elif area.get_class() == "Segment" or area.get_class() == "Head":
			if area.get_parent() != get_parent() and direction in [Directions.LEFT, Directions.RIGHT]:
				has_collided = true
		
	
