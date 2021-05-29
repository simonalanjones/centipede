class_name PlayerShot

extends KinematicBody2D

signal mushroom_hit
var speed = 60

var velocity = Vector2(0, -8 * speed)

func _physics_process(delta):
	
	if position.y > 8:
		
		
		var collision = move_and_collide(velocity * delta)
		#print(velocity * delta)
		if collision:
			print(collision.collider)
			queue_free()
			#if collision.collider.get_class() == "Segment":
			#	collision.collider.hit()
				
			if collision.collider is TileMap:
				#print(collision.collider.world_to_map(position))
				emit_signal("mushroom_hit", collision.collider.world_to_map(position))
				#print(collision.collider)
				
	else:
		queue_free()
