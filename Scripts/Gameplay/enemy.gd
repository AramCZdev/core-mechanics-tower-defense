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
var hit_flash_timer: float = 0.0
const HIT_FLASH_DURATION := 0.1
var coin_reward: int = 100
var is_dead := false

@onready var map: Node2D = get_parent().get_node("Map")
@onready var game = get_parent()


func _ready() -> void:
	add_to_group("enemies")

	map.path_changed.connect(_on_path_changed)

	path = map.calculate_enemy_path(map.START_CELL)

	if path.is_empty():
		print("No path to base!")
		return

	position = map.cell_to_position(path[0])



func _process(delta: float) -> void:
	if hit_flash_timer > 0.0:
		hit_flash_timer -= delta
		queue_redraw()

	if path_index >= path.size():
		die()
		return

	var target: Vector2 = map.cell_to_position(path[path_index])

	position = position.move_toward(target, speed * delta)

	if position.distance_to(target) < 2.0:
		path_index += 1

func take_damage(amount: int) -> void:
	if is_dead:
		return

	health -= amount

	hit_flash_timer = HIT_FLASH_DURATION
	queue_redraw()

	print("Enemy health: ", health)

	if health <= 0:
		die()

func die() -> void:
	if is_dead:
		return

	is_dead = true
	game.coins += coin_reward
	remove_from_group("enemies")
	queue_free()

func _on_path_changed() -> void:
	var current_cell: Vector2i = map.position_to_cell(position)

	path = map.calculate_enemy_path(current_cell)
	path_index = 0


func _draw() -> void:
	# Health bar
	var bar_width := 40.0
	var bar_height := 5.0
	var bar_position := Vector2(-bar_width / 2.0, -30.0)

	# Red background
	draw_rect(
		Rect2(bar_position, Vector2(bar_width, bar_height)),
		Color.RED
	)

	# Green health
	var health_ratio := float(health) / float(max_health)

	draw_rect(
		Rect2(
			bar_position,
			Vector2(bar_width * health_ratio, bar_height)
		),
		Color.GREEN
	)
	var enemy_color: Color

	if hit_flash_timer > 0.0:
		enemy_color = Color(0.35, 0.0, 0.0)
	else:
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

	draw_circle(Vector2.ZERO, 20.0, enemy_color)

func setup_enemy(type: EnemyType) -> void:
	enemy_type = type

	match enemy_type:
		EnemyType.NORMAL:
			max_health = 100
			speed = 100.0
			coin_reward = 100

		EnemyType.FAST:
			max_health = 60
			speed = 180.0
			coin_reward = 125

		EnemyType.TANK:
			max_health = 300
			speed = 60.0
			coin_reward = 250

	health = max_health
	queue_redraw()
