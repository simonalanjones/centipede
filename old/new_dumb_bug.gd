extends Node2D

onready var new_dumb_segment_scene: PackedScene = preload("res://scenes/new_dumb_segment.tscn")

var direction = Vector2(2,0)
var next_direction = Vector2(2,0)

func _ready() -> void:

	var create_vars = {
		'num_sections': 12,
		'x_position': 128,
		'y_position': 32,
		'direction': Vector2.RIGHT
	}

	create_bug(create_vars)


func create_bug(create_vars: Dictionary) -> void:

	for n in range(0, create_vars.num_sections):
		var bug_segment = new_dumb_segment_scene.instance()
				
		# if initial direction is left then build to the right
		if create_vars.direction == Vector2.LEFT:
			bug_segment.position.x = create_vars.x_position + (n*8)
		else:
			# if initial direction is right then build to the left
			bug_segment.position.x = create_vars.x_position - (n*8)
					
		bug_segment.position.y = create_vars.y_position
		add_child(bug_segment)
		
	
	get_child(0).modulate.a = 0.5
	set_target_positions()
	
	#var head = get_child(0)
	#head.get_node("Label").text = str(head.get_index())
	#set_target_positions
	
# monitor body segments for reaching target position
func _process(_delta: float) -> void:
	var all_done = true
	for n in range(1, get_child_count()):
		if get_child(n).has_reached == false:
			all_done = false
				
	if all_done == true:
		set_target_positions()
	
	
func set_target_positions():
	# set target position on each segment apart from the head
	for n in range(1, get_child_count()):
		get_child(n).target_position = get_child(n-1).position
		get_child(n).reset()
	
