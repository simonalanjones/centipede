extends Node

onready var explosion_scene: PackedScene = preload("res://scenes/enemy_explosion.tscn")

func spawn(world_position: Vector2):
	var explosion = explosion_scene.instance()
	explosion.position = world_position
	add_child(explosion)
