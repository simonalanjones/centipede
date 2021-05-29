extends Node2D

onready var flea_scene: PackedScene = preload("res://scenes/flea.tscn")

var rng = RandomNumberGenerator.new()
var flea_in_motion:bool = false
var get_score: Reference
var infield_mushroom_count: Reference
var mushroom_spawn: Reference

func _ready() -> void:
	rng.randomize()


func required_mushrooms_in_infield() -> int:
	var score = get_score.call_func()
	
	if score <= 20000:
		return 5
	elif score <= 120000:
		return 9
	else:
		return 15 + ((score - 140000) / 20000)

	
func _on_Timer_timeout() -> void:
	# when mushrooms spawn they are added to an array if y position within infield area (lower 12 squares)
	if infield_mushroom_count.call_func() < required_mushrooms_in_infield() and flea_in_motion == false:
		flea_in_motion = true
		var flea = flea_scene.instance()
		flea.position = Vector2((rng.randi() % 29 ) * 8, 16)
		flea.connect("spawned_mushroom", self, "_on_flea_spawned_mushroom")
		flea.connect('flea_left_screen', self, '_on_flea_exit_screen')
		add_child(flea)
		
		
func _on_flea_spawned_mushroom(mushroom_position: Vector2) -> void:
	mushroom_spawn.call_func(mushroom_position)
		
		
func _on_flea_exit_screen() -> void:
	flea_in_motion = false
	
