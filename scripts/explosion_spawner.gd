extends Node

onready var explosion_scene: PackedScene = preload("res://scenes/enemy_explosion.tscn")

func spawn(enemy_position: Vector2):
	var explosion = explosion_scene.instance()
	explosion.position = enemy_position
	add_child(explosion)
