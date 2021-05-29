extends Area2D

const CLASS_NAME = "Player"

#onready var player_shot_scene: PackedScene = preload("res://scenes/player_shot.tscn")
onready var player_shot_scene: PackedScene = preload("res://scenes/player_shot_k2d.tscn")
onready var mushroom_spawner = get_node("/root/root/mushroom_spawner")

func _ready() -> void:
	#global_position.x = 32
	#global_position.y = 232
	pass # Replace with function body.

func get_class() -> String:
	return CLASS_NAME

func _process(_delta: float) -> void:
	
	if Input.is_action_just_pressed("toggle_fullscreen"):
		OS.window_fullscreen = !OS.window_fullscreen
	
	var direction = Vector2.ZERO
	
	if Input.is_action_pressed("ui_up"):
		#if global_position.y > 192:
		direction.y -= 2
		
	if Input.is_action_pressed("ui_down"):
		if global_position.y < 245:
			direction.y += 2
		
	if Input.is_action_pressed("ui_left"):
		if global_position.x > 0:
			direction.x -= 2
		
	if Input.is_action_pressed("ui_right"):
		if global_position.x < 233:
			direction.x += 2

		
	position += direction
		
		
	if Input.is_action_pressed("ui_accept"):
		
		var ok_to_shoot = true
		for _n in get_node("../").get_children():
			if _n.name == "PlayerShot":
				ok_to_shoot = false
		
		# NEEDS TO BE ALIGNED TO GRID WHEN LAUNCHING AS IT MOVES 8 PIXELS PER CYCLE
		if ok_to_shoot == true:
			var player_shot = player_shot_scene.instance()
			player_shot.connect("mushroom_hit", mushroom_spawner, "_on_mushroom_hit")
			player_shot.name = "PlayerShot"
			
			player_shot.position.y = position.y
			
			player_shot.position = player_shot.position.snapped(Vector2.ONE * 8)
			player_shot.position.x = position.x + 3
			
			get_node("../").add_child(player_shot)


func _on_Player_area_entered(_area: Area2D) -> void:
	pass
	#print(area.name)
