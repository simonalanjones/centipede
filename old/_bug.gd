extends Node2D

signal bug_hit

#onready var head_segment_scene: PackedScene = preload("res://scenes/bug_head.tscn")
#onready var body_segment_scene: PackedScene = preload("res://scenes/bug_body.tscn")
onready var bug_segment_scene: PackedScene = preload("res://scenes/bug_segment.tscn")

var segment_hit_index: int


func create_from_nodes(nodes: Array) -> void:

	var bug_segment: BugSegment
	var counter:int = 0
	
	for n in nodes:
		bug_segment = bug_segment_scene.instance()
		bug_segment.position.x = n.position.x
		bug_segment.position.y = n.position.y
		bug_segment.set_initial_direction(n.direction)
		bug_segment.set_drop_count(n.drop_count)
		bug_segment.set_type(BugSegment.Types.HEAD if counter == 0 else BugSegment.Types.BODY)		

		var _b = bug_segment.connect("segment_hit", self, "_on_segment_hit")
		add_segment(bug_segment)
		
		n.queue_free()
		counter += 1
		
	
func create_new(create_vars: Dictionary) -> void:

	# help us filter out segment collisions of the same group
	var bug_group_name = "bug_" + str(get_index())
	
	var bug_segment: BugSegment
	var body_frame: int = 0
	
	for n in range(0, create_vars.num_sections):
		bug_segment = bug_segment_scene.instance()
		
		if n > 0:
			bug_segment.set_type(BugSegment.Types.BODY)
			bug_segment.set_body_frame(body_frame)
			body_frame += 1 % 8
		else:
			# first segment is always the head
			bug_segment.set_type(BugSegment.Types.HEAD)
		
		# if initial direction is left then build to the right
		if create_vars.direction == BugSegment.Directions.LEFT:
			bug_segment.position.x = create_vars.x_position + (n*8)
		else:
			# if initial direction is right then build to the left
			bug_segment.position.x = create_vars.x_position - (n*8)
		
		bug_segment.group_name = bug_group_name
		#bug_segment.add_to_group(bug_group_name)
		bug_segment.position.y = create_vars.y_position
		bug_segment.set_initial_direction(create_vars.direction)
		var _a = bug_segment.connect("segment_hit", self, "_on_segment_hit")
		add_segment(bug_segment)
		
		
func add_segment(bug_segment: BugSegment):
	get_node("segments").call_deferred("add_child", bug_segment)
		

func get_segments():
	return get_node("segments").get_children()

		
func get_segment_hit():
	for segment in get_node("segments").get_children():
		if segment.was_hit == true:
			return segment
			
			
func _on_segment_hit(bug_segment: BugSegment, area: Area2D):
	#area.print_tree_pretty()
	
	emit_signal('bug_hit', self)
