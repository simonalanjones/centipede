extends Node2D

func _process(_delta):
	get_node("Label").set_text(str(get_index()))
