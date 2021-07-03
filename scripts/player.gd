extends Area2D

signal player_hit

const CLASS_NAME = "Player"
const START_POSITION = Vector2(120,245)
const LOWEST_Y = 245
const HIGHEST_Y = 192
const LOWEST_X = 0
const HIGHEST_X = 233

onready var player_shot_scene: PackedScene = preload("res://scenes/player_shot_k2d.tscn")

var collided:bool = false
var is_exploding:bool = false

func _ready() -> void:
	spawn_player()


func get_class() -> String:
	return CLASS_NAME


func spawn_player():
	position = START_POSITION
	get_node("AnimatedSprite").visible = false
	get_node("Sprite").visible = true
	is_exploding = false


func _process(_delta: float) -> void:
	var direction = Vector2.ZERO
		
	if not is_exploding == true:
		
		if Input.is_action_pressed("ui_up"):
			if not $RayCastUp.is_colliding():
				if position.y > HIGHEST_Y:
					direction.y -= 2
				
		if Input.is_action_pressed("ui_down"):
			if position.y < LOWEST_Y:
				direction.y += 2
			
		if Input.is_action_pressed("ui_left"):
			#if not $RayCastLeft.is_colliding():
			if position.x > LOWEST_X:
				direction.x -= 2
			
		if Input.is_action_pressed("ui_right"):
			#if not $RayCastRight.is_colliding():
			if position.x < HIGHEST_X:
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
			player_shot.name = "PlayerShot"
			player_shot.position.y = position.y
			player_shot.position = player_shot.position.snapped(Vector2.ONE * 8)
			player_shot.position.x = position.x + 3
			get_node("../").add_child(player_shot)
			SoundManager.play_shoot_sound()


func _on_Player_area_entered(area: Area2D) -> void:
	if is_exploding == false:
		if area is BugSegmentBase:
			area.visible = false
			is_exploding = true
			emit_signal("player_hit")
			$Sprite.visible = false
			$AnimatedSprite.visible = true
			$AnimatedSprite.frame = 0
			$AnimatedSprite.play("explode")
		#print(area.name)


func _on_Player_body_entered(_body: Node) -> void:
	collided = true


func _on_Player_body_exited(_body: Node) -> void:
	collided = false



func _on_AnimatedSprite_animation_finished() -> void:
	get_node("AnimatedSprite").visible = false
