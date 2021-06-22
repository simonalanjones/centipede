class_name Scorpion

extends Area2D

signal scorpion_left_screen
signal scorpion_destroyed

#const POINTS_AWARDED:int = 1000
var points_awarded:int = 1000

var move_vector: Vector2
var speed_factor:int = 1


func _ready() -> void:
	if global_position.x < 10:
		$AnimatedSprite.flip_h = true
		move_vector = Vector2.RIGHT
	else:
		move_vector = Vector2.LEFT
		
	
func _process(_delta: float) -> void:
	position += move_vector * speed_factor
	
	if Globals.tilemap_cell_value(position) != -1:
		Globals.poison_tilemap_cell(position)
	
	if move_vector == Vector2.RIGHT and global_position.x > 240:
		screen_exit()
	elif move_vector == Vector2.LEFT and global_position.x < -16:
		screen_exit()


func screen_exit():
	emit_signal("scorpion_left_screen")
	queue_free()


func _on_Area2D_area_entered(area: Area2D) -> void:
	if area.name == "PlayerShot":
		emit_signal("scorpion_destroyed", self)
		emit_signal("scorpion_left_screen")
		queue_free()

