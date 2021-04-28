extends Sprite

const CLASS_NAME = "Player"

onready var player_shot_scene: PackedScene = preload("res://scenes/player_shot.tscn")

func get_class() -> String:
	return CLASS_NAME
	
	
func _ready() -> void:
	pass # Replace with function body.


func _process(_delta: float) -> void:
	if Input.is_action_pressed("ui_up"):
		position.y -= 1
		
	if Input.is_action_pressed("ui_down"):
		position.y += 1
		
	if Input.is_action_pressed("ui_left"):
		position.x -= 1
		
	if Input.is_action_pressed("ui_right"):
		position.x += 1
		
	if Input.is_action_just_pressed("ui_accept"):
		
		var ok_to_shoot = true
		for _n in  get_node("../").get_children():
			if _n.name == "PlayerShot":
				ok_to_shoot = false
		
		if ok_to_shoot == true:
			var player_shot = player_shot_scene.instance()
			player_shot.name = "PlayerShot"
			player_shot.position.x = position.x + 3
			player_shot.position.y = position.y - 5
			get_node("../").add_child(player_shot)
