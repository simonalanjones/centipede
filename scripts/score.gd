extends Label

const SCORE_FOR_EXTRA_LIFE = 20000

var score: int

func _ready() -> void:
	score = 0
	set_text(str(score))
	
func get_score() -> int:
	return score

func add_points(points: int):
	score += points
	set_text(str(score))
	
func on_points_awarded(points):
	#print('points awarded:' + str(points))
	score += points
	set_text(str(score))
