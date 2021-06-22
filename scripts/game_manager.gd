extends Node


var spawn_new_wave: Reference
var spawn_flea: Reference
var spawn_scorpion: Reference
#var eat_mushroom: Reference
#var spawn_mushroom: Reference
var spawn_explosion: Reference

var attack_wave:int = 1
var scorpion_in_motion:bool = false
var flea_in_motion:bool = false


func _ready() -> void:
	yield(get_tree(), "idle_frame")
	spawn_new_wave.call_func(attack_wave)


func on_points_awarded(points):
	Globals.add_score_points(points)


# centralise score management - extra life etc	
func award_points(points) -> void:
	Globals.add_score_points(points)


func segment_hit(segment: BugSegmentBase) -> void:
	award_points(segment.points_awarded)
	Globals.spawn_tilemap_mushroom(segment.mushroom_spawn_position())
	#spawn_mushroom.call_func(segment.mushroom_spawn_position())
	spawn_explosion.call_func(segment.position)


func _on_wave_complete() -> void:
	attack_wave += 1
	if attack_wave > 12:
		attack_wave = 1
	spawn_new_wave.call_func(attack_wave)

	
func _on_flea_timer_timeout() -> void:
	if Globals.should_spawn_flea():
		if flea_in_motion == false and scorpion_in_motion == false:
			spawn_flea.call_func()
			flea_in_motion = true
			

func flea_destroyed(flea: Flea) -> void:
	award_points(flea.points_awarded)
	spawn_explosion.call_func(flea.position)
	
				
func on_flea_left_screen():
	flea_in_motion = false
	

func _on_scorpion_timer_timeout() -> void:
	if flea_in_motion == false and scorpion_in_motion == false:
		spawn_scorpion.call_func()
		scorpion_in_motion = true


func on_scorpion_destroyed(scorpion: Scorpion) -> void:
	award_points(scorpion.points_awarded)
	scorpion_in_motion = false
	spawn_explosion.call_func(scorpion.position)
	
	
func on_scorpion_left_screen():
	scorpion_in_motion = false
