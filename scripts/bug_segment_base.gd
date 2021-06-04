class_name BugSegmentBase

extends Area2D

signal segment_hit(segment)

enum Directions { UP, DOWN, LEFT, RIGHT }

const CLASS_NAME = "Segment"

var movement_vectors: Array = [
	Vector2.UP,
	Vector2.DOWN,
	Vector2.LEFT,
	Vector2.RIGHT
]

var speed: int = 1 setget set_speed, get_speed

var horizontal_direction: int
var vertical_direction: int

var is_moving_vertically:bool = false
var is_moving_horizontally:bool = false


# debugging vars to slow down movement
var can_move: bool = true
var cycles: int = 0
var cycles_limit: int = 100


onready var sprite: AnimatedSprite = get_node("Sprite")


func _ready() -> void:
	pass
	get_node("Label").set_text(str(get_index()))
	#set_ortientation()


func set_horizontal_direction(set_direction:int) -> void:
	if set_direction in [ Directions.LEFT, Directions.RIGHT ]:
		horizontal_direction = set_direction
	else:
		print('error setting horizontal direction')
		
		
func set_vertical_direction(set_direction:int) -> void:
	if set_direction in [ Directions.UP, Directions.DOWN ]:
		vertical_direction = set_direction
	else:
		print('error setting vertical direction')

		
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
	
		
func get_class() -> String:
	return CLASS_NAME
	
	
func set_speed(speed_value: int) -> void:
	speed = speed_value

		
func get_speed() -> int:
	return speed


func hit():
	emit_signal("segment_hit", self)
