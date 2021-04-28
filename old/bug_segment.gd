extends Area2D

onready var raycast_left = get_node("RayCastLeft")
onready var raycast_right = get_node("RayCastRight")

var move_count_limit = 0


class_name BugSegment

signal segment_hit

const CLASS_NAME = "segment"

enum Directions { UP, DOWN, LEFT, RIGHT }
enum Types { HEAD, BODY }

var movement_vectors = [
	Vector2.UP,
	Vector2.DOWN,
	Vector2.LEFT,
	Vector2.RIGHT
]

var drop_count:int = 0

var direction: int
var last_direction: int
var was_hit:bool = false
var segment_type: int
var move_count = 0
var group_name: String


func get_class() -> String:
	return CLASS_NAME


func __ready() -> void:
	var dynamic_font = DynamicFont.new()
	dynamic_font.font_data = load('res://PressStart2P-vaV7.ttf')
	dynamic_font.size = 8
	var label = Label.new()
	label.set_text(str(get_index()))
	label.set("custom_fonts/font", dynamic_font)
	label.set_uppercase(true)
	label.margin_top = 8
	add_child(label)


func is_moving_left():
	return direction == Directions.LEFT


func is_moving_right():
	return direction == Directions.RIGHT
	

func is_moving_down():
	return direction == Directions.DOWN

	
func set_body_frame(frame: int) -> void:
	$Body.set_frame(frame)
	
	
func set_type(type: int) -> void:
	segment_type = type
	$Head.visible = true if segment_type == 0 else false
	$Body.visible = true if segment_type == 1 else false
	
	$Head.set_animation("default")
	$Body.set_animation("default")
	$Head.set_frame(0)
	$Body.set_frame(0)
	


func get_type() -> int:
	return segment_type


func set_orientation() -> void:
	$Head.flip_h = false if is_moving_left() or is_moving_down() else true
	$Body.flip_h = false if is_moving_left() or is_moving_down() else true
	
	
func change_direction(new_direction: int) -> void:
	last_direction = direction
	direction = new_direction
	drop_count = 0
	
	# use a 1 pixel offset to allow for head's extra space
	# when horizontally inverted
	if new_direction == Directions.RIGHT and segment_type == Types.HEAD:
		$Head.offset = Vector2(-1,0)
	if new_direction == Directions.LEFT and segment_type == Types.HEAD:
		$Head.offset = Vector2(0,0)
		
	set_orientation()
	
	if new_direction == Directions.DOWN:
		$Head.play("turn")
		$Body.play("turn")
	else:
		$Head.play("default")
		$Body.set_animation("default")

	
	
	
func set_initial_direction(set_direction:int) -> void:
	direction = set_direction
	last_direction = set_direction
	set_orientation()	
	if direction == Directions.RIGHT and segment_type == Types.HEAD:
		$Head.offset = Vector2(-1,0)
	if direction == Directions.LEFT and segment_type == Types.HEAD:
		$Head.offset = Vector2(0,0)


func set_drop_count(set_count:int) -> void:
	drop_count = set_count


func get_drop_count() -> int:
	return drop_count


# use raycast or add extra raycast to record if another segment next to it
# that raycast can be set to only collide with segments etc
func check_mushrooms():
	
	if direction == Directions.LEFT:
		if raycast_left.is_colliding() and raycast_left.get_collider().name == "Mushroom":
			change_direction(Directions.DOWN)
			#print(raycast_left.get_collider().name)

	elif direction == Directions.RIGHT:
		if raycast_right.is_colliding() and raycast_right.get_collider().name == "Mushroom":
			change_direction(Directions.DOWN)
			#print(raycast_right.get_collider().name)



func _process(_delta: float) -> void:
	
	#check_mushrooms()
	# slow down the movement
	move_count += 1
	if move_count > move_count_limit:
		move_count = 0
		
		if direction == Directions.LEFT:	
			
			if position.x > 0:
				position += movement_vectors[direction] 
			else:
				change_direction(Directions.DOWN)
				
		elif direction == Directions.RIGHT:
				
			if position.x < 232:
				position += movement_vectors[direction] 
			else:
				change_direction(Directions.DOWN)
				
		elif direction == Directions.DOWN:
			if drop_count <= 6:
				drop_count += 2
				position += (movement_vectors[direction]*2)
			else:
				change_direction(Directions.LEFT if last_direction == Directions.RIGHT else Directions.RIGHT)


func _on_Area2D_area_entered(area: Area2D) -> void:
	

	if area.name == "Mushroom": # or area.name =="Segment": # and segment_type == Types.HEAD:
		
		# these checks ensure the segment only collides when a mushroom
		# is in your path and not midpoint when mushroom is suddenly spawned in
		
		# if travelling left and mushroom left of segment position (in front)
		if direction == Directions.LEFT and area.global_position.x < global_position.x:
			change_direction(Directions.DOWN)
			
		# if travelling right and mushroom right of segment (in front)
		elif direction == Directions.RIGHT and global_position.x < area.global_position.x:
			change_direction(Directions.DOWN)
			
			
	elif area.name == "PlayerShot":
		was_hit = true
		emit_signal("segment_hit", self, area)
		queue_free()



