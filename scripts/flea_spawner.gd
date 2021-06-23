extends Node

signal mushroom_spawned
signal flea_left_screen
signal flea_destroyed

onready var flea_scene: PackedScene = preload("res://scenes/flea.tscn")
var Rng = RandomNumberGenerator.new()

func _ready() -> void:
	Rng.randomize()


func spawn():
	var flea = flea_scene.instance()
	flea.position = Vector2((Rng.randi() % 29 ) * 8, 16)
	
	flea.connect('flea_left_screen', self, 'on_flea_left_screen')
	flea.connect('flea_destroyed', self, 'on_flea_destroyed')
	add_child(flea)
		
		
func on_flea_left_screen() -> void:
	emit_signal("flea_left_screen")
	

func on_flea_destroyed(flea) -> void:
	emit_signal("flea_destroyed", flea)
