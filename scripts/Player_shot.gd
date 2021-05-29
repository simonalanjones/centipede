extends Area2D
signal mushroom_hit
var stuck = false

var move_count_limit = 1  # debugging aid - add slowdown
var move_count = 0 # debugging aid - add slowdown

const CLASS_NAME = "PlayerShot"

func get_class() -> String:
	return CLASS_NAME
	
	
func _process(_delta: float) -> void:
	move_count += 1
	if move_count >= move_count_limit:
		move_count = 0
		
	if stuck == false:
		if position.y > 8:
			position.y -= 8
		else:
			queue_free()
	

func _on_PlayerShot_area_entered(_area: Area2D) -> void:
	print('hit an area')
	stuck = true
	
	#if area.get_class == "Mushroom":
	#	print('hit mushroom')
	#	emit_signal("mushroom_hit", area)
	queue_free()


func _on_PlayerShot_body_entered(body: Node) -> void:
	if body is TileMap:
		emit_signal("mushroom_hit", body.world_to_map(position))
		queue_free()
