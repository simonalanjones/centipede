extends Area2D

signal segment_hit
signal segment_collided

const CLASS_NAME = "Segment"

var has_reached:bool = false
var target_position: Vector2

func get_class() -> String:
	return CLASS_NAME

func _ready() -> void:
	if is_head():
		$Head.visible = true
		$Body.visible = false
	else:
		$Head.visible = false
		$Body.visible = true
			


#func set_orientation() -> void:
#	$Head.flip_h = false if is_moving_left() or is_moving_down() else true
#	$Body.flip_h = false if is_moving_left() or is_moving_down() else true
	
	
func is_head() -> bool:
	return get_index() == 0
	
	
func is_body() -> bool:
	return get_index() > 0

	
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
	
	
func move()-> void:
	
	var diff:Vector2 = target_position - position
			
	if diff.x > 0:
		translate(Vector2(1,0))
	elif diff.x < 0:
		translate(Vector2(-1,0))
	elif diff.y > 0:
		translate(Vector2(0,1))
	elif diff.y < 0:
		translate(Vector2(0,-1))

	if position == target_position:
		has_reached = true
	
			
func reset() -> void:
	has_reached = false


func _on_Area2D_area_entered(area: Area2D) -> void:
	#print(area.get_class())
	if area.get_class() == "PlayerShot":
		emit_signal("segment_hit", self, area)
	elif is_head():
		# only the head segment can collide
		emit_signal("segment_collided", self, area)
