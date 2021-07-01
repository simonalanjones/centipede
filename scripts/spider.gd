extends Area2D

signal spider_destroyed
signal spider_left_screen

const POINTS_AWARDED_CLOSE = 900
const POINTS_AWARDED_MEDIUM = 600
const POINTS_AWARDED_FAR = 300
const SCORE_THRESHOLDS: Array = [ 79999, 99999, 119000, 139000, 159000, 859000 ]

var max_height: int = 12
var speed_factor:int = 1
var stop = 0

var vertical_direction: Vector2  # whether we're climbing or descending
var horizontal_direction:Vector2 # direction left or right 
var is_moving_horizontally:bool = true

var spider_start_side:Vector2
var Rng = RandomNumberGenerator.new()



# used to bounce direction
func is_on_bottom_line() -> bool:
	return position.y >= 248
	
func is_at_top_line() -> bool:
	return position.y <= ( 30 - max_height ) * 8
	
# if set to false - movement is vertical only	
func moving_horizontally() -> bool:   # can change from diagonal to vertical only
	if horizontal_direction == Vector2(1,0) or horizontal_direction == Vector2(-1,0):
		return true
	else:
		return false


func set_movement_directions():
	# if not going up and down
	if is_moving_horizontally == true:
		if randf() < 0.01:
			is_moving_horizontally = false
	else:
		if randf() < 0.02:
			is_moving_horizontally = true

		
	
func _process(_delta: float) -> void:
	
	if $RayCastDown.is_colliding() and vertical_direction == Vector2(0,1):
		if is_at_top_line() == false:
			vertical_direction = Vector2(0,-1)
		
	if $RayCastUp.is_colliding() and vertical_direction == Vector2(0,-1):
		if is_on_bottom_line() == false:
			vertical_direction = Vector2(0,1)	
	
	
	if stop == 0:
		set_movement_directions()
		if is_moving_horizontally == true:
			global_position += horizontal_direction * speed_factor
		global_position += vertical_direction * speed_factor
		
		if vertical_direction == Vector2(0,1) and is_on_bottom_line():
			vertical_direction = Vector2(0,-1)
		elif vertical_direction == Vector2(0,-1) and is_at_top_line():
			vertical_direction = Vector2(0,1)
			
		if position.x > 240 or position.x < -8:
			emit_signal("spider_left_screen")
			queue_free()

	# eat mushroom if spider overlaps tilemap mushroom
	var spider_centre = Vector2( position.x + 8, position.y + 4)
	if Globals.check_map_position(spider_centre) != -1:
		Globals.eat_tilemap_cell(spider_centre)



func _ready() -> void:
	Rng.randomize()
	var player_score = Globals.player_score()	
	
	for score in SCORE_THRESHOLDS:
		if player_score > score:
			max_height -= 1
	
	if max_height < 7:
		max_height = 12
		
	if player_score > 5000:
		speed_factor = 2
		
	# set starting position	
	var y_pos_start = 21 * 8
	var x_pos_start = -8
	horizontal_direction = Vector2(1,0)
	vertical_direction = Vector2(0,1)
	
	if randf() < 0.5:
		x_pos_start = 232
		horizontal_direction = Vector2(-1, 0)
	position = Vector2(x_pos_start, y_pos_start)
	
		
	
	
	
func _on_Area2D_body_entered(body: Node) -> void:
	## need to bounce of any instances of bug_segment_base
	if body is TileMap:
		pass
		#print(body.collision)
		
	
			
func _on_Area2D_area_entered(area: Area2D) -> void:
	
	if area is BugSegmentBody or area is BugSegmentHead:
		
		if vertical_direction == Vector2(0,1):
			vertical_direction = Vector2(0,-1)
		elif vertical_direction == Vector2(0,-1):
			vertical_direction = Vector2(0,1)
	
	if area.name == "PlayerShot":
		
		var levels_from_target = (area.position.y - position.y) / 8
		var points_awarded
		if levels_from_target <= 1:
			points_awarded = POINTS_AWARDED_CLOSE
		elif levels_from_target <= 4:
			points_awarded = POINTS_AWARDED_MEDIUM
		else:
			points_awarded = POINTS_AWARDED_FAR
		
		
		# need destroyed signal to change frequency to 4 seconds rather than 2
		emit_signal("spider_destroyed")
		Globals.add_score_points(points_awarded)

		queue_free()



