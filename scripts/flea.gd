class_name Flea

extends Area2D

signal flea_left_screen
signal flea_destroyed(points_awarded)

const CLASS_NAME = "Flea"

# fleas need to be hit twice to destroy
var hits_taken:int = 0
var speed_factor:int = 1
var points_awarded:int = 200

func get_class() -> String:
	return CLASS_NAME


func _process(_delta: float) -> void:
	if position.y < 256:
		position.y += 2 * speed_factor
		if randf() < 0.1 and position.y < 248:
			Globals.spawn_tilemap_mushroom(position)
	else:
		emit_signal('flea_left_screen')
		queue_free()


func _on_Flea_area_entered(area: Area2D) -> void:
	#print(area.name)
	
	if area.name == "PlayerShot":
		hits_taken += 1
		speed_factor += 1 # flea taking a hit causes the flea to speed up
		if hits_taken == 2:
			emit_signal('flea_left_screen')
			emit_signal('flea_destroyed', self)
			# award 200 points
			# run shot animation
			queue_free()
	elif area.name == "Player":
		emit_signal('flea_left_screen')
		# should player register hit?
		queue_free()
