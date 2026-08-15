extends Node2D

const CELL_SIZE := 96
const GRID_WIDTH := 12
const GRID_HEIGHT := 7

var blocked_cells: Array[Vector2i] = []


func _draw() -> void:
	for x in range(GRID_WIDTH + 1):
		var start := Vector2(x * CELL_SIZE, 0)
		var end := Vector2(x * CELL_SIZE, GRID_HEIGHT * CELL_SIZE)
		draw_line(start, end, Color.WHITE, 1.0)

	for y in range(GRID_HEIGHT + 1):
		var start := Vector2(0, y * CELL_SIZE)
		var end := Vector2(GRID_WIDTH * CELL_SIZE, y * CELL_SIZE)
		draw_line(start, end, Color.WHITE, 1.0)

		draw_rect(rect, Color.RED)


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			var cell := Vector2i(
				floor(event.position.x / CELL_SIZE),
				floor(event.position.y / CELL_SIZE)
			)

			if cell.x >= 0 and cell.x < GRID_WIDTH and cell.y >= 0 and cell.y < GRID_HEIGHT:
				if not blocked_cells.has(cell):
					blocked_cells.append(cell)
					print("Blocked cell: ", cell)
