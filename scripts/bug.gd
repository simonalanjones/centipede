class_name Bug

extends Node2D

signal bug_ready
signal bug_hit(segment, area)

var is_locked:bool = false
var is_side_feed:bool = false
var speed_factor:int = 1 setget set_speed, get_speed
var is_checking

func set_lock_state(state: bool):
	is_locked = state


func get_lock_state() -> bool:
	return is_locked

	
func _ready():
	yield(get_tree(), "idle_frame") # wait for all segment to load in
	set_body_target_positions()
	if is_side_feed == true:
		get_head().is_side_feed = true
	emit_signal('bug_ready')


func move():
	get_head().move()
	for n in range(1, get_child_count()):
		get_child(n).move()
		#var d = get_child(n).position
		#var e = get_child(n-1).position
		#if d==e:
		#	print('overlap')
		#	print('child n   H direction: ' + str(get_child(n).horizontal_direction))
		#	print('child n-1 H direction: ' + str(get_child(n-1).horizontal_direction))
		#	
		#	print('child n   index: ' + str(get_child(n).get_index()))
		#	print('child n-1   index: ' + str(get_child(n-1).get_index()))
			
		#	get_tree().paused = true
	if get_head().is_on_grid_boundary():
		set_body_target_positions()
			

# signal poisoned_state_changed(true/false)
func _on_head_poisoned():
	for n in range(1, get_child_count()):
		get_child(n).set_poisoned(true)
	
	
func _on_head_clear_poisoned():
	for n in range(1, get_child_count()):
		get_child(n).set_poisoned(false)
		
	
func has_moved_all_body_segments_to_target() -> bool:
	for n in range(1, get_child_count()):
		if get_child(n).has_reached_target_position() == false:
			return false
	return true
	
	
func set_body_target_positions(debug = false):
	#is_locked = true
	# set target position on each body segment (not head) starting from index 1
	# assign target position to current position of previous segment	
	if debug == true:
		print('----- start debug ----')
	for n in range(1, get_child_count()):
				
		if get_child(n).is_queued_for_deletion():
			print(str(n) + " : is marked for deletion")
					
		var target_dict = {
			'target_position' : get_child(n-1).position,
			'is_moving_horizontally' : get_child(n-1).is_moving_horizontally,
			'is_moving_vertically' : get_child(n-1).is_moving_vertically
		}
		if debug == true:
			print(target_dict)
		get_child(n).set_target_data(target_dict)
	if debug == true:
		print('----- end debug ----')
		
	#is_locked = false


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
	emit_signal("bug_hit", segment, self)
	
