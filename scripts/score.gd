extends Label

const SCORE_FOR_EXTRA_LIFE = 20000

var score: int

func _ready() -> void:
	score = 20000
	
func get_score() -> int:
	return score
