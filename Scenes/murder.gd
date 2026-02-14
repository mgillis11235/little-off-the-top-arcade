extends Control

# Called to handle drawing
func _draw():
	# Define the rectangle position and size
	var rect = Rect2(Vector2(0, 0), Vector2(2100, 1400))
	# Draw the rectangle with a black color
	draw_rect(rect, Color(0, 0, 0))
