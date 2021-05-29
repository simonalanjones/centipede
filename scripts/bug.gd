extends Node2D

signal bug_hit(segment, area)

var speed_factor:int = 60 setget set_speed_factor, get_speed_factor
#var can_move = true


func _ready():
	set_body_target_positions()
	#yield(get_tree(), "idle_frame")
	#for n in get_children():
	#	print(str(n) + ":" + str(global_position))


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


func _stop_bug():
	for n in get_children():
		n.can_move = false
			
			
func get_speed_factor() -> int:
	return speed_factor
	
	
func _physics_process(_delta: float) -> void:
	if Input.is_action_pressed("ui_cancel"):
		for n in get_children():
			n.can_move = true
	
	if Input.is_action_pressed("ui_focus_next"):
		for n in get_children():
			n.can_move = false
				
	if has_moved_all_body_segments() and get_head().is_on_grid_boundary():
		set_body_target_positions()


func has_moved_all_body_segments() -> bool:
	var all_moved_state = true	
	for n in range(1, get_child_count()):
		if get_child(n).has_reached_target_position() == false:
			all_moved_state = false
	return all_moved_state
	
	
func set_body_target_positions():
	# set target position on each body segment (not head) starting from index 1
	# assign target position to current position of previous segment
	for n in range(1, get_child_count()): 
		get_child(n).set_target_position(get_child(n-1).position)
		#print(str(get_child(n).position))
		

	
func _on_segment_hit(segment:Node):
	
	# got here if player shot collided with head or body segment
	# if last segment remains hit then remove bug
	# child count won't be 0 until next cycle
	if get_child_count() <= 1:
		segment.queue_free()
		queue_free()
	else:
		# more than one segment remains
		# sent to bug_spawner function _on_bug_hit
		emit_signal("bug_hit", segment, self)
		
