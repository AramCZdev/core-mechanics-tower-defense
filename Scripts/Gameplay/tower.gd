extends Node2D

var tower_type: int

var damage: int
var attack_cooldown: float
var attack_range: float

var current_target: Node2D = null
var cooldown_timer: float = 0.0

var is_ghost: bool = false
var placed_cost: int = 0

func setup_tower(type: int) -> void:
	tower_type = type

	match tower_type:
		0: # NORMAL
			damage = 20
			attack_cooldown = 1.2
			attack_range = 130.0

		1: # FAST
			damage = 3
			attack_cooldown = 0.1
			attack_range = 100.0

		2: # CANON
			damage = 60
			attack_cooldown = 3.0
			attack_range = 150.0

	queue_redraw()



func _process(delta: float) -> void:
	if is_ghost:
		return

	cooldown_timer -= delta

	# Remove dead/out-of-range target
	if current_target != null:
		if not is_instance_valid(current_target):
			current_target = null
		elif global_position.distance_to(current_target.global_position) > attack_range:
			current_target = null

	# Find another enemy
	if current_target == null:
		current_target = find_target()

	# Attack
	if current_target != null and cooldown_timer <= 0.0:
		attack(current_target)
		cooldown_timer = attack_cooldown


func find_target() -> Node2D:
	var closest_enemy: Node2D = null
	var closest_distance: float = INF

	for enemy_node in get_tree().get_nodes_in_group("enemies"):
		if not is_instance_valid(enemy_node):
			continue

		if not enemy_node is Node2D:
			continue

		var enemy: Node2D = enemy_node
		var distance: float = global_position.distance_to(enemy.global_position)

		if distance <= attack_range and distance < closest_distance:
			closest_distance = distance
			closest_enemy = enemy

	return closest_enemy


func attack(target: Node2D) -> void:
	target.take_damage(damage)

	print(
		"Tower ",
		name,
		" attacked ",
		target.name,
		" for ",
		damage,
		" damage"
	)

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
