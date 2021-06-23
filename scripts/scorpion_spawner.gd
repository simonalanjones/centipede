extends Node

signal scorpion_left_screen
signal scorpion_destroyed

const SCORE_THRESHOLD = 20000

onready var scorpion_scene: PackedScene = preload("res://scenes/scorpion.tscn")

var Rng = RandomNumberGenerator.new()
var direction: Vector2

func _ready() -> void:
	Rng.randomize()		


func on_scorpion_left_screen():
	emit_signal("scorpion_left_screen")


func on_scorpion_destroyed(scorpion: Scorpion ) -> void:
	emit_signal("scorpion_destroyed", scorpion)
	

func spawn():
	var scorpion = scorpion_scene.instance()

	var r = Rng.randi_range(0, 12)
	if randf() < 0.5:
		scorpion.position = Vector2(0, r * 8)
	else:
		scorpion.position = Vector2(232, r * 8)
	
	scorpion.connect('scorpion_left_screen', self, 'on_scorpion_left_screen')
	scorpion.connect('scorpion_destroyed', self, 'on_scorpion_destroyed')
	scorpion.speed_factor = 1 if Globals.player_score() < SCORE_THRESHOLD else 2
	add_child(scorpion)
