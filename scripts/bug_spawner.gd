extends Node2D

signal wave_complete

onready var bug_scene: PackedScene = preload("res://scenes/bug.tscn")
onready var bug_body_scene: PackedScene = preload("res://scenes/bug_body_segment.tscn")
onready var bug_head_scene: PackedScene = preload("res://scenes/bug_head_segment.tscn")
onready var mushroom_scene = get_node("/root/root/mushroom_spawner")

onready var rng = RandomNumberGenerator.new()

onready var side_feed_triggered: bool = false
onready var cycles_per_side_feed_spawn: int = 180
onready var cycle_count:int = 0

var attack_wave:int = 1

enum Directions { UP, DOWN, LEFT, RIGHT, STOP }


func _ready() -> void:
	rng.randomize()
	new_attack_wave()

	
func new_attack_wave():
	
	var create_vars = {
		'num_sections': 13 - attack_wave,
		'x_position': 8*26,
		'y_position': 8,
		'direction': Directions.RIGHT,
		'speed_factor': 2
	}

	var bug = create_new_bug(create_vars)
	bug.add_to_group("bugs")
	call_deferred("add_child", bug)
	
	# instance the individual bugs
	if attack_wave > 1:
		
		var spawn_x: int
		var cols_used: Array = []
		
		for _n in range(0, attack_wave - 1):

			while true:
				spawn_x = rng.randi_range(1, 30)
				if not cols_used.has(spawn_x):
					break
					
			cols_used.append(spawn_x)
			
			create_vars = {
				'num_sections': 1,
				'x_position': 8 * spawn_x,
				'y_position': 8,
				'direction': Directions.RIGHT,
				'speed_factor': 1
			}
			
			bug = create_new_bug(create_vars)
			bug.add_to_group("bugs")
			call_deferred("add_child", bug)



func create_new_bug(create_vars):
	var bug = bug_scene.instance()
	bug.set_speed_factor(create_vars.speed_factor)
	
	var bug_segment
	
	for n in range(0, create_vars.num_sections):
		if n == 0:
			bug_segment = bug_head_scene.instance()
			bug_segment.set_initial_direction(create_vars.direction)	
			bug_segment.connect('side_feed_triggered', self, '_on_side_feed_triggered')
		else:
			bug_segment = bug_body_scene.instance()
		
		bug_segment.connect('segment_hit', bug, '_on_segment_hit')
		
		
		# if initial direction is left then build to the right
		if create_vars.direction == Directions.LEFT:	
			bug_segment.position.x = create_vars.x_position + (n*8)
		else:
			# if initial direction is right then build to the left
			bug_segment.position.x = create_vars.x_position - (n*8)
					
		bug_segment.position.y = create_vars.y_position
		bug.call_deferred("add_child", bug_segment)


	bug.connect("bug_hit", self, "_on_bug_hit")
	bug.connect('bug_hit', mushroom_scene, '_on_bug_segment_hit')
	return bug	



func create_bug_from_nodes(nodes, direction):
	
	var bug = bug_scene.instance()
	var bug_segment
		
	for n in range(0, nodes.size()):
		if n == 0:
			bug_segment = bug_head_scene.instance()
			bug_segment.set_initial_direction(direction)
			bug_segment.connect('side_feed_triggered', self, '_on_side_feed_triggered')
		else:
			bug_segment = bug_body_scene.instance()
		
		bug_segment.connect('segment_hit', bug, '_on_segment_hit')
		
		bug_segment.position.x = nodes[n].position.x
		bug_segment.position.y = nodes[n].position.y

		bug.call_deferred("add_child", bug_segment)
		nodes[n].queue_free()
	
	bug.connect("bug_hit", self, "_on_bug_hit")
	bug.connect('bug_hit', mushroom_scene, '_on_bug_segment_hit')
	return bug



func _on_side_feed_triggered():
	side_feed_triggered = true


# this happens when all centipede links are destroyed
func stop_side_feed() -> void:
	side_feed_triggered = false	


func _process(_delta: float) -> void:
	if side_feed_triggered == true:
		cycle_count +=1
		if cycle_count >= cycles_per_side_feed_spawn:
			cycle_count = 0
			spawn_side_feed()
			# reduce cycles_per_side_feed_spawn by 7


func spawn_side_feed():
	
	var start_x
	var direction
	
	if randf() < 0.5:
		start_x = 0
		direction = Directions.RIGHT
	else:
		start_x = 240
		direction = Directions.LEFT
		
	
	var create_vars = {
		'num_sections': 1,
		'x_position': start_x,
		'y_position': 23*8,
		'direction': direction,
		'speed_factor': 1
	}

	var bug = create_new_bug(create_vars)
	bug.add_to_group("bugs")
	call_deferred("add_child", bug)
	
	
# this outer container captures the bug hit (from the bug segment)
# if it's from the player shot and decides how to handle it
func _on_bug_hit(segment, bug):
	var count_of_segments = bug.get_child_count()
	
	# temporary array to hold segments that will make new bug
	var new_segments: Array = []
			
	# loop through all segments in bug
	for bug_segment in bug.get_children():
		
		if bug_segment.get_index() > segment.get_index():
			# add segment to new bug
			new_segments.append(bug_segment)
			# remove segment from this bug
			#bug_segment.modulate.a = 0.5
			bug_segment.queue_free()
			# decrease count of segments remaining in this bug
			count_of_segments -= 1
	
	# create a new bug if new_segments array size > 0
	if new_segments.size() > 0:
		 
		var new_bug = create_bug_from_nodes(new_segments, bug.get_head().direction)
		new_bug.self_modulate.a = 0.5

		call_deferred("add_child", new_bug)
		new_bug.add_to_group("bugs")
	
	# remove existing bug if no segments left
	if count_of_segments <= 1:
		bug.queue_free()
	



func _on_Timer_timeout() -> void:
	var count_of_bugs = get_tree().get_nodes_in_group("bugs").size()
	if count_of_bugs == 0:
		stop_side_feed()
		attack_wave += 1
		new_attack_wave()
		emit_signal("wave_complete")
