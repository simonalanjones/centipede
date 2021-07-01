extends Node

var is_paused:bool = false

func _process(_delta: float) -> void:
	if Input.is_action_just_released("pause"):
		if is_paused == true:
			get_tree().paused = false
			is_paused = false
		else:
			get_tree().paused = true
			is_paused = true
			
