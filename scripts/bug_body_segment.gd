extends Area2D

signal segment_hit

const CLASS_NAME = "Segment"
var has_reached_target:bool setget ,has_reached_target_position
var target_position: Vector2 setget set_target_position,get_target_position
var speed_factor:int = 1


func _ready() -> void:
	has_reached_target = false
	var _a = connect('area_entered', self, '_on_area_entered')
	speed_factor = get_parent().get_speed_factor()


func get_class() -> String:
	return CLASS_NAME
	
	
func set_target_position(new_position: Vector2) -> void:
	target_position = new_position
	has_reached_target = false


func get_target_position() -> Vector2:
	return target_position
	

func has_reached_target_position() -> bool:
	return has_reached_target


func move()-> void:
	if has_reached_target == false:
		
		var diff:Vector2 = target_position - position
				
		if diff.x > 0:
			translate(Vector2.RIGHT * speed_factor)
		elif diff.x < 0:
			translate(Vector2.LEFT * speed_factor)
		elif diff.y > 0:
			translate(Vector2.DOWN * speed_factor)
		elif diff.y < 0:
			translate(Vector2.UP * speed_factor)

	if position == target_position and has_reached_target == false:
		has_reached_target = true
		
		
func _on_area_entered(area: Area2D) -> void:
	if area.get_class() == "PlayerShot":
		emit_signal("segment_hit", self, area)	
		
	
