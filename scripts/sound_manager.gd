class_name SoundPlayer

extends Node

var player_shoot_waveform = preload("res://sounds/centipede_shoot.wav")
var player_shoot = AudioStreamPlayer.new()

var enemy_explosion_waveform = preload("res://sounds/enemy_explosion.wav")
var enemy_explode = AudioStreamPlayer.new()

var mushroom_respawn_waveform = preload("res://sounds/mushroom_respawn.wav")
var mushroom_respawn = AudioStreamPlayer.new()

var player_dies_waveform = preload("res://sounds/player_dies.wav")
var player_dies = AudioStreamPlayer.new()

func _ready() -> void:
	player_shoot.stream = player_shoot_waveform
	self.add_child(player_shoot)
	enemy_explode.stream = enemy_explosion_waveform
	self.add_child(enemy_explode)	
	mushroom_respawn.stream = mushroom_respawn_waveform
	self.add_child(mushroom_respawn)
	player_dies.stream = player_dies_waveform
	self.add_child(player_dies)
	
	
func play_mushroom_respawn() -> void:
	mushroom_respawn.play()


func play_dies_sound() -> void:
	player_dies.play()
		

func play_shoot_sound() -> void:
	player_shoot.play()	


func play_enemy_explodes() -> void:
	enemy_explode.play()
