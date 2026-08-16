extends Node2D

signal path_changed

const CELL_SIZE := 96
const GRID_WIDTH := 12
const GRID_HEIGHT := 7

const START_CELL := Vector2i(0, 3)
const BASE_CELL := Vector2i(11, 3)
const BASE_ATTACK_RANGE := 200.0

@onready var game = get_tree().current_scene
@onready var enemy = get_parent().get_node("Enemy")
@onready var action_text = $"../CanvasLayer/Bottom Panel/Action Text"

var astar := AStarGrid2D.new()
var blocked_cells: Array[Vector2i] = []
var hovered_cell := Vector2i(-1, -1)

func _ready() -> void:
	setup_pathfinding()
	queue_redraw()

func setup_pathfinding() -> void:
	astar.region = Rect2i(0, 0, GRID_WIDTH, GRID_HEIGHT)
	astar.cell_size = Vector2(CELL_SIZE, CELL_SIZE)
	astar.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
	astar.update()

func _draw() -> void:
	# Grid
	for x in range(GRID_WIDTH + 1):
		var start := Vector2(x * CELL_SIZE, 0)
		var end := Vector2(x * CELL_SIZE, GRID_HEIGHT * CELL_SIZE)
		draw_line(start, end, Color.WHITE, 1.0)

	for y in range(GRID_HEIGHT + 1):
		var start := Vector2(0, y * CELL_SIZE)
		var end := Vector2(GRID_WIDTH * CELL_SIZE, y * CELL_SIZE)
		draw_line(start, end, Color.WHITE, 1.0)
	
	# Hover Indicator
	if hovered_cell != Vector2i(-1, -1):
		draw_rect(
			Rect2(
				hovered_cell.x * CELL_SIZE,
				hovered_cell.y * CELL_SIZE,
				CELL_SIZE,
				CELL_SIZE
			),
			Color(1.0, 1.0, 1.0, 0.2)
		)

	# Placed towers
	for cell in blocked_cells:
		var tower_position := cell_to_position(cell)

		draw_circle(
			tower_position,
			30.0,
			Color(0.2, 0.2, 0.2, 1.0)
		)

		draw_circle(
			tower_position,
			20.0,
			Color(0.6, 0.6, 0.6, 1.0)
		)

	# Point A
	draw_rect(
		Rect2(
			START_CELL.x * CELL_SIZE,
			START_CELL.y * CELL_SIZE,
			CELL_SIZE,
			CELL_SIZE
		),
		Color(0.0, 1.0, 0.0, 0.25)
	)

	# Point B
	draw_rect(
		Rect2(
			BASE_CELL.x * CELL_SIZE,
			BASE_CELL.y * CELL_SIZE,
			CELL_SIZE,
			CELL_SIZE
		),
		Color(1.0, 0.0, 0.0, 0.25)
	)

	# Base attack range
	var base_position := cell_to_position(BASE_CELL)

	draw_circle(
		base_position,
		BASE_ATTACK_RANGE,
		Color(1.0, 0.0, 0.0, 0.1)
	)

	# A marker
	var start_position := cell_to_position(START_CELL)
	draw_circle(start_position, 25.0, Color.GREEN)

	# B marker
	draw_circle(base_position, 30.0, Color.RED)


func cell_to_position(cell: Vector2i) -> Vector2:
	return Vector2(
		cell.x * CELL_SIZE + CELL_SIZE / 2.0,
		cell.y * CELL_SIZE + CELL_SIZE / 2.0
	)


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		var cell: Vector2i = mouse_to_cell()

		if cell.x >= 0 and cell.x < GRID_WIDTH and cell.y >= 0 and cell.y < GRID_HEIGHT:
			hovered_cell = cell
		else:
			hovered_cell = Vector2i(-1, -1)

		queue_redraw()

	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			var cell: Vector2i = mouse_to_cell()

			if cell.x >= 0 and cell.x < GRID_WIDTH and cell.y >= 0 and cell.y < GRID_HEIGHT:
				if cell != START_CELL and cell != BASE_CELL:
					if not blocked_cells.has(cell):
						var enemy_cell: Vector2i = position_to_cell(enemy.position)

						# Don't place on the enemy
						if cell == enemy_cell:
							action_text.text = "Cannot place a tower on the enemy"
							print("Cannot place a tower on the enemy")
							return

						var cost: int = game.get_selected_tower_cost()

						# Check money BEFORE doing anything with the placement
						if cost > game.coins:
							
							action_text.text ="Not enough coins"
							print("Not enough coins")
							return

						# Temporarily block the cell
						astar.set_point_solid(cell, true)

						# Check whether the enemy can still reach B
						var test_path: Array[Vector2i] = astar.get_id_path(
							enemy_cell,
							BASE_CELL
						)

						if test_path.is_empty():
							astar.set_point_solid(cell, false)
							
							action_text.text = "Cannot place tower it would block the enemy"
							print("Cannot place tower it would block the enemy")
							return

						# Everything is valid, so actually buy the tower
						game.coins -= cost
						blocked_cells.append(cell)

						action_text.text = ""
						print("Placed tower for ", cost, " coins")
						print("Coins remaining: ", game.coins)

						path_changed.emit()
						queue_redraw()

func calculate_enemy_path(start_cell: Vector2i) -> Array[Vector2i]:
	return astar.get_id_path(start_cell, BASE_CELL)

func position_to_cell(pos: Vector2) -> Vector2i:
	return Vector2i(
		floor(pos.x / CELL_SIZE),
		floor(pos.y / CELL_SIZE)
	)

func mouse_to_cell() -> Vector2i:
	# Some resizing stuff
	var mouse_position := get_viewport().get_canvas_transform().affine_inverse() * get_viewport().get_mouse_position()

	return Vector2i(
		floor(mouse_position.x / CELL_SIZE),
		floor(mouse_position.y / CELL_SIZE)
	)
