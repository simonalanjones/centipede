extends Area2D

const CLASS_NAME = "Mushroom"

var frame_counter:int = 0

onready var frames = [
	preload("res://sprites/mushroom/mushroom_frame1.png"),
	preload("res://sprites/mushroom/mushroom_frame2.png"),
	preload("res://sprites/mushroom/mushroom_frame3.png"),
	preload("res://sprites/mushroom/mushroom_frame4.png"),
]


func get_class() -> String:
	return CLASS_NAME


func _ready() -> void:
	get_node("Sprite").texture = frames[frame_counter]


func ____hit_by_missile():
	frame_counter += 1
	if frame_counter < frames.size()-1:
		get_node("Sprite").texture = frames[frame_counter]
	else:
		queue_free()


func _on_Mushroom_area_entered(area: Area2D) -> void:
	if area.get_class() == "PlayerShot":
		frame_counter += 1
		if frame_counter < frames.size()-1:
			get_node("Sprite").texture = frames[frame_counter]
		else:
			queue_free()
