extends Area2D

signal segment_hit(segment, area)
signal side_feed_triggered

enum Directions { UP, DOWN, LEFT, RIGHT }

const CLASS_NAME = "Head"

var movement_vectors: Array = [
	Vector2.UP,
	Vector2.DOWN,
	Vector2.LEFT,
	Vector2.RIGHT
]
var side_feed_triggered: bool = false
var last_direction: int = Directions.RIGHT

var horizontal_direction: int = Directions.RIGHT
# is the centipede in a overall downwards or upwards movement
var vertical_direction: int = Directions.DOWN
var is_moving_vertically:bool = false
var check_map_function: Reference

onready var sprite:AnimatedSprite = get_node("Sprite")
onready var raycast_left:RayCast2D = get_node("RayCastLeft")
onready var raycast_right:RayCast2D = get_node("RayCastRight")


func _ready():
	var _a = connect("area_entered", self, "_on_area_entered")
	set_ortientation()
	
	
func _process(_delta: float) -> void:	
	$Label.set_text(str(is_moving_vertically))

	
func set_ortientation() -> void:
#	if last_direction == Directions.LEFT and is_moving_vertically == true:
#		sprite.flip_h = false
#		sprite.flip_v = false if is_moving_down() else true
#		sprite.offset.x = 0
##		
#	elif last_direction == Directions.RIGHT and is_moving_vertically == true:
#		sprite.flip_h = true
#		sprite.flip_v = false if is_moving_down() else true
#		sprite.offset.x = 0
		
		
	if horizontal_direction == Directions.LEFT:
		sprite.flip_h = false
		sprite.flip_v = false
		sprite.offset.x = 0
		
	elif horizontal_direction == Directions.RIGHT:
		sprite.flip_h = true
		sprite.flip_v = false	
		sprite.offset.x = -1
		
		
func get_class() -> String:
	return CLASS_NAME
	
	
func is_moving_left() -> int:
	return horizontal_direction == Directions.LEFT
	
	
func is_moving_right() -> int:
	return horizontal_direction == Directions.RIGHT	
	
	
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
	
	
func set_initial_direction(set_direction:int) -> void:
	if set_direction in [ Directions.LEFT, Directions.RIGHT ]:
		horizontal_direction = set_direction
		last_direction = set_direction
		
		
func check_mushroom_map(screen_position: Vector2) -> bool:
	return true if check_map_function.call_func(screen_position) != -1 else false
		
		
func check_for_mushroom_collision() -> bool:
	if horizontal_direction == Directions.LEFT:
		return check_mushroom_map(position + (Vector2.LEFT*8))
	elif horizontal_direction == Directions.RIGHT:
		return check_mushroom_map(position + (Vector2.RIGHT*8))
	else:
		return false
		

func move_in_horizontal_direction(speed_factor: int) -> void:
	position += movement_vectors[horizontal_direction] * speed_factor
	
	
func move_in_vertical_direction(speed_factor: int) -> void:
	position += movement_vectors[vertical_direction] * speed_factor
	
	
func move(speed_factor: int) -> void:
	
	if is_at_screen_edge():
			
		if is_on_bottom_line() and vertical_direction == Directions.DOWN:
			vertical_direction = Directions.UP
				
		# first cycle at screen edge
		if is_moving_vertically == false:
			horizontal_direction = Directions.LEFT if horizontal_direction == Directions.RIGHT else Directions.RIGHT
			set_ortientation()
			is_moving_vertically = true
			move_in_vertical_direction(speed_factor)
		else:
			# subsequent cycles at screen edge
			if is_on_grid_boundary():
				move_in_horizontal_direction(speed_factor)
				is_moving_vertically = false
			else:
				move_in_vertical_direction(speed_factor)
				
					
	elif is_on_grid_boundary():
		
		if is_within_outfield() and vertical_direction == Directions.UP:
			vertical_direction = Directions.DOWN
					
		if check_for_mushroom_collision() == true:
			horizontal_direction = Directions.LEFT if horizontal_direction == Directions.RIGHT else Directions.RIGHT
			set_ortientation()
			is_moving_vertically = true
			move_in_vertical_direction(speed_factor)
			
		elif is_moving_vertically == true:
			is_moving_vertically = false
			
		else:
			move_in_horizontal_direction(speed_factor)
		
	else:
		if is_moving_vertically == true:
			move_in_vertical_direction(speed_factor)
		else:
			move_in_horizontal_direction(speed_factor)


func _on_area_entered(area: Area2D) -> void:
	if area.get_class() == "PlayerShot":
		area.queue_free()
		emit_signal("segment_hit", self, area)
		
	# this detects collision with another bug???
	elif area.get_class() in ["Segment", "Head"] and is_on_grid_boundary():
		if area.get_parent() != get_parent() and horizontal_direction in [Directions.LEFT, Directions.RIGHT]:
			print('hit another bug')
