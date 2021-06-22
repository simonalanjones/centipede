class_name Bug

extends Node2D

signal bug_hit(segment, area)

var is_side_feed:bool = false
var speed_factor:int = 1 setget set_speed, get_speed


func _ready():
	set_body_target_positions()
	if is_side_feed == true:
		get_head().is_side_feed = true


func _process(_delta: float) -> void:	
	get_head().move()
	for n in range(1, get_child_count()):
		get_child(n).move()
	if get_head().is_on_grid_boundary():
			set_body_target_positions()
			

func has_moved_all_body_segments_to_target() -> bool:
	var all_moved_state = true	
	for n in range(1, get_child_count()):
		if get_child(n).has_reached_target_position() == false:
			all_moved_state = false
	return all_moved_state
	
	
func set_body_target_positions():
	# set target position on each body segment (not head) starting from index 1
	# assign target position to current position of previous segment	
	for n in range(1, get_child_count()):
		var target_dict = {
			'target_position' : get_child(n-1).position,
			'is_moving_horizontally' : get_child(n-1).is_moving_horizontally,
			'is_moving_vertically' : get_child(n-1).is_moving_vertically
		}
		get_child(n).set_target_data(target_dict)
	

func get_head():
	return get_child(0)
	

# speed factor can be 1 or 2 (slow/fast)
func set_speed(speed: int) -> void:	
	if speed >= 2:
		speed_factor = 2 
	elif speed <= 1:
		speed_factor = 1


func get_speed() -> int:
	return speed_factor
	
	
func _on_segment_hit(segment:Node):
	# wait until all segments moved
	emit_signal("bug_hit", segment, self)
	
