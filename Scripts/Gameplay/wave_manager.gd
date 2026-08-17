extends Node2D

@export var enemy_scene: PackedScene

@onready var map: Node2D = $"../Map"

var current_wave: int = 0
var enemies_to_spawn: int = 0
var spawning: bool = false
var waves: Array = []

const TIME_BETWEEN_ENEMIES := 1.0


func _ready() -> void:
	load_waves()

	await get_tree().create_timer(2.0).timeout
	start_wave()


func start_wave() -> void:
	if current_wave >= waves.size():
		print("All waves completed!")
		return

	current_wave += 1

	print("Starting wave ", current_wave)

	spawning = true

	await spawn_wave()

	spawning = false


func spawn_wave() -> void:
	var wave: Dictionary = waves[current_wave - 1]
	var enemies: Array = wave["enemies"]

	for enemy_type: Variant in enemies:
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
