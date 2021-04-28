extends Node2D


onready var flea_scene: PackedScene = preload("res://scenes/flea.tscn")
onready var mushroom_spawner = get_node("../mushroom_spawner")

var rng = RandomNumberGenerator.new()
var flea_in_motion:bool = false
var get_score: Reference


func _ready() -> void:
	rng.randomize()


func required_mushrooms_in_infield(score) -> int:
	if score <= 20000:
		return 5
	elif score <= 120000:
		return 9
	else:
		return 15 + ((score - 140000) / 20000)

	
func _on_Timer_timeout() -> void:
	# when mushrooms spawn they are added to a group if y position within infield area
	var number_mushrooms_in_infield = get_tree().get_nodes_in_group("mushrooms_in_infield").size()
	var score = get_score.call_func()
	
	if number_mushrooms_in_infield < required_mushrooms_in_infield(score) and flea_in_motion == false:
		
		flea_in_motion = true
		var flea = flea_scene.instance()
		var x = (rng.randi() % 29 ) * 8
		var y = 16
		flea.position = Vector2(x,y)
		# give the flea a reference to the mushroom spawner function
		flea.mushroom_spawn = funcref(mushroom_spawner, "spawn_mushroom")
		flea.connect('flea_left_screen', self, '_on_flea_exit_screen')
		
		add_child(flea)
		
func _on_flea_exit_screen():
	flea_in_motion = false
	
