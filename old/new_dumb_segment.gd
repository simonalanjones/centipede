extends Sprite

# body vars
var has_reached:bool = false
var target_position: Vector2

# head vars
var direction: = Vector2.RIGHT
var next_direction: = Vector2.RIGHT

var move_count_limit = 60
var move_count = 0


func _process(_delta: float) -> void:
	
	# body segment
	if has_reached == false and get_index() != 0:
		
		if position == target_position:
			has_reached = true
			print('reach')
		else:
			
			var diff:Vector2 = target_position - position
			
			if diff.x > 0:
				translate(Vector2(2,0))
			elif diff.x < 0:
				translate(Vector2(-2,0))
			elif diff.y > 0:
				translate(Vector2(0,2))
			elif diff.y < 0:
				translate(Vector2(0,-2))

				
	# head segment				
	if get_index() == 0:
			
		if Input.is_action_pressed("ui_up"):
			next_direction = Vector2(0,-2)
				
		if Input.is_action_pressed("ui_down"):
			next_direction = Vector2(0,2)
			
		if Input.is_action_pressed("ui_left"):
			next_direction = Vector2(-2,-0)
			
		if Input.is_action_pressed("ui_right"):
			next_direction = Vector2(2,0)
			
		if Input.is_action_pressed("ui_accept"):
			next_direction = Vector2(0,0)	
			
		if direction != next_direction:
			direction = next_direction
		translate(direction)


func reset() -> void:
	has_reached = false	

