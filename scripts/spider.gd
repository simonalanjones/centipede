extends Area2D

signal spider_destroyed(points)
signal spider_left_screen

const POINTS_AWARDED_CLOSE = 900
const POINTS_AWARDED_MEDIUM = 600
const POINTS_AWARDED_FAR = 300
const SCORE_THRESHOLDS: Array = [ 79999, 99999, 119000, 139000, 159000, 859000 ]

var max_height: int = 12
var speed_factor:int = 1

var spider_start_side:Vector2
var check_map_location: Reference
var eat_mushroom: Reference

# should we have a global object that provides access to certain functions??
# rather than relaying it from game manager to spawner to child object
# no benefit to passing rather than global access?
func spawn(player_score, ref_eat_mushroom):
	
	eat_mushroom = ref_eat_mushroom
	
	for score in SCORE_THRESHOLDS:
		if player_score > score:
			max_height -= 1
	
	if max_height < 7:
		max_height = 12
		
	if player_score > 5000:
		speed_factor = 2
	
	
func _on_Area2D_body_entered(body: Node) -> void:
	if body is TileMap:
		pass
		# spider has touched/eaten mushroom
		#emit_signal("mushroom_hit", body.world_to_map(position))

			
func _on_Area2D_area_entered(area: Area2D) -> void:
	
	if area.name == "PlayerShot":
		
		var levels_from_target = (area.position.y - position.y) / 8
		var points_awarded
		if levels_from_target <= 1:
			points_awarded = POINTS_AWARDED_CLOSE
		elif levels_from_target <= 4:
			points_awarded = POINTS_AWARDED_MEDIUM
		else:
			points_awarded = POINTS_AWARDED_FAR
		
		
		emit_signal("spider_destroyed", points_awarded)
		#emit_signal("spider_left_screen")
		queue_free()
