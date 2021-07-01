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
	get_node("Label").set_text(str(get_index()))
	#set_ortientation()


func get_speed():
	return get_parent().get_speed()
	
	
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


func is_on_vertical_boundary() -> bool:
	return int(position.y) % 8 == 0
	

func is_on_horizontal_boundary() -> bool:
	return int(position.x) % 8 == 0	


func is_at_screen_edge() -> bool:
	return position.x >= 232 or position.x <= 0


func is_on_bottom_line() -> bool:
	return position.y >= 248


func is_within_outfield() -> bool:
	return position.y <= 152


func is_at_top_of_retreat() -> bool:
	return position.y <= 184


func is_off_screen() -> bool:
	return position.x > 232 or position.x < 0
	
			
func get_class() -> String:
	return CLASS_NAME
	

func mushroom_spawn_position() -> Vector2:
	var mushroom_position: Vector2 = position # default mushroom position
	if is_moving_horizontally == true:
		if is_moving_left():
			mushroom_position = position + Vector2(-8,0)
		else:
			mushroom_position = position + Vector2(8,0)
	if mushroom_position.x < 0:
		mushroom_position.x = 0	
		
	if mushroom_position.x > 232:
		mushroom_position.x = 232
	return mushroom_position
		
			
func hit() -> void:
	emit_signal("segment_hit", self)
