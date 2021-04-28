extends Area2D

const CLASS_NAME = "PlayerShot"

func get_class() -> String:
	return CLASS_NAME
			
	
func _process(_delta: float) -> void:
	if position.y > 8:
		position.y -= 8
	else:
		queue_free()
	

func _on_PlayerShot_area_entered(_area: Area2D) -> void:
	#if area.get_class == "Mushroom":
	queue_free()
