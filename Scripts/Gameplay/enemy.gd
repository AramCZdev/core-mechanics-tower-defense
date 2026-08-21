extends Node2D

enum EnemyType {
	NORMAL,
	FAST,
	TANK,
	FANATIC,
	FLYING,
	SUPER_TANK,
	GIGANT
}

var enemy_type: EnemyType = EnemyType.NORMAL

var health: int
var max_health: int
var speed: float
var base_speed: float
var reward: int

var path: Array[Vector2i] = []
var path_index := 0
var hit_flash_timer: float = 0.0
const HIT_FLASH_DURATION := 0.1
var coin_reward: int = 100
var is_dead := false
var base_damage: int = 1
var current_direction: Vector2 = Vector2.RIGHT

@onready var map: Node2D = get_parent().get_node("Map")
@onready var game = get_parent()


func _ready() -> void:
	add_to_group("enemies")

	if enemy_type == EnemyType.FLYING:
		path = map.calculate_flying_path(map.START_CELL)
	else:
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
		reach_base()
		return

	var target: Vector2 = map.cell_to_position(path[path_index])
	current_direction = (target - position).normalized()

	speed = base_speed
	if enemy_type != EnemyType.FLYING:
		speed *= map.get_path_stretch()

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

	if enemy_type == EnemyType.FANATIC:
		for ally in get_tree().get_nodes_in_group("enemies"):
			if ally == self or not is_instance_valid(ally):
				continue
			if ally.is_dead:
				continue
			if global_position.distance_to(ally.global_position) <= 160.0:
				ally.health = min(ally.health + 1000, ally.max_health)
				ally.queue_redraw()

	game.coins += coin_reward
	remove_from_group("enemies")
	queue_free()

func reach_base() -> void:
	if is_dead:
		return

	is_dead = true
	game.take_base_damage(base_damage)
	remove_from_group("enemies")
	queue_free()

func _on_path_changed() -> void:
	var current_cell: Vector2i = map.position_to_cell(position)

	path = map.calculate_enemy_path(current_cell)
	path_index = 0


func _draw() -> void:

	if SettingsManager.get_setting("health_bar", true):
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
	else:
		pass

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

			EnemyType.FANATIC:
				enemy_color = Color.PURPLE

			EnemyType.FLYING:
				enemy_color = Color.CYAN

			EnemyType.SUPER_TANK:
				enemy_color = Color.BLACK

			EnemyType.GIGANT:
				enemy_color = Color.ORANGE

			_:
				enemy_color = Color.GRAY


	draw_circle(Vector2.ZERO, 20.0, enemy_color)

func setup_enemy(type: EnemyType) -> void:
	enemy_type = type

	match enemy_type:
		EnemyType.NORMAL:
			max_health = 100
			base_speed = 70.0
			coin_reward = 100
			base_damage = 1

		EnemyType.FAST:
			max_health = 60
			base_speed = 130.0
			coin_reward = 125
			base_damage = 1

		EnemyType.TANK:
			max_health = 300
			base_speed = 45.0
			coin_reward = 250
			base_damage = 3

		EnemyType.FANATIC:
			max_health = 80
			base_speed = 100.0
			coin_reward = 150
			base_damage = 1

		EnemyType.FLYING:
			max_health = 250
			base_speed = 200.0
			coin_reward = 200
			base_damage = 2

		EnemyType.SUPER_TANK:
			max_health = 500
			base_speed = 60.0
			coin_reward = 300
			base_damage = 4

		EnemyType.GIGANT:
			max_health = 1500
			base_speed = 30.0
			coin_reward = 1000
			base_damage = 10

	health = max_health
	speed = base_speed
	queue_redraw()
