extends Node2D

signal bug_hit

var move_count_limit = 1
var move_count = 0
var speed_factor:int = 1 setget set_speed_factor, get_speed_factor


func _ready():
	set_body_target_positions()


# speed factor can be 1 or 2 (slow/fast)
func set_speed_factor(speed: int) -> void:
	if speed > 2:
		speed_factor = 2
	elif speed < 1:
		speed_factor = 1
	else:
		speed_factor = speed


func get_speed_factor() -> int:
	return speed_factor
	
	
func _process(_delta: float) -> void:
	
	if Input.is_action_just_released("ui_focus_next"):
		move_count_limit = 100
		print('next')
	elif Input.is_action_just_released("ui_cancel"):
		print('prev')
		move_count_limit = 1
	
	
	move_count += 1
		
	if move_count >= move_count_limit:
		move_count = 0
				
		# move the head
		get_child(0).move()
		
		# move the body segments
		for n in range(1, get_child_count()):
			get_child(n).move()
		
		if has_moved_all_body_segments():
			set_body_target_positions()


func get_head():
	return get_child(0)
	

func has_moved_all_body_segments() -> bool:
	var all_moved_state = true	
	for n in range(1, get_child_count()):
		if get_child(n).has_reached_target_position() == false:
			all_moved_state = false
	return all_moved_state
	
	
func set_body_target_positions():
	# set target position on each body segment 
	for n in range(1, get_child_count()): 
		get_child(n).set_target_position(get_child(n-1).position)
	

	
func _on_segment_hit(segment:Node, _area:Area2D):
	# got here if player shot collided with head or body segment
	segment.queue_free()
	
	# if last segment hit then remove bug
	if get_child_count() <= 1:
		queue_free()
	else:
		# more than one segment remains so split it via signal 
		# sent to dumb_bug_container at function _on_bug_hit
		emit_signal("bug_hit", segment, self)
		
