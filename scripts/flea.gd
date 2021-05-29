extends Area2D

signal flea_left_screen
signal spawned_mushroom(position)

const CLASS_NAME = "Flea"


# fleas need to be hit twice to destroy
var hits_taken:int = 0
var speed_factor:int = 1


func get_class() -> String:
	return CLASS_NAME


func _process(_delta: float) -> void:
	if position.y < 256:
		position.y += 1 * speed_factor
		if randf() < 0.1 and position.y < 248:
			emit_signal('spawned_mushroom', position)
	else:
		emit_signal('flea_left_screen')
		queue_free()


func _on_Flea_area_entered(area: Area2D) -> void:
	print(area.name)
	if area.name == "PlayerShot":
		hits_taken += 1
		if hits_taken == 2:
			print('hit')
			emit_signal('flea_left_screen')
			# award 200 points
			# run shot animation
			queue_free()
	elif area.name == "Player":
		emit_signal('flea_left_screen')
		# should player register hit?
		queue_free()
