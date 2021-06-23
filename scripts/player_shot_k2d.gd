class_name PlayerShot

extends Area2D

var speed = 60
var velocity = Vector2(0, -8)

func _physics_process(_delta) -> void:
	if position.y > 0:
		position += velocity
	else:
		queue_free()


func _on_Area2D_area_entered(area: Area2D) -> void:
	set_block_signals(true)
	if area is BugSegmentBase:
		area.hit()
	queue_free()


func _on_Area2D_body_entered(body: Node) -> void:
	if body is TileMap:
		Globals.register_tilemap_collision(body.world_to_map(position))
		queue_free()
