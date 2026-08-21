extends Node2D

@export var enemy_scene: PackedScene

@onready var map: Node2D = $"../Map"
@onready var game = get_parent()
@onready var wave_text = $"../CanvasLayer/Bottom Panel/Wave Text"
@onready var wave_counter = $"../CanvasLayer/Wave Counter"

var current_wave: int = 0
var enemies_to_spawn: int = 0
var spawning: bool = false
var waves: Array = []
var exiting := false

const TIME_BETWEEN_ENEMIES := 1.0


func _ready() -> void:
	print("WAVE MANAGER READY")

	load_waves()

	print("Waves loaded: ", waves.size())

	if not await wait_seconds(2.0):
		return

	print("Calling start_wave()")

	await start_wave()

	print("start_wave() finished")


func wait_seconds(seconds: float) -> bool:
	if exiting or not is_inside_tree():
		return false

	await get_tree().create_timer(seconds).timeout

	return not exiting and is_inside_tree()


func start_wave() -> void:
	while not exiting:
		while not exiting and is_inside_tree() and get_tree().paused:
			await get_tree().process_frame

		if exiting:
			return

		current_wave += 1
		wave_counter.text = "Wave " + str(current_wave)

		print(">>> STARTING WAVE ", current_wave)

		spawning = true

		await spawn_wave()

		if exiting:
			return

		spawning = false

		print(">>> FINISHED SPAWNING WAVE ", current_wave)

		while not exiting and is_inside_tree() and not get_tree().get_nodes_in_group("enemies").is_empty():
			if game.game_over:
				return

			while not exiting and is_inside_tree() and get_tree().paused:
				await get_tree().process_frame

			if exiting:
				return

			if not await wait_seconds(0.2):
				return

		if exiting:
			return

		if game.game_over:
			wave_text.add_theme_color_override("font_color", Color.RED)
			wave_text.text = "GAME OVER"
			return

		print(">>> WAVE ", current_wave, " COMPLETED")

		await wave_complete_action_text()

		if exiting:
			return


func spawn_wave() -> void:
	if exiting:
		return

	if current_wave % 15 == 0:
		await spawn_boss_wave()
	elif current_wave <= waves.size():
		await spawn_handmade_wave()
	else:
		await spawn_random_wave()


func spawn_enemy(type_name: String) -> void:
	var enemy = enemy_scene.instantiate()

	var enemy_type: int = get_enemy_type(type_name)

	enemy.setup_enemy(enemy_type)

	get_parent().add_child(enemy)


func load_waves() -> void:
	var file := FileAccess.open("res://Scripts/Gameplay/waves.json", FileAccess.READ)

	if file == null:
		print("Could not open waves.json")
		return

	var json_text := file.get_as_text()
	var json: Variant = JSON.parse_string(json_text)

	if json == null:
		print("Could not parse waves.json")
		return

	waves = json["waves"] as Array

	print("Loaded ", waves.size(), " waves")


func get_enemy_type(type_name: String) -> int:
	match type_name:
		"normal":
			return 0
		"fast":
			return 1
		"tank":
			return 2
		"fanatic":
			return 3
		"flying":
			return 4
		"super_tank":
			return 5
		"gigant":
			return 6
		_:
			print("Unknown enemy type: ", type_name)
			return 0


func wave_complete_action_text() -> void:
	wave_text.text = "Wave " + str(current_wave) + " completed!"

	if not await wait_seconds(1.0):
		return

	for seconds in [3, 2, 1]:
		if not is_inside_tree():
			return

		while is_inside_tree() and get_tree().paused:
			await get_tree().process_frame

			if not is_inside_tree():
				return

		wave_text.text = "Next wave in " + str(seconds) + "..."

		if not await wait_seconds(1.0):
			return

	if is_inside_tree():
		wave_text.text = ""

		await wait_seconds(1.0)

	wave_text.text = ""


func spawn_handmade_wave() -> void:
	var wave: Dictionary = waves[current_wave - 1]
	var enemies: Array = wave["enemies"]

	print("Wave ", current_wave, " has ", enemies.size(), " enemies")

	for enemy_type: Variant in enemies:
		if game.game_over:
			return

		while is_inside_tree() and get_tree().paused:
			await get_tree().process_frame

		print("Spawning: ", enemy_type)

		spawn_enemy(str(enemy_type))

		await wait_seconds(TIME_BETWEEN_ENEMIES)


func spawn_random_wave() -> void:
	var enemy_count: int = 3 + current_wave

	print(
		"Random wave ",
		current_wave,
		" has ",
		enemy_count,
		" enemies"
	)

	for i in range(enemy_count):
		if game.game_over:
			return

		while is_inside_tree() and get_tree().paused:
			await get_tree().process_frame

		var enemy_type := get_random_enemy_type()

		print("Spawning random: ", enemy_type)

		spawn_enemy(enemy_type)

		await wait_seconds(TIME_BETWEEN_ENEMIES)


func get_random_enemy_type() -> String:
	var roll := randf()

	if current_wave < 7:
		if roll < 0.7:
			return "normal"
		else:
			return "fast"

	if roll < 0.35:
		return "normal"
	elif roll < 0.55:
		return "fast"
	elif roll < 0.72:
		return "tank"
	elif roll < 0.75:
		return "flying"
	elif roll < 0.85:
		return "fanatic"
	else:
		return "super_tank"


func spawn_boss_wave() -> void:
	print("BOSS WAVE ", current_wave)

	spawn_enemy("gigant")

	await wait_seconds(TIME_BETWEEN_ENEMIES)

	if game.game_over:
		return

func _exit_tree() -> void:
	exiting = true
