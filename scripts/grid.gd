extends Node2D

# this grid is for debugging purposes

func _draw() -> void:
	# draw vertical lines
	for n in range (0,240,8):
		draw_line(Vector2(n, 0), Vector2(n, 256), Color(1, 1, 0))
		
	# draw horizontal lines	
	for n in range (0,256,8):
		draw_line(Vector2(0, n), Vector2(240, n), Color(1, 1, 0))	
