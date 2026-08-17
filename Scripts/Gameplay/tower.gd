extends Node2D

var tower_type: int


func setup_tower(type: int) -> void:
	tower_type = type
	queue_redraw()


func _draw() -> void:
	var tower_color: Color

	match tower_type:
		0: # NORMAL
			tower_color = Color.BLUE

		1: # FAST
			tower_color = Color.YELLOW

		2: # CANON
			tower_color = Color.RED

		_:
			tower_color = Color.GRAY

	draw_circle(
		Vector2.ZERO,
		30.0,
		tower_color
	)
