extends Node

const SETTINGS_PATH = "user://settings.cfg"
var _data: Dictionary = {}

func _ready() -> void:
	load_settings()

func set_setting(key: String, value) -> void:
	_data[key] = value
	save_settings()

func get_setting(key: String, default = null):
	return _data.get(key, default)

func save_settings() -> void:
	var file := FileAccess.open(SETTINGS_PATH, FileAccess.WRITE)
	file.store_var(_data)
	file.close()

func load_settings() -> void:
	if not FileAccess.file_exists(SETTINGS_PATH):
		_data = {}
		return

	var file := FileAccess.open(SETTINGS_PATH, FileAccess.READ)
	_data = file.get_var()
	file.close()

func reset() -> void:
	_data = {}
	save_game()

func save_game() -> void:
	var file := FileAccess.open(SETTINGS_PATH, FileAccess.WRITE)
	file.store_var(_data)
	file.close()
