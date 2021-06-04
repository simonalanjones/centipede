extends Node2D

signal bug_hit(segment, area)

var speed_factor:int = 60 setget set_speed_factor, get_speed_factor
#var can_move = true


func _ready():
	set_body_target_positions()
	#stop_bug()


func _process(_delta: float) -> void:
	get_head().move()
	
	for n in range(1, get_child_count()):
		get_child(n).move()
	
	if get_head().is_on_grid_boundary():
		set_body_target_positions()
		
	#if has_moved_all_body_segments() and get_head().is_on_grid_boundary():
	#	set_body_target_positions()
	

func has_moved_all_body_segments() -> bool:
	var all_moved_state = true	
	for n in range(1, get_child_count()):
		if get_child(n).has_reached_target_position() == false:
			all_moved_state = false
	return all_moved_state
	
	
func set_body_target_positions():
	# set target position on each body segment (not head) starting from index 1
	# assign target position to current position of previous segment
	#print('head:' + str(get_child(0).position))
	
	for n in range(1, get_child_count()):
		var target_dict = {
			'target_position' : get_child(n-1).position,
			'is_moving_horizontally' : get_child(n-1).is_moving_horizontally,
			'is_moving_vertically' : get_child(n-1).is_moving_vertically
		}
		
		get_child(n).set_target_data(target_dict)
	#print('--------------')	
	#print('----')
		#get_child(n).set_target_position(get_child(n-1).position)
		#	print('child ' + str(n) + ' position:' + str(get_child(n).position))
		#	print('child ' + str(n) + ' target:' + str(get_child(n-1).position))
		#print('----')
		

func get_head():
	return get_child(0)
	

# speed factor can be 1 or 2 (slow/fast)
func set_speed_factor(speed: int) -> void:	
	if speed > 2:
		speed_factor = 2
	elif speed < 1:
		speed_factor = 1
	else:
		speed_factor = 60 * speed


func stop_bug():
	for n in get_children():
		n.can_move = false
			


func start_bug():
	for n in get_children():
		n.can_move = true
				
func get_speed_factor() -> int:
	return speed_factor
	
	
func _physics_process(_delta: float) -> void:
	if Input.is_action_pressed("ui_cancel"):
		for n in get_children():
			n.can_move = true
	
	if Input.is_action_pressed("ui_focus_next"):
		for n in get_children():
			n.can_move = false
				
	
func _on_segment_hit(segment:Node):
	emit_signal("bug_hit", segment, self)
	
