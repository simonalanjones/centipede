extends Node


onready var spider_scene: PackedScene = preload("res://scenes/spider.tscn")
var Rng = RandomNumberGenerator.new()


func _ready() -> void:
	Rng.randomize()	
	
	
func spawn(score, eat_mushroom):
	pass
