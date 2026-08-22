extends Node2D

@export var tower_scene: PackedScene

signal path_changed

const CELL_SIZE := 96
const GRID_WIDTH := 12
const GRID_HEIGHT := 7

const START_CELL := Vector2i(0, 3)
const START_CELL_HARD := Vector2i(0, 5)
const BASE_CELL := Vector2i(11, 3)

@onready var game = get_tree().current_scene
@onready var action_text = $"../CanvasLayer/Bottom Panel/Action Text"

var astar := AStarGrid2D.new()
var flying_astar := AStarGrid2D.new()
var blocked_cells: Array[Vector2i] = []
var hovered_cell := Vector2i(-1, -1)
var ghost_tower: Node2D = null
var tower_count: int = 0

func _ready() -> void:
	setup_pathfinding()
	queue_redraw()



func setup_pathfinding() -> void:
	astar.region = Rect2i(0, 0, GRID_WIDTH, GRID_HEIGHT)
	astar.cell_size = Vector2(CELL_SIZE, CELL_SIZE)
	astar.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
	astar.update()

	flying_astar.region = Rect2i(0, 0, GRID_WIDTH, GRID_HEIGHT)
	flying_astar.cell_size = Vector2(CELL_SIZE, CELL_SIZE)
	flying_astar.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
	flying_astar.update()

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
	# Point A Hard Mode
	if SettingsManager.game_mode == SettingsManager.GameMode.HARD:
		draw_rect(
			Rect2(
				START_CELL_HARD.x * CELL_SIZE,
				START_CELL_HARD.y * CELL_SIZE,
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

	# A marker
	var start_position := cell_to_position(START_CELL)
	draw_circle(start_position, 25.0, Color.GREEN)

	# A Marker Hard Mode
	var start_position_hard := cell_to_position(START_CELL_HARD)

	if SettingsManager.game_mode == SettingsManager.GameMode.HARD:
		draw_circle(start_position_hard, 25.0, Color.GREEN)

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
			update_ghost_tower()
		else:
			hovered_cell = Vector2i(-1, -1)

			if ghost_tower != null:
				ghost_tower.queue_free()
				ghost_tower = null

		queue_redraw()

	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			var cell: Vector2i = mouse_to_cell()

			if blocked_cells.has(cell):
				action_text.add_theme_color_override("font_color", Color.RED)
				action_text.text = "A tower is already there"
				return

			if cell.x >= 0 and cell.x < GRID_WIDTH and cell.y >= 0 and cell.y < GRID_HEIGHT:
				if cell != START_CELL and cell != BASE_CELL:
					var dist_to_spawn: int = absi(cell.x - START_CELL.x) + absi(cell.y - START_CELL.y)

					if SettingsManager.game_mode == SettingsManager.GameMode.HARD:
						var dist_to_spawn_hard: int = absi(cell.x - START_CELL_HARD.x) + absi(cell.y - START_CELL_HARD.y)

						if dist_to_spawn <= 1 or dist_to_spawn_hard <= 1:
							action_text.add_theme_color_override("font_color", Color.RED)
							action_text.text = "Too close to enemy spawn"
							return
					elif dist_to_spawn <= 1:
						action_text.add_theme_color_override("font_color", Color.RED)
						action_text.text = "Too close to enemy spawn"
						return

					if not blocked_cells.has(cell):
						for enemy_node in get_tree().get_nodes_in_group("enemies"):
							if not is_instance_valid(enemy_node):
								continue

							var enemy_cell: Vector2i = position_to_cell(enemy_node.position)

							if cell == enemy_cell:
								action_text.add_theme_color_override("font_color", Color.RED)
								action_text.text = "Cannot place a tower on the enemy"
								print("Cannot place a tower on the enemy")
								return

						var cost: int = game.get_selected_tower_cost()

						# Check money BEFORE doing anything with the placement
						if cost > game.coins:
							
							action_text.add_theme_color_override("font_color", Color.RED)
							action_text.text ="Not enough coins"
							print("Not enough coins")
							return

						if not can_place_tower(cell):
							action_text.add_theme_color_override("font_color", Color.RED)
							action_text.text = "Cannot place a tower it would block the enemy"
							print("Cannot place a tower it would block the enemy")
							return

						# Everything is valid, so actually block the cell
						astar.set_point_solid(cell, true)

						# Everything is valid, so actually buy the tower
						game.coins -= cost
						blocked_cells.append(cell)
						tower_count += 1

						var tower = tower_scene.instantiate()

						tower.position = cell_to_position(cell)
						tower.setup_tower(game.selected_tower)
						tower.placed_cost = cost

						add_child(tower)

						action_text.text = ""
						print("Placed tower for ", cost, " coins")
						print("Coins remaining: ", game.coins)

					path_changed.emit()
					queue_redraw()

		if event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
			var cell: Vector2i = mouse_to_cell()
			if blocked_cells.has(cell):
				sell_tower(cell)

func sell_tower(cell: Vector2i) -> void:
	for child in get_children():
		if child is Node2D and not child.is_ghost and position_to_cell(child.position) == cell:
			var refund: int = child.placed_cost / 2
			game.coins += refund
			child.queue_free()
			break

	astar.set_point_solid(cell, false)
	blocked_cells.erase(cell)

	tower_removed()
	action_text.text = ""
	print("Sold tower for refund")

func calculate_enemy_path(start_cell: Vector2i) -> Array[Vector2i]:
	return astar.get_id_path(start_cell, BASE_CELL)

func calculate_flying_path(start_cell: Vector2i) -> Array[Vector2i]:
	return flying_astar.get_id_path(start_cell, BASE_CELL)

func get_path_stretch() -> float:
	return 1.0 + log(tower_count + 1) * 0.25

func tower_removed() -> void:
	tower_count -= 1
	path_changed.emit()

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

func can_place_tower(cell: Vector2i) -> bool:
	# Temporarily block the cell
	astar.set_point_solid(cell, true)

	# Check the normal spawn
	var test_path: Array[Vector2i] = astar.get_id_path(
		START_CELL,
		BASE_CELL
	)

	# Normal mode only needs one path
	if SettingsManager.game_mode != SettingsManager.GameMode.HARD:
		astar.set_point_solid(cell, false)
		return not test_path.is_empty()

	# Hard mode needs BOTH paths to remain open
	var hard_path: Array[Vector2i] = astar.get_id_path(
		START_CELL_HARD,
		BASE_CELL
	)

	# Unblock the cell
	astar.set_point_solid(cell, false)

	# Both spawns must have a route to the base
	return not test_path.is_empty() and not hard_path.is_empty()

func update_ghost_tower() -> void:
	if ghost_tower == null:
		ghost_tower = tower_scene.instantiate()
		ghost_tower.is_ghost = true
		add_child(ghost_tower)

	ghost_tower.position = cell_to_position(hovered_cell)
	ghost_tower.setup_tower(game.selected_tower)
	ghost_tower.modulate.a = 0.5
