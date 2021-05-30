class_name BugBaseSegment

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

# debugging vars to slow down movement
var can_move: bool = true
var cycles: int = 0
var cycles_limit: int = 0


onready var sprite: AnimatedSprite = get_node("Sprite")


func _ready() -> void:
	set_ortientation()


func get_class() -> String:
	return CLASS_NAME
	
	
func set_speed(speed_value: int) -> void:
	speed = speed_value

		
func get_speed() -> int:
	return speed


func set_ortientation() -> void:
	if horizontal_direction == Directions.LEFT:
		sprite.flip_h = false
		sprite.flip_v = false
		sprite.offset.x = 0
		
	elif horizontal_direction == Directions.RIGHT:
		sprite.flip_h = true
		sprite.flip_v = false	
		sprite.offset.x = -1


func hit():
	emit_signal("segment_hit", self)
