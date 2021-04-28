extends Node2D

signal bug_segment_hit

onready var bug_scene: PackedScene = preload("res://scenes/bug.tscn")
onready var mushrooms = get_node("../mushrooms")

	

# directions out the gate alternate left/right (odd/even)
func _ready() -> void:
	var _a = self.connect("bug_segment_hit", mushrooms, "_on_bug_segment_hit")
	
	
	var bug = bug_scene.instance()
	bug.connect('bug_hit', self, '_on_bug_hit')
	add_child(bug)
	
	var create_vars = {
		'num_sections': 10,
		'x_position': 10,
		'y_position': 32,
		'direction': BugSegment.Directions.LEFT
	}

	bug.create_new(create_vars)
	
	
	
	


func _process(_delta: float) -> void:
	if get_children().size() == 0:
		print('all done')


func _on_bug_hit(bug):

	# find segment marked as hit
	var segment_hit: BugSegment = bug.get_segment_hit()
	emit_signal("bug_segment_hit", segment_hit)
		
	# if last segment in bug then no need to loop through it
	if bug.get_segments().size() <= 1:
		bug.queue_free()

	else:
		
		# temporary array to hold segments that will make new bug
		var new_segments: Array = []
			
		# get a count of existing bug segments to work from.
		# we'll check how many we're left with at the end
		var count_of_segments = bug.get_segments().size()
		
		# loop through all segments in bug
		for bug_segment in bug.get_segments():
			
			### todo: also have going down direction to check
			
			if bug_segment.get_index() > segment_hit.get_index():
				# add segment to new bug
				new_segments.append(bug_segment)
				# remove segment from this bug
				bug_segment.queue_free()
				# decrease count of segments remaining in this bug
				count_of_segments -= 1
				
			
		# create a new bug if new_segments array size > 0
		if new_segments.size() > 0:
			var new_bug = bug_scene.instance()
			add_child(new_bug)
			new_bug.connect('bug_hit', self, '_on_bug_hit')
			new_bug.create_from_nodes(new_segments)
				
		# remove existing bug if no segments left
		if count_of_segments <= 1:
			bug.queue_free()
	
