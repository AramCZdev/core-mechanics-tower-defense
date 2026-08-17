extends Node2D

@export var enemy_scene: PackedScene

@onready var map: Node2D = $"../Map"
@onready var action_text = $"../CanvasLayer/Bottom Panel/Action Text"
@onready var wave_counter = $"../CanvasLayer/Wave Counter"

var current_wave: int = 0
var enemies_to_spawn: int = 0
var spawning: bool = false
var waves: Array = []

const TIME_BETWEEN_ENEMIES := 1.0


func _ready() -> void:
	print("WAVE MANAGER READY")

	load_waves()

	print("Waves loaded: ", waves.size())

	await get_tree().create_timer(2.0).timeout

	print("Calling start_wave()")

	await start_wave()

	print("start_wave() finished")


func start_wave() -> void:
	while current_wave < waves.size():
		current_wave += 1
		wave_counter.text = str("Wave ", current_wave)

		print(">>> STARTING WAVE ", current_wave)

		spawning = true

		await spawn_wave()

		spawning = false

		print(">>> FINISHED SPAWNING WAVE ", current_wave)
		print(">>> ENEMIES ALIVE: ", get_tree().get_nodes_in_group("enemies").size())

		while not get_tree().get_nodes_in_group("enemies").is_empty():
			await get_tree().create_timer(0.2).timeout

		print(">>> WAVE ", current_wave, " COMPLETED")

		await wave_complete_action_text()


		await get_tree().create_timer(5.0).timeout

	print(">>> ALL WAVES COMPLETED")


func spawn_wave() -> void:
	var wave: Dictionary = waves[current_wave - 1]
	var enemies: Array = wave["enemies"]

	print("Wave ", current_wave, " has ", enemies.size(), " enemies")

	for enemy_type: Variant in enemies:
		print("Spawning: ", enemy_type)

		spawn_enemy(str(enemy_type))

		await get_tree().create_timer(TIME_BETWEEN_ENEMIES).timeout


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
		_:
			print("Unknown enemy type: ", type_name)
			return 0


func wave_complete_action_text() -> void:
	action_text.add_theme_color_override("font_color", Color.WHITE)
	action_text.text = "Wave " + str(current_wave) + " completed!"

	await get_tree().create_timer(1.0).timeout

	action_text.text = "intermission"

	await get_tree().create_timer(4.0).timeout

	action_text.text = ""
