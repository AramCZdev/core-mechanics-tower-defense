extends Node2D

enum EnemyType {
	NORMAL,
	FAST,
	TANK
}

var enemy_type: EnemyType = EnemyType.NORMAL

var health: int
var max_health: int
var speed: float
var reward: int

var path: Array[Vector2i] = []
var path_index := 0

@onready var map: Node2D = get_parent().get_node("Map")


func _ready() -> void:
	setup_enemy(EnemyType.NORMAL)

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

	position = position.move_toward(target, speed * delta)

	if position.distance_to(target) < 2.0:
		path_index += 1


func _on_path_changed() -> void:
	var current_cell: Vector2i = map.position_to_cell(position)

	path = map.calculate_enemy_path(current_cell)
	path_index = 0


func _draw() -> void:
	var enemy_color: Color

	match enemy_type:
		EnemyType.NORMAL:
			enemy_color = Color.GREEN

		EnemyType.FAST:
			enemy_color = Color.YELLOW

		EnemyType.TANK:
			enemy_color = Color.RED

		_:
			enemy_color = Color.GRAY

	draw_circle(Vector2.ZERO, 20.0, enemy_color)

func setup_enemy(type: EnemyType) -> void:
	enemy_type = type

	match enemy_type:
		EnemyType.NORMAL:
			max_health = 100
			speed = 100.0
			reward = 20

		EnemyType.FAST:
			max_health = 50
			speed = 160.0
			reward = 15

		EnemyType.TANK:
			max_health = 300
			speed = 60.0
			reward = 50

	health = max_health
	queue_redraw()
