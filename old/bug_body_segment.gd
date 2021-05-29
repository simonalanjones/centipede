extends Area2D

signal segment_hit(segment, area)

const CLASS_NAME = "Segment"

var has_reached_target:bool = false setget ,has_reached_target_position
var target_position: Vector2 setget set_target_position,get_target_position

onready var sprite:AnimatedSprite = get_node("Sprite")

func _ready() -> void:
	var _a = connect('area_entered', self, '_on_area_entered')


func get_class() -> String:
	return CLASS_NAME
	
	
func set_target_position(new_position: Vector2) -> void:
	target_position = new_position
	
	if target_position.x  > position.x:
		sprite.flip_h = true
	else:
		sprite.flip_h = false		
	
	
	var diff:Vector2 = target_position - position
	
	# diff.y =  8 when head below body
	# diff.y = -8 when head above body
	# diff.y =  0 when head and body horizontally aligned
	
	# diff.x = -8 when head left of body segment
	# diff.x =  8 when head right of body segment
	# diff.x =  0 when head and body segment vertically aligned
	
		
	# flip sprite
	#var neighbour = get_parent().get_child(get_index()-1)
	#sprite.flip_h = neighbour.get_node("Sprite").flip_h
	#sprite.flip_h = false if diff.x <= 0 else true
	
	#$Label.set_text(str(diff.y))
	
	
	# animation
	if diff.x == 0 and abs(diff.y) == 8:
		#sprite.frame = 0
		sprite.play("down")
	else:
		#sprite.frame = 0
		sprite.play("default")
		
	
	has_reached_target = false


func get_target_position() -> Vector2:
	return target_position
	

func has_reached_target_position() -> bool:
	return has_reached_target


func move(speed_factor)-> void:
	if has_reached_target == false:
		
		var diff: Vector2 = target_position - position
				
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
		area.queue_free()
		print('hit body segment')
		emit_signal("segment_hit", self, area)	
		
