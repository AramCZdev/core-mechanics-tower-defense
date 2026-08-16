extends Node2D

const SPEED := 100.0

var path: Array[Vector2i] = []
var path_index := 0

@onready var map: Node2D = get_parent().get_node("Map")


func _ready() -> void:
	map.path_changed.connect(_on_path_changed)

	path = map.calculate_enemy_path(map.START_CELL)

	if path.is_empty():
		print("No path to base!")
		return

	position = map.cell_to_position(path[0])


func _process(delta: float) -> void:
	if path_index >= path.size():
		return

	var target: Vector2 = map.cell_to_position(path[path_index])

	position = position.move_toward(target, SPEED * delta)

	if position.distance_to(target) < 2.0:
		path_index += 1


func _on_path_changed() -> void:
	var current_cell: Vector2i = map.position_to_cell(position)

	path = map.calculate_enemy_path(current_cell)
	path_index = 0


func _draw() -> void:
	draw_circle(Vector2.ZERO, 20.0, Color.YELLOW)
